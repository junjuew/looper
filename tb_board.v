`timescale 1ns / 10ps
module tb_board();
   
   /*autowire*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 GPIO_LED_1;             // From tester of looper_tester.v
   wire                 blank;                  // From tester of looper_tester.v
   wire [11:0]          d;                      // From tester of looper_tester.v
   wire                 dvi_clk;                // From tester of looper_tester.v
   wire                 dvi_clk_n;              // From tester of looper_tester.v
   wire                 dvi_rst;                // From tester of looper_tester.v
   wire                 hsync;                  // From tester of looper_tester.v
   wire                 scl_tri;                // To/From tester of looper_tester.v
   wire                 sda_tri;                // To/From tester of looper_tester.v
   wire [3:0]           state;                  // From tester of looper_tester.v
   wire                 txd;                    // From tester of looper_tester.v
   wire                 vsync;                  // From tester of looper_tester.v
   
   // End of automatics
   /*autoreginput*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [1:0]            br_cfg;                 // To tester of looper_tester.v
   reg                  clk_100mhz;             // To tester of looper_tester.v
   reg                  rst_n;                  // To tester of looper_tester.v
   reg                  rxd;                    // To tester of looper_tester.v
   // End of automatics
   looper_tester DUT(/*autoinst*/
                     // Outputs
                     .txd            (txd),
                     .state          (state[3:0]),
                     .d              (d[11:0]),
                     .blank          (blank),
                     .hsync          (hsync),
                     .vsync          (vsync),
                     .dvi_clk        (dvi_clk),
                     .dvi_clk_n      (dvi_clk_n),
                     .dvi_rst        (dvi_rst),
                     .GPIO_LED_1     (GPIO_LED_1),
                     // Inouts
                     .scl_tri        (scl_tri),
                     .sda_tri        (sda_tri),
                     // Inputs
                     .clk_100mhz     (clk_100mhz),
                     .rst_n          (rst_n),
                     .rxd            (rxd),
                     .br_cfg         (br_cfg[1:0]));
   


   initial begin
      forever #0.5 clk_100mhz = ~clk_100mhz;
   end

   initial begin
      rst_n = 1'b0;
      //100mhz
      clk_100mhz = 0;
      
      repeat(5) @(posedge clk_100mhz);
      rst_n = 1'b1;

//      $monitor("%g state:%x pc:%x flsh:%x mem_done_after_prg:%x", $time, state, DUT.cpu_pc, DUT.flsh, DUT.mmu1.driver0.mem_done_aft_prg);

      $monitor("%g state:%x flsh:%x mem_done_after_prg:%x", $time, state, DUT.flsh, DUT.mmu1.driver0.mem_done_aft_prg);


      $display(" ==================== test addd1_mmu =================");
      
      repeat(300) @(posedge clk_100mhz);
      //                DUT.mmu1.driver0.cmd[7:0]=8'h73;
      force DUT.mmu1.driver0.data_in = 8'h73;
      force DUT.mmu1.driver0.ld_cmd = 1'b1;
      DUT.mmu1.driver0.stored_spart_data[0][7:0] = 8'h0;
      DUT.mmu1.driver0.stored_spart_data[1][7:0] = 8'h0;
      DUT.mmu1.driver0.stored_spart_data[2][7:0] = 8'h0;
      DUT.mmu1.driver0.stored_spart_data[3][7:0] = 8'h0;
      DUT.mmu1.driver0.stored_spart_data[4][7:0] = 8'h0;
      DUT.mmu1.driver0.stored_spart_data[5][7:0] = 8'h0;
      DUT.mmu1.driver0.stored_spart_data[6][7:0] = 8'h0;
      DUT.mmu1.driver0.stored_spart_data[7][7:0] = 8'h4;

      @(posedge clk_100mhz);
      
      release DUT.mmu1.driver0.data_in;
      release DUT.mmu1.driver0.ld_cmd;

//      force DUT.mmu1.driver0.enb=1'b1;
 //     force DUT.mmu1.driver0.web=1'b0;

      @(posedge clk_100mhz);
//      release DUT.mmu1.driver0.web;
		
		@(posedge clk_100mhz);
//      release DUT.mmu1.driver0.enb;		
      $display("%g 0x3fff value:%x", $time, DUT.mmu1.driver0.doutb);

      
      $display("%g changed memory content", $time);
      //first bench mark is at memory addr 0x4
      //cmd will be auto cleared in driver
      //      DUT.mmu1.driver0.cmd[7:0]=8'h73;
      $display("%g wrt_mem_data: %x, cmd:%x. should be 0x4 and 0x73 ", $time, DUT.mmu1.driver0.wrt_mem_data, DUT.mmu1.driver0.cmd);
      $display("%g. state should go to CLR_MEM(1) as program begins to start", $time);

      //add1 store value from decimal 50, for physical memory, that is 50/4= 12
      DUT.mmu1.driver0.start_mem_addr = 14'd12;
      //stop 64/4 = 16  -- r1 -- r15
      DUT.mmu1.driver0.stop_mem_addr = 14'd16;
      $display("%g. mem start addr %x, should be decimal 12", $time,       DUT.mmu1.driver0.start_mem_addr);
      $display("%g. mem stop addr %x, should be decimal 16", $time,       DUT.mmu1.driver0.stop_mem_addr);

      //transfer 12
      @(state==4'h7);//trans_load
      $display("%g state:%x, should be 4'h7, mem addr:%x enb:%x web:%x", $time, state, DUT.mmu_mem_addrb, DUT.mmu_mem_enb, DUT.mmu_mem_web);
      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      

      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      
      force DUT.mmu1.driver0.enb=1'b1;
		force DUT.mmu1.driver0.addrb=14'd13;

      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      
      force DUT.mmu1.driver0.enb=1'b1;
		force DUT.mmu1.driver0.addrb=14'd14;
		
      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      
      force DUT.mmu1.driver0.enb=1'b1;
		force DUT.mmu1.driver0.addrb=14'd15;

      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      
      force DUT.mmu1.driver0.enb=1'b1;
		force DUT.mmu1.driver0.addrb=14'd16;

      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      
		release DUT.mmu1.driver0.addrb;
		release DUT.mmu1.driver0.enb;

      //transfer 13
      @(state==4'h7);//trans_load
      $display("%g state:%x, should be 4'h7, mem addr:%x enb:%x web:%x", $time, state, DUT.mmu_mem_addrb, DUT.mmu_mem_enb, DUT.mmu_mem_web);
      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      

      //transfer 14
      @(state==4'h7);//trans_load
      $display("%g state:%x, should be 4'h7, mem addr:%x enb:%x web:%x", $time, state, DUT.mmu_mem_addrb, DUT.mmu_mem_enb, DUT.mmu_mem_web);
      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      

      //transfer 15
      @(state==4'h7);//trans_load
      $display("%g state:%x, should be 4'h7, mem addr:%x enb:%x web:%x", $time, state, DUT.mmu_mem_addrb, DUT.mmu_mem_enb, DUT.mmu_mem_web);
      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      

      //transfer 16
      @(state==4'h7);//trans_load
      $display("%g state:%x, should be 4'h7, mem addr:%x enb:%x web:%x", $time, state, DUT.mmu_mem_addrb, DUT.mmu_mem_enb, DUT.mmu_mem_web);
      @(posedge clk_100mhz);
      $display("%g state:%x, should be 4'h8, data:%x ", $time, state, DUT.mmu_mem_doutb);      
      

      repeat(100) @(posedge clk_100mhz);

      $finish;
   end
   
endmodule // tb_topmodule
