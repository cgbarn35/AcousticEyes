`timescale 1ns / 1ps



module HalfBand1 (
	input clk,
	input clkdiv,
	input rst,
	input signed [16:0] x_in,//Q0.17
	output reg signed [17:0] y_out //Q0.17
);

//Fixed Coefficients for Halfband Filter
//Q8.17
reg signed [24:0] HB1coff0 = 25'h0000413;
reg signed [24:0] HB1coff2 = 25'h1FFE42B;
reg signed [24:0] HB1coff4 = 25'h00097C7;
reg signed [24:0] HB1coff5 = 25'h0010000;

reg signed [17:0] D[9:0]; //Delay Registers
reg signed [47:0] r[8:0];//Sum Registers

//NAIVE APPROACH, TODO REFACTOR
//TODO USE DSP48E ?

MACBlock m0(HB1coff0,{1'b0,x_in},48'b0,r[0]);//Sign extend x_in to Q1.17
MACBlock m1(HB1coff2,D[1],r[0],r[1]);
MACBlock m2(HB1coff4,D[3],r[1],r[2]);
MACBlock m3(HB1coff5,D[4],r[2],r[3]);
MACBlock m4(HB1coff4,D[5],r[3],r[4]);
MACBlock m5(HB1coff2,D[7],r[4],r[5]);
MACBlock m6(HB1coff0,D[9],r[5],r[6]);

integer i;
always @(posedge clk or posedge rst) begin 
	if(rst) for(i = 0; i < 10; i = i + 1) D[i] <= 0;
	else begin 
		for(i = 1; i< 10; i = i + 1) D[i] <= D[i-1];
                D[0] <= {1'b0,x_in};//Q1.17
	end
end

always @(posedge clkdiv or posedge rst) begin 
	if(rst) y_out <= 0;
	else  	y_out <= r[6]>>16;
end

endmodule

module HalfBand2 ( 
	input clk,
	input clkdiv,
	input rst,
	input signed [17:0] x_in, //TODO CHECK ON THIS
	output reg signed [17:0] y_out 
);

//Q8.17
reg signed [24:0] HB2coff0 = 25'h0000030;
reg signed [24:0] HB2coff2 = 25'h1FFFEFA;
reg signed [24:0] HB2coff4 = 25'h0000367;
reg signed [24:0] HB2coff6 = 25'h1FFF725;
reg signed [24:0] HB2coff8 = 25'h0001431;
reg signed [24:0] HB2coffA = 25'h1FFD222;
reg signed [24:0] HB2coffC = 25'h0009FF6;
reg signed [24:0] HB2coffD = 25'h0010000;

reg[17:0] D[25:0]; //Delay Registers
reg[47:0] r[14:0];//Sum Registers


MACBlock m0(HB2coff0,x_in,48'b0,r[0]);
MACBlock m1(HB2coff2,D[1],r[0],r[1]);
MACBlock m2(HB2coff4,D[3],r[1],r[2]);
MACBlock m3(HB2coff6,D[5],r[2],r[3]);
MACBlock m4(HB2coff8,D[7],r[3],r[4]);
MACBlock m5(HB2coffA,D[9],r[4],r[5]);
MACBlock m6(HB2coffC,D[11],r[5],r[6]);
MACBlock m7(HB2coffD,D[12],r[6],r[7]);
MACBlock m8(HB2coffC,D[13],r[7],r[8]);
MACBlock m9(HB2coffA,D[15],r[8],r[9]);
MACBlock mA(HB2coff8,D[17],r[9],r[10]);
MACBlock mB(HB2coff6,D[19],r[10],r[11]);
MACBlock mC(HB2coff4,D[21],r[11],r[12]);
MACBlock mD(HB2coff2,D[23],r[12],r[13]);
MACBlock mE(HB2coff0,D[25],r[13],r[14]);


integer i;
always @(posedge clk or posedge rst) begin 
	if(rst) for(i = 0; i < 26; i = i + 1) D[i] <= 0;
        else begin
		for(i = 1; i < 26; i = i + 1) D[i] <= D[i-1];
                D[0] <= x_in;
	end
end

always @(posedge clkdiv or posedge rst) begin 
	if(rst) y_out <= 0;
	else	y_out <= r[14]>>17;
end

endmodule

module F_FIR(
	input clk,
	input rst,
	input signed [17:0] x_in,
	output reg signed [15:0] y_out 
);

//Q8.17
reg signed [24:0] FIRcoff0 = 25'h000002a;
reg signed [24:0] FIRcoff1 = 25'h0000098;
reg signed [24:0] FIRcoff2 = 25'h1ffff5a;
reg signed [24:0] FIRcoff3 = 25'h1fffeb3;
reg signed [24:0] FIRcoff4 = 25'h00001b2;
reg signed [24:0] FIRcoff5 = 25'h0000278;
reg signed [24:0] FIRcoff6 = 25'h1fffc3a;
reg signed [24:0] FIRcoff7 = 25'h1fffc02;
reg signed [24:0] FIRcoff8 = 25'h0000779;
reg signed [24:0] FIRcoff9 = 25'h00005c0;
reg signed [24:0] FIRcoffA = 25'h1fff231;
reg signed [24:0] FIRcoffB = 25'h1fff879;
reg signed [24:0] FIRcoffC = 25'h0001916;
reg signed [24:0] FIRcoffD = 25'h0000910;
reg signed [24:0] FIRcoffE = 25'h1ffce83;
reg signed [24:0] FIRcoffF = 25'h1fff5e5;
reg signed [24:0] FIRcoffG = 25'h000a14e;
reg signed [24:0] FIRcoffH = 25'h0010a7a;

reg[17:0] D[33:0]; //Delay Registers
reg[47:0] r[34:0];//Sum Registers

MACBlock m0(FIRcoff0,x_in,48'b0,r[0]);
MACBlock m1(FIRcoff1,D[0],r[0],r[1]);
MACBlock m2(FIRcoff2,D[1],r[1],r[2]);
MACBlock m3(FIRcoff3,D[2],r[2],r[3]);
MACBlock m4(FIRcoff4,D[3],r[3],r[4]);
MACBlock m5(FIRcoff5,D[4],r[4],r[5]);
MACBlock m6(FIRcoff6,D[5],r[5],r[6]);
MACBlock m7(FIRcoff7,D[6],r[6],r[7]);
MACBlock m8(FIRcoff8,D[7],r[7],r[8]);
MACBlock m9(FIRcoff9,D[8],r[8],r[9]);
MACBlock mA(FIRcoffA,D[9],r[9],r[10]);
MACBlock mB(FIRcoffB,D[10],r[10],r[11]);
MACBlock mC(FIRcoffC,D[11],r[11],r[12]);
MACBlock mD(FIRcoffD,D[12],r[12],r[13]);
MACBlock mE(FIRcoffE,D[13],r[13],r[14]);
MACBlock mF(FIRcoffF,D[14],r[14],r[15]);
MACBlock mG(FIRcoffG,D[15],r[15],r[16]);
MACBlock mH(FIRcoffH,D[16],r[16],r[17]);
MACBlock mI(FIRcoffG,D[17],r[17],r[18]);
MACBlock mJ(FIRcoffF,D[18],r[18],r[19]);
MACBlock mK(FIRcoffE,D[19],r[19],r[20]);
MACBlock mL(FIRcoffD,D[20],r[20],r[21]);
MACBlock mM(FIRcoffC,D[21],r[21],r[22]);
MACBlock mN(FIRcoffB,D[22],r[22],r[23]);
MACBlock mO(FIRcoffA,D[23],r[23],r[24]);
MACBlock mP(FIRcoff9,D[24],r[24],r[25]);
MACBlock mQ(FIRcoff8,D[25],r[25],r[26]);
MACBlock mR(FIRcoff7,D[26],r[26],r[27]);
MACBlock mS(FIRcoff6,D[27],r[27],r[28]);
MACBlock mT(FIRcoff5,D[28],r[28],r[29]);
MACBlock mU(FIRcoff4,D[29],r[29],r[30]);
MACBlock mV(FIRcoff3,D[30],r[30],r[31]);
MACBlock mW(FIRcoff2,D[31],r[31],r[32]);
MACBlock mX(FIRcoff1,D[32],r[32],r[33]);
MACBlock mY(FIRcoff0,D[33],r[33],r[34]);


integer i;
always @(posedge clk or posedge rst) begin 
	if(rst) for(i = 0; i < 34; i = i + 1) D[i] <= 0;
        else begin
		for(i = 1; i < 34; i = i + 1) D[i] <= D[i-1];
                D[0] <= x_in;
	end
end

always @(posedge clk or posedge rst) begin 
	if(rst) y_out <= 0;
	else 	y_out <= r[34]>>18;
end

endmodule

module MACBlock ( //TEMPORARY FOR IVERILOG COMPILATION
	input signed [24:0] a,
	input signed [17:0] b,
	input signed [47:0] c,
	output signed [47:0] out
);
//TODO INTRODUCE ACTUAL DSP48E FUNCTIONALITY
assign out = (a*b) + c;
endmodule





