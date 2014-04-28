/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// D-flipflop
`timescale 1ns/1ps
module dff (q, d, clk, rst_n);

    output         q;
    input          d;
    input          clk;
    input          rst_n;

    reg            state;

    assign q = state;

    always @(posedge clk, negedge rst_n) begin
      if(~rst_n)
			state <= 1'b0;
		else
			state <= d;
    end

endmodule
// DUMMY LINE FOR REV CONTROL :0:
