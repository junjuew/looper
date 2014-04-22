/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// D-flipflop

module dff (q, d, clk, rst_n);

    output         q;
    input          d;
    input          clk;
    input          rst_n;

    reg            state;

    assign #(1) q = state;

    always @(posedge clk) begin
      state = rst_n? d : 0;
    end

endmodule
// DUMMY LINE FOR REV CONTROL :0:
