module MACBlock_valid (
	input clk,
	input rst, //for shits n giggles
	input signed [24:0] a,
	input signed [17:0] b,
	input signed [47:0] c,
	output signed [47:0] out,
	output valid
);

always @(posedge clk) begin
	if(rst) begin
	out <= 0;
	valid <= 0;
	end else begin

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

