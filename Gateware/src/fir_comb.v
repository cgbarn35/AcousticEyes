`timescale 1ns / 1ps


module FIR_COMB (
	input CICCLK,
	input MACCLK,
	input RST,
	input signed [16:0] x_in,
	output reg signed [16:0] y_out
);

wire HB1CLK;
wire HB2CLK;
wire FIRCLK;

ClockDivider #(1) C1 (//HALFBAND 1 CLOCK DIVIDER
        CICCLK,
        RST,
        HB1CLK
        );
 
 ClockDivider #(1) C2 (//HALFBAND 2 CLOCK DIVIDER
        HB1CLK,
        RST,
        HB2CLK
        );
 
  ClockDivider #(1) C3 (//FIR OUT CLOCK DIVIDER
        HB2CLK,
        RST,
        FIRCLK
        );
 
//Q9.16
reg signed [24:0] HB1coff0 = 25'h0000209;
reg signed [24:0] HB1coff2 = 25'h1FFF218;
reg signed [24:0] HB1coff4 = 25'h0004BE4;
reg signed [24:0] HB1coff5 = 25'h0008000;

reg signed [17:0] HB1D[9:0];//HB1 Delay Registers
reg signed [47:0] HB1R[8:0];//HB2 Sum Registers

//QI dont remember TODO
reg[24:0] HB2coff0 = {4'b0,21'h000180};
reg[24:0] HB2coff2 = {4'hF,21'h1FF7D0};
reg[24:0] HB2coff4 = {4'b0,21'h001B38};
reg[24:0] HB2coff6 = {4'hF,21'h1FB928};
reg[24:0] HB2coff8 = {4'b0,21'h00A188};
reg[24:0] HB2coff10 ={4'hF,21'h1E9110};
reg[24:0] HB2coff12 ={4'b0,21'h04FFb0};
reg[24:0] HB2coff13 ={4'b0,21'h080000};


reg signed [17:0] HB2D[25:0];//HB2 Delay Registers
reg signed [47:0] HB2R[14:0];//HB2 Sum Registers


//TODO COMBINATIONAL LOGIC

integer i;
//Halfband 1 Delay Registers
always @(posedge CICCLK or posedge RST) begin 
        if(rst) for(i = 0; i < 10; i = i + 1) HB1D[i] <= 0;
        else begin 
                for(i = 1; i< 10; i = i + 1) HB1D[i] <= HB1D[i-1];
                HB1D[0] <= {1'b0,x_in};//Q1.17
        end
end
 
//HalfBand 2 Delay Registers
always @(posedge HB1CLK or posedge RST) begin 
        if(rst) for(i = 0; i < 26; i = i + 1) HB2D[i] <= 0;                
        else begin
                for(i = 1; i < 26; i = i + 1) HB2D[i] <= D[i-1];
                HB2D[0] <= {{1{1'b0}},x_in};
        end
end




always @(posedge HB1CLK or posedge RST) begin 
        if(rst) HB1_OUT <= 0;
        else    HB1_OUT <= HB1R[6]>>16;
end


always @(posedge HB2CLK or posedge RST) begin 
        if(rst) HB2_OUT <= 0;
        else    HB2_OUT <= HB2R[14]>>18;
end

