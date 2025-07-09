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
wire [47:0] FOUT;
//FILE CONTENTS
integer fd;
integer csv;
integer x;
genvar i;
reg [CICCount*9992:0] testData;

ClockDivider #(16) C0 (//16 DIV CLOCK DIVISION
	CLK,
	RST,
	CLKDIV
	);

//CIC FILTERS GENERATED
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

HalfBand1 uutH (
	.clk(CLK),
	.clkdiv(CLKDIV),
	.rst(RST),
	.x_in(OUT[0]),
	.y_out(FOUT)
	);


//TEST DATA GENERATED
initial begin 
	fd = $fopen("./pdm.dat","rb");
	if(fd) $display("file opened successfully %0d",fd);
	else   $display("file not opened %0d",fd);
	$fread(testData,fd);
	//$display("data read %b",testData);
	$fclose(fd);
	csv = $fopen("./pdm.csv","w");
	if(csv) $display("file opened successfully %0d",csv);
	else   $display("file not opened %0d",csv);
end

//Python Test Data Read

always @(posedge CLKDIV) begin 
	$display("%d,%d,%d",$time,OUT[0],FOUT);
	$fwrite(csv,"%d,%d,%d\n",$time,OUT[0],FOUT);
end


initial begin
	CLK = 0;
	RST = 0;
	cnt = 0;
	#50 
	RST = 1;
	#100
        RST = 0;
	#36000
	$fclose(csv);
        $finish;
end

//CLK INITIALIZATION
always begin                                                 
	#`HalfClockPeriod CLK = ~CLK;                         
end

//TEST DATA SHIFT REGISTERS
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

//CLOCK DIVIDER 
module ClockDivider #(parameter N=16)(
	input clk,
	input rst,
	output reg clkdiv
	);
	reg[$clog2(N):0] cnt;
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
