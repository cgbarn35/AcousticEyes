`timescale 1ns / 1ps

module CICNR16 #(parameter N=3)( //16 bit output 
	input clk,
	input clkdiv,
	input rst,
	input x_in,
	output reg[15:0] y_out
);

reg [25:0] I [N-1:0];//Integrators
reg [25:0] C [N  :0];//Combs
reg [25:0] CD[N-1:0];//Comb Delays

//INTEGRATORS
integer x;

wire [25:0] Itemp;
assign Itemp = I[N-1];//VISUALIZATION FOR GTKWAVE

always @(posedge clk or posedge rst)
begin
	if(rst) begin 
		for(x=0; x < N; x = x + 1) begin 
			I[x] <= 0;
		end 
	end
	else begin
		I[0] <= I[0] + {{15{1'b0}},x_in};
		for(x = 1; x < N; x = x + 1) begin 
			I[x] <= I[x] + I[x-1];
		end
	end
end

//COMBS

wire [25:0] Ctemp0,Ctemp1,Ctemp2,Ctemp3;
wire [25:0] CDtemp0,CDtemp1,CDtemp2;
assign CDtemp0 = CD[0];
assign CDtemp1 = CD[1];
assign CDtemp2 = CD[2];
assign Ctemp0 = C[0];
assign Ctemp1 = C[1];
assign Ctemp2 = C[2];
assign Ctemp3 = C[3];

always @(posedge clkdiv or posedge rst)
begin
	if(rst) begin 
		for(x=0; x < N; x = x + 1) begin 
			C[x] <= 0;
			CD[x] <= 0;
		end
	end
	else begin
		CD[0]<= I[N-1];
		C[0] <= I[N-1] - CD[0];
		CD[1]<= C[0];
		C[1] <= C[0] - CD[1];
		CD[2]<= C[1];
		C[2] <= C[1] - CD[2];
		CD[3]<= C[2];
		C[3] <= C[2] - CD[3];

		//for(x = 1; x < N; x = x + 1) begin 
		//	CD[x] = C[x];
		//	C[x+1] = C[x] - CD[x];
		//end
	end
end

initial begin 
	for(x=0; x < N; x = x + 1) begin 
		C[x] <= 0;
		CD[x] <= 0;
		I[x] <= 0;
	end
	C[N] <= 0;
end

assign y_out = C[3][16:1];

endmodule
