module Hazard_Detection(
	IF_ID_RS1addr_i,
	IF_ID_RS2addr_i,
	ID_EX_RDaddr_i,
	ID_EX_MemRead_i,
	Stall_o, // to testbench.v.  Also, to IF_ID.load_use_data_hazard_preserve_IF_ID_i
	NoOp_o, // to Control.v : for load-use data hazard, no operations for ID_EX
	PCWrite_o // to PC.v : for load-use data hazard, preserve PC
);
input [4:0] IF_ID_RS1addr_i;
input [4:0] IF_ID_RS2addr_i;
input [4:0] ID_EX_RDaddr_i;
input ID_EX_MemRead_i;
output reg Stall_o; // to testbench.v.  Also, to IF_ID.load_use_data_hazard_preserve_IF_ID_i
output reg NoOp_o; // to Control.v : for load-use data hazard, no operations for ID_EX
output reg PCWrite_o; // to PC.v : for load-use data hazard, preserve PC

initial begin
	Stall_o = 1'b0;
	NoOp_o = 1'b0;
	PCWrite_o = 1'b1;
end

always @(*) begin
	if(ID_EX_MemRead_i && (ID_EX_RDaddr_i == IF_ID_RS1addr_i || ID_EX_RDaddr_i == IF_ID_RS2addr_i) ) begin
		// load-use data hazard: (1) preserve PC & IF_ID. 
		// (2) Control.v give sall 0 control signals to ID_EX
		Stall_o <= 1'b1;
		NoOp_o <= 1'b1; // select : all 0 control signals
		PCWrite_o <= 1'b0;
	end else begin
		// normal : all opposite of the above
		Stall_o <= 1'b0;
		NoOp_o <= 1'b0;
		PCWrite_o <= 1'b1;
	end
end
endmodule
