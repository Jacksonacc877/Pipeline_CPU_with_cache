module And(
	start_i,
	data1_i,
	data2_i,
	data_o
);
input start_i; //TODO
input data1_i;
input data2_i;
output reg data_o;

initial begin
	data_o = 1'b0;
end

always@(*) begin
	if(start_i)
		data_o <= data1_i & data2_i;
end

endmodule
