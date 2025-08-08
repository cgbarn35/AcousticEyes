`timescale 1ns / 1ps


module FIR_COMB (
	input CICCLK,
	input MACCLK,
	input RST,
	input signed [16:0] x_in,
	output reg signed [15:0] y_out
);

wire HB1CLK;
wire OUTCLK;
reg wr_en;
reg rd_en;
reg [24:0] a_in;
reg [17:0] b_in;
reg [5:0] fifo_state_in;
reg [24:0] mac_a;
reg [17:0] mac_b;
reg [5:0] fifo_state_out;
reg full;
reg empty;
wire signed [47:0] mac_out;
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
        OUTCLK
        );
 
	//43 = 25 + 18 + 6 bit width
  sync_fifo #(.WIDTH(49),.DEPTH(64)) F0 (
	  .clk(MACCLK),
	  .rst(RST),
	  .wr_en(wr_en),
          .rd_en(rd_en),
          .d_in({a_in,b_in,fifo_state_in}),
          .d_out({mac_a,mac_b,fifo_state_out}),
	  .full(full),
	  .empty(empty)
  );

MACBlock m0 (mac_a,mac_b,48'h0,mac_out);
 
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

reg [5:0] MACD[5:0];

//State Machines
reg [2:0] FilterState;
reg [2:0] HB1State;
reg [3:0] HB2State;
reg [5:0] FIRState;

//HB1 State
always @(posedge CICCLK or posedge RST) begin
	if(RST) FilterState[0] <= 0;
        else FilterState[0] <= 1;
end
//HB2 State
always @(posedge HB1CLK or posedge RST) begin
	if(RST) FilterState[1] <= 0;
        else FilterState[1] <= 1;
end
//FIR State
always @(posedge OUTCLK or posedge RST) begin
	if(RST) FilterState[2] <= 0;
        else FilterState[2] <= 1;
end

//FIFO INPUT
always @(posedge MACCLK or posedge RST) begin
	if(RST) begin 
		wr_en <= 0;
		HB1State <= 0;
		HB2State <= 0;
                FIRState <= 0;
	end
	else begin
		casez(FilterState) 
		3'b??1: begin 
			wr_en <= 1;
			case(HB1State)
				3'h0: begin wr_en <= 1;
			  {a_in,b_in,fifo_state_in} <= {HB1coff0,{1'b0,x_in},6'h0}; HB1State <= 3'h1; end
			3'h1: begin {a_in,b_in,fifo_state_in} <= {HB1coff2,HB1D[1],6'h1}; HB1State <= 3'h2; end
			3'h2: begin {a_in,b_in,fifo_state_in} <= {HB1coff4,HB1D[3],6'h2}; HB1State <= 3'h3; end
			3'h3: begin {a_in,b_in,fifo_state_in} <= {HB1coff5,HB1D[4],6'h3}; HB1State <= 3'h4; end
			3'h4: begin {a_in,b_in,fifo_state_in} <= {HB1coff4,HB1D[5],6'h4}; HB1State <= 3'h5; end
			3'h5: begin {a_in,b_in,fifo_state_in} <= {HB1coff2,HB1D[7],6'h5}; HB1State <= 3'h6; end
			3'h6: begin {a_in,b_in,fifo_state_in} <= {HB1coff0,HB1D[9],6'h6}; 
			HB1State <= 3'h0;
			FilterState[0] <= 0; end
			endcase
		end
		3'b?10: begin wr_en <= 1; 
			case(HB2State)
			4'h0: begin wr_en <= 1;
			      {a_in,b_in,fifo_state_in} <= {HB2coff0,HB1_OUT,6'h07}; HB2State <= 4'h1; end
			4'h1: begin {a_in,b_in,fifo_state_in} <= {HB2coff2,HB2D[1],6'h08}; HB2State <= 4'h2; end
			4'h2: begin {a_in,b_in,fifo_state_in} <= {HB2coff4,HB2D[3],6'h09}; HB2State <= 4'h3; end
			4'h3: begin {a_in,b_in,fifo_state_in} <= {HB2coff6,HB2D[5],6'h0A}; HB2State <= 4'h4; end
			4'h4: begin {a_in,b_in,fifo_state_in} <= {HB2coff8,HB2D[7],6'h0B}; HB2State <= 4'h5; end
			4'h5: begin {a_in,b_in,fifo_state_in} <= {HB2coffA,HB2D[9],6'h0C}; HB2State <= 4'h6; end
			4'h6: begin {a_in,b_in,fifo_state_in} <= {HB2coffC,HB2D[11],6'h0D}; HB2State <= 4'h7; end
			4'h7: begin {a_in,b_in,fifo_state_in} <= {HB2coffD,HB2D[12],6'h0E}; HB2State <= 4'h8; end
			4'h8: begin {a_in,b_in,fifo_state_in} <= {HB2coffC,HB2D[13],6'h0F}; HB2State <= 4'h9; end
			4'h9: begin {a_in,b_in,fifo_state_in} <= {HB2coffA,HB2D[15],6'h10}; HB2State <= 4'hA; end
			4'hA: begin {a_in,b_in,fifo_state_in} <= {HB2coff8,HB2D[17],6'h11}; HB2State <= 4'hB; end
			4'hB: begin {a_in,b_in,fifo_state_in} <= {HB2coff6,HB2D[19],6'h12}; HB2State <= 4'hC; end
			4'hC: begin {a_in,b_in,fifo_state_in} <= {HB2coff4,HB2D[21],6'h13}; HB2State <= 4'hD; end
			4'hD: begin {a_in,b_in,fifo_state_in} <= {HB2coff2,HB2D[23],6'h14}; HB2State <= 4'hE; end
			4'hE: begin {a_in,b_in,fifo_state_in} <= {HB2coff0,HB2D[25],6'h15}; 
			HB2State <= 4'h0;
			FilterState[1] <= 0; end
			endcase
		end
		3'b1??: begin 
			wr_en <= 1;
			case(FIRState)
			6'h0 : begin wr_en <= 1;
			      	    {a_in,b_in,fifo_state_in} <= {FIRcoff0,HB2_OUT,6'h16}; FIRState <= 6'h1; end
			6'h1: begin {a_in,b_in,fifo_state_in} <= {FIRcoff1,FIRD[0],6'h17}; FIRState <= 6'h2; end
			6'h2: begin {a_in,b_in,fifo_state_in} <= {FIRcoff2,FIRD[1],6'h18}; FIRState <= 6'h3; end
			6'h3: begin {a_in,b_in,fifo_state_in} <= {FIRcoff3,FIRD[1],6'h19}; FIRState <= 6'h4; end
			6'h4: begin {a_in,b_in,fifo_state_in} <= {FIRcoff4,FIRD[1],6'h1A}; FIRState <= 6'h5; end
			6'h5: begin {a_in,b_in,fifo_state_in} <= {FIRcoff5,FIRD[1],6'h1B}; FIRState <= 6'h6; end
			6'h6: begin {a_in,b_in,fifo_state_in} <= {FIRcoff6,FIRD[1],6'h1C}; FIRState <= 6'h7; end
			6'h7: begin {a_in,b_in,fifo_state_in} <= {FIRcoff7,FIRD[1],6'h1D}; FIRState <= 6'h8; end
			6'h8: begin {a_in,b_in,fifo_state_in} <= {FIRcoff8,FIRD[1],6'h1E}; FIRState <= 6'h9; end
			6'h9: begin {a_in,b_in,fifo_state_in} <= {FIRcoff9,FIRD[1],6'h1F}; FIRState <= 6'hA; end
			6'hA: begin {a_in,b_in,fifo_state_in} <= {FIRcoffA,FIRD[1],6'h20}; FIRState <= 6'hB; end
			6'hB: begin {a_in,b_in,fifo_state_in} <= {FIRcoffB,FIRD[1],6'h21}; FIRState <= 6'hC; end
			6'hC: begin {a_in,b_in,fifo_state_in} <= {FIRcoffC,FIRD[1],6'h22}; FIRState <= 6'hD; end
			6'hD: begin {a_in,b_in,fifo_state_in} <= {FIRcoffD,FIRD[1],6'h23}; FIRState <= 6'hE; end
			6'hE: begin {a_in,b_in,fifo_state_in} <= {FIRcoffE,FIRD[1],6'h24}; FIRState <= 6'hF; end
			6'hF: begin {a_in,b_in,fifo_state_in} <= {FIRcoffF,FIRD[1],6'h25}; FIRState <= 6'h10; end
			6'h10:begin {a_in,b_in,fifo_state_in} <= {FIRcoffG,FIRD[1],6'h26}; FIRState <= 6'h11; end
			6'h11:begin {a_in,b_in,fifo_state_in} <= {FIRcoffH,FIRD[1],6'h27}; FIRState <= 6'h12; end
			6'h12:begin {a_in,b_in,fifo_state_in} <= {FIRcoffG,FIRD[1],6'h28}; FIRState <= 6'h13; end
			6'h13:begin {a_in,b_in,fifo_state_in} <= {FIRcoffF,FIRD[1],6'h29}; FIRState <= 6'h14; end
			6'h14:begin {a_in,b_in,fifo_state_in} <= {FIRcoffE,FIRD[1],6'h2A}; FIRState <= 6'h15; end
			6'h15:begin {a_in,b_in,fifo_state_in} <= {FIRcoffD,FIRD[1],6'h2B}; FIRState <= 6'h16; end
			6'h16:begin {a_in,b_in,fifo_state_in} <= {FIRcoffC,FIRD[1],6'h2C}; FIRState <= 6'h17; end
			6'h17:begin {a_in,b_in,fifo_state_in} <= {FIRcoffB,FIRD[1],6'h2D}; FIRState <= 6'h18; end
			6'h18:begin {a_in,b_in,fifo_state_in} <= {FIRcoffA,FIRD[1],6'h2E}; FIRState <= 6'h19; end
			6'h19:begin {a_in,b_in,fifo_state_in} <= {FIRcoff9,FIRD[1],6'h2F}; FIRState <= 6'h1A; end
			6'h1A:begin {a_in,b_in,fifo_state_in} <= {FIRcoff8,FIRD[1],6'h30}; FIRState <= 6'h1B; end
			6'h1B:begin {a_in,b_in,fifo_state_in} <= {FIRcoff7,FIRD[1],6'h31}; FIRState <= 6'h1C; end
			6'h1C:begin {a_in,b_in,fifo_state_in} <= {FIRcoff6,FIRD[1],6'h32}; FIRState <= 6'h1D; end
			6'h1D:begin {a_in,b_in,fifo_state_in} <= {FIRcoff5,FIRD[1],6'h33}; FIRState <= 6'h1E; end
			6'h1E:begin {a_in,b_in,fifo_state_in} <= {FIRcoff4,FIRD[1],6'h34}; FIRState <= 6'h1F; end
			6'h1F:begin {a_in,b_in,fifo_state_in} <= {FIRcoff3,FIRD[1],6'h35}; FIRState <= 6'h20; end
			6'h20:begin {a_in,b_in,fifo_state_in} <= {FIRcoff2,FIRD[1],6'h36}; FIRState <= 6'h21; end
			6'h21:begin {a_in,b_in,fifo_state_in} <= {FIRcoff1,FIRD[1],6'h37}; FIRState <= 6'h22; end
			6'h22:begin {a_in,b_in,fifo_state_in} <= {FIRcoff0,FIRD[1],6'h38}; 
			FIRState <= 6'h0;
			FilterState[2] <= 0; end
			endcase
		end
		3'b000: begin wr_en <= 0; end
		endcase
	end
end

//FIFO OUTPUT
always @(posedge MACCLK or posedge RST) begin
	if(RST) begin
		rd_en <= 0;
	end
	else begin 
		if(!empty) begin rd_en <= 1;
			//{mac_a,mac_b,fifo_state_out} <= fifo_out;
		end
		else rd_en <= 0;
	end
end

//MAC State Machine
always @(posedge MACCLK or posedge RST) begin
	if(RST) begin 
		for(i = 0; i < 7; i = i + 1) HB1R[i] <= 0;
		for(i = 0; i < 15; i = i + 1) HB2R[i] <= 0;
		for(i = 0; i < 35; i = i + 1) FIRR[i] <= 0;
	end
	else begin 
		case(fifo_state_out)//TODO DET MACD
			//
			6'h0: begin HB1R[0] <= mac_out; end
			6'h1: begin HB1R[1] <= mac_out; end
			6'h2: begin HB1R[2] <= mac_out; end
			6'h3: begin HB1R[3] <= mac_out; end
			6'h4: begin HB1R[4] <= mac_out; end
			6'h5: begin HB1R[5] <= mac_out; end
			6'h6: begin HB1R[6] <= mac_out; end

			6'h07: begin HB2R[0] <= mac_out; end
			6'h08: begin HB2R[1] <= mac_out; end
			6'h09: begin HB2R[2] <= mac_out; end
			6'h0A: begin HB2R[3] <= mac_out; end
			6'h0B: begin HB2R[4] <= mac_out; end
			6'h0C: begin HB2R[5] <= mac_out; end
			6'h0D: begin HB2R[6] <= mac_out; end
			6'h0E: begin HB2R[7] <= mac_out; end
			6'h0F: begin HB2R[8] <= mac_out; end
			6'h10: begin HB2R[9] <= mac_out; end
			6'h11: begin HB2R[10] <= mac_out; end
			6'h12: begin HB2R[11] <= mac_out; end
			6'h13: begin HB2R[12] <= mac_out; end
			6'h14: begin HB2R[13] <= mac_out; end
			6'h15: begin HB2R[14] <= mac_out; end

			6'h16: begin FIRR[0] <= mac_out; end
			6'h17: begin FIRR[1] <= mac_out; end
			6'h18: begin FIRR[2] <= mac_out; end
			6'h19: begin FIRR[3] <= mac_out; end
			6'h1A: begin FIRR[4] <= mac_out; end
			6'h1B: begin FIRR[5] <= mac_out; end
			6'h1C: begin FIRR[6] <= mac_out; end
			6'h1D: begin FIRR[7] <= mac_out; end
			6'h1E: begin FIRR[8] <= mac_out; end
			6'h1F: begin FIRR[9] <= mac_out; end
			6'h20: begin FIRR[10] <= mac_out; end
			6'h21: begin FIRR[11] <= mac_out; end
			6'h22: begin FIRR[12] <= mac_out; end
			6'h23: begin FIRR[13] <= mac_out; end
			6'h24: begin FIRR[14] <= mac_out; end
			6'h25: begin FIRR[15] <= mac_out; end
			6'h26: begin FIRR[16] <= mac_out; end
			6'h27: begin FIRR[17] <= mac_out; end
			6'h28: begin FIRR[18] <= mac_out; end
			6'h29: begin FIRR[19] <= mac_out; end
			6'h2A: begin FIRR[20] <= mac_out; end
			6'h2B: begin FIRR[21] <= mac_out; end
			6'h2C: begin FIRR[22] <= mac_out; end
			6'h2D: begin FIRR[23] <= mac_out; end
			6'h2E: begin FIRR[24] <= mac_out; end
			6'h2F: begin FIRR[25] <= mac_out; end
			6'h30: begin FIRR[26] <= mac_out; end
			6'h31: begin FIRR[27] <= mac_out; end
			6'h32: begin FIRR[28] <= mac_out; end
			6'h33: begin FIRR[29] <= mac_out; end
			6'h34: begin FIRR[30] <= mac_out; end
			6'h35: begin FIRR[31] <= mac_out; end
			6'h36: begin FIRR[32] <= mac_out; end
			6'h37: begin FIRR[33] <= mac_out; end
			6'h38: begin FIRR[34] <= mac_out; end
		endcase
	end
end






integer i;

//MAC OUT Delay Registers
always @(posedge MACCLK or posedge RST) begin 
        if(RST) for(i = 0; i < 6; i = i + 1) MACD[i] <= 0;
        else begin
                for(i = 1; i < 6; i = i + 1) MACD[i] <= MACD[i-1];
                MACD[0] <= fifo_state_out;
        end
end

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
always @(posedge OUTCLK or posedge RST) begin 
        if(RST) for(i = 0; i < 34; i = i + 1) FIRD[i] <= 0;
        else begin
                for(i = 1; i < 34; i = i + 1) FIRD[i] <= FIRD[i-1];
                FIRD[0] <= x_in;
        end
end

//Halfband 1 Output 
always @(posedge HB1CLK or posedge RST) begin 
        if(RST) HB1_OUT <= 0;
        else    HB1_OUT <= (HB1R[0]+HB1R[1]+HB1R[2]+HB1R[3]+HB1R[4]+HB1R[5]+HB1R[6])>>16;
end

//Halfband 2 Output
always @(posedge OUTCLK or posedge RST) begin 
        if(RST) HB2_OUT <= 0;
        else    HB2_OUT <= (
		HB2R[0] + HB2R[1] + HB2R[2] + HB2R[3] + HB2R[4] + HB2R[5] +
		HB2R[6] + HB2R[7] + HB2R[8] + HB2R[9] + HB2R[10] + HB2R[11] +
		HB2R[12] + HB2R[13] + HB2R[14])>>17;
end

//FIR Output
always @(posedge OUTCLK or posedge RST) begin 
        if(RST) y_out <= 0;
        else    y_out <= (
		FIRR[0] + FIRR[1] + FIRR[2] + FIRR[3] + FIRR[4] + FIRR[5] + FIRR[6] + 
		FIRR[7] + FIRR[8] + FIRR[9] + FIRR[10] + FIRR[11] + FIRR[12] + FIRR[13] + 
		FIRR[14] + FIRR[15] + FIRR[16] + FIRR[17] + FIRR[18] + FIRR[19] + FIRR[20] + 
		FIRR[21] + FIRR[22] + FIRR[23] + FIRR[24] + FIRR[25] + FIRR[26] + FIRR[27] + 
		FIRR[28] + FIRR[29] + FIRR[30] + FIRR[31] + FIRR[33] + FIRR[34] + FIRR[34])>>17;
end

endmodule
