//`default_nettype none

  /////////////////
  //test problem: when load in a new instruction, need to reset dst_rdy_reg
  // to 0, but if synchronous, only can be resetted next cycle
  // need to add async reset to dst_rdy register in tpu_lin
  //////////////////////////////////////////////
  module tpu_tb();

   parameter ISQ_DEPTH = 4;
   parameter INST_WIDTH = 22;
   parameter ISQ_IDX_BITS_NUM =2;
   localparam ISQ_LINE_WIDTH=INST_WIDTH + ISQ_IDX_BITS_NUM;
   localparam TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5; 
   
   reg clk,rst_n, arch_swt;

   reg[ISQ_DEPTH -1 :0] dst_reg_rdy;
   reg[ISQ_DEPTH-1:0] dst_rdy_reg_en;
   wire [ISQ_LINE_WIDTH*ISQ_DEPTH-1:0] isq_lin_flat;

   reg [ISQ_LINE_WIDTH-1:0]          isq_lin[ISQ_DEPTH -1 :0];
   
   
   wire [ISQ_DEPTH-1:0]              tpu_inst_rdy;

   wire [TPU_INST_WIDTH * ISQ_DEPTH-1:0] tpu_out_flat;
   wire [TPU_INST_WIDTH * ISQ_DEPTH-1:0] tpu_out_reo_flat;   
   
   wire [7 * ISQ_DEPTH -1 : 0]  fre_preg_out_flat;
   
   wire [TPU_INST_WIDTH-1:0]             inst_out[ISQ_DEPTH-1:0];
   wire [TPU_INST_WIDTH-1:0]             inst_out_reo[ISQ_DEPTH-1:0];

   
   wire [1:0]                            inst_idx[ISQ_DEPTH-1:0];
   wire                                  inst_vld[ISQ_DEPTH-1:0];
   wire [6:0]                            inst_psrc1[ISQ_DEPTH-1:0];
   wire [6:0]                            inst_psrc2[ISQ_DEPTH-1:0];
   wire [5:0]                            inst_pdst[ISQ_DEPTH-1:0];   

   
   
   wire [6:0]             fre_preg[ISQ_DEPTH-1:0];
   
   wire [7:0]               top_hed[15:0];
   wire [7:0]               mid_hed[15:0];
   
        
   tpu #(.ISQ_DEPTH(ISQ_DEPTH), .INST_WIDTH(INST_WIDTH), .ISQ_IDX_BITS_NUM(ISQ_IDX_BITS_NUM) ) DUT (/*autoinst*/
            // Outputs
            .tpu_inst_rdy               (tpu_inst_rdy[ISQ_DEPTH-1:0]),
            .tpu_out_flat               (tpu_out_flat[TPU_INST_WIDTH*ISQ_DEPTH-1:0]),
            .tpu_out_reo_flat           (tpu_out_reo_flat[TPU_INST_WIDTH*ISQ_DEPTH-1:0]),
            .fre_preg_out_flat          (fre_preg_out_flat[7*ISQ_DEPTH-1:0]),
            // Inputs
            .clk                        (clk),
            .rst_n                      (rst_n),
            .isq_lin_flat               (isq_lin_flat[ISQ_LINE_WIDTH*ISQ_DEPTH-1:0]),
            .dst_reg_rdy                (dst_reg_rdy[ISQ_DEPTH-1:0]),
            .dst_rdy_reg_en             (dst_rdy_reg_en[ISQ_DEPTH-1:0]),
            .arch_swt                   (arch_swt));


   //================== separate each tpu output ===============
   generate
      genvar                                      inst_out_i;
      //16 logical registers to physical mappings
      for (inst_out_i=0; inst_out_i<ISQ_DEPTH; inst_out_i=inst_out_i+1) 
        begin
           //possible mapping
           assign inst_out[inst_out_i][TPU_INST_WIDTH-1:0] = tpu_out_flat[TPU_INST_WIDTH*(inst_out_i+1)-1:TPU_INST_WIDTH*inst_out_i];
           assign inst_out_reo[inst_out_i][TPU_INST_WIDTH-1:0] = tpu_out_reo_flat[TPU_INST_WIDTH*(inst_out_i+1)-1:TPU_INST_WIDTH*inst_out_i];
           
           assign inst_idx[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-1:TPU_INST_WIDTH-2];
           assign inst_vld[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-3];
           assign inst_psrc1[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-4:TPU_INST_WIDTH-10];           
           assign inst_psrc2[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-11:TPU_INST_WIDTH-17];
           assign inst_pdst[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-18:TPU_INST_WIDTH-23];                                 

        end
   endgenerate


   //================== separate each free physical registers output =====
   generate
      genvar                                      preg_i;
      //16 logical registers to physical mappings
      for (preg_i=0; preg_i<ISQ_DEPTH; preg_i=preg_i+1) 
        begin
           //possible mapping
           assign fre_preg[preg_i][6:0] = fre_preg_out_flat[7*(preg_i+1)-1:7*preg_i];
        end
   endgenerate


   //================== group instruction together =====
   generate
      genvar                                      inst_in_i;
      //16 logical registers to physical mappings
      for (inst_in_i=0; inst_in_i<ISQ_DEPTH; inst_in_i=inst_in_i+1) 
        begin
           assign isq_lin_flat[ISQ_LINE_WIDTH*(inst_in_i+1)-1:ISQ_LINE_WIDTH*inst_in_i]= isq_lin[inst_in_i][ISQ_LINE_WIDTH-1:0];
        end
   endgenerate
   

   //================== separate each field for easy debuggin
   //generate output mapping
   generate
      genvar                                      map_i;
      //16 logical registers to physical mappings
      for (map_i=0; map_i<16; map_i=map_i+1) 
        begin
           //possible mapping
           assign top_hed[map_i][7:0] = DUT.top_hed_map[7*(map_i+1)-1:7*map_i];
           assign mid_hed[map_i][7:0] = DUT.mid_hed_map[7*(map_i+1)-1:7*map_i];           
        end
   endgenerate


   //monitor inst_out and inst_out_reo
   always @(inst_out[0],inst_out[1],inst_out[2],inst_out[3], inst_out_reo[0], inst_out_reo[1], inst_out_reo[2], inst_out_reo[3])
     begin
        $strobe("inst_out[0]: %x\ninst_out[1]: %x\ninst_out[2]: %x\ninst_out[3]: %x\ninst_out_reo[0]: %x\ninst_out_reo[1]: %x\ninst_out_reo[2]: %x\ninst_out_reo[3]: %x\n", inst_out[0],inst_out[1],inst_out[2],inst_out[3], inst_out_reo[0], inst_out_reo[1], inst_out_reo[2], inst_out_reo[3]);
     end
   
   

   initial
     forever #5 clk=~clk;

   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, tpu_tb);
        $monitor ("%g\n (3)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n (2)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n (1)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n (0)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n top head map: %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x, mid head map: %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x, arch:%b ",$time, tpu_inst_rdy[3],  inst_idx[3], inst_vld[3], inst_psrc1[3], inst_psrc2[3], inst_pdst[3] , fre_preg[3] ,  tpu_inst_rdy[2],  inst_idx[2], inst_vld[2], inst_psrc1[2], inst_psrc2[2], inst_pdst[2] , fre_preg[2] , tpu_inst_rdy[1],  inst_idx[1], inst_vld[1], inst_psrc1[1], inst_psrc2[1], inst_pdst[1] , fre_preg[1] , tpu_inst_rdy[0],  inst_idx[0], inst_vld[0], inst_psrc1[0], inst_psrc2[0], inst_pdst[0] , fre_preg[0],top_hed[15],  top_hed[14],  top_hed[13],  top_hed[12], top_hed[11],  top_hed[10],  top_hed[9],  top_hed[8],  top_hed[7],  top_hed[6],  top_hed[5],  top_hed[4], top_hed[3],  top_hed[2],  top_hed[1],  top_hed[0],mid_hed[15],  mid_hed[14],  mid_hed[13],  mid_hed[12], mid_hed[11],  mid_hed[10],  mid_hed[9],  mid_hed[8],  mid_hed[7],  mid_hed[6],  mid_hed[5],  mid_hed[4], mid_hed[3],  mid_hed[2],  mid_hed[1],  mid_hed[0], DUT.arch);
        
        clk=0;
        rst_n=1;


        isq_lin[0]={ISQ_LINE_WIDTH{1'b0}};
        isq_lin[1]={ISQ_LINE_WIDTH{1'b0}};
        isq_lin[2]={ISQ_LINE_WIDTH{1'b0}};
        isq_lin[3]={ISQ_LINE_WIDTH{1'b0}};

        dst_reg_rdy={ISQ_DEPTH{1'b0}};
        dst_rdy_reg_en={ISQ_DEPTH{1'b0}};
        arch_swt= 1'b0;
        
        repeat(2) @(posedge clk);

        //=== use display since we are working on combinational logic
        $display("%g =============begin test. reset==========", $time);
        rst_n=0;
        
        @(posedge clk);
        $display("%g  =============reset finished ==========", $time);
        rst_n=1;
        
        @(posedge clk);
        $display("%g  =============load invalid instruction ==========", $time);

        @(posedge clk);
        $display("%g  ============= valid inst. physcial register ready  ==========", $time);
        $display("%g  ===inst: idx:00, vld:1, src1:1,0000, src2:1,0001, ldst:1,0010, pdst:010000", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001        
        isq_lin[0] = { 2'b00, 1'b1, 1'b1, 4'b0000, 1'b1, 4'b0010, 1'b1, 4'b0001, 6'b010000};
        
        @(posedge clk);
        $display("%g  ============= valid inst. no dependency  ==========", $time);
        $display("%g  ===inst: idx:01, vld:1, src1:1,0011, src2:1,0100, ldst:1,0101, pdst:010001", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001        
        isq_lin[1] = { 2'b01, 1'b1, 1'b1, 4'b0011, 1'b1, 4'b0101, 1'b1, 4'b0100, 6'b010001};


        @(posedge clk);
        $display("%g  ============= valid inst. no dependency  ==========", $time);
        $display("%g  ===inst: idx:10, vld:1, src1:1,0011, src2:1,0100, ldst:1,0101, pdst:010010", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001        
        isq_lin[2] = { 2'b10, 1'b1, 1'b1, 4'b0011, 1'b1, 4'b0101, 1'b1, 4'b0100, 6'b010010};

        //test dependency        
        @(posedge clk);
        $display("%g  ============= valid inst. src1 has dependency  ==========", $time);
        $display("%g  ===inst: idx:11, vld:1, src1:1,0101, src2:1,0100, ldst:1,0110, pdst:010011", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001        
        isq_lin[3] = { 2'b11, 1'b1, 1'b1, 4'b0101, 1'b1, 4'b0110, 1'b1, 4'b0100, 6'b010011};
        
        //test physical register becomes rdy
        @(posedge clk);
        $display("%g  ============= physical register of ldst 0101 becomes rdy ==========", $time);
        $display("%g  ===inst[3] should become ready", $time);
        dst_rdy_reg_en[2]=1'b1;
        dst_reg_rdy[2]=1'b1;
        dst_rdy_reg_en[1]=1'b1;
        dst_reg_rdy[1]=1'b1;
        dst_rdy_reg_en[0]=1'b1;
        dst_reg_rdy[0]=1'b1;

        @(posedge clk);
        dst_rdy_reg_en[2]=1'b0;
        dst_reg_rdy[2]=1'b0;
        dst_rdy_reg_en[1]=1'b0;
        dst_reg_rdy[1]=1'b0;
        dst_rdy_reg_en[0]=1'b0;
        dst_reg_rdy[0]=1'b0;
        
        
        //test arch switch
        @(posedge clk);
        $display("%g  ============= arch swch  ==========", $time);
        arch_swt=1'b1;
        
        @(posedge clk);
        arch_swt=1'b0;

        //clear the free preg rdy bits. IMPORTANT!!!!
        //clear the physical ready bit in the prev instruction
        //should be done when loading in instruction from allocation stage
        dst_rdy_reg_en[1]=1;
        dst_rdy_reg_en[2]=1;
        dst_rdy_reg_en[3]=1;
        dst_rdy_reg_en[0]=1;
        dst_reg_rdy[1]=1'b0;
        dst_reg_rdy[2]=1'b0;
        dst_reg_rdy[3]=1'b0;
        dst_reg_rdy[0]=1'b0;        

        @(posedge clk);
        dst_rdy_reg_en[1]=0;
        dst_rdy_reg_en[2]=0;
        dst_rdy_reg_en[3]=0;
        dst_rdy_reg_en[0]=0;
        
        $display("%g  ============= test suit 2  ==========", $time);
        $display("%g  ===inst 2: idx:00, vld:1, src1:1,2, src2:1,3, ldst:1,0, pdst:20", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001        
        isq_lin[2] = { 2'b10, 1'b1, 1'b1, 4'd2, 1'b1, 4'd0, 1'b1, 4'd3, 6'b100000};
        
        $display("%g  ===inst 3: idx:01, vld:1, src1:1,0, src2:1,1, ldst:1,0, pdst:21", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001
        isq_lin[3] = { 2'b11, 1'b1, 1'b1, 4'd0, 1'b1, 4'd0, 1'b1, 4'd1, 6'b100001};
        
        $display("%g  ===inst 0: idx:10, vld:1, src1:1,0, src2:1,0, ldst:1,1, pdst:22", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001
        isq_lin[0] = { 2'b00, 1'b1, 1'b1, 4'd0, 1'b1, 4'd1, 1'b1, 4'd0, 6'b100010};

        $display("%g  ===inst 1: idx:11, vld:1, src1:1,0, src2:1,1, ldst:1,3, pdst:23", $time);
        //inst, src1, ldst (0010) valid, src2, physical 000001        
        isq_lin[1] = { 2'b01, 1'b1, 1'b1, 4'd0, 1'b1, 4'd3, 1'b1, 4'd1, 6'b100011};

        @(posedge clk);
        dst_rdy_reg_en[2]=1'b1;
        dst_reg_rdy[2]=1'b1;
        

        @(posedge clk);
        $display("%g  ============= 02 inst dest solved  ==========", $time);                
        dst_rdy_reg_en[2]=1'b0;
        dst_reg_rdy[2]=1'b0;
        
        dst_rdy_reg_en[3]=1'b1;
        dst_reg_rdy[3]=1'b1;

        @(posedge clk);
        $display("%g  ============= 03 inst dest solved  ==========", $time);                        
        dst_rdy_reg_en[3]=1'b0;
        dst_reg_rdy[3]=1'b0;

        @(posedge clk);
        arch_swt=1;
        @(posedge clk);
        $display("%g  ============= arch swt  ==========", $time);                                
        arch_swt=0;

        
        
        repeat(20)@(posedge clk);        
        $finish;
     end
   

   
endmodule // tpu_tb
