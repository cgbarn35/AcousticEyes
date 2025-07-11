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
wire CLKDIVC1;
wire CLKDIVH1;
wire CLKDIVH2;
wire [15:0] OUT [CICCount:0];
wire [47:0] FOUT;
wire [47:0] HB2OUT;
//FILE CONTENTS
integer fd;
integer csv;
integer x;
genvar i;
reg [CICCount*9992:0] testData;

ClockDivider #(8) C0 (//CIC FILTER CLOCK DIVIDER
	CLK,
	RST,
	CLKDIVC1
	);

 ClockDivider #(1) C1 (//HALFBAND 1 CLOCK DIVIDER
	CLKDIVC1,
	RST,
	CLKDIVH1
	);

 ClockDivider #(1) C2 (//HALFBAND 2 CLOCK DIVIDER
	CLKDIVH1,
	RST,
	CLKDIVH2
	);

//CIC FILTERS GENERATED
generate 
	for(i = 0; i < CICCount; i = i + 1) begin: CIC 
	wire [15:0] outT;
	wire sftT;
	assign outT = OUT[i];
	assign sftT = sftData[i];
	CICNR16 #(4) uut (
		.clk(CLK),
		.clkdiv(CLKDIVC1),
		.rst(RST),
		.x_in(sftData[i]),
		.y_out(OUT[i])
		);
	end
endgenerate

HalfBand1 HB1 (
	.clk(CLKDIVC1),
	.clkdiv(CLKDIVH1),
	.rst(RST),
	.x_in(OUT[18]),
	.y_out(FOUT)
	);

HalfBand2 HB2(
	.clk(CLKDIVH1),
	.clkdiv(CLKDIVH2),
	.rst(RST),
	.x_in(FOUT[32:17]),
	.y_out(HB2OUT)
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

always @(posedge CLKDIVC1) begin 
	$display("%d,%d,%d,%d",$time,OUT[18],FOUT,HB2OUT);
	$fwrite(csv,"%d,%d,%d,%d\n",$time,OUT[18],FOUT,HB2OUT);
end


initial begin
	CLK = 0;
	RST = 0;
	cnt = 0;
	#10 
	RST = 1;
	#10
        RST = 0;
	#10000
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
