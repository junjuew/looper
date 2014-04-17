//`default_nettype none

module isq_tb();

   parameter ISQ_DEPTH=16;
   parameter ISQ_ADDR=4;
   parameter INST_PORT=4;
   parameter INST_WIDTH=6;
   parameter BITS_IN_COUNT=2;   
   parameter ISQ_LINE_WIDTH=INST_WIDTH +2;

   localparam ISQ_OUT_WIDTH=ISQ_LINE_WIDTH + ISQ_ADDR;   // 4  = log(ISQ_DEPTH)

   /////////////////
   //isq
   ////////////////////
   reg clk, rst_n, isq_en;
   reg [ISQ_DEPTH-1:0] issd;
   reg [INST_WIDTH*INST_PORT-1:0] inst_in_flat;


   ////////////////////////////
   //counter
   //////////////////////////////
   reg                            set;
   reg [ISQ_ADDR-1:0]             val;
   reg [INST_PORT -1 :0]          inst_vld;
   wire [ISQ_OUT_WIDTH*ISQ_DEPTH-1:0] isq_out_flat;
   wire [ISQ_DEPTH-1:0] isq_lin_en;      


   isq #(.ISQ_DEPTH(ISQ_DEPTH), .INST_PORT(INST_PORT), .INST_WIDTH(INST_WIDTH),.ISQ_OUT_WIDTH(ISQ_OUT_WIDTH),.ISQ_ADDR(ISQ_ADDR))
                  DUT(
                  // Outputs
                  .isq_out_flat         (isq_out_flat[ISQ_OUT_WIDTH*ISQ_DEPTH-1:0]),
                  // Inputs
                  .inst_in_flat         (inst_in_flat[INST_WIDTH*INST_PORT-1:0]),
                  .isq_en               (isq_en),
                  .rst_n                (rst_n),
                  .clk                  (clk),
                  .isq_lin_en           (isq_lin_en[ISQ_DEPTH-1:0]),
                  .issd                 (issd[ISQ_DEPTH-1:0]));


   counter #(.ISQ_DEPTH(ISQ_DEPTH), .INST_PORT(INST_PORT),.ISQ_ADDR(ISQ_ADDR), .BITS_IN_COUNT(BITS_IN_COUNT))  
     isq_counter      (
                       // Outputs
                       .isq_lin_en      (isq_lin_en[ISQ_DEPTH-1:0]),
                       // Inputs
                       .clk             (clk),
                       .en (isq_en),
                       .rst_n           (rst_n),
                       .set             (set),
                       .val             (val[ISQ_ADDR-1:0]),
                       .inst_vld        (inst_vld[INST_PORT-1:0]));
   

   
   initial
     forever #5 clk=~clk;

   
   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, isq_tb);
        $monitor ("%g  isq_lin_out=%x, isq_lin_en=%x",$time, isq_out_flat, isq_lin_en);

        isq_en=0;
        clk=0;
        rst_n=1;
        isq_en=0;
        inst_vld=0;
        repeat(2) @(posedge clk);
        $strobe("=============begin test. reset==========");
        @(posedge clk);
        rst_n=0;
        @(posedge clk);
        rst_n=1;
        $strobe("=============reset finished ==========");                
        @(posedge clk);
        isq_en=1;
        inst_vld=4'hf;
//        isq_lin_en=16'h000f;
        inst_in_flat={6'h01, 6'h02,6'h03,6'h04};
        $strobe("=============load in 0x01, 0x02, 0x03, 0x04 ==========");        
        @(posedge clk);
        isq_en=1;
//        isq_lin_en=16'h00f0;        
        inst_in_flat={6'h05, 6'h06,6'h07,6'h08};
        $strobe("=============load in 0x05, 0x06, 0x07, 0x08 ==========");        
        @(posedge clk);
        inst_vld = 4'h0;
        inst_in_flat={6'h05, 6'h06,6'h07,6'h08};
        $strobe("=============load in 4 invalid instructions ==========");
        @(posedge clk);
        inst_vld = 4'hf;
        inst_in_flat={6'h05, 6'h06,6'h07,6'h08};
        $strobe("=============valid instructions again ==========");        
        repeat(6) @(posedge clk);
        isq_en=0;
        $strobe("=============disable issue queue bit ==========");                

        repeat(40) @(posedge clk);
        $finish;
        
        // @(posedge clk);
        // clr_val=0;        
        // clr_wat=1;
        // $strobe("=============clear wat bit ==========");                        
        // @(posedge clk);
        // clr_wat=0;        
        // fls=1;
        // $strobe("============= flush ==========");        
        // @(posedge clk);
        // fls=0;        
        // set_val=1;
        // $strobe("============= set valid bit ==========");        
        // @(posedge clk);
        // set_val=0;        
        // set_wat=1;
        // $strobe("============= set wat bit ==========");        
        // repeat(40) @(posedge clk);
        // $finish;
     end
   
   
   
endmodule   
