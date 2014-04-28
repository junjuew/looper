`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:49:32 04/27/2014 
// Design Name: 
// Module Name:    looper_tester 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module looper_tester(
    input clk_100MHz,
    input rst_n
    );

	wire clk_10MHz;
	
	top_module_looper looper_DUT(
		.clk(clk_10MHz),
		.rst_n(rst_n),
		.extern_pc(15'b0),
		.extern_pc_en(1'b0)
	);
	
	clock_gen c0(
		.CLKIN_IN(clk_100MHz),
		.RST_IN(~rst_n),
		.CLKDV_OUT(clk_10MHz),
		.CLKIN_IBUFG_OUT(),
		.CLK0_OUT()
	);
	

endmodule
