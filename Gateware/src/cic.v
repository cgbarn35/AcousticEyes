`timescale 1ns / 1ps

module CICNR16 #(parameter N=3)( //16 bit output 
	input clk,
	input clkdiv,
	input rst,
	input x_in,
	output[15:0] y_out
);

reg [25:0] I [N-1:0];//Integrators
reg [25:0] C [N  :0];//Combs
reg [25:0] CD[N-1:0];//Comb Delays

//INTEGRATORS

wire [25:0] Itemp;
assign Itemp = I[0];//VISUALIZATION FOR GTKWAVE

always @(posedge clk or posedge rst)
begin
	if(rst) begin 
		I[0] <= 0;
	end else begin 
		I[0] <= I[0] + x_in;
	end
end

//COMBS

wire [25:0] Ctemp;
wire [25:0] CDtemp;
assign Ctemp = C[0];//VISUALIZATION FOR GTKWAVE
assign CDtemp = CD[0];//VISUALIZATION FOR GTKWAVE

always @(posedge clkdiv or posedge rst)
begin
        if(rst) begin
		C[0] <= 0;
		CD[0] <= 0;
	end else begin 
		C[0] <= I[N-1];
		CD[0]<= C[0];
		C[1] <= C[0] - CD[0];
	end
end

generate
	genvar i; 
	for(i = 1; i < N; i = i + 1) begin: integrator 
		wire [25:0] Itemp;
		assign Itemp = I[i];//VISUALIZATION FOR GTKWAVE
		always @(posedge clk or posedge rst) 
		begin 
		if(rst) begin
			I[i] <= 0;
		end else begin 
			I[i] <= I[i] + I[i-1];
		end
	end
end
	for(i = 1; i < N; i = i + 1) begin: comb //COMBS
		wire [25:0] Ctemp;
		wire [25:0] CDtemp;
		assign Ctemp = C[i];//VISUALIZATION FOR GTKWAVE
		assign CDtemp = CD[i];//VISUALIZATION FOR GTKWAVE
		always @(posedge clkdiv or posedge rst)
		begin
                if(rst) begin
			C[i] <= 0;
			CD[i] <= 0;
		end else begin 
			CD[i] <= C[i];
			C[i+1] <= C[i] - CD[i];
		end
	end
end
endgenerate

assign y_out = C[N][20:4];

endmodule
