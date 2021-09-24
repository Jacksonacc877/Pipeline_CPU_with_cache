module ALU(
	data1_i,
	data2_i,
	ALUCtrl_i,
	data_o,
	Zero_o // not used
);

input signed [31:0] data1_i;
input [31:0] data2_i;


input [3:0] ALUCtrl_i; 
output reg signed [31:0] data_o;

output Zero_o;

parameter ALUCtrl_and = 4'b0_000;
parameter ALUCtrl_xor = 4'b0_001;
parameter ALUCtrl_add = 4'b0_010;
parameter ALUCtrl_sll = 4'b0_011;
parameter ALUCtrl_mul = 4'b0_100;
parameter ALUCtrl_addi = 4'b0_101;
parameter ALUCtrl_sub = 4'b0_110;
parameter ALUCtrl_srai = 4'b0_111;
parameter ALUCtrl_or = 4'b1_000; 

always @(*) begin
	case(ALUCtrl_i)
		ALUCtrl_and: data_o <= data1_i & data2_i; 
		ALUCtrl_xor: data_o <= data1_i ^ data2_i;
		ALUCtrl_sll: data_o <= data1_i << data2_i;
		ALUCtrl_add: data_o <= data1_i + data2_i;
		ALUCtrl_sub: data_o <= data1_i - data2_i;
		ALUCtrl_mul: data_o <= data1_i * data2_i;
		ALUCtrl_addi: data_o <= data1_i + data2_i;
		ALUCtrl_srai: data_o <= data1_i >>> data2_i[4:0];
		ALUCtrl_or: data_o <= data1_i | data2_i; 
		default: data_o <= data1_i + data2_i;
	endcase
end

endmodule
