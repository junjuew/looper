`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UW-Madison
// Engineer: J.J.(Junjue) Wang, Pari Lingampally, Zheng Ling
// 
// Create Date: Feb 03   
// Design Name: SPART
// Module Name: top_level
// Project Name: SPART
// Target Devices: FPGA Virtex 2 Pro
// Tool versions: Xilinx 10.1
// Description: 
// The overall purpose of the SPART (Special Purpose Asynchronous Receiver/Transmitter) is to function as a serial I/O interface of communicating between the computer and the FPGA. 
//
// Dependencies: spart, driver
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module mmu(/*autoarg*/
   // Outputs
   txd, enb, web, addrb, dinb, flsh,state,
   // Inputs
   clk, rst_n, rxd, br_cfg, doutb, cpu_pc, mem_sys_fin
   );

   input wire       clk; // 100mhz clock
   input wire       rst_n; // Asynchronous reset, tied to dip switch 0
   output wire      txd; // RS232 Transmit Data
   input wire       rxd; // RS232 Recieve Data
   input wire [1:0] br_cfg; // Baud Rate Configuration, Tied to dip switches 2 and 3
        output wire [3:0] state;

   //interface with memory
   // output value for simple debug for right now
   // should conceal it in the final release
   output wire                               enb, web;
   output wire [13:0]                        addrb;
   output wire [63:0]                        dinb;
   output wire                               flsh;   
   input wire [63:0]                         doutb;
   input wire [15:0]                         cpu_pc;
   input wire                                mem_sys_fin;

   
   wire                                      iocs;
   wire                                      iorw;
   wire                                      rda;
   wire                                      tbr;
   wire [1:0]                                ioaddr;
   wire [7:0]                                databus;

   // Instantiate your SPART here
   spart spart0( .clk(clk),
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



   
   // Instantiate your driver here
   driver driver0(/*autoinst*/
                  // Outputs
                  .iocs                 (iocs),
                  .iorw                 (iorw),
                  .ioaddr               (ioaddr[1:0]),
                  .enb                  (enb),
                  .web                  (web),
                  .addrb                (addrb[13:0]),
                  .dinb                 (dinb[63:0]),
                  .flsh                 (flsh),
                  // Inouts
                  .databus              (databus[7:0]),
                  // Inputs
                  .clk                  (clk),
                  .rst_n                (rst_n),
                  .br_cfg               (br_cfg[1:0]),
                  .rda                  (rda),
                  .tbr                  (tbr),
                  .doutb                (doutb[63:0]),
                  .cpu_pc               (cpu_pc[15:0]),
                  .mem_sys_fin          (mem_sys_fin),
                                                .state (state));

   
endmodule
