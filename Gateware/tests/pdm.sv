`timescale 100ns / 10ps
`define HalfClockPeriod 1.6275

module PDMTest;

parameter HzCount = 20;
parameter FreqSet = 19;
initial begin 
	$dumpfile("pdm.vcd");
	$dumpvars;
end

//INPUT
reg CLK;
reg RST;
reg [15:0] cnt;
reg sftData [HzCount:0];
//OUTPUT
wire CLKDIVC1;
wire CLKDIVH1;
wire CLKDIVH2;
wire [16:0] CIC_OUT [HzCount:0];
wire [17:0] HB1_OUT [HzCount:0];
wire [17:0] HB2_OUT [HzCount:0];
wire [15:0] FIR_OUT [HzCount:0];
//FILE CONTENTS
integer fd;
integer csv;
integer x;
genvar i;
reg [10000:0] testData [0:HzCount];
wire [10000:0] testTemp;
assign testTemp = testData[0];
//3.072MHz TODO
//3.125MHz -> 195.3KHz
ClockDivider #(8) C0 (//CIC FILTER CLOCK DIVIDER
	CLK,
	RST,
	CLKDIVC1
	);
//195.3KHz -> 97.656KHz
 ClockDivider #(1) C1 (//HALFBAND 1 CLOCK DIVIDER
	CLKDIVC1,
	RST,
	CLKDIVH1
	);
//97.656KHz -> 48.828Khz
 ClockDivider #(1) C2 (//HALFBAND 2 CLOCK DIVIDER
	CLKDIVH1,
	RST,
	CLKDIVH2
	);

//FILTERS GENERATED
generate 
	for(i = 0; i < HzCount; i = i + 1) begin: Filters 
	wire [15:0] outT;
	wire sftT;
	assign outT = FIR_OUT[i];
	assign sftT = sftData[i];
	CICNR16 #(4) uutC (
		.clk(CLK),
		.clkdiv(CLKDIVC1),
		.rst(RST),
		.x_in(sftData[i]),
		.y_out(CIC_OUT[i])
		);
	HalfBand1 uutH1 ( //TODO CONVERT FROM NAIVE MULT BLOCK IMPLEMENTATION TO FSM CONTROL
		.clk(CLKDIVC1),
		.clkdiv(CLKDIVH1),
		.rst(RST),
		.x_in(CIC_OUT[i]),
		.y_out(HB1_OUT[i])
		);
	HalfBand2 uutH2 (
		.clk(CLKDIVH1),
		.clkdiv(CLKDIVH2),
		.rst(RST),
		.x_in(HB1_OUT[i]),
		.y_out(HB2_OUT[i])
		);
	F_FIR uutF(
		.clk(CLKDIVH2),
		.rst(RST),
		.x_in(HB2_OUT[i]),
		.y_out(FIR_OUT[i])
	);
	end
endgenerate


//TEST DATA GENERATED
initial begin 
	$readmemb("pdm.mem",testData);
	//$display("data read %b",testData);
	$fclose(fd);
	csv = $fopen("./pdm.csv","w");
	if(csv) $display("file opened successfully %0d",csv);
	else   $display("file not opened %0d",csv);
	$fwrite(csv,"0,0,0,0,%d\n",FreqSet);
end

//Python Test Data Read

always @(posedge CLKDIVH2) begin 
	$display("%d,%d,%d,%d,%d",$time,CIC_OUT[FreqSet],HB1_OUT[FreqSet],HB2_OUT[FreqSet],FIR_OUT[FreqSet]);
	$fwrite(csv,"%d,%d,%d,%d,%d\n",$time,CIC_OUT[FreqSet],HB1_OUT[FreqSet],HB2_OUT[FreqSet],FIR_OUT[FreqSet]);
end


initial begin
	CLK = 0;
	RST = 0;
	cnt = 0;
	#10 
	RST = 1;
	#10
        RST = 0;
	#20000
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
		cnt <= 0;
		for(x = 0; x < HzCount; x = x + 1) sftData[x] <= 0;
	end
	else begin
		cnt <= cnt + 1;
		for(x = 0; x < HzCount; x = x + 1) sftData[x] <= testData[x][cnt];
	end
end

	endmodule
