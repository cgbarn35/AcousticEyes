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
reg [16:0] CIC_OUT;
reg [17:0] HB1_OUT;
reg [17:0] HB2_OUT;
reg [15:0] FIR_OUT;

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
 
//Q8.17
reg signed [24:0] HB1coff0 = 25'h0000413;
reg signed [24:0] HB1coff2 = 25'h1FFE42B;
reg signed [24:0] HB1coff4 = 25'h00097C7;
reg signed [24:0] HB1coff5 = 25'h0010000;

reg signed [24:0] HB2coff0 = 25'h0000030;
reg signed [24:0] HB2coff2 = 25'h1FFFEFA;
reg signed [24:0] HB2coff4 = 25'h0000367;
reg signed [24:0] HB2coff6 = 25'h1FFF725;
reg signed [24:0] HB2coff8 = 25'h0001431;
reg signed [24:0] HB2coffA = 25'h1FFD222;
reg signed [24:0] HB2coffC = 25'h0009FF6;
reg signed [24:0] HB2coffD = 25'h0010000;

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

reg signed [17:0] HB1D[9:0];//HB1 Delay Registers
reg signed [47:0] HB1R[8:0];//HB2 Sum Registers

reg signed [17:0] HB2D[25:0];//HB2 Delay Registers
reg signed [47:0] HB2R[14:0];//HB2 Sum Registers

reg signed [17:0] FIRD[33:0];//FIR Delay Registers
reg signed [47:0] FIRR[34:0];//FIR Sum Registers

//TODO SEQUENTIAL LOGIC


integer i;
//Halfband 1 Delay Registers
always @(posedge CICCLK or posedge RST) begin 
        if(RST) for(i = 0; i < 10; i = i + 1) HB1D[i] <= 0;
        else begin 
                for(i = 1; i< 10; i = i + 1) HB1D[i] <= HB1D[i-1];
                HB1D[0] <= {1'b0,x_in};//Q1.17
        end
end
 
//HalfBand 2 Delay Registers
always @(posedge HB1CLK or posedge RST) begin 
        if(RST) for(i = 0; i < 26; i = i + 1) HB2D[i] <= 0;                
        else begin
                for(i = 1; i < 26; i = i + 1) HB2D[i] <= HB2D[i-1];
                HB2D[0] <= x_in;
        end
end

//FIR Delay Registers
always @(posedge HB2CLK or posedge RST) begin 
        if(RST) for(i = 0; i < 34; i = i + 1) FIRD[i] <= 0;
        else begin
                for(i = 1; i < 34; i = i + 1) FIRD[i] <= FIRD[i-1];
                FIRD[0] <= x_in;
        end
end

always @(posedge HB1CLK or posedge RST) begin 
        if(RST) HB1_OUT <= 0;
        else    HB1_OUT <= HB1R[6]>>16;
end

always @(posedge HB2CLK or posedge RST) begin 
        if(RST) HB2_OUT <= 0;
        else    HB2_OUT <= HB2R[14]>>17;
end

always @(posedge FIRCLK or posedge RST) begin 
        if(RST) y_out <= 0;
        else    y_out <= FIRR[34]>>18;
end


endmodule
