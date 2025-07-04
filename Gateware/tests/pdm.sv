`timescale 100ns / 10ps


`define HalfClockPeriod 1.6

module PDMTest;

initial begin 
	$dumpfile("out.vcd");
	$dumpvars;
end




//INPUT
reg CLK;
reg RST;
reg [11:0] cnt;
reg sftData;
//OUTPUT
wire CLKDIV;
wire [15:0] OUT;
//FILE CONTENTS
integer fd;
reg [2992:0] testData; //TODO VERIFIY TEST LENGTH

ClockDivider C0(//TODO PARAMETERIZE CLOCK DIVISION
	CLK,
	RST,
	CLKDIV
	);

	CICNR16 #(3) uut (
		.clk(CLK),
		.clkdiv(CLKDIV),
		.rst(RST),
		.x_in(sftData),
		.y_out(OUT)
		);


		initial begin 
			CLK = 0;
			RST = 0;
			cnt = 0;

			fd = $fopen("./pdm.dat","r");
			if(fd) $display("file opened successfully %0d",fd);
			else   $display("file not opened %0d",fd);
			$fread(testData,fd);
			$display("data read %b",testData);
			$fclose(fd);
			#100
			RST = 1;
			#100
			RST = 0;

			#10000 //TODO DETERMINE
			$finish;
	end

	always begin                                                 
		#`HalfClockPeriod CLK = ~CLK;                         
	end

	always @(posedge CLK or posedge RST) begin                                                 
		if(RST) begin 
			cnt = 0;
			sftData = 0;
		end
		else begin
		cnt = cnt + 1;
		sftData = testData[cnt];
	end
end

	endmodule

	module ClockDivider(
		input clk,
		input rst,
		output reg clkdiv
		);
		parameter N = 16;

		reg[6:0] cnt;
		initial begin 
			cnt = 0;
			clkdiv = 0;
		end


		always @(posedge clk) begin 
			if(rst) begin 
				cnt = 0;
				clkdiv = 0;
			end
			cnt <= cnt + 1;
			if(cnt >= N-1) begin
				cnt <= 0;
				clkdiv <= ~clkdiv;
			end
		end
		endmodule
