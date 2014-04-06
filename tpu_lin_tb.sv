`default_nettype none

module tpu_lin_tb();


   parameter INST_WIDTH=22;
   parameter ISQ_IDX_BITS_NUM=2;      
   localparam ISQ_LINE_WIDTH=INST_WIDTH+ ISQ_IDX_BITS_NUM;

   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   parameter TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 +2 ; 
   
   
   reg clk, rst_n;
   
   reg dst_reg_rdy, dst_rdy_reg_en;
   
   reg [ISQ_LINE_WIDTH-1:0] isq_lin;
   reg [TPU_MAP_WIDTH-1:0] prv_map;   
   
   wire [TPU_INST_WIDTH-1:0] tpu_out;
   wire [TPU_MAP_WIDTH-1:0] cur_map;
   wire                     tpu_inst_rdy;

   wire [7:0]               psrc1,psrc2;
   wire [7:0]               phys_map[15:0];

   //================== separate each field for easy debuggin
   //generate output mapping
   generate
      genvar                                      map_i;
      //16 logical registers to physical mappings
      for (map_i=0; map_i<16; map_i=map_i+1) 
        begin
           //possible mapping
           assign phys_map[map_i][7:0] = cur_map[7*(map_i+1)-1:7*map_i];
        end
   endgenerate

   assign psrc1= tpu_out[TPU_INST_WIDTH -1 - ISQ_IDX_BITS_NUM - 1 -1: TPU_INST_WIDTH - 1 - ISQ_IDX_BITS_NUM - 1 -1 -6];
   assign psrc2= tpu_out[TPU_INST_WIDTH - 1 - ISQ_IDX_BITS_NUM - 1 -1 - 6 -1 : TPU_INST_WIDTH - 1 - ISQ_IDX_BITS_NUM - 1 -1 -6 -1 -6];
   
   //============================

   
   tpu_lin #(.INST_WIDTH(INST_WIDTH), .TPU_MAP_WIDTH(TPU_MAP_WIDTH), .ISQ_IDX_BITS_NUM(ISQ_IDX_BITS_NUM) )
               DUT(/*autoinst*/
               // Outputs
               .cur_map                 (cur_map[TPU_MAP_WIDTH-1:0]),
               .tpu_out                 (tpu_out[TPU_INST_WIDTH-1:0]),
               .tpu_inst_rdy            (tpu_inst_rdy),
               // Inputs
               .rst_n                   (rst_n),
               .clk                     (clk),
               .dst_reg_rdy             (dst_reg_rdy),
               .dst_rdy_reg_en          (dst_rdy_reg_en),
               .isq_lin                 (isq_lin[ISQ_LINE_WIDTH-1:0]),
               .prv_map                 (prv_map[TPU_MAP_WIDTH-1:0]));

   
   initial
     forever #5 clk=~clk;

   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, tpu_lin_tb);
        $monitor ("%g  inst_rdy:%b,  psrc1:%x,  psrc2: %x , physical map: %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x dut.lsrc1:%x, dut.lsrc2:%x, dut.psrc1:%x, dut.psrc2:%x",$time, tpu_inst_rdy, psrc1, psrc2, phys_map[15],  phys_map[14],  phys_map[13],  phys_map[12], phys_map[11],  phys_map[10],  phys_map[9],  phys_map[8],  phys_map[7],  phys_map[6],  phys_map[5],  phys_map[4], phys_map[3],  phys_map[2],  phys_map[1],  phys_map[0], DUT.lsrc1, DUT.lsrc2, DUT.psrc1, DUT.psrc2);
//        $monitor ("%g  tpu_out=%b,  cur_map: %b , tpu_inst_rdy",$time, tpu_out, cur_map, tpu_inst_rdy);
        
        clk=0;
        rst_n=1;

        isq_lin = {ISQ_LINE_WIDTH{1'b0}};
        prv_map = {TPU_MAP_WIDTH {1'b0}};
        
                 
        repeat(2) @(posedge clk);

        //=== use display since we are working on combinational logic
        $strobe("=============begin test. reset==========");
        @(posedge clk);
        rst_n=0;
        @(posedge clk);
        $display("%g  =============reset finished ==========", $time);
        rst_n=1;
        @(posedge clk);
        $display("%g  =============load invalid instruction ==========", $time); 
        isq_lin = {INST_WIDTH{1'b0}};
        @(posedge clk);
        $display("%g  ============= valid inst. physcial register not ready  ==========", $time);
        $display("%g  ===inst: idx:01, vld:1, src1:1,0000, src2:1,0001, ldst:1,0010, pdst:000001", $time);
        $display("%g  ===prev mapping: all 0. no one is ready", $time);
        
        //inst, src1, ldst (0010) valid, src2, physical 000001        
        isq_lin = { 2'b01, 1'b1, 1'b1, 4'b0000, 1'b1, 4'b0010, 1'b1, 4'b0001, 6'b000001};
        //source not ready
        prv_map = {16{7'b0000000}};
        
        @(posedge clk);
        $display("%g  =============test valid inst. physcial register ready  ==========", $time);
        $display("%g  ===inst: idx:01, vld:1, src1:1,0000, src2:1,0000, ldst:1,0010, pdst:000001", $time);
        $display("%g  ===prev mapping: all 0. but all ready", $time);
        //source ready
        prv_map = {16{7'b1000000}};

        @(posedge clk);
        $display("%g  =============test valid inst. only physical reg 15 not rdy ==========", $time);
        prv_map = {{7'b0000000},{15{7'b1000000}} };


        @(posedge clk);
        $display("%g  ===inst: idx:01, vld:1, src1:1,0100, src2:1,0111, ldst:1,0010, pdst:100000", $time);        
        $display("%g  ============= prev mapping 15->15, 14->14, 13-> 13 ==========", $time);
        isq_lin = { 2'b01, 1'b1, 1'b1, 4'b0100, 1'b1, 4'b0010, 1'b1, 4'b0111, 6'b100000};   
        prv_map = { {1'b1,6'd15},{1'b1,6'd14},{1'b1,6'd13},{1'b1,6'd12},{1'b1,6'd11},{1'b1,6'd10},{1'b1,6'd9},{1'b1,6'd8},{1'b1,6'd7},{1'b1,6'd6},{1'b1,6'd5},{1'b1,6'd4},{1'b1,6'd3},{1'b1,6'd2},{1'b1,6'd1},{1'b1,6'd0} };
        
        @(posedge clk);
        dst_reg_rdy=1;
        dst_rdy_reg_en=0;
        $display("%g =====set dst_rdy_reg_en to low, dst_reg_rdy to high", $time);           
        $display("%g ====== should change output", $time);        
        $display("%g  ============= prev mapping 15->15, 14->14, 13-> 13 ==========", $time);
        prv_map = { {1'b1,6'd15},{1'b1,6'd14},{1'b1,6'd13},{1'b1,6'd12},{1'b1,6'd11},{1'b1,6'd10},{1'b1,6'd9},{1'b1,6'd8},{1'b1,6'd7},{1'b1,6'd6},{1'b1,6'd5},{1'b1,6'd4},{1'b1,6'd3},{1'b1,6'd2},{1'b1,6'd1},{1'b1,6'd0} };


        @(posedge clk);
        dst_reg_rdy=1;
        dst_rdy_reg_en=1;
        $display("%g =====dest physical reg high", $time);           
        $display("%g ====== cur_mapping should change", $time);                
        
/* -----\/----- EXCLUDED -----\/-----
        @(posedge clk);
        $display("=============test valid inst. dest physcial register ready  ==========");
        $display("inst: idx:01, vld:1, src1:1,0000, src2:1,0000, ldst:1,0010, pdst:000001");
        $display("prev mapping: all 0. but all ready");
        
        //inst, src1, ldst (0010) valid, src2, physical 000001
        isq_lin = { 2'b01, 1'b1, 1'b1, 4'b0000, 1'b0, 4'b0010, 1'b1, 4'b0001, 6'b000001};
        //source not ready
        prv_map = {16{7'b0000000}};
 -----/\----- EXCLUDED -----/\----- */

        repeat(20)@(posedge clk);
        
        //test physical register becomes rdy
        $finish;
     end
   
   
   
endmodule   