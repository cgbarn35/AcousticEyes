`timescale 100ns / 10ps
`define HalfClockPeriod 1.6275
 
module fifoUUT;

parameter AWIDTH = 18;
parameter BWIDTH = 25;

initial begin
        $dumpfile("../../../../build/fifo.vcd");
	$dumpvars;
end

reg stop;

//INPUT
reg CLK;
reg RST;
reg wr_en;
reg rd_en;
reg [AWIDTH-1:0] a_in;
reg [BWIDTH-1:0] b_in;
//OUTPUT
reg [AWIDTH-1:0] a_out;
reg [BWIDTH-1:0] b_out;
reg empty;
reg full;
//FILE CONTENTS


sync_fifo #(.WIDTH(43), .DEPTH(64)) uutF (
	.clk(CLK),
	.rst(RST),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.d_in({a_in,b_in}),
	.d_out({a_out,b_out}),
	.empty(empty),
	.full(full)
        );

initial begin
	stop <= 1;
        CLK <= 0;
        RST <= 0;
	wr_en <= 0;
	rd_en <= 0;
        #10 
        RST <= 1;
        #10 
        RST <= 0;
end


initial begin 
	@(posedge CLK);

	for(int i = 0; i < 500; i = i+1) begin 
		while(full) begin 
			@(posedge CLK);
			$display("%d Fifo Full",$time);
		end
	wr_en <= $random;
	a_in <= $random;
	b_in <= $random;
	
	@(posedge CLK);
	end
	stop <= 0;
        $finish;
end

initial begin @(posedge CLK);

	while(stop) begin 
		while(empty) begin 
		@(posedge CLK);
		rd_en <= 0;
		$display("%d FIFO empty",$time);
		end
	rd_en <= $random;
	@(posedge CLK);
	end 
end

//CLK INITIALIZATION
always begin
        #`HalfClockPeriod CLK = ~CLK;                         
end

endmodule
