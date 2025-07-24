`timescale 1ns / 1ps



module HalfBand1 (
	input clk,
	input clkdiv,
	input rst,
	input signed [16:0] x_in,//Q0.17
	output reg signed [16:0] y_out //Q0.17
);

//Fixed Coefficients for Halfband Filter
//Q8.17
//reg signed [24:0] HB1coff0 = {{7{1'b0}},21'h002098 >> 3};
//coff1 is not used
//reg signed [24:0] HB1coff2 = {{7{1'b1}},18'h3E42B}; //Don't
//coff3 is not used
//reg signed [24:0] HB1coff4 = {{7{1'b0}},21'h04BE38 >> 3};
//reg signed [24:0] HB1coff5 = {{7{1'b0}},21'h080000 >> 3};

//Q9.16
reg signed [24:0] HB1coff0 = 25'h0000209;
reg signed [24:0] HB1coff2 = 25'h1FFF218;
reg signed [24:0] HB1coff4 = 25'h0004BE4;
reg signed [24:0] HB1coff5 = 25'h0008000;

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
	input [16:0] x_in, //TODO CHECK ON THIS
	output reg [17:0] y_out 
);

reg[24:0] HB2coff0 = {{4{1'b0}},21'h000180};
reg[24:0] HB2coff2 = {{4{1'b1}},21'h1FF7D0};
reg[24:0] HB2coff4 = {{4{1'b0}},21'h001B38};
reg[24:0] HB2coff6 = {{4{1'b1}},21'h1FB928};
reg[24:0] HB2coff8 = {{4{1'b0}},21'h00A188};
reg[24:0] HB2coff10 ={{4{1'b1}},21'h1E9110};
reg[24:0] HB2coff12 ={{4{1'b0}},21'h04FFb0};
reg[24:0] HB2coff13 ={{4{1'b0}},21'h080000};

reg[17:0] D[25:0]; //Delay Registers
reg[47:0] r[14:0];//Sum Registers


MACBlock m0(HB2coff0,{1'b0,x_in},48'b0,r[0]);
MACBlock m1(HB2coff2,D[1],r[0],r[1]);
MACBlock m2(HB2coff4,D[3],r[1],r[2]);
MACBlock m3(HB2coff6,D[5],r[2],r[3]);
MACBlock m4(HB2coff8,D[7],r[3],r[4]);
MACBlock m5(HB2coff10,D[9],r[4],r[5]);
MACBlock m6(HB2coff12,D[11],r[5],r[6]);
MACBlock m7(HB2coff13,D[12],r[6],r[7]);
MACBlock m8(HB2coff12,D[13],r[7],r[8]);
MACBlock m9(HB2coff10,D[15],r[8],r[9]);
MACBlock m10(HB2coff8,D[17],r[9],r[10]);
MACBlock m11(HB2coff6,D[19],r[10],r[11]);
MACBlock m12(HB2coff4,D[21],r[11],r[12]);
MACBlock m13(HB2coff2,D[23],r[12],r[13]);
MACBlock m14(HB2coff0,D[25],r[13],r[14]);


integer i;
always @(posedge clk or posedge rst) begin 
	if(rst) for(i = 0; i < 26; i = i + 1) D[i] <= 0;
        else begin
		for(i = 1; i < 26; i = i + 1) D[i] <= D[i-1];
                D[0] <= {{1{1'b0}},x_in};
	end
end

always @(posedge clkdiv or posedge rst) begin 
	if(rst) y_out <= 0;
	else	y_out <= r[14]>>18;
end

endmodule

module F_FIR(
	input clk,
	input clkdiv,
	input rst,
	input [17:0] x_in,
	output reg [17:0] y_out 
);

reg[24:0] FIRcoff0 = {{4{1'b0}},21'h000148};
reg[24:0] FIRcoff1 = {{4{1'b0}},21'h0004C0};
reg[24:0] FIRcoff2 = {{4{1'b0}},21'h1FFAD0};
reg[24:0] FIRcoff3 = {{4{1'b0}},21'h1FF590};
reg[24:0] FIRcoff4 = {{4{1'b0}},21'h000D88};
reg[24:0] FIRcoff5 = {{4{1'b0}},21'h0013B8};
reg[24:0] FIRcoff6 = {{4{1'b0}},21'h1FE1D0};
reg[24:0] FIRcoff7 = {{4{1'b0}},21'h1FE008};
reg[24:0] FIRcoff8 = {{4{1'b0}},21'h003BC0};
reg[24:0] FIRcoff9 = {{4{1'b0}},21'h002E00};
reg[24:0] FIRcoffA = {{4{1'b0}},21'h1F9180};
reg[24:0] FIRcoffB = {{4{1'b0}},21'h1FC3C0};
reg[24:0] FIRcoffC = {{4{1'b0}},21'h00C8A8};
reg[24:0] FIRcoffD = {{4{1'b0}},21'h004880};
reg[24:0] FIRcoffE = {{4{1'b0}},21'h1E7410};
reg[24:0] FIRcoffF = {{4{1'b0}},21'h1FAF20};
reg[24:0] FIRcoffG = {{4{1'b0}},21'h050A68};
reg[24:0] FIRcoffH = {{4{1'b0}},21'h0853C8};



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
MACBlock m10(FIRcoffA,D[9],r[9],r[10]);
MACBlock m11(FIRcoffB,D[10],r[10],r[11]);
MACBlock m12(FIRcoffC,D[11],r[11],r[12]);
MACBlock m13(FIRcoffD,D[12],r[12],r[13]);
MACBlock m14(FIRcoffE,D[13],r[13],r[14]);
MACBlock m15(FIRcoffF,D[14],r[14],r[15]);
MACBlock m16(FIRcoffG,D[15],r[15],r[16]);
MACBlock m17(FIRcoffH,D[16],r[16],r[17]);
MACBlock m18(FIRcoffG,D[17],r[17],r[18]);
MACBlock m19(FIRcoffF,D[18],r[18],r[19]);
MACBlock m20(FIRcoffE,D[19],r[19],r[20]);
MACBlock m21(FIRcoffD,D[20],r[20],r[21]);
MACBlock m22(FIRcoffC,D[21],r[21],r[22]);
MACBlock m23(FIRcoffB,D[22],r[22],r[23]);
MACBlock m24(FIRcoffA,D[23],r[23],r[24]);
MACBlock m25(FIRcoff9,D[24],r[24],r[25]);
MACBlock m26(FIRcoff8,D[25],r[25],r[26]);
MACBlock m27(FIRcoff7,D[26],r[26],r[27]);
MACBlock m28(FIRcoff6,D[27],r[27],r[28]);
MACBlock m29(FIRcoff5,D[28],r[28],r[29]);
MACBlock m30(FIRcoff4,D[29],r[29],r[30]);
MACBlock m31(FIRcoff3,D[20],r[30],r[31]);
MACBlock m32(FIRcoff2,D[31],r[31],r[32]);
MACBlock m33(FIRcoff1,D[32],r[32],r[33]);
MACBlock m34(FIRcoff0,D[33],r[33],r[34]);


integer i;
always @(posedge clk or posedge rst) begin 
	if(rst) begin 
		for(i = 0; i < 34; i = i + 1) D[i] <= 0;
	end
        else begin
		for(i = 1; i < 34; i = i + 1) D[i] <= D[i-1];
                D[0] <= {{1{1'b0}},x_in};
	end
end
initial begin 
	y_out <= 0;
end
always @(posedge clkdiv or posedge rst) begin 
	if(rst) begin 
		y_out <= 0;
	end 
	else begin 
		y_out <= r[34]>>18;
	end
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





