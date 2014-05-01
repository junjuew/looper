`timescale 1ns / 1ps   
module mmu_wrong_baud_board_tb();

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 enb;                    // From DUT of mmu.v
   wire                 txd;                    // From DUT of mmu.v
	wire [3:0] state;
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [1:0]            br_cfg;                 // To DUT of mmu.v
   reg                  clk;                    // To DUT of mmu.v
   reg            cpu_pc_MSB;                 // To DUT of mmu.v
   reg                  mem_sys_fin;            // To DUT of mmu.v
   reg                  rst_n;                  // To DUT of mmu.v
   reg                  rxd;                    // To DUT of mmu.v
   // End of automatics

   reg [7:0]            spart_in_byte[7:0];
   integer              i,j;

   mmu_board DUT
     (/*AUTOINST*/
	     // Outputs
		.txd(txd), .state(state),
   // Inputs
   .clk(clk), .rst_n(rst_n), .rxd(rxd), .br_cfg(br_cfg), .cpu_pc_MSB(cpu_pc_MSB), .mem_sys_fin(mem_sys_fin));


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
 //       $wlfdumpvars(0, mmu_wrong_baud_board_tb);
        $monitor ("%g  enb:%b, addrb:%x, dinb:%x, doutb:%x, wrt_mem_data:%x tx_enable:%b,  tx_out_data: %x driver_state:%x mem_out_buf:%x start_mem_addr:%x stop_mem_addr:%x cmd:%x trans_cnt:%x flsh:%b",
		  $time, DUT.DUT.enb,DUT.DUT.addrb, DUT.DUT.dinb, DUT.DUT.doutb, DUT.DUT.driver0.wrt_mem_data, DUT.DUT.spart0.tx_enable, DUT.DUT.spart0.tx_data, DUT.DUT.driver0.state, DUT.DUT.driver0.mem_out_buf, DUT.DUT.driver0.start_mem_addr, DUT.DUT.driver0.stop_mem_addr, DUT.DUT.driver0.cmd, DUT.DUT.driver0.trans_cnt, DUT.DUT.driver0.flsh);

//       $monitor ("%g  enb:%b, addrb:%x, dinb:%x, doutb:%x, wrt_mem_data:%x tx_enable:%b,  tx_out_data: %x driver_state:%x mem_out_buf:%x start_mem_addr:%x stop_mem_addr:%x cmd:%x trans_cnt:%x flsh:%b",
//		  $time, DUT.DUT.enb,DUT.DUT.addrb, DUT.DUT.dinb, DUT.DUT.doutb, DUT.DUT.driver0.wrt_mem_data, DUT.DUT.spart0.spart_tx0.load, DUT.DUT.spart0.spart_tx0.TransShiftReg, DUT.DUT.driver0.state, DUT.DUT.driver0.mem_out_buf, DUT.DUT.driver0.start_mem_addr, DUT.DUT.driver0.stop_mem_addr, DUT.DUT.driver0.cmd, DUT.DUT.driver0.trans_cnt, DUT.DUT.driver0.flsh);
  
 
        clk=1;
        rst_n=0;
        rxd=1; 
        baud[0] = 64*16; // baud: 4800 -- transmission. the value specified in driver.v is for receiption
        baud[1] = 104166; // baud: 9600: 10^9 / 9600 = 104166
        baud[2] = 52083; // baud: 19200
        baud[3] = 26041; // baud: 38400       
        br_cfg = 2'b00; // test 4800 first
        cpu_pc_MSB = 16'h0;
//        doutb= 64'ha1a2a3a4a5a6a7a8;
        mem_sys_fin=0;
        
        
        @(posedge clk) rst_n=1;
        $display("%g ==============start testing==========", $time);
        $display("%g ==============baud rate: %d ==========", $time, baud[br_cfg]);


        /************ test 1 work flow********/
        /**** set start transmission addr *****/
        @(posedge clk);
        $display("%g ============== start transmission start addr 0x4  ==========", $time);
        for (i=0;i<8;i=i+1)
          begin
             spart_in_byte[i]= 8'h30;
             $display("%g spart_in_byte[i]: %x", $time, spart_in_byte[i]);
          end
        spart_in_byte[7] = 8'h34;
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
        /********* transmit final send cmd "a", echo back "a"**************/
        spart_in_byte[0] = 8'h61;
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




        /******* set end transmission addr *********/
        @(posedge clk);
        $display("%g ============== start end transmission addr 0x05  ==========", $time);
        for (i=0;i<8;i=i+1)
          begin
             spart_in_byte[i]= 8'h30;
             $display("%g spart_in_byte[i]: %x", $time, spart_in_byte[i]);
          end
        spart_in_byte[7] = 8'h35;

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
        /********* transmit final send cmd "e", echo back "e"**************/
        spart_in_byte[0] = 8'h65;
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
        


        /******** start changing data memory for pc *******/
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


        //mimic cpu_pc changed its value        
        @(posedge clk);
        cpu_pc_MSB=1'b1;


        @(posedge clk);
        cpu_pc_MSB= 1'b0;


        @(posedge clk);
        $display("%g mem_sys_fin becomes 1", $time);
        mem_sys_fin = 1'b1;
        
        
        repeat (400000) @(posedge clk);
        
        $finish;
     end   
   
   
endmodule // UART_tx_tb

        
               
     
