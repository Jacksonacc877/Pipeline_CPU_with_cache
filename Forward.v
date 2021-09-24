module Forward(
	ID_EX_RS1addr_i,
	ID_EX_RS2addr_i,
	EX_MEM_RDaddr_i,
	MEM_WB_RDaddr_i,
	EX_MEM_RegWrite_i,
	MEM_WB_RegWrite_i,
	ForwardA,
	ForwardB
);
input [4:0] ID_EX_RS1addr_i;
input [4:0] ID_EX_RS2addr_i;
input [4:0] EX_MEM_RDaddr_i;
input [4:0] MEM_WB_RDaddr_i;
input EX_MEM_RegWrite_i;
input MEM_WB_RegWrite_i;
output reg [1:0] ForwardA;
output reg [1:0] ForwardB;

parameter from_EX_MEM = 2'b10; // select data2_i
parameter from_MEM_WB = 2'b01; // select data3_i
parameter from_ID_EX = 2'b00; // select data1_i

initial begin
	ForwardA = from_ID_EX;
	ForwardB = from_ID_EX;
end

always @(*) begin
	// A
	if(EX_MEM_RegWrite_i && EX_MEM_RDaddr_i != 0 && EX_MEM_RDaddr_i == ID_EX_RS1addr_i)
		ForwardA <= from_EX_MEM;
	else if(MEM_WB_RegWrite_i && MEM_WB_RDaddr_i != 0 && MEM_WB_RDaddr_i == ID_EX_RS1addr_i)
		ForwardA <= from_MEM_WB;
	else
		ForwardA <= from_ID_EX;
	// B
	if(EX_MEM_RegWrite_i && EX_MEM_RDaddr_i != 0 && EX_MEM_RDaddr_i == ID_EX_RS2addr_i)
		ForwardB <= from_EX_MEM;
	else if(MEM_WB_RegWrite_i && MEM_WB_RDaddr_i != 0 && MEM_WB_RDaddr_i == ID_EX_RS2addr_i)
		ForwardB <= from_MEM_WB;
	else
		ForwardB <= from_ID_EX;
end
endmodule
