`timescale 100ns / 10ps

module ClockDivider #(parameter N=16)(
        input clk,
        input rst,
        output reg clkdiv
        );
        reg[$clog2(N):0] cnt;
        initial begin 
                cnt = 0;
                clkdiv = 0;
        end
        always @(posedge clk) begin 
                if(rst) begin 
                        cnt = 0;
                        clkdiv = 0;
                end
                cnt <= cnt + 1;
                if(cnt >= N-1) begin
                        cnt <= 0;
                        clkdiv <= ~clkdiv;
                end
        end
endmodule
