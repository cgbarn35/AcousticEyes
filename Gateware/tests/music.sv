`timescale 100ns / 10ps
`define HalfClockPeriod 1.6
 
module MusicTest;

parameter dataLength = 2000000;
initial begin
        //$dumpfile("music.vcd");
	//$dumpvars;
end

//INPUT
reg CLK;
reg RST;
reg [27:0] cnt;//TODO 
reg sftData;
//OUTPUT
wire CLKDIVC1;
wire CLKDIVH1;
wire CLKDIVH2;
wire [16:0] CIC_OUT;
wire [17:0] HB1_OUT;
wire [17:0] HB2_OUT;
wire [15:0] FIR_OUT;
//FILE CONTENTS
integer fd;
integer csv;
integer x;
genvar i;
reg [dataLength:0] testData;


ClockDivider #(8) C0 (//CIC FILTER CLOCK DIVIDER
        CLK,
        RST,
        CLKDIVC1
        );

 ClockDivider #(1) C1 (//HALFBAND 1 CLOCK DIVIDER
        CLKDIVC1,
        RST,
        CLKDIVH1
        );

 ClockDivider #(1) C2 (//HALFBAND 2 CLOCK DIVIDER
        CLKDIVH1,
        RST,
        CLKDIVH2
        );




CICNR16 #(4) uutC (
	.clk(CLK),
        .clkdiv(CLKDIVC1),
        .rst(RST),
        .x_in(sftData),
	.y_out(CIC_OUT)
        );

        HalfBand1 uutH1 ( //TODO CONVERT FROM NAIVE MULT BLOCK IMPLEMENTATION TO FSM CONTROL
                .clk(CLKDIVC1),
                .clkdiv(CLKDIVH1),
                .rst(RST),
                .x_in(CIC_OUT),
                .y_out(HB1_OUT)
                );
        HalfBand2 uutH2 (
                .clk(CLKDIVH1),
                .clkdiv(CLKDIVH2),
                .rst(RST),
                .x_in(HB1_OUT),
                .y_out(HB2_OUT)
                );

F_FIR F0(
        .clk(CLKDIVH2),
        .rst(RST),
        .x_in(HB2_OUT),
        .y_out(FIR_OUT)
        );



initial begin 
	fd = $fopen("./music.dat","rb");
	if(fd) $display("file opened successfully %0d",fd);
	else   $display("file not opened %0d",fd);
	$fread(testData,fd);
        $fclose(fd);
        csv = $fopen("./music.csv","w");
        if(csv) $display("file opened successfully %0d",csv);
        else   $display("file not opened %0d",csv);
end


always @(posedge CLKDIVH2) begin 
        //$display("%d,%d",$time,FIR_OUT);
        $fwrite(csv,"%d,%d\n",$time,FIR_OUT);
end

initial begin
        CLK = 0;
        RST = 0;
        cnt = 0;
        #10 
        RST = 1;
        #10
        RST = 0;
        #dataLength
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
                sftData <= 0;
        end
        else begin
                cnt <= cnt + 1;
                sftData <= testData[cnt];
        end
end
 
        endmodule

