`default_nettype none
`timescale 1ns / 1ps
  
module spart_rx_tb();

   ////////////baud///////////////////////
   //hl_sel determine whether it's high byte or low byte
   //1: high. 0: low
   reg           clk, rst_n, enable, wrt, hl_sel,clr_tx_baud; //wrt is for reading in divisor constant.
   reg [7:0]     data; //data line for divisor constant


   /////////////////////// receiver ////////////////
   reg           clr_rda;
   wire          tx_baud_en, rx_baud_en, baud_en, rda;
   wire [7:0]    rx_data;
   reg          RX;
   

   baud aux_baud(/*autoinst*/
                 // Outputs
                 .tx_baud_en            (tx_baud_en),
                 .rx_baud_en            (rx_baud_en),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .enable                (enable),
                 .wrt                   (wrt),
                 .hl_sel                (hl_sel),
                 .clr_tx_baud           (clr_tx_baud),
                 .data                  (data[7:0]));
   
   spart_rx DUT(/*autoinst*/
                // Outputs
                .rda                    (rda),
                .rx_data                (rx_data[7:0]),
                // Inputs
                .clk                    (clk),
                .rst_n                  (rst_n),
                .clr_rda                (clr_rda),
                .baud_en                (baud_en),
                .RX                     (RX));
   

   assign baud_en = rx_baud_en;


   initial
     begin
        forever #1 clk=~clk;
     end


   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, spart_rx_tb);
        $monitor ("%g  rx_data=%h, rda=%b",$time,rx_data, rda);
        clk=1;
        rst_n=0;
        clr_rda=0;
        @(posedge clk) rst_n=1;
        enable=1;
        $display("==============start testing==========");

        
        repeat (2) @(posedge clk);
        $strobe("==============load divisor 4 for rx==========");
        data=8'h40;
        hl_sel=0;
        wrt=1;
        @(posedge clk) wrt=0;
        $strobe("divisor value: %h, correct value: 0040", aux_baud.divisor);
        repeat(2) @(posedge clk);

        @(posedge clk);
        $display("%g   ==============start transmission on RX==========", $time);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);

        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        
        
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        $display("%g rda should go high", $time);
        $display("%g rx_data should output 0xaa", $time);
        
        @(posedge clk)
        $display("%g wait one cycle", $time);           
        if (rx_data != 16'haa)
          $display("%g wrong!!!! rx_data is %h, but should be 0xaa", $time, rx_data);
        else
          $display("%g correct!!!! rx_data is %h, should be", $time, rx_data);          
        repeat(80) @(posedge clk);
        $display("%g   ==============clear rda==========", $time);        
        clr_rda=1;
        @(posedge clk);
        clr_rda=0;

        
        @(posedge clk);        
        $display("%g   ==============start another transmission on RX==========", $time);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);
        
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=0;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        RX=1;
        $strobe("%g  transmitting RX=%d",$time, RX);                
        repeat (4*16) @(posedge clk);
        $display("%g rda should go high", $time);
        $display("%g rx_data should output 0x88", $time);
        
        @(posedge clk)
        $display("%g wait one cycle", $time);           
        if (rx_data != 16'h88)
          $display("%g wrong!!!! rx_data is %h, but should be 0x88", $time, rx_data);
        else
          $display("%g correct!!!! rx_data is %h, should be", $time, rx_data);          
        repeat(80) @(posedge clk);
        $finish;
     end   
   
   
endmodule // UART_tx_tb

        
               
     
