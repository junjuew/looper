//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:	05/04/2014
// Design Name: pipeline register
// Module Name: rf_enable
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: This is a general pipeline register with enble signal
//
// Revision 1.0 - initial version
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module rf_en_flsh ( q, d, wrt_en, flush, clk, rst_n);

	input          d;
	input		   wrt_en;
    input          clk;
    input          rst_n;
	input          flush;

    output         q;

    wire           w1;
    wire           w1_f;

	assign w1_f = (flush) ? 0 : w1;

    dff    a (.q(q), .d(w1_f), .clk(clk), .rst_n(rst_n));

    assign w1 = wrt_en? d : q;


endmodule



