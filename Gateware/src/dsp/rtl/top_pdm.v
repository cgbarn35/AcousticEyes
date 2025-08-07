`timescale 100ns / 10ps


module top_pdm #(parameter N=96)(
	input wire [N-1:0] PDM, //
	input wire clk,
	input wire rst,
	output wire [15:0] PCM [N-1:0]
);

wire CLKDIVC1;
wire CLKDIVH1;
wire CLKDIVH2;
wire [16:0] CIC_OUT [N-1:0];
wire [17:0] HB1_OUT [N-1:0];
wire [17:0] HB2_OUT [N-1:0];

//Generator
genvar i;

//3.125MHz -> 195.3KHz
ClockDivider #(8) C0 (//CIC FILTER CLOCK DIVIDER
        clk,
        rst,
        CLKDIVC1
        );
//195.3KHz -> 97.656KHz
 ClockDivider #(1) C1 (//HALFBAND 1 CLOCK DIVIDER
        CLKDIVC1,
        rst,
        CLKDIVH1
        );
//97.656KHz -> 48.828Khz
 ClockDivider #(1) C2 (//HALFBAND 2 CLOCK DIVIDER
        CLKDIVH1,
        rst,
        CLKDIVH2
        );

generate
	for(i = 0; i < N; i = i + 1) begin: PDMtoPCM
	CICNR16 #(4) uutC (
		.clk(clk),
		.clk(CLKDIVC1),
		.rst(rst),
		.x_in(PDM[i]),
		.y_out(CIC_OUT[i])
		);
        HalfBand1 uutH1 ( 
                .clk(CLKDIVC1),
                .clkdiv(CLKDIVH1),
                .rst(RST),
                .x_in(CIC_OUT[i]),
                .y_out(HB1_OUT[i])
                );
        HalfBand2 uutH2 (
                .clk(CLKDIVH1),
                .clkdiv(CLKDIVH2),
                .rst(RST),
                .x_in(HB1_OUT[i]),
                .y_out(HB2_OUT[i])
                );
        F_FIR uutF(
                .clk(CLKDIVH2),
                .rst(RST),
                .x_in(HB2_OUT[i]),
                .y_out(FIR_OUT[i])
        	);
        end
endgenerate


