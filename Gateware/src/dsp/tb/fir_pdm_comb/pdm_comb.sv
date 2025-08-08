`timescale 100ns / 10ps
`define PDMClockPeriod 1.6275
`define MACClockPeriod 0.9

module pdm;

parameter N = 20;
parameter FreqSet = 10;
initial begin 
	$dumpfile("../../../../build/pdm.vcd");
	$dumpvars;
end

//INPUT
reg CLK;
reg CLKM;
reg RST;
reg [15:0] cnt;
reg sftData [N-1:0];
//OUTPUT
wire CLKDIVC1;
wire [16:0] CIC_OUT [N-1:0];
wire [15:0] FIR_OUT [N-1:0];
//FILE CONTENTS
integer fd;
integer csv;
integer x;
genvar i;
reg [10000:0] testData [0:N-1];
wire [10000:0] testTemp;
assign testTemp = testData[0];
//3.072MHz TODO
//3.125MHz -> 195.3KHz
ClockDivider #(8) C0 (//CIC FILTER CLOCK DIVIDER
	CLK,
	RST,
	CLKDIVC1
	);

//FILTERS GENERATED
generate 
	for(i = 0; i < N; i = i + 1) begin: Filters 
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
	FIR_COMB uuF (
		.CICCLK(CLKDIVC1),
		.MACCLK(CLKM),
		.RST(RST),
		.x_in(CIC_OUT[i]),
		.y_out(FIR_OUT[i])
		);
	end
endgenerate


//TEST DATA GENERATED
initial begin 
	$readmemb("../../../../build/pdm.mem",testData);
	//$display("data read %b",testData);
	$fclose(fd);
	csv = $fopen("../../../../build/pdm.csv","w");
	if(csv) $display("file opened successfully %0d",csv);
	else   $display("file not opened %0d",csv);
	$fwrite(csv,"0,0,0,0,%d\n",FreqSet);
end

//Python Test Data Read

//always @(posedge CLKDIVH2) begin 
	//TODO $display("%d,%d,%d,%d,%d",$time,CIC_OUT[FreqSet],HB1_OUT[FreqSet],HB2_OUT[FreqSet],FIR_OUT[FreqSet]);
	//$fwrite(csv,"%d,%d,%d,%d,%d\n",$time,CIC_OUT[FreqSet],HB1_OUT[FreqSet],HB2_OUT[FreqSet],FIR_OUT[FreqSet]);
//end


initial begin
	CLK = 0;
	CLKM= 0;
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
	#`PDMClockPeriod CLK = ~CLK;                         
end

always begin
	#`MACClockPeriod CLKM = ~CLKM;                         
end

//TEST DATA SHIFT REGISTERS
always @(posedge CLK or posedge RST) begin
	if(RST) begin 
		cnt <= 0;
		for(x = 0; x < N; x = x + 1) sftData[x] <= 0;
	end
	else begin
		cnt <= cnt + 1;
		for(x = 0; x < N; x = x + 1) sftData[x] <= testData[x][cnt];
	end
end

	endmodule
