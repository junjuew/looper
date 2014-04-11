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

module rf_enable ( q, d, wrt_en, clk, rst);

	input          d;
	input		   wrt_en;
    input          clk;
    input          rst;

    output         q;

    wire           w1;

    dff    a (.q(q), .d(w1), .clk(clk), .rst(rst));

    assign w1 = wrt_en? d : q;


endmodule



