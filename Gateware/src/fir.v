`timescale 1ns / 1ps



module HalfBand1 (
	input clk,
	input clkdiv,
	input rst,
	input [15:0] x_in,
	output [47:0] y_out 
);

//Fixed Coefficients for Halfband Filter
//following numbers are in Q(1,20) format, sign extended to Q(5,20)
reg[24:0] coff0 = {{4{1'b0}},21'h002090};
//coff1 is not used
reg[24:0] coff2 = {{4{1'b1}},21'h1F2158};
//coff3 is not used
reg[24:0] coff4 = {{4{1'b0}},21'h04BE38};
reg[24:0] coff5 = {{4{1'b0}},21'h080000};

reg[17:0] D[9:0]; //Delay Registers
reg[47:0] r[8:0];//Sum Registers

//NAIVE APPROACH, TODO REFACTOR

//TODO USE DSP48E ?
assign y_out = r[6]>>3;

MACBlock m0(coff0,{{2{1'b0}},x_in},48'b0,r[0]);//Sign extend x_in
MACBlock m1(coff2,D[1],r[0],r[1]);
MACBlock m2(coff4,D[3],r[1],r[2]);
MACBlock m3(coff5,D[4],r[2],r[3]);
MACBlock m4(coff4,D[5],r[3],r[4]);
MACBlock m5(coff2,D[7],r[4],r[5]);
MACBlock m6(coff0,D[9],r[5],r[6]);

integer i;
always @(posedge clkdiv or posedge rst) begin 
	if(rst) begin 
		for(i = 0; i < 10; i = i + 1) D[i] <= 0;
	end
        else begin
		for(i = 1; i < 10; i = i + 1) D[i] <= D[i-1];
                D[0] <= x_in;
	end
end



endmodule

module MACBlock ( //TEMPORARY FOR IVERILOG COMPILATION
	input [24:0] a,
	input [17:0] b,
	input [47:0] c,
	output[47:0] out
);
//TODO INTRODUCE ACTUAL DSP48E FUNCTIONALITY
assign out = a*b + c;

endmodule
