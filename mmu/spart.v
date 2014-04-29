`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UW-Madison
// Engineer: J.J.(Junjue) Wang, Pari Lingampally, Zheng Ling
// 
// Create Date: Feb 03   
// Design Name: SPART
// Module Name: spart
// Project Name: SPART
// Target Devices: FPGA Virtex 2 Pro
// Tool versions: Xilinx 10.1
// Description: 
// This block connects the individual components in the spart, including: the receiver, transmitter, baud generator and bus interface. 
//
// Dependencies: spart_tx, spart_rx,baud,spart_businterface
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input wire clk,
    input wire rst_n,
    input wire iocs,
    input wire iorw,
    output wire rda,
    output wire tbr,
    input wire [1:0] ioaddr,
    inout wire [7:0] databus,
    output wire txd,
    input wire rxd
    );


   wire   /*tx_done,*/tx_enable,clr_rda,tx_baud_en,rx_baud_en,baud_select,baud_write;
   wire [7:0] tx_data,rx_data,baud_high,baud_low,baud_data;
   
   
   spart_tx Tx (/*autoinst*/
                // Outputs
                .tx_out                 (txd),
                .tx_done                (tbr),
                // Inputs
                .in_data                (tx_data[7:0]),
                .clk                    (clk),
                .rst_n                  (rst_n),
                .trmt                   (tx_enable),
                .clr_tbr                (tx_enable),
                .baud_full              (tx_baud_en));

   spart_rx Rx (/*autoinst*/
                // Outputs
                .rda                    (rda),
                .rx_data                (rx_data[7:0]),
                // Inputs
                .clk                    (clk),
                .rst_n                  (rst_n),
                .clr_rda                (clr_rda),
                .baud_en                (rx_baud_en),
                .RX                     (rxd));

   baud baudGen (/*autoinst*/
                 // Outputs
                 .tx_baud_en            (tx_baud_en),
                 .rx_baud_en            (rx_baud_en),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .enable                (1'b1),
                 .wrt                   (baud_write),
                 .hl_sel                (baud_select),
                 .clr_tx_baud           (tx_enable),
                 .data                  (baud_data[7:0]));

   spart_businterface businterface(/*autoinst*/
                                   // Outputs
                                   .tx_enable           (tx_enable),
                                   .baud_write          (baud_write),
                                   .baud_select         (baud_select),
                                   .baud_high           (baud_high[7:0]),
                                   .baud_low            (baud_low[7:0]),
                                   .tx_data             (tx_data[7:0]),
                                   .clr_rda             (clr_rda),
                                   // Inouts
                                   .databus             (databus[7:0]),
                                   // Inputs
                                   .rx_data             (rx_data[7:0]),
                                   .IOCS                (iocs),
                                   .IORW                (iorw),
                                   .RDA                 (rda),
                                   .TBR                 (tbr),
                                   .IOADDR              (ioaddr[1:0]));
   
   assign baud_data = (baud_select) ? baud_high : baud_low;
   
   
endmodule
