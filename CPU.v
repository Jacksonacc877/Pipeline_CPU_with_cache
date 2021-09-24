module CPU
(
	clk_i, 
	rst_i,
	start_i,
	
	mem_data_i, 
	mem_ack_i,

	mem_data_o, 
	mem_addr_o,
	mem_enable_o, 
	mem_write_o

);

// Ports
input clk_i;
input rst_i;
input start_i;

input [255:0] mem_data_i;
input mem_ack_i;
output [255:0] mem_data_o;
output [31:0] mem_addr_o;
output mem_enable_o;
output mem_write_o;

wire Flush = And_Branch.data_o;

// IF Stage
MUX2 MUX_PC(
	.data1_i (Add_PC_4.data_o),
	.data2_i (Add_PC_Branch.data_o),
	.select_i (And_Branch.data_o),
	.data_o ()
);
PC PC(	
	.clk_i (clk_i),
	.rst_i (rst_i),
	.start_i (start_i),

	.stall_i(dcache.cpu_stall_o),


	.PCWrite_i (Hazard_Detection.PCWrite_o),
	.pc_i (MUX_PC.data_o),
	.pc_o ()
);
Adder Add_PC_4(
	.data1_i (PC.pc_o),
	.data2_i (32'd4),
	.data_o ()
);
Instruction_Memory Instruction_Memory(
	.addr_i (PC.pc_o), 
	.instr_o ()
);

// ID Stage
IF_ID IF_ID(
	// P2 begin
	.cpu_stall_i(dcache.cpu_stall_o),
	// P2 end

	.start_i (start_i),
	.clk_i (clk_i),
	
	.branch_taken_control_hazard_flush_zero_IF_ID_instruction_i (And_Branch.data_o),
	.load_use_data_hazard_preserve_IF_ID_i (Hazard_Detection.Stall_o),
	// usual pipelin registers
	.PC_i (PC.pc_o),
	.PC_o (),
	.instr_i (Instruction_Memory.instr_o),
	.instr_o ()
);
Hazard_Detection Hazard_Detection(
	// for load-use data hazard
	.IF_ID_RS1addr_i (IF_ID.instr_o[19:15]),
	.IF_ID_RS2addr_i (IF_ID.instr_o[24:20]),
	.ID_EX_RDaddr_i (ID_EX.RDaddr_o),
	.ID_EX_MemRead_i (ID_EX.MemRead_o),
	.Stall_o (), // to testbench.v.  Also, to IF_ID.load_use_data_hazard_preserve_IF_ID_i
	.NoOp_o (), // to Control.v : for load-use data hazard, no operations for ID_EX
	.PCWrite_o () // to PC.v : for load-use data hazard, preserve PC
);
Control Control(
	.NoOp_i (Hazard_Detection.NoOp_o), // from Hazard_Detection.NoOp_o 
	.Op_i (IF_ID.instr_o[6:0]),
	// ID
	.Branch_o (),
	// EX
	.ALUOp_o (),
	.ALUSrc_o (),
	// MEM
	.MemRead_o (),
	.MemWrite_o (),
	// WB
	.RegWrite_o (),
	.MemtoReg_o ()
);
Registers Registers(
	.clk_i (clk_i),
	.RS1addr_i (IF_ID.instr_o[19:15]),
	.RS2addr_i (IF_ID.instr_o[24:20]),
	.RDaddr_i (MEM_WB.RDaddr_o), 
	.RDdata_i (MUX_MemtoReg.data_o),
	.RegWrite_i (MEM_WB.RegWrite_o), 
	.RS1data_o (),
	.RS2data_o ()
);
And And_Branch(
	.start_i (start_i), //TODO
	.data1_i (Control.Branch_o),
	.data2_i ((Registers.RS1data_o == Registers.RS2data_o)? 1'b1:1'b0),
	.data_o ()
);
Sign_Extend Sign_Extend(
	.instr_i (IF_ID.instr_o),
	.imm_o ()
);
Adder Add_PC_Branch(
	.data1_i (IF_ID.PC_o),
	.data2_i (Sign_Extend.imm_o << 1),
	.data_o ()
);

// EX Stage
ID_EX ID_EX(
	// P2 begin
	.cpu_stall_i(dcache.cpu_stall_o),
	// P2 end

	.start_i (start_i),
	.clk_i (clk_i),
	// EX
	.funct_i ( { IF_ID.instr_o[31:25], IF_ID.instr_o[14:12] } ), // {funct7, funct3}
	.funct_o (),
	.ALUOp_i (Control.ALUOp_o),
	.ALUOp_o (),
	.ALUSrc_i (Control.ALUSrc_o),
	.ALUSrc_o (),
	.imm_i (Sign_Extend.imm_o),
	.imm_o (),
	// EX for ALU
	.RS1data_i (Registers.RS1data_o),
	.RS1data_o (),
	.RS2data_i (Registers.RS2data_o),
	.RS2data_o (),
	// for Forward.v
	.RS1addr_i (IF_ID.instr_o[19:15]),
	.RS1addr_o (),
	.RS2addr_i (IF_ID.instr_o[24:20]),
	.RS2addr_o (),

	// for EX_MEM
	.RDaddr_i (IF_ID.instr_o[11:7]),
	.RDaddr_o (),

	// MEM
	.MemRead_i (Control.MemRead_o),
	.MemRead_o (),
	.MemWrite_i (Control.MemWrite_o),
	.MemWrite_o (),
	// WB
	.RegWrite_i (Control.RegWrite_o),
	.RegWrite_o (),
	.MemtoReg_i (Control.MemtoReg_o),
	.MemtoReg_o ()
);
ALU_Control ALU_Control(
	.funct_i (ID_EX.funct_o),
	.ALUOp_i (ID_EX.ALUOp_o),
	.ALUCtrl_o ()
);
Forward Forward(
	.ID_EX_RS1addr_i (ID_EX.RS1addr_o),
	.ID_EX_RS2addr_i (ID_EX.RS2addr_o),
	.EX_MEM_RDaddr_i (EX_MEM.RDaddr_o),
	.MEM_WB_RDaddr_i (MEM_WB.RDaddr_o),
	.EX_MEM_RegWrite_i (EX_MEM.RegWrite_o),
	.MEM_WB_RegWrite_i (MEM_WB.RegWrite_o),
	.ForwardA (),
	.ForwardB ()
);
MUX3 MUX_ForwardA(
	.data1_i (ID_EX.RS1data_o),
	.data2_i (MUX_MemtoReg.data_o),
	.data3_i (EX_MEM.ALU_Result_o),
	.select_i (Forward.ForwardA),
	.data_o ()
);
MUX3 MUX_ForwardB(
	.data1_i (ID_EX.RS2data_o),
	.data2_i (MUX_MemtoReg.data_o),
	.data3_i (EX_MEM.ALU_Result_o),
	.select_i (Forward.ForwardB),
	.data_o ()
);
MUX2 MUX_ALUSrc(
	.data1_i (MUX_ForwardB.data_o),
	.data2_i (ID_EX.imm_o),
	.select_i (ID_EX.ALUSrc_o),
	.data_o ()
); 
ALU ALU(
	.data1_i (MUX_ForwardA.data_o),
	.data2_i (MUX_ALUSrc.data_o), //(MUX_ForwardB.data_o),
	.ALUCtrl_i (ALU_Control.ALUCtrl_o),
	.data_o (),
	.Zero_o () // not used
);

// MEM Stage

EX_MEM EX_MEM(
	// P2 begin
	.cpu_stall_i(dcache.cpu_stall_o),
	// P2 end

	.start_i (start_i),
	.clk_i (clk_i),
	// MEM
	.MemRead_i (ID_EX.MemRead_o),
	.MemRead_o (),
	.MemWrite_i (ID_EX.MemWrite_o),
	.MemWrite_o (),
	// MEM for Data Memory
	.ALU_Result_i (ALU.data_o),
	.ALU_Result_o (),
	.RS2data_i (MUX_ForwardB.data_o), // not from ID_EX
	.RS2data_o (),
	// for Forward & WB
	.RDaddr_i (ID_EX.RDaddr_o),
	.RDaddr_o (),
	// WB
	.RegWrite_i (ID_EX.RegWrite_o),
	.RegWrite_o (),
	.MemtoReg_i (ID_EX.MemtoReg_o),
	.MemtoReg_o ()
);
// P2 begin
dcache_controller dcache(
    // System clock, reset and stall
    .clk_i (clk_i), 
    .rst_i (rst_i),

    // to Data Memory interface        
    .mem_data_i (mem_data_i), 
    .mem_ack_i (mem_ack_i),     
    .mem_data_o (mem_data_o), 
    .mem_addr_o (mem_addr_o),     
    .mem_enable_o (mem_enable_o), 
    .mem_write_o (mem_write_o), 
    
    // to CPU interface    
    .cpu_data_i (EX_MEM.RS2data_o), 
    .cpu_addr_i (EX_MEM.ALU_Result_o),     
    .cpu_MemRead_i (EX_MEM.MemRead_o), 
    .cpu_MemWrite_i (EX_MEM.MemWrite_o), 
    .cpu_data_o (), 
    .cpu_stall_o ()
);


/* 
Data_Memory Data_Memory(
	.clk_i (clk_i),
	.addr_i (EX_MEM.ALU_Result_o),
	.MemRead_i (EX_MEM.MemRead_o),
	.MemWrite_i (EX_MEM.MemWrite_o),
	.data_i (EX_MEM.RS2data_o),
	.data_o ()
); */

// WB Stage
MEM_WB MEM_WB(

	.cpu_stall_i(dcache.cpu_stall_o),


	.start_i (start_i),
	.clk_i (clk_i),
	// WB
	.RegWrite_i (EX_MEM.RegWrite_o),
	.RegWrite_o (),
	.MemtoReg_i (EX_MEM.MemtoReg_o),
	.MemtoReg_o (),

	.RDaddr_i (EX_MEM.RDaddr_o),
	.RDaddr_o (),
	// for MUX2.v
	.ALU_Result_i (EX_MEM.ALU_Result_o),
	.ALU_Result_o (),
	.Data_Memory_data_i (dcache.cpu_data_o), // P2 //(Data_Memory.data_o),
	.Data_Memory_data_o ()
);
MUX2 MUX_MemtoReg(
	.data1_i (MEM_WB.ALU_Result_o),
	.data2_i (MEM_WB.Data_Memory_data_o),
	.select_i (MEM_WB.MemtoReg_o),
	.data_o ()
);

endmodule

