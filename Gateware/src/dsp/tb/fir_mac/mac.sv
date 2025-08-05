`timescale 100ns / 10ps
`define HalfClockPeriod 1.6

module MACTest;


task passTest;
                input [64:0] actualOut, expectedOut;
                input [`STRLEN*8:0] testType;
                inout [7:0] passed;
        
                if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
                else $display ("%s failed: %x should be %x", testType, actualOut, expectedOut);
        endtask

	task allPassed;
                input [7:0] passed;
                input [7:0] numTests;
                
                if(passed == numTests) $display ("All tests passed");
                else $display("Some tests failed");
        endtask


//INPUT
reg CLK;
reg RST;
reg [24:0] a;
reg [17:0] b;
wire [47:0] c;
//OUTPUT
wire [47:0] out;
wire valid;

MACBlock_valid uut(
	.clk(CLK),
	.rst(RST),
	.a(a),
	.b(b),
	.c(c),
	.out(out),
	.valid(vaid)
	);


initial begin 
	$dumpfile("mac.vcd");
	$dumpvars;
	CLK = 0;
	RST = 0;
	{a,b} = {0,0};
	#10 
	RST = 1;
	#10
        RST = 0;
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
