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
module looper_tester(/*autoarg*/
   // Outputs
   txd, state, d, blank, hsync, vsync, dvi_clk, dvi_clk_n, dvi_rst,
   GPIO_LED_4, GPIO_LED_5,GPIO_LED_6,
   // Inouts
   scl_tri, sda_tri,
   // Inputs
   clk_100mhz, rst_n, rxd, br_cfg
   );


   input wire       clk_100mhz; // 100mhz clock
   input wire       rst_n; // asynchronous reset, tied to dip switch 0
   output wire      txd; // rs232 transmit data
   input wire       rxd; // rs232 recieve data
   input wire [1:0] br_cfg; // baud rate configuration, tied to dip switches 2 and 3
   output wire [3:0] state;
   
   //dvi ouput
   output wire [11:0] d          ;
   output wire        blank      ;
   output wire        hsync      ;
   output wire        vsync      ;
   output wire        dvi_clk        ;
   output wire        dvi_clk_n      ;
   output wire        dvi_rst    ;
   // inouts
   inout wire         scl_tri               ;
   inout wire         sda_tri   ;
   
   output reg         GPIO_LED_4 ;
   output reg         GPIO_LED_5 ;
   output reg         GPIO_LED_6 ;
   
   wire               clk_100mhz_buf;
   wire               clk_25mhz,clk_10mhz;   
   reg [21:0]         cnt;
   

   //fetch to mmu
   wire[15:0]        cpu_pc;
   wire[63:0]        pc_to_dec;
   //concern about the first inst
   assign cpu_pc = pc_to_dec[63:48];
   //wb to mmu
   wire        mem_sys_fin; 


   always@(posedge clk_10mhz, negedge rst_n) begin
      if(!rst_n) begin
         GPIO_LED_4 <= 1'b0;
      end
      else begin
         if(cpu_pc[15:0] > 3) begin
            GPIO_LED_4 <= 1'b1;
         end
         else begin
            GPIO_LED_4 <= 1'b0;
         end
      end
   end

   always@(posedge clk_10mhz, negedge rst_n) begin
      if(!rst_n) begin
         GPIO_LED_5 <= 1'b0;
      end
      else begin
         if(cpu_pc[15:0] ==0 ) begin
            GPIO_LED_5 <= 1'b1;
         end
         else begin
            GPIO_LED_5 <= 1'b0;
         end
      end
   end

   always@(posedge clk_10mhz, negedge rst_n) begin
      if(!rst_n) begin
         GPIO_LED_6 <= 1'b0;
      end
      else begin
         if(cpu_pc[15:0] >0 ) begin
            GPIO_LED_6 <= 1'b1;
         end
         else begin
            GPIO_LED_6 <= 1'b0;
         end
      end
   end


   /*   
    top_module_looper looper_DUT(
    .clk(clk_10MHz),
    .rst_n(rst_n),
    .extern_pc(15'b0),
    .extern_pc_en(1'b0));*/


   wire[63:0] mmu_mem_doutb;
   
   wire       mmu_mem_clk;
   wire       mmu_mem_rst;
   wire       mmu_mem_enb;
   wire       mmu_mem_web;
   wire [13:0] mmu_mem_addrb;
   wire [63:0] mmu_mem_dinb;

   assign mmu_mem_clk = clk_10mhz;
   assign mmu_mem_rst = ~rst_n;


   
   
   top_module_looper looper_DUT(
                                // Outputs
                                .mmu_mem_doutb  (mmu_mem_doutb[63:0]),
                                .pc_to_dec (pc_to_dec),
                                .mem_sys_idle (mem_sys_fin),                                
                                // Inputs
                                .mmu_mem_clk    (mmu_mem_clk),
                                .mmu_mem_rst    (mmu_mem_rst),
                                .mmu_mem_enb    (mmu_mem_enb),
                                .mmu_mem_web    (mmu_mem_web),
                                .mmu_mem_addrb  (mmu_mem_addrb[13:0]),
                                .mmu_mem_dinb   (mmu_mem_dinb[63:0]),
                                .clk            (clk_10mhz),
                                .rst_n          (rst_n),
                                .flush_cache    (flsh),
                                .extern_pc      (16'b0),
                                .extern_pc_en   (1'b0));

   /*   
    clock_gen c0(
    .CLKIN_IN(clk_100MHz),
    .RST_IN(~rst_n),
    .CLKDV_OUT(clk_10MHz),
    .CLKIN_IBUFG_OUT(clk_100MHz_buf),
    .CLK0_OUT()
    );
    */
   
//   clk_gen clk_25mhz1(clk, ~rst_n, clk_25mhz, clkin_ibufg_out, clk_100mhz_buf, locked_dcm); 
        
	  clk_gen clk_10mhz1 (
    .CLKIN_IN(clk_100mhz), 
    .RST_IN(~rst_n), 
    .CLKDV_OUT(clk_10mhz), //right now use 10Mhz clk
    .CLKIN_IBUFG_OUT(clkin_ibufg_out), 
    .CLK0_OUT(clk_100mhz_buf), 
    .LOCKED_OUT(locked_dcm)
    );
/*
	  clk_gen_vga clk_25mhz1 (
    .CLKIN_IN(clk_100mhz), 
    .RST_IN(~rst_n), 
    .CLKDV_OUT(clk_25mhz), //for dvi
    .CLKIN_IBUFG_OUT(), 
    .CLK0_OUT(), 
    .LOCKED_OUT()
    );
*/



   mmu mmu1(
            // Outputs
            .txd                        (txd),
            .state                      (state[3:0]),
            .enb                        (mmu_mem_enb),
            .web                        (mmu_mem_web),
            .addrb                      (mmu_mem_addrb[13:0]),
            .dinb                       (mmu_mem_dinb[63:0]),
            .flsh                       (flsh),
            .d                          (d[11:0]),
            .blank                      (blank),
            .hsync                      (hsync),
            .vsync                      (vsync),
            .dvi_clk                    (dvi_clk),
            .dvi_clk_n                  (dvi_clk_n),
            .dvi_rst                    (dvi_rst),
            .scl                        (scl),
            .sda                        (sda),
            // Inputs
            .clk_100mhz                 (clk_10mhz),
            .clk_25mhz                  (clk_10mhz),//wrong, just for testing. should use 25mhz
            .rst_n                      (rst_n),
            .rxd                        (rxd),
            .br_cfg                     (br_cfg[1:0]),
            .doutb                      (mmu_mem_doutb[63:0]),
            .cpu_pc                     (cpu_pc[15:0]),
            .mem_sys_fin                (mem_sys_fin),
            .locked_dcm                 (locked_dcm));
   
   //may need to make inout global
   assign sda_tri = (sda)? 1'bz: 1'b0;
   assign scl_tri = (scl)? 1'bz: 1'b0;
   
	wire[35:0] control;
	
	chipscopeicon icon(.CONTROL0(control)) /* synthesis syn_noprune=1 */;
	chipscopeila ila(.CLK(clk_10mhz),.DATA({pc_to_dec}), .TRIG0(state[0]), .CONTROL(control) ) /* synthesis syn_noprune=1 */;

	
   
endmodule
