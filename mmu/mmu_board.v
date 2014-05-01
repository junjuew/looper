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

module mmu_board(/*autoarg*/
   // Outputs
   txd, state,
   // Inputs
   clk, rst_n, rxd, br_cfg, cpu_pc_MSB, mem_sys_fin
   );

   input wire       clk; // 100mhz clock
   input wire       rst_n; // Asynchronous reset, tied to dip switch 0
   output wire      txd; // RS232 Transmit Data
   input wire       rxd; // RS232 Recieve Data
   input wire [1:0] br_cfg; // Baud Rate Configuration, Tied to dip switches 2 and 3
   input wire       cpu_pc_MSB; //only the MSB of mimic PC
   input wire                  mem_sys_fin;            // To DUT of mmu.v
   output wire [3:0]           state;
   

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [13:0]          addrb;                  // From DUT of mmu.v
   wire [63:0]          dinb;                   // From DUT of mmu.v
   wire                 enb;                    // From DUT of mmu.v
   wire                 flsh;                   // From DUT of mmu.v
   wire                 web;                    // From DUT of mmu.v
   // End of automatics
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   wire [15:0]           cpu_pc;                 // To DUT of mmu.v
   wire [63:0]           doutb;                  // To DUT of mmu.v
   // End of automatics

   assign cpu_pc = {cpu_pc_MSB, 15'h0};
   
   mmu DUT(/*autoinst*/
           // Outputs
           .txd                         (txd),
           .state                       (state[3:0]),
           .enb                         (enb),
           .web                         (web),
           .addrb                       (addrb[13:0]),
           .dinb                        (dinb[63:0]),
           .flsh                        (flsh),
           // Inputs
           .clk                         (clk),
           .rst_n                       (rst_n),
           .rxd                         (rxd),
           .br_cfg                      (br_cfg[1:0]),
           .doutb                       (doutb[63:0]),
           .cpu_pc                      (cpu_pc[15:0]),
           .mem_sys_fin                 (mem_sys_fin));

   mem data_mem(
                .clka(clk),
                .wea(1'b0), // Bus [0 : 0] 
                .addra(3'h0), // Bus [2 : 0] 
                .dina(64'h0), // Bus [15 : 0] 
                .douta(), // Bus [15 : 0] 
                .clkb(clk),
                .web(web), // Bus [0 : 0] 
                .addrb(addrb), // Bus [2 : 0] 
                .dinb(dinb), // Bus [15 : 0] 
                .doutb(doutb)); // Bus [15 : 0] 
   
endmodule
