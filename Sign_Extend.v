module Sign_Extend(
	instr_i,
	imm_o
);
input [31:0] instr_i;
output [31:0] imm_o;

reg [11:0] imm_reg;
wire [6:0] Op_i = instr_i[6:0];
wire [2:0] funct3 = instr_i[14:12]; // for distinguishing addi & srai
// for concatenating immediate :
wire [6:0] funct7 = instr_i[31:25];
wire [4:0] rs2 = instr_i[24:20];
wire [4:0] rd = instr_i[11:7];

parameter Opcode_I_type = 7'b001_0011;
parameter Opcode_lw = 7'b000_0011;
parameter Opcode_sw = 7'b010_0011;
parameter Opcode_beq = 7'b110_0011;

parameter funct3_srai = 3'b101;

initial begin 
	imm_reg = 12'b0;
end

assign imm_o = {  {20{imm_reg[11]}}, imm_reg };

always @(*) begin
	// determine I type, lw, sw, beq by opcode
	if(Op_i == Opcode_I_type) begin // I type
		if(funct3 == funct3_srai)
			imm_reg <= {  {7{rs2[4]}}, rs2 }; //{   {7{inst_i[24]}}, inst_i[24:20] }; 
		else
			imm_reg <= {funct7, rs2}; //inst_i[31:20]; // normal funct7+rs2 // addi
	end else if(Op_i == Opcode_lw) begin // lw
		imm_reg <= {funct7, rs2}; //inst_i[31:20]; // normal funct7+rs2 // lw
	end else if(Op_i == Opcode_sw) begin // sw
		imm_reg <= {funct7, rd}; //{ inst_i[], inst_i[] }; // normal funct7+rd // sw
	end else if(Op_i == Opcode_beq) begin // beq
		imm_reg <= { funct7[6], rd[0], funct7[5:0], rd[4:1] }; // mixing funct7 & rd // beq
	end
end
endmodule
