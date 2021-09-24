module MEM_WB(

	cpu_stall_i,

	start_i,
	clk_i,
	// WB
	RegWrite_i,
	RegWrite_o,
	MemtoReg_i,
	MemtoReg_o,

	RDaddr_i,
	RDaddr_o,
	// for MUX2.v
	ALU_Result_i,
	ALU_Result_o,
	Data_Memory_data_i,
	Data_Memory_data_o
);

input cpu_stall_i;


input start_i;
input clk_i;
// WB
input RegWrite_i;
output reg RegWrite_o;
input MemtoReg_i;
output reg MemtoReg_o;

input [4:0] RDaddr_i;
output reg [4:0] RDaddr_o;
// for MUX2.v
input [31:0] ALU_Result_i;
output reg [31:0] ALU_Result_o;
input [31:0] Data_Memory_data_i;
output reg [31:0] Data_Memory_data_o;

initial begin
	// WB
	RegWrite_o = 1'b0;
	MemtoReg_o = 1'b0;

	RDaddr_o = 5'b0;
	// for MUX2.v
	ALU_Result_o = 32'b0;
	Data_Memory_data_o = 32'b0;
end

always @(posedge clk_i) begin
	if(cpu_stall_i) begin
		// do nothing
	end
	else if(start_i) begin
		// WB
		RegWrite_o <= RegWrite_i;
		MemtoReg_o <= MemtoReg_i;

		RDaddr_o <= RDaddr_i;
		// for MUX2.v
		ALU_Result_o <= ALU_Result_i;
		Data_Memory_data_o <= Data_Memory_data_i;
	end
end
endmodule
