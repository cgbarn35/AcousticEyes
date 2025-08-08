`timescale 1ns / 1ps

module sync_fifo #(parameter WIDTH = 18, DEPTH = 32)(
	input clk,
	input rst,
	input wr_en,
	input rd_en,
	input reg [WIDTH-1:0] d_in,
	output reg [WIDTH-1:0] d_out,
	output empty,
	output full
);

reg [$clog2(DEPTH)-1:0] wr_ptr;
reg [$clog2(DEPTH)-1:0] rd_ptr;

reg [WIDTH-1:0] fifo [DEPTH-1:0];

initial begin 
	wr_ptr <= 0;
	rd_ptr <= 0;
end

always @(posedge clk) begin 
	if(rst) begin 
		wr_ptr <= 0;
	end else begin 
		if(wr_en & !full) begin 
			fifo[wr_ptr] <= d_in;
			wr_ptr <= wr_ptr + 1;
		end
	end
end

always @(posedge clk) begin 
	if(rst) begin 
		rd_ptr <= 0;
	end else begin 
		if(rd_en & !empty) begin
			d_out <= fifo[rd_ptr];
                        rd_ptr <= rd_ptr + 1;
		end
        end
end

assign empty = wr_ptr == rd_ptr;
assign full = (wr_ptr + 1) == rd_ptr;

endmodule

