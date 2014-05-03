`timescale 1ns / 1ps   
module display_tb();

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [11:0]          D;                      // From DUT of mmu_board.v
   wire                 GPIO_LED_0;             // From DUT of mmu_board.v
   wire                 GPIO_LED_1;             // From DUT of mmu_board.v
   wire                 GPIO_LED_2;             // From DUT of mmu_board.v
   wire                 GPIO_LED_4;             // From DUT of mmu_board.v
   wire                 GPIO_LED_7;             // From DUT of mmu_board.v
   wire                 blank;                  // From DUT of mmu_board.v
   wire                 dvi_clk;                // From DUT of mmu_board.v
   wire                 dvi_clk_n;              // From DUT of mmu_board.v
   wire                 dvi_rst;                // From DUT of mmu_board.v
   wire                 hsync;                  // From DUT of mmu_board.v
   wire                 scl_tri;                // To/From DUT of mmu_board.v
   wire                 sda_tri;                // To/From DUT of mmu_board.v
   wire [3:0]           state;                  // From DUT of mmu_board.v
   wire                 txd;                    // From DUT of mmu_board.v
   wire                 vsync;                  // From DUT of mmu_board.v
   // End of automatics

   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [1:0]            br_cfg;                 // To DUT of mmu_board.v
   reg                  clk;                    // To DUT of mmu_board.v
   reg                  cpu_pc_MSB;             // To DUT of mmu_board.v
   reg                  mem_sys_fin;            // To DUT of mmu_board.v
   reg                  rst_n;                  // To DUT of mmu_board.v
   reg                  rxd;                    // To DUT of mmu_board.v
   // End of automatics


   mmu_board DUT
     (/*AUTOINST*/
      // Outputs
      .txd                              (txd),
      .state                            (state[3:0]),
      .D                                (D[11:0]),
      .blank                            (blank),
      .hsync                            (hsync),
      .vsync                            (vsync),
      .dvi_clk                          (dvi_clk),
      .dvi_clk_n                        (dvi_clk_n),
      .dvi_rst                          (dvi_rst),
      .GPIO_LED_0                       (GPIO_LED_0),
      .GPIO_LED_1                       (GPIO_LED_1),
      .GPIO_LED_2                       (GPIO_LED_2),
      .GPIO_LED_4                       (GPIO_LED_4),
      .GPIO_LED_7                       (GPIO_LED_7),
      // Inouts
      .scl_tri                          (scl_tri),
      .sda_tri                          (sda_tri),
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .rxd                              (rxd),
      .br_cfg                           (br_cfg[1:0]),
      .cpu_pc_MSB                       (cpu_pc_MSB),
      .mem_sys_fin                      (mem_sys_fin));



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
//        $wlfdumpvars(0, mmu_wrong_baud_tb);
		  $monitor ("%g D:%x", $time, D);
        clk=1;
        rst_n=0;
        br_cfg=2'b00;
        cpu_pc_MSB=1'b1;
        mem_sys_fin=1'b1;
        
        repeat(2) @(posedge clk);
        rst_n=1;
		  DUT.DUT.driver0.cmd= 8'h64;
        
     

        repeat(10000) @(posedge clk) DUT.DUT.driver0.cmd= 8'h64;;
        
        $finish;
     end   
   
   
endmodule // UART_tx_tb

        
               
     
