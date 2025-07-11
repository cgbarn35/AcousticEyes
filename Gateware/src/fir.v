`timescale 1ns / 1ps



module HalfBand1 (
	input clk,
	input clkdiv,
	input rst,
	input [15:0] x_in,
	output reg [47:0] y_out 
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

MACBlock m0(coff0,{{2{1'b0}},x_in},48'b0,r[0]);//Sign extend x_in
MACBlock m1(coff2,D[1],r[0],r[1]);
MACBlock m2(coff4,D[3],r[1],r[2]);
MACBlock m3(coff5,D[4],r[2],r[3]);
MACBlock m4(coff4,D[5],r[3],r[4]);
MACBlock m5(coff2,D[7],r[4],r[5]);
MACBlock m6(coff0,D[9],r[5],r[6]);

integer i;
always @(posedge clk or posedge rst) begin 
	if(rst) begin 
		for(i = 0; i < 10; i = i + 1) D[i] <= 0;
	end
        else begin
		for(i = 1; i < 10; i = i + 1) D[i] <= D[i-1];
                D[0] <= {{2{1'b0}},x_in};
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
		y_out <= r[6]>>3;
	end
end



endmodule

module HalfBand2 ( 
	input clk,
	input clkdiv,
	input rst,
	input [15:0] x_in,
	output reg [47:0] y_out 
);

reg[24:0] coff0 = 18'h00180;
reg[24:0] coff2 = 18'h3F7D0;
reg[24:0] coff4 = 18'h01B38;
reg[24:0] coff6 = 18'h3B928;
reg[24:0] coff8 = 18'h0A188;
reg[24:0] coff10= 18'h29110;
reg[24:0] coff12= 18'h4FFB0; //TODO
reg[24:0] coff13= 18'h10000;

reg[17:0] D[26:0]; //Delay Registers
reg[47:0] r[14:0];//Sum Registers


MACBlock m0(coff0,{{2{1'b0}},x_in},48'b0,r[0]);//Sign extend x_in
MACBlock m1(coff2,D[1],r[0],r[1]);
MACBlock m2(coff4,D[3],r[1],r[2]);
MACBlock m3(coff6,D[5],r[2],r[3]);
MACBlock m4(coff8,D[7],r[3],r[4]);
MACBlock m5(coff10,D[9],r[4],r[5]);
MACBlock m6(coff12,D[11],r[5],r[6]);
MACBlock m7(coff13,D[12],r[6],r[7]);
MACBlock m8(coff12,D[13],r[7],r[8]);
MACBlock m9(coff10,D[15],r[8],r[9]);
MACBlock m10(coff8,D[17],r[9],r[10]);
MACBlock m11(coff6,D[19],r[10],r[11]);
MACBlock m12(coff4,D[21],r[11],r[12]);
MACBlock m13(coff2,D[23],r[12],r[13]);
MACBlock m14(coff0,D[25],r[13],r[14]);


integer i;
always @(posedge clk or posedge rst) begin 
	if(rst) begin 
		for(i = 0; i < 26; i = i + 1) D[i] <= 0;
	end
        else begin
		for(i = 1; i < 26; i = i + 1) D[i] <= D[i-1];
                D[0] <= {{2{1'b0}},x_in};
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
		y_out <= r[14];
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
assign out = (a*b) + c;

endmodule
