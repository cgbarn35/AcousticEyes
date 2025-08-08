`timescale 100ns / 10ps
`define HalfClockPeriod 1.6275

module top;

parameter N = 96;
parameter Graph = 19;
initial begin 
	$dumpfile("../../../../build/pdm.vcd");
	$dumpvars;
end

//INPUT
reg CLK;
reg RST;
reg [15:0] cnt;
reg sftData [N-1:0];
//OUTPUT
wire CLKDIVC1;
wire CLKDIVH1;
wire CLKDIVH2;
wire [15:0] OUT [HzCount:0];
//FILE CONTENTS
integer fd;
integer csv;
integer x;
genvar i;
reg [10000:0] testData [0:HzCount];
wire [10000:0] testTemp;
assign testTemp = testData[0];

//FILTERS GENERATED
generate 
	for(i = 0; i < N; i = i + 1) begin: Filters 
	wire [15:0] outT;
	wire sftT;
	assign outT = FIR_OUT[i];
	assign sftT = sftData[i];
	top_pdm #(N) uutP(
		.clk(CLK),
		.rst(RST),
		.PDM(sftData[i]),
		.PCM(OUT[i])
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

always @(posedge CLKDIVH2) begin 
	$display("%d,%d",$time,OUT[Graph]);
	$fwrite(csv,"%d,%d\n",$time,OUT[Graph]);
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
		for(x = 0; x < N; x = x + 1) sftData[x] <= 0;
	end
	else begin
		cnt <= cnt + 1;
		for(x = 0; x < N; x = x + 1) sftData[x] <= testData[x][cnt];
	end
end

	endmodule
