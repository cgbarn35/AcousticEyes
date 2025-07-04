`timescale 100ns / 10ps


`define HalfClockPeriod 2

module PDMTest;

parameter CICCount = 20;

initial begin 
	$dumpfile("out.vcd");
	$dumpvars;
end




//INPUT
reg CLK;
reg RST;
reg [15:0] cnt;
reg sftData [CICCount:0];
//OUTPUT
wire CLKDIV;
wire [15:0] OUT [CICCount:0];
//FILE CONTENTS
integer fd;
integer x;
genvar i;
reg [CICCount*9992:0] testData;

ClockDivider #(16) C0 (//TODO PARAMETERIZE CLOCK DIVISION 16 DIV
	CLK,
	RST,
	CLKDIV
	);

generate 
	for(i = 0; i < CICCount; i = i + 1) begin: CIC 
	wire [15:0] outT;
	wire sftT;
	assign outT = OUT[i];
	assign sftT = sftData[i];
	CICNR16 #(3) uut (
		.clk(CLK),
		.clkdiv(CLKDIV),
		.rst(RST),
		.x_in(sftData[i]),
		.y_out(OUT[i])
		);
	end
endgenerate

initial begin 
	fd = $fopen("./pdm.dat","rb");
	if(fd) $display("file opened successfully %0d",fd);
	else   $display("file not opened %0d",fd);
	$fread(testData,fd);
	//$display("data read %b",testData);
	$fclose(fd);
end



initial begin
	CLK = 0;
	RST = 0;
	cnt = 0;
	#100 
	RST = 1;
	#100
        RST = 0;
	#36000
        $finish;
end

always begin                                                 
	#`HalfClockPeriod CLK = ~CLK;                         
end

always @(posedge CLK or posedge RST) begin
	if(RST) begin 
		cnt = 0;
		for(x = 0; x < CICCount; x = x + 1) sftData[x] = 0;
	end
	else begin
		cnt = cnt + 1;
		for(x = 0; x < CICCount; x = x + 1) sftData[x] = testData[x*10000+cnt];
	end
end

	endmodule

module ClockDivider #(parameter N=16)(
	input clk,
	input rst,
	output reg clkdiv
	);
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
