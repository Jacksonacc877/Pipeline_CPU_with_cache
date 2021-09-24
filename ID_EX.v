// ID_EX.v new
module ID_EX(
	// P2 begin
	cpu_stall_i,
	// P2 end

	start_i,
	clk_i,
	// EX
	funct_i, // {funct7, funct3}
	funct_o,
	ALUOp_i,
	ALUOp_o,
	ALUSrc_i,
	ALUSrc_o,
	imm_i,
	imm_o,
	// EX for ALU
	RS1data_i,
	RS1data_o,
	RS2data_i,
	RS2data_o,
	// for Forward.v
	RS1addr_i,
	RS1addr_o,
	RS2addr_i,
	RS2addr_o,

	// for EX_MEM
	RDaddr_i,
	RDaddr_o,

	// MEM
	MemRead_i,
	MemRead_o,
	MemWrite_i,
	MemWrite_o,
	// WB
	RegWrite_i,
	RegWrite_o,
	MemtoReg_i,
	MemtoReg_o
);
// P2 begin
input cpu_stall_i;
// P2 end

input start_i;
input clk_i;
// EX
input [9:0] funct_i; // {funct7, funct3}
output reg [9:0] funct_o;
input [1:0] ALUOp_i;
output reg [1:0] ALUOp_o;
input ALUSrc_i;
output reg ALUSrc_o;
input [31:0] imm_i;
output reg [31:0] imm_o;
// EX for ALU
input [31:0] RS1data_i;
output reg [31:0] RS1data_o;
input [31:0] RS2data_i;
output reg [31:0] RS2data_o;
// for Forward.v
input [4:0] RS1addr_i;
output reg [4:0] RS1addr_o;
input [4:0] RS2addr_i;
output reg [4:0] RS2addr_o;

// for EX_MEM
input [4:0] RDaddr_i;
output reg [4:0] RDaddr_o;

// MEM
input MemRead_i;
output reg MemRead_o;
input MemWrite_i;
output reg MemWrite_o;
// WB
input RegWrite_i;
output reg RegWrite_o;
input MemtoReg_i;
output reg MemtoReg_o;

initial begin
	// EX
	funct_o = 10'b0; // {funct7, funct3}
	ALUOp_o = 2'b0;
	ALUSrc_o = 1'b0;
	imm_o = 31'b0;
	// EX for ALU
	RS1data_o = 32'b0;
	RS2data_o = 32'b0;
	// for Forward.v
	RS1addr_o = 5'b0;
	RS2addr_o = 5'b0;
	// for EX_MEM
	RDaddr_o = 5'b0;

	// MEM
	MemRead_o = 1'b0;
	MemWrite_o = 1'b0;
	// WB
	RegWrite_o = 1'b0;
	MemtoReg_o = 1'b0;
end

always @(posedge clk_i) begin
	//XXX "<=" nonblocking, must have start_i
	if(cpu_stall_i) begin
		// P2 : do nothing
	end
	else if(start_i) begin
		// EX
		funct_o <= funct_i; // {funct7, funct3}
		ALUOp_o <= ALUOp_i;
		ALUSrc_o <= ALUSrc_i;
		imm_o <= imm_i;
		// EX for ALU
		RS1data_o <= RS1data_i;
		RS2data_o <= RS2data_i;
		// for Forward.v
		RS1addr_o <= RS1addr_i;
		RS2addr_o <= RS2addr_i;
		// for EX_MEM
		RDaddr_o <= RDaddr_i;

		// MEM
		MemRead_o <= MemRead_i;
		MemWrite_o <= MemWrite_i;
		// WB
		RegWrite_o <= RegWrite_i;
		MemtoReg_o <= MemtoReg_i;
	end
end
endmodule
