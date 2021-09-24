module EX_MEM(

	cpu_stall_i,

	start_i,
	clk_i,
	// MEM
	MemRead_i,
	MemRead_o,
	MemWrite_i,
	MemWrite_o,
	// MEM for Data Memory
	ALU_Result_i,
	ALU_Result_o,
	RS2data_i,
	RS2data_o,
	// for Forward & WB
	RDaddr_i,
	RDaddr_o,
	// WB
	RegWrite_i,
	RegWrite_o,
	MemtoReg_i,
	MemtoReg_o
);

input cpu_stall_i;


input start_i;
input clk_i;
// MEM
input MemRead_i;
output reg MemRead_o;
input MemWrite_i;
output reg MemWrite_o;
// MEM for Data Memory
input [31:0] ALU_Result_i;
output reg [31:0] ALU_Result_o;
input [31:0] RS2data_i;
output reg [31:0] RS2data_o;
// for Forward & WB
input [4:0] RDaddr_i;
output reg [4:0] RDaddr_o;
// WB
input RegWrite_i;
output reg RegWrite_o;
input MemtoReg_i;
output reg MemtoReg_o;

initial begin
	// MEM
	MemRead_o = 1'b0;
	MemWrite_o = 1'b0;
	// MEM for Data Memory
	ALU_Result_o = 32'b0;
	RS2data_o = 32'b0;
	// for Forward & WB
	RDaddr_o = 5'b0;
	// WB
	RegWrite_o = 1'b0;
	MemtoReg_o = 1'b0;
end

always @(posedge clk_i) begins

	if(cpu_stall_i) begin
		//  do nothing
	end
	else if(start_i) begin
		// MEM
		MemRead_o <= MemRead_i;
		MemWrite_o <= MemWrite_i;
		// MEM for Data Memory
		ALU_Result_o <= ALU_Result_i;
		RS2data_o <= RS2data_i;
		// for Forward & WB
		RDaddr_o <= RDaddr_i;
		// WB
		RegWrite_o <=RegWrite_i;
		MemtoReg_o <= MemtoReg_i;
	end
end
endmodule
