module Control(
	NoOp_i, // from HazardDetection.NoOp_o 
	Op_i,
	// ID
	Branch_o,
	// EX
	ALUOp_o,
	ALUSrc_o,
	// MEM
	MemRead_o,
	MemWrite_o,
	// WB
	RegWrite_o,
	MemtoReg_o
);
input NoOp_i; // from HazardDetection.NoOp_o 
input [6:0] Op_i;
// ID
output reg Branch_o;
// EX
output reg [1:0] ALUOp_o;
output reg ALUSrc_o;
// MEM
output reg MemRead_o;
output reg MemWrite_o;
// WB
output reg RegWrite_o;
output reg MemtoReg_o;

// R-type & I-type both depend on funct fields, 
// but to distinguish them, use different ALUOp
parameter ALUOp_lw_sw = 2'b00;
parameter ALUOp_beq = 2'b01;
parameter ALUOp_R_type = 2'b10;
parameter ALUOp_I_type = 2'b11; // self-defined

parameter Opcode_R_type = 7'b011_0011;
parameter Opcode_I_type = 7'b001_0011;
parameter Opcode_lw = 7'b000_0011;
parameter Opcode_sw = 7'b010_0011;
parameter Opcode_beq = 7'b110_0011;

initial begin
	Branch_o = 1'b0;
	// EX
	ALUOp_o = 2'b00; // ALUOp_lw_sw
	ALUSrc_o = 1'b0;
	// MEM
	MemRead_o = 1'b0;
	MemWrite_o = 1'b0;
	// WB
	RegWrite_o = 1'b0;
	MemtoReg_o = 1'b0;
end

always @(*) begin
	if(Op_i == Opcode_beq)
		Branch_o <= 1'b1;
	else
		Branch_o <= 1'b0;
	//
	if(NoOp_i) begin
		// EX
		ALUOp_o <= 2'b00;
		ALUSrc_o <= 1'b0;
		// MEM
		MemRead_o <= 1'b0;
		MemWrite_o <= 1'b0;
		// WB
		RegWrite_o <= 1'b0;
		MemtoReg_o <= 1'b0;
	end else begin
		if(Op_i == Opcode_R_type)
			ALUOp_o <= ALUOp_R_type; // R type
		else if(Op_i == Opcode_I_type)
			ALUOp_o <= ALUOp_I_type; // I type
		else if(Op_i == Opcode_beq)
			ALUOp_o <= ALUOp_beq; // beq
		else
			ALUOp_o <= ALUOp_lw_sw; // lw sw
		//
		if(Op_i == Opcode_I_type || Op_i == Opcode_lw || Op_i == Opcode_sw)
			ALUSrc_o <= 1'b1; // I type. lw sw // lw: Reg[rd] = DataMem[Reg[rs1]+imm]. sw: DataMem[Reg[rs1]+imm] = Reg[rs2]
		else
			ALUSrc_o <= 1'b0; // R type. beq
		//
		if(Op_i == Opcode_lw)
			MemRead_o <= 1'b1; // lw
		else
			MemRead_o <= 1'b0; // R type. I type. sw beq
		//
		if(Op_i == Opcode_sw)
			MemWrite_o <= 1'b1; // sw
		else
			MemWrite_o <= 1'b0; // R type. I type. lw beq
		//
		if(Op_i == Opcode_R_type || Op_i == Opcode_I_type || Op_i == Opcode_lw)
			RegWrite_o <= 1'b1; // R type. I type. lw
		else
			RegWrite_o <= 1'b0; // sw beq
		//
		if(Op_i == Opcode_lw)
			MemtoReg_o <= 1'b1; // lw
		else
			MemtoReg_o <= 1'b0; // R type. I type. sw beq
	end
end
endmodule
