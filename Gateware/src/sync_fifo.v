`timescale 1ns / 1ps

module sync_fifo #(parameter WIDTH = 18, DEPTH = 32)(
	input clk,
	input rst,
	input wr_en,
	input rd_en,
	input reg [AWIDTH-1:0] a_in,
	input reg [BWIDTH-1:0] b_in,
	output reg [WIDTH-1:0] c_out,
	output empty,
	output full
);


reg [$clog2(DEPTH):0] wr_ptr;
reg [$clog2(DEPTH):0] rd_ptr;

reg [WIDTH-1:0] mem [0:DEPTH-1];


always @(posedge clk) begin 
	if(rst) begin 
		wr_ptr <= 0;
	end else begin 
		if(wr_en & !full) begin 
			fifo[wr_ptr] <= x_in;
			wr_ptr <= wr_ptr + 1;
		end
	end
end

always @(posedge clk) begin 
	if(rst) begin 
		rd_ptr <= 0;
	end else begin 
		if(rd_en & !empty) begin
			c_out <= fifo[rd_ptr];
                        rd_ptr <= rd_ptr + 1;
		end
        end
end

assign empty = wr_ptr == rd_ptr;
assign full = wr_ptr + 1 == rd_ptr;

endmodule

