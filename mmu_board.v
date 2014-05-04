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

module mmu_board(/*autoarg*/
   // Outputs
   txd, state, d, blank, hsync, vsync, dvi_clk, dvi_clk_n, dvi_rst,
   // Inouts
   scl_tri, sda_tri,
   // Inputs
   clk, rst_n, rxd, br_cfg, cpu_pc_msb, mem_sys_fin
   );

   input wire       clk; // 100mhz clock
   input wire       rst_n; // asynchronous reset, tied to dip switch 0
   output wire      txd; // rs232 transmit data
   input wire       rxd; // rs232 recieve data
   input wire [1:0] br_cfg; // baud rate configuration, tied to dip switches 2 and 3
   input wire       cpu_pc_msb; //only the msb of mimic pc
   input wire                  mem_sys_fin;            // to dut of mmu.v
   output wire [3:0]           state;
   
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

   
   // beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [13:0]          addrb;                  // from dut of mmu.v
   wire [63:0]          dinb;                   // from dut of mmu.v
   wire                 enb;                    // from dut of mmu.v
   wire                 flsh;                   // from dut of mmu.v
   wire                 web;                    // from dut of mmu.v
        wire scl,sda;
   // end of automatics
   // beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   wire [15:0]           cpu_pc;                 // to dut of mmu.v
   wire [63:0]           doutb;                  // to dut of mmu.v
   // end of automatics

   assign cpu_pc = {cpu_pc_msb, 15'h0};
        
        wire clk_100mhz, clk_25mhz;
        wire               locked_dcm;
   wire               clkin_ibufg_out;
   
   mmu dut(/*autoinst*/
           // Outputs
           .txd                         (txd),
           .state                       (state[3:0]),
           .enb                         (enb),
           .web                         (web),
           .addrb                       (addrb[13:0]),
           .dinb                        (dinb[63:0]),
           .flsh                        (flsh),
           .d                           (d[11:0]),
           .blank                       (blank),
           .hsync                       (hsync),
           .vsync                       (vsync),
           .dvi_clk                     (dvi_clk),
           .dvi_clk_n                   (dvi_clk_n),
           .dvi_rst                     (dvi_rst),
           .scl                         (scl),
           .sda                         (sda),
           // Inputs
           .clk_100mhz                  (clk_100mhz),
           .clk_25mhz                   (clk_25mhz),
           .rst_n                       (rst_n),
           .rxd                         (rxd),
           .br_cfg                      (br_cfg[1:0]),
           .doutb                       (doutb[63:0]),
           .cpu_pc                      (cpu_pc[15:0]),
           .mem_sys_fin                 (mem_sys_fin),
           .locked_dcm                  (locked_dcm));


   clk_25mhz clk_25mhz1(clk, ~rst_n, clk_25mhz, clkin_ibufg_out, clk_100mhz, locked_dcm);   

   
   mem data_mem(
                .clka(clk_100mhz),
                .wea(1'b0), // bus [0 : 0] 
                .addra(13'h0), // bus [2 : 0] 
                .dina(64'h0), // bus [15 : 0] 
                .douta(), // bus [15 : 0] 
                .clkb(clk_100mhz),
                .web(web), // bus [0 : 0] 
                .addrb(addrb), // bus [2 : 0] 
                .dinb(dinb), // bus [15 : 0] 
                .doutb(doutb)); // bus [15 : 0] 

   //may need to make inout global
   assign sda_tri = (sda)? 1'bz: 1'b0;
   assign scl_tri = (scl)? 1'bz: 1'b0;
   
endmodule
