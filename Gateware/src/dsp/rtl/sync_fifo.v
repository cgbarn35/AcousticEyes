`timescale 1ns / 1ps

module sync_fifo #(parameter AWIDTH = 18, BWIDTH = 25, DEPTH = 32)(
	input clk,
	input rst,
	input wr_en,
	input rd_en,
	input reg [AWIDTH-1:0] a_in,
	input reg [BWIDTH-1:0] b_in,
	output reg [AWIDTH-1:0] a_out,
	output reg [BWIDTH-1:0] b_out,
	output empty,
	output full
);

reg [$clog2(DEPTH):0] wr_ptr;
reg [$clog2(DEPTH):0] rd_ptr;

reg [AWIDTH-1:0] aMEM [0:DEPTH-1];
reg [BWIDTH-1:0] bMEM [0:DEPTH-1];

initial begin 
	wr_ptr <= 0;
	rd_ptr <= 0;
end

always @(posedge clk) begin 
	if(rst) begin 
		wr_ptr <= 0;
	end else begin 
		if(wr_en & !full) begin 
			aMEM[wr_ptr] <= a_in;
			bMEM[wr_ptr] <= b_in;
			wr_ptr <= wr_ptr + 1;
		end
	end
end

always @(posedge clk) begin 
	if(rst) begin 
		rd_ptr <= 0;
	end else begin 
		if(rd_en & !empty) begin
			a_out <= aMEM[rd_ptr];
			b_out <= bMEM[rd_ptr];
                        rd_ptr <= rd_ptr + 1;
		end
        end
end

assign empty = wr_ptr == rd_ptr;
assign full = wr_ptr + 1 == rd_ptr;

endmodule

