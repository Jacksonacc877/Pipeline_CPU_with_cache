module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   [24:0]    tag_o;
output   [255:0]   data_o;
output             hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];    
reg      [255:0]   data[0:15][0:1];

integer            i, j;


wire [22:0] sram_tag_way0 = tag[addr_i][0][22:0]; 
wire [22:0] sram_tag_way1 = tag[addr_i][1][22:0]; 
wire sram_valid_way0 = tag[addr_i][0][24];
wire sram_valid_way1 = tag[addr_i][1][24];
wire hit_way0 = (tag_i[22:0] == sram_tag_way0 && sram_valid_way0)? 1'b1 : 1'b0; 
wire hit_way1 = (tag_i[22:0] == sram_tag_way1 && sram_valid_way1)? 1'b1 : 1'b0; 

assign hit_o = hit_way0 || hit_way1;
wire both_ways_full = sram_valid_way0 && sram_valid_way1;

reg lru[0:15]; // replace the way that's least recently used


assign data_o = (hit_way0)? data[addr_i][0] :
		(hit_way1)? data[addr_i][1] :
		(both_ways_full && lru[addr_i] == 1'b0)? data[addr_i][0] :
		(both_ways_full && lru[addr_i] == 1'b1)? data[addr_i][1] :
		(sram_valid_way1 == 1'b0)? data[addr_i][1] : data[addr_i][0]; //if(way1 empty) else (way0 empty)
assign tag_o  = (hit_way0)? tag[addr_i][0] :
		(hit_way1)? tag[addr_i][1] :
		(both_ways_full && lru[addr_i] == 1'b0)? tag[addr_i][0] :
		(both_ways_full && lru[addr_i] == 1'b1)? tag[addr_i][1] :
		(sram_valid_way1 == 1'b0)? tag[addr_i][1] : tag[addr_i][0]; //if(way1 empty) else (way0 empty)
// P2 end

// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
	if(hit_way0) begin // (A) write hit
		data[addr_i][0] <= data_i;
		tag[addr_i][0] <= tag_i;
	end else if(hit_way1) begin // (A) write hit
		data[addr_i][1] <= data_i;
		tag[addr_i][1] <= tag_i;
	end else if(both_ways_full && lru[addr_i] == 1'b0) begin // (B) load from Data Memory. LRU on way 0
		data[addr_i][0] <= data_i;
		tag[addr_i][0] <= tag_i;
	end else if(both_ways_full && lru[addr_i] == 1'b1) begin // (B) load from Data Memory. LRU on way 1
		data[addr_i][1] <= data_i;
		tag[addr_i][1] <= tag_i;
	end else if(sram_valid_way1 == 1'b0) begin // (B) load from Data Memory. way 1 empty
		data[addr_i][1] <= data_i;
		tag[addr_i][1] <= tag_i;
	end else begin // (B) load from Data Memory. way 0 empty
		data[addr_i][0] <= data_i;
		tag[addr_i][0] <= tag_i;
	end
	

    end

end

// update lru
always@(negedge clk_i or posedge rst_i) begin
	if (rst_i) begin
		for (i=0;i<16;i=i+1) begin
			lru[i] = 1'b0;
		end
	end

    	if(enable_i && hit_o) begin
		if(hit_way0)
			lru[addr_i] <= 1'b1;
		else
			lru[addr_i] <= 1'b0;
	end
end

endmodule
