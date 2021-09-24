module ALU_Control(
	funct_i,
	ALUOp_i,
	ALUCtrl_o
);
input [9:0] funct_i;
input [1:0] ALUOp_i;
output reg [3:0] ALUCtrl_o; 

parameter ALUOp_lw_sw = 2'b00;
parameter ALUOp_beq = 2'b01;
parameter ALUOp_R_type = 2'b10;
parameter ALUOp_I_type = 2'b11; 

parameter ALUCtrl_and = 4'b0_000;
parameter ALUCtrl_xor = 4'b0_001;
parameter ALUCtrl_add = 4'b0_010;
parameter ALUCtrl_sll = 4'b0_011;
parameter ALUCtrl_mul = 4'b0_100;
parameter ALUCtrl_addi = 4'b0_101;
parameter ALUCtrl_sub = 4'b0_110;
parameter ALUCtrl_srai = 4'b0_111;
parameter ALUCtrl_or = 4'b1_000; 


parameter funct3_or = 3'b110; 
parameter funct3_and = 3'b111;
parameter funct3_xor = 3'b100;
parameter funct3_sll = 3'b001;

parameter funct7_sub = 7'b010_0000;
parameter funct7_mul = 7'b000_0001;

parameter funct3_srai = 3'b101;

wire [2:0] funct3 = funct_i[2:0];
wire [6:0] funct7 = funct_i[9:3];

initial begin
	ALUCtrl_o <= ALUOp_lw_sw; // add
end

always @(*) begin
	if(ALUOp_i == ALUOp_lw_sw)
		ALUCtrl_o <= ALUCtrl_add; // lw sw
	else if(ALUOp_i == ALUOp_beq)
		ALUCtrl_o <= ALUCtrl_sub; // beq
	else if(ALUOp_i == ALUOp_I_type) begin // I type
		if(funct3 == funct3_srai)
			ALUCtrl_o <= ALUCtrl_srai; // srai
		else
			ALUCtrl_o <= ALUCtrl_add; // addi
	end else begin // R type
		if(funct3 == funct3_or) // by funct3
			ALUCtrl_o <= ALUCtrl_or; 
		else if(funct3 == funct3_and) //if(funct3 == funct3_and) // by funct3 // by funct3
			ALUCtrl_o <= ALUCtrl_and; // and
		else if(funct3 == funct3_xor)
			ALUCtrl_o <= ALUCtrl_xor; // xor
		else if(funct3 == funct3_sll)
			ALUCtrl_o <= ALUCtrl_sll; // sll
		else if(funct7 == funct7_sub) // by funct7 (funct3 == 000 below)
			ALUCtrl_o <= ALUCtrl_sub; // sub
		else if(funct7 == funct7_mul)
			ALUCtrl_o <= ALUCtrl_mul; // mul
		else
			ALUCtrl_o <= ALUCtrl_add; // add
	end
end
endmodule
