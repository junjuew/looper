`default_nettype none
`timescale 1ns / 1ps   
module baud_tb();

   //hl_sel determine whether it's high byte or low byte
   //1: high. 0: low
   reg           clk, rst_n, enable, wrt, hl_sel, clr_tx_baud; //wrt is for reading in divisor constant.
   reg [7:0]     data; //data line for divisor constant
   
   wire     tx_baud_en; //the baud enable line for transmission
   wire     rx_baud_en; //for receiption (x16 times of transmission)
   

   initial forever #1 clk=~clk;

   baud DUT(/*autoinst*/
            // Outputs
            .tx_baud_en                 (tx_baud_en),
            .rx_baud_en                 (rx_baud_en),
            // Inputs
            .clk                        (clk),
            .rst_n                      (rst_n),
            .enable                     (enable),
            .wrt                        (wrt),
            .hl_sel                     (hl_sel),
            .clr_tx_baud                (clr_tx_baud),
            .data                       (data[7:0]));
   
   
   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, baud_tb);
        $monitor ("%g  tx_baud_en=%b, rx_baud_en=%b",$time,tx_baud_en, rx_baud_en);
        
        clk=1;
        rst_n=0;
        @(posedge clk) rst_n=1;
        enable=1;
        $display("==============start testing==========\n before load in any divisor value\noutput should all be 0");
        repeat (2) @(posedge clk);
        $display("==============test loading in high byte divisor==========");
        data=8'h01;
        hl_sel=1;
        wrt=1;
        @(posedge clk) wrt=0;
        $strobe("divisor value: %h, correct value: 0100", DUT.divisor);
        repeat(2) @(posedge clk);
        $display("==============test loading in low byte divisor==========");
        data=8'h10;
        hl_sel=0;
        wrt=1;
        @(posedge clk) wrt=0;
        $strobe("%g  divisor value: %h, correct value: 0110", $time, DUT.divisor);
        $strobe("rx_baud_en should goes up after 17 cyle");
        $strobe("tx_baud_en should goes up after 272 cyle");
        repeat(17) @(posedge clk);
        $strobe ("%g  17 cycle after",$time);
        repeat(255) @(posedge clk);
        $strobe ("%g  272 cycle after",$time);
        $strobe("============== basic function test finished ==========\n");
        repeat(10) @(posedge clk);
        $strobe("============== test changing divisor  ==========\n");
        data=8'h00;
        hl_sel=0;
        wrt=1;
        @(posedge clk) wrt=0;
        $strobe("%g  divisor value: %h, correct value: 0100",$time, DUT.divisor);
        repeat(500) @(posedge clk);
        $strobe("============== test clr_tx_baud  ==========\n");        
        clr_tx_baud=1;
        $strobe("%g  tx_baud_cntr: %h",$time, DUT.tx_baud_cntr);
        @(posedge clk);
        $strobe("%g  tx_baud_cntr: %h",$time, DUT.tx_baud_cntr);
        clr_tx_baud=0;
        @(posedge clk);
        $strobe("%g  tx_baud_cntr: %h",$time, DUT.tx_baud_cntr);
        repeat(10) @(posedge clk);
        $strobe("%g  tx_baud_cntr: %h",$time, DUT.tx_baud_cntr);        
        $finish;
     end
   
endmodule
