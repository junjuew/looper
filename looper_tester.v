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
    input rst_n,
	 output reg GPIO_LED_0,
	 output     GPIO_LED_1
    );

	wire clk_10MHz, clk_100MHz_buf;
	reg [21:0] cnt;
	
	assign GPIO_LED_1 = 1'b1;
	
	always@(posedge clk_100MHz_buf, negedge rst_n) begin
	if(!rst_n) begin
		GPIO_LED_0 <= 1'b0;
		cnt <= 22'h0;
	end
	else begin
		cnt <= cnt+1;
		if(cnt[21] == 1) begin
			GPIO_LED_0 <= 1'b1;
		end
		else begin
			GPIO_LED_0 <= 1'b0;
		end
	end
	end
	
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
		.CLKIN_IBUFG_OUT(clk_100MHz_buf),
		.CLK0_OUT()
	);
	

endmodule
