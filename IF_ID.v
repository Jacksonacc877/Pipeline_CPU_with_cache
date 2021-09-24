module IF_ID(

	cpu_stall_i,


	start_i,
	clk_i,
	
	branch_taken_control_hazard_flush_zero_IF_ID_instruction_i,
	load_use_data_hazard_preserve_IF_ID_i,
	// usual pipelin registers
	PC_i,
	PC_o,
	instr_i,
	instr_o
);
// P2 begin
input cpu_stall_i;
// P2 end

input start_i;
input clk_i;

// from And.Branch_Taken_o : 
// When branch taken (prediction wrong), zero the instruction field of IF_ID
input branch_taken_control_hazard_flush_zero_IF_ID_instruction_i; 
// from HazardDetection.Stall_o : 
// When load-use data hazard, preserve IF_ID & PC
input load_use_data_hazard_preserve_IF_ID_i; 

// usual pipelin registers
input [31:0] PC_i;
output reg [31:0] PC_o;
input [31:0] instr_i;
output reg [31:0] instr_o;

initial begin
	PC_o = 32'b0;
	instr_o = 32'b0;
end

always @(posedge clk_i) begin
	if(cpu_stall_i) begin
		// do nothing
	end
	else if(start_i && load_use_data_hazard_preserve_IF_ID_i == 1'b0) begin
		PC_o <= PC_i;
		if(branch_taken_control_hazard_flush_zero_IF_ID_instruction_i)
			instr_o <= 32'b0;
		else
			instr_o <= instr_i;
	end
end
endmodule
