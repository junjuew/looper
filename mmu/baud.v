`default_nettype none
`timescale 1ns / 1ps
  
//////////////////////////////////////////////////////////////////////////////////
// Company: UW-Madison
// Engineer: J.J.(Junjue) Wang, Pari Lingampally, Zheng Ling
// 
// Create Date: Feb 03   
// Design Name: SPART
// Module Name: baud
// Project Name: SPART
// Target Devices: FPGA Virtex 2 Pro
// Tool versions: Xilinx 10.1
// Description: 
// This block implements two counters, serving as two enable signals for transmission module and reception module. It also maintains a writable divisor to control the baud rate
//
// Dependencies:
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module baud(
   // Outputs
   tx_baud_en, rx_baud_en,clr_tx_baud,
   // Inputs
   clk, rst_n, enable, wrt, hl_sel, data
   );

   //hl_sel determine whether it's high byte or low byte
   //1: high. 0: low
   input wire           clk, rst_n, enable, wrt, hl_sel, clr_tx_baud; //wrt is for reading in divisor constant.
   input wire [7:0]     data; //data line for divisor constant
   
   output wire     tx_baud_en; //the baud enable line for transmission
   output wire     rx_baud_en; //for receiption (x16 times of transmission)
   reg [15:0]       divisor; //record the divisor

   reg [15:0]       rx_baud_cntr, tx_baud_cntr;
   wire             rx_baud_full,tx_baud_full;
   
   //load the divisor constant
   always @(posedge clk, negedge rst_n)
      if (!rst_n)
        divisor <= 0;
      else if (enable)
        begin
           if (wrt)
             begin
                if (hl_sel)
                  divisor[15:8] <= data[7:0];
                else
                  divisor[7:0] <= data[7:0];
             end
           else
             divisor<=divisor;
        end // if (enable)
   
   
   ///////////////////////
   //rx baud gen
   //////////////////////
   assign rx_baud_full = (rx_baud_cntr == {divisor[15:0]})? 1'b1:1'b0;
   always @(posedge clk, negedge rst_n)
      if (!rst_n)
        rx_baud_cntr<= 16'h0001;
      else if (enable)
        if (wrt)
          rx_baud_cntr <=16'h0001;
        else
          if (rx_baud_full)
           rx_baud_cntr <=16'h0001; //the cycle that this is high should be the start 
          else
           rx_baud_cntr<=rx_baud_cntr +1;



   ///////////////////////
   //tx baud gen
   //////////////////////
   assign tx_baud_full = (tx_baud_cntr == {divisor[11:0],4'b0000})? 1'b1:1'b0;
   always @(posedge clk, negedge rst_n)
     if (!rst_n)
       tx_baud_cntr<= 16'h0001;
     else if (enable)
       if (wrt || clr_tx_baud)
         tx_baud_cntr <=16'h0001;
       else
         if (tx_baud_full)
           tx_baud_cntr <=16'h0001;
         else
           tx_baud_cntr<=tx_baud_cntr +1;


   //////////////////
   //output signal
   //////////////////
   assign tx_baud_en = (~enable) ? 1'b0:
                       (divisor == 16'h0) ? 1'b0: tx_baud_full;

   assign rx_baud_en = (~enable) ? 1'b0:
                       (divisor == 16'h0) ? 1'b0: rx_baud_full;
   
   
endmodule
