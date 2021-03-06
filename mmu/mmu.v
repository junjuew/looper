//`default_nettype none
`timescale 1ns / 1ps
  //////////////////////////////////////////////////////////////////////////////////
// company: uw-madison
  // engineer: j.j.(junjue) wang, pari lingampally, zheng ling
  // 
  // create date: feb 03   
  // design name: spart
  // module name: top_level
  // project name: spart
  // target devices: fpga virtex 2 pro
  // tool versions: xilinx 10.1
  // description: 
  // the overall purpose of the spart (special purpose asynchronous receiver/transmitter) is to function as a serial i/o interface of communicating between the computer and the fpga. 
  //
  // dependencies: spart, driver
  //
  // revision: 
  // revision 0.01 - file created
  // additional comments: 
  //
  //////////////////////////////////////////////////////////////////////////////////

  module mmu(/*autoarg*/
   // Outputs
   txd, state, enb, web, addrb, dinb, flsh, d, blank, hsync, vsync,
   dvi_clk, dvi_clk_n, dvi_rst, gpio_led_0, gpio_led_1, gpio_led_2,
   gpio_led_4, gpio_led_7, scl, sda,
   // Inputs
   clk_100mhz, clk_25mhz, rst_n, rxd, br_cfg, doutb, cpu_pc,
   mem_sys_fin, locked_dcm
   );

   input wire       clk_100mhz; // 100mhz clock
   input wire       clk_25mhz; // 100mhz clock   
   input wire       rst_n; // asynchronous reset, tied to dip switch 0
   output wire      txd; // rs232 transmit data
   input wire       rxd; // rs232 recieve data
   input wire [1:0] br_cfg; // baud rate configuration, tied to dip switches 2 and 3
   output wire [3:0] state;

   //interface with memory
   // output value for simple debug for right now
   // should conceal it in the final release
   output wire       enb, web;
   output wire [13:0] addrb;
   output wire [63:0] dinb;
   output wire        flsh;   
   input wire [63:0]  doutb;
   input wire [15:0]  cpu_pc;
   input wire         mem_sys_fin;
	input wire locked_dcm;


   //dvi ouput
   output wire [11:0] d          ;
   output wire        blank      ;
   output wire        hsync      ;
   output wire        vsync      ;
   output wire        dvi_clk        ;
   output wire        dvi_clk_n      ;
   output wire        dvi_rst    ;
   output wire        gpio_led_0 ;
   output wire        gpio_led_1 ;
   output wire        gpio_led_2 ;
   output wire        gpio_led_4 ;
   output wire        gpio_led_7 ;
   // inouts
   output wire         scl               ;
   output wire         sda   ;
   
   
   
   
   wire               iocs;
   wire               iorw;
   wire               rda;
   wire               tbr;
   wire [1:0]         ioaddr;
   wire [7:0]         databus;

   // instantiate your spart here
   spart spart0( .clk(clk_100mhz),
                 .rst_n(rst_n),
                 .iocs(iocs),
                 .iorw(iorw),
                 .rda(rda),
                 .tbr(tbr),
                 .ioaddr(ioaddr),
                 .databus(databus),
                 .txd(txd),
                 .rxd(rxd)
                 );


   wire [23:0]        rom_out;
   wire [12:0]        display_plane_addr;
   wire               dis_dvi_out;
   
   // instantiate your driver here
   driver driver0(
                  // Outputs
                  .iocs                 (iocs),
                  .iorw                 (iorw),
                  .ioaddr               (ioaddr[1:0]),
                  .enb                  (enb),
                  .web                  (web),
                  .addrb                (addrb[13:0]),
                  .dinb                 (dinb[63:0]),
                  .flsh                 (flsh),
                  .rom_out              (rom_out[23:0]),
                  .dis_dvi_out          (dis_dvi_out),
                  .state                (state[3:0]),
                  // Inouts
                  .databus              (databus[7:0]),
                  // Inputs
                  .clk                  (clk_100mhz),
                  .rst_n                (rst_n),
                  .br_cfg               (br_cfg[1:0]),
                  .rda                  (rda),
                  .tbr                  (tbr),
                  .doutb                (doutb[63:0]),
                  .cpu_pc               (cpu_pc[15:0]),
                  .mem_sys_fin          (mem_sys_fin),
                  .display_plane_addr   (display_plane_addr[12:0]));



   dvi dvi0(
            // outputs
            .d                          (d[11:0]),
            .blank                      (blank),
            .hsync                      (hsync),
            .vsync                      (vsync),
            .dvi_clk                    (dvi_clk),
            .dvi_clk_n                  (dvi_clk_n),
            .dvi_rst                    (dvi_rst),
            .gpio_led_0                 (gpio_led_0),
            .gpio_led_1                 (gpio_led_1),
            .gpio_led_2                 (gpio_led_2),
            .gpio_led_4                 (gpio_led_4),
            .gpio_led_7                 (gpio_led_7),
            .display_plane_addr         (display_plane_addr[12:0]),
            // inouts
            .scl                    (scl),
            .sda                    (sda),
            // inputs
            .clk_100mhz                 (clk_100mhz),
            .clk_25mhz                 (clk_25mhz),   
				.locked_dcm 	(locked_dcm),
            // rst or disabled
            .rst                        (~rst_n || dis_dvi_out),
            .rom_out                    (rom_out[23:0]));
   
   
   
endmodule
