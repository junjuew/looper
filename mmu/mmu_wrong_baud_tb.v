`timescale 1ns / 1ps   
module mmu_wrong_baud_tb();

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [13:0]          addrb;                  // From DUT of mmu.v
   wire [63:0]          dinb;                   // From DUT of mmu.v
   wire                 enb;                    // From DUT of mmu.v
   wire                 txd;                    // From DUT of mmu.v
   wire                 web;                    // From DUT of mmu.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [1:0]            br_cfg;                 // To DUT of mmu.v
   reg                  clk;                    // To DUT of mmu.v
   reg [63:0]           doutb;                  // To DUT of mmu.v
   reg                  rst_n;                  // To DUT of mmu.v
   reg                  rxd;                    // To DUT of mmu.v
   // End of automatics

   reg [7:0]            spart_in_byte[7:0];
   integer              i,j;

   mmu DUT
     (/*AUTOINST*/
      // Outputs
      .txd                              (txd),
      .enb                              (enb),
      .web                              (web),
      .addrb                            (addrb[13:0]),
      .dinb                             (dinb[63:0]),
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .rxd                              (rxd),
      .br_cfg                           (br_cfg[1:0]),
      .doutb                            (doutb[63:0]));



   integer              baud[3:0];

   initial
     begin
        forever #0.5 clk=~clk;
     end

   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, mmu_wrong_baud_tb);
        $monitor ("%g  enb:%b, web:%b, addrb:%x, dinb:%x, doutb:%x, === tx_enable:%b,  tx_out_data: %x ",$time, enb,web,addrb, dinb, doutb, DUT.spart0.tx_enable, DUT.spart0.tx_data);
        
        clk=1;
        rst_n=0;
        rxd=1; 
        baud[0] = 64*16; // baud: 4800 -- transmission. the value specified in driver.v is for receiption
        baud[1] = 104166; // baud: 9600: 10^9 / 9600 = 104166
        baud[2] = 52083; // baud: 19200
        baud[3] = 26041; // baud: 38400       
        br_cfg = 2'b00; // test 4800 first

        
        @(posedge clk) rst_n=1;
        $display("%g ==============start testing==========", $time);
        $display("%g ==============baud rate: %d ==========", $time, baud[br_cfg]);

        
        @(posedge clk);
        $display("%g ============== start transmission ASCII 12345678  ==========", $time);
        for (i=0;i<8;i=i+1)
          begin
             spart_in_byte[i]= i+ 8'h31;
             $display("%g spart_in_byte[i]: %x", $time, spart_in_byte[i]);
          end

        /********* transmit all byte**************/
        @(posedge clk);
        for (j=0;j<8;j=j+1)
          begin
             $display("%g ============== start transmission ASCII %d %x  ==========", $time, j, spart_in_byte[j]);
             rxd=0;
             $strobe("%g  transmitting start %d",$time, rxd);
             repeat (baud[br_cfg]) @(posedge clk);
             
             for (i=0;i<8;i=i+1)
               begin
                  rxd=spart_in_byte[j][i];
                  $strobe("%g  transmitting rxd=%d",$time, rxd);
                  repeat (baud[br_cfg]) @(posedge clk);                     
               end
             rxd=1;
             $strobe("%g  transmitting rxd end =%d",$time, rxd);
             $strobe("%g finish transmission", $time);
             


             repeat(25*baud[br_cfg] + 1000) @(posedge clk);
          end


        
        /********* transmit final send cmd "s", echo back "s"**************/
        spart_in_byte[0] = 8'h73;
        j=0;
        $display("%g ============== start transmission cmd %x  ==========", $time, spart_in_byte[j]);
        rxd=0;
        $strobe("%g  transmitting start %d",$time, rxd);
        repeat (baud[br_cfg]) @(posedge clk);
        
        for (i=0;i<8;i=i+1)
          begin
             rxd=spart_in_byte[j][i];
             $strobe("%g  transmitting rxd=%d",$time, rxd);
             repeat (baud[br_cfg]) @(posedge clk);                     
          end
        rxd=1;
        $strobe("%g  transmitting rxd end =%d",$time, rxd);
        $strobe("%g finish transmission", $time);
        

        repeat(25*baud[br_cfg] + 1000) @(posedge clk);




        /********************** 2nd test ********************/
        @(posedge clk);
        $display("%g ============== start transmission ASCII 34567810  ==========", $time);
        spart_in_byte[0] = 3+8'h30;
        spart_in_byte[1] = 4+8'h30;        
        spart_in_byte[2] = 5+8'h30;
        spart_in_byte[3] = 6+8'h30;        
        spart_in_byte[4] = 7+8'h30;
        spart_in_byte[5] = 8+8'h30;        
        spart_in_byte[6] = 1+8'h30;
        spart_in_byte[7] = 0+8'h30;        
        for (i=0;i<8;i=i+1)
          begin
             $display("%g spart_in_byte[i]: %x", $time, spart_in_byte[i]);
          end

        /********* transmit all byte**************/
        @(posedge clk);
        for (j=0;j<8;j=j+1)
          begin
             $display("%g ============== start transmission ASCII %d %x  ==========", $time, j, spart_in_byte[j]);
             rxd=0;
             $strobe("%g  transmitting start %d",$time, rxd);
             repeat (baud[br_cfg]) @(posedge clk);
             
             for (i=0;i<8;i=i+1)
               begin
                  rxd=spart_in_byte[j][i];
                  $strobe("%g  transmitting rxd=%d",$time, rxd);
                  repeat (baud[br_cfg]) @(posedge clk);                     
               end
             rxd=1;
             $strobe("%g  transmitting rxd end =%d",$time, rxd);
             $strobe("%g finish transmission", $time);
             


             repeat(25*baud[br_cfg] + 1000) @(posedge clk);
          end


        
        /********* transmit final send cmd "s", echo back "s"**************/
        spart_in_byte[0] = 8'h73;
        j=0;
        $display("%g ============== start transmission cmd %x  ==========", $time, spart_in_byte[j]);
        rxd=0;
        $strobe("%g  transmitting start %d",$time, rxd);
        repeat (baud[br_cfg]) @(posedge clk);
        
        for (i=0;i<8;i=i+1)
          begin
             rxd=spart_in_byte[j][i];
             $strobe("%g  transmitting rxd=%d",$time, rxd);
             repeat (baud[br_cfg]) @(posedge clk);                     
          end
        rxd=1;
        $strobe("%g  transmitting rxd end =%d",$time, rxd);
        $strobe("%g finish transmission", $time);
        

        repeat(25*baud[br_cfg] + 1000) @(posedge clk);



/*               
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                        
        repeat (baud[br_cfg]) @(posedge clk);        
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);
        $strobe("%g finished transmission", $time);

        @(posedge DUT.spart0.tx_enable);
        $display("tx_out_data: %x, should be 0xaa - 0x30 =0x7a", DUT.spart0.tx_data);

        
        repeat(25*baud[br_cfg] + 1000) @(posedge clk);


        $display("%g ============== start transmission 0xb2 ==========", $time);        
        rxd=0;
        $strobe("%g  transmitting RX=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                        
        repeat (baud[br_cfg]) @(posedge clk);        
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=0;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        rxd=1;
        $strobe("%g  transmitting rxd=%d",$time, rxd);                
        repeat (baud[br_cfg]) @(posedge clk);
        $strobe("%g finished transmission, transmit back should be 0xb2-0x30=0x82", $time);

        repeat(32*baud[br_cfg] + 10000) @(posedge clk);
*/        
        $finish;
     end   
   
   
endmodule // UART_tx_tb

        
               
     
