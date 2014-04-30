//`default_nettype none

  //////////////////////////////////////////////////
  //
  // isq line input format:
  // idx | wat| inst vld | vld , lsrc1 | vld, ldst | vld, lsrc2 | controls... | pdest
  // tpu line out format:
  // idx | wat | inst vld | vld, psrc1 | vld, psrc2 |  other control signals ... | pdest
  //
  //
  // tpu module:
  // an array of tpu lines (ISQ_DEPTH = 64)
  // two segment headers to record architecture state
  // tpu will also output the instructions with higher prority to lower physical lines
  // tpu_out_reo_flat: reordered instructions as described above, should use this output
  // tpu_out_flat: same-order instructiosn as issue queue
  /////////////////////////////////////////////////// /

  module tpu(/*autoarg*/
   // Outputs
   tpu_inst_rdy, tpu_out_reo_flat, fre_preg_out_flat, isq_ful, arch,
   arch_swt_fls,
   // Inputs
   clk, rst_n, isq_out_flat, dst_reg_rdy, dst_rdy_reg_en, counter
   );

   parameter ISQ_DEPTH = 64;
   parameter INST_WIDTH= 56;
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   // 6 is just an arbitrary value for widths of idx bit   
   parameter ISQ_IDX_BITS_NUM= 6;
   parameter ISQ_LINE_WIDTH= INST_WIDTH + ISQ_IDX_BITS_NUM + 2; //63
   //psrc1 and psrc2 need two more bits than lsrc1, lsrc2, ldst is not outputed
   parameter TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5; //62
   //bitmap for instructions
   //everything is relative to the inst_width, not isq_lin_width, by default!!
   parameter BIT_INST_VLD = INST_WIDTH  - 1 ;
   parameter BIT_INST_WAT = INST_WIDTH ;
   parameter BIT_INST_BRN_WAT = INST_WIDTH +1;   
   parameter BIT_LSRC1_VLD = INST_WIDTH   -1 -1  ;   
   parameter BIT_LSRC2_VLD = INST_WIDTH  - 1 - 11;      
   parameter BIT_LDST_VLD = INST_WIDTH  - 1 - 6;

   parameter BITS_IN_COUNT = 4;//=log2(ISQ_DEPTH/INST_PORT)

   input wire clk, rst_n;
   input wire [ISQ_LINE_WIDTH*ISQ_DEPTH-1:0] isq_out_flat;
   
   input wire [ISQ_DEPTH-1:0]               dst_reg_rdy;
   input wire [ISQ_DEPTH-1:0]               dst_rdy_reg_en;
   
   input wire [BITS_IN_COUNT-1:0]          counter;   
   //switch architecture state.
   //should happen when there is no branch instruction waiting to be cleared
   //and every inst in below section has 0 as wait bit
   wire                                     arch_swt; //switch architecture state

   output wire [ISQ_DEPTH-1:0]              tpu_inst_rdy;   
   //re-order tpu lines, so that insts with high priority always goes to the physcial low
   //lines which serve as input insts to pdc
   output wire [TPU_INST_WIDTH * ISQ_DEPTH-1:0] tpu_out_reo_flat;   
   output wire [7 * ISQ_DEPTH-1:0] fre_preg_out_flat;
   output wire                            isq_ful;
   output reg                       arch;
   //clr instruction in the operating region when arch_swt happens
   // for example when changed from head 0->1, flsh 0-- 31
   // head 1->0, flsh 32 --63
   output wire [ISQ_DEPTH-1:0]      arch_swt_fls;
   
   // get the tpu_inst_rdy before reordered
   wire [ISQ_DEPTH-1:0]            tpu_inst_rdy_raw;      
   // output from tpu lines
   wire [TPU_INST_WIDTH-1:0] tpu_out[ISQ_DEPTH-1:0];      
   //current mapping from logical to physical for all existing mappings
   //in tpu
   wire [TPU_MAP_WIDTH-1:0]  cur_map[ISQ_DEPTH-1:0];
   wire [6:0]  fre_preg[ISQ_DEPTH-1:0];   
   
   
   //mapping input to each line of tpu
   wire [TPU_MAP_WIDTH-1:0]  prv_map[ISQ_DEPTH-1:0];
   wire [ISQ_LINE_WIDTH-1:0] isq_lin[ISQ_DEPTH-1:0];   
   //////////////////////////////


   reg[TPU_MAP_WIDTH-1:0]    top_hed_map, mid_hed_map;
   wire                      top_hed_map_en,mid_hed_map_en;

   //inst valid
   wire [ISQ_DEPTH-1:0] inst_vld;
   //inst wait
   wire [ISQ_DEPTH-1:0] inst_wat;
   //inst brn_wat
   wire [ISQ_DEPTH-1:0] inst_brn_wat;
   //inst done: 1. inst not valid 
   //           or
   //           1. inst valid
   //           2. inst not wait
   //           3. inst not branch wait
   wire [ISQ_DEPTH-1:0] inst_done;                         


   ////////////////////////////
   //unflat input wire
   //////////////////////////
   generate
      genvar                                      isq_lin_i;
      for (isq_lin_i=0; isq_lin_i<ISQ_DEPTH; isq_lin_i=isq_lin_i+1) 
        begin : isq_lin_gen
           assign isq_lin[isq_lin_i][ISQ_LINE_WIDTH-1:0] = isq_out_flat[ISQ_LINE_WIDTH*(isq_lin_i+1)-1 : ISQ_LINE_WIDTH*isq_lin_i];
        end
   endgenerate
   

   ////////////////////////////
   // reorder all the output wires correspondingly
   // not only tpu_out_flat needs to be reorderd, but also fre_preg and inst_rdy
   // flat output wire
   //////////////////////////
   generate
      genvar                                      out_i;
      for (out_i=0; out_i<ISQ_DEPTH; out_i=out_i+1) 
        begin : out_gen
           //tpu output lines after priority routing
           // if arch == 0, then normal order 0--63
           // else 32 -- 63, 0 -- 31
           assign tpu_out_reo_flat[TPU_INST_WIDTH*(out_i+1)-1:TPU_INST_WIDTH*out_i]= (~arch)? tpu_out[out_i][TPU_INST_WIDTH-1:0]:
                                                                                     (out_i< ISQ_DEPTH/2)? tpu_out[out_i + ISQ_DEPTH/2][TPU_INST_WIDTH-1:0]:
                                                                                     tpu_out[out_i - ISQ_DEPTH/2][TPU_INST_WIDTH-1:0];
           assign fre_preg_out_flat[7*(out_i+1)-1:7*out_i]= (~arch)? fre_preg[out_i][6:0]:
                                                            (out_i< ISQ_DEPTH/2)? fre_preg[out_i + ISQ_DEPTH/2][6:0]:
                                                            fre_preg[out_i - ISQ_DEPTH/2][6:0];
           assign tpu_inst_rdy[out_i]= (~arch)? tpu_inst_rdy_raw[out_i]:
                                       (out_i< ISQ_DEPTH/2)? tpu_inst_rdy_raw[out_i + ISQ_DEPTH/2]:
                                       tpu_inst_rdy_raw[out_i - ISQ_DEPTH/2];
        end
   endgenerate

   
   //////////////////////////////
   //TPU line matrix
   //in out case 64 tpu line in total
   //generate all interconnect among these 64 lines
   ///////////////////////////////
   generate
      genvar                 tpu_lin_idx;
      for (tpu_lin_idx=0; tpu_lin_idx<ISQ_DEPTH; tpu_lin_idx=tpu_lin_idx+1)
        begin : tpu_lin_idx_gen
           if (0 == tpu_lin_idx)
              //~arch true if top segment is arch
             assign prv_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]= (~arch)? top_hed_map[TPU_MAP_WIDTH-1:0]: cur_map[ISQ_DEPTH-1][TPU_MAP_WIDTH-1:0];
           else if ( (ISQ_DEPTH/2) == tpu_lin_idx)
             assign prv_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]= (~arch)? cur_map[(ISQ_DEPTH/2)-1][TPU_MAP_WIDTH-1:0]:mid_hed_map[TPU_MAP_WIDTH-1:0];
           else 
             assign prv_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]= cur_map[tpu_lin_idx-1][TPU_MAP_WIDTH-1:0];
           
           tpu_lin #(/*autoinstparam*/
                     // Parameters
                     .INST_WIDTH        (INST_WIDTH),
                     .TPU_MAP_WIDTH     (TPU_MAP_WIDTH),
                     .ISQ_IDX_BITS_NUM  (ISQ_IDX_BITS_NUM),
                     .ISQ_LINE_WIDTH    (ISQ_LINE_WIDTH),
                     .TPU_INST_WIDTH    (TPU_INST_WIDTH),
                     .BIT_INST_VLD      (BIT_INST_VLD),
                     .BIT_LSRC1_VLD     (BIT_LSRC1_VLD),
                     .BIT_LSRC2_VLD     (BIT_LSRC2_VLD),
                     .BIT_LDST_VLD      (BIT_LDST_VLD))
           tpu_mat(
                   // Outputs
                   .cur_map           (cur_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]),
                   .tpu_out           (tpu_out[tpu_lin_idx][TPU_INST_WIDTH-1:0]),
                   .tpu_inst_rdy      (tpu_inst_rdy_raw[tpu_lin_idx]),
                   .fre_preg          (fre_preg[tpu_lin_idx][6:0]),
                   // Inputs
                   .rst_n             (rst_n),
                   .clk               (clk),
                   .dst_reg_rdy       (dst_reg_rdy[tpu_lin_idx]),
                   .dst_rdy_reg_en    (dst_rdy_reg_en[tpu_lin_idx]),
                   .isq_lin           (isq_lin[tpu_lin_idx][ISQ_LINE_WIDTH-1:0]),
                   .prv_map           (prv_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]));
        end
   endgenerate


   ///////////////////////////////
   // two segment headers
   ////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        //at reset, assign 15 to 0 physical reg to 15 to 0 logical reg as default
        if (~rst_n)
          top_hed_map <= { {1'b1,6'd15},{1'b1,6'd14},{1'b1,6'd13},{1'b1,6'd12},{1'b1,6'd11},{1'b1,6'd10},{1'b1,6'd9},{1'b1,6'd8},{1'b1,6'd7},{1'b1,6'd6},{1'b1,6'd5},{1'b1,6'd4},{1'b1,6'd3},{1'b1,6'd2},{1'b1,6'd1},{1'b1,6'd0} };
        
        else if (top_hed_map_en)
          top_hed_map[TPU_MAP_WIDTH-1:0] <=cur_map[ISQ_DEPTH-1][TPU_MAP_WIDTH-1:0];
     end
   
   always @(posedge clk, negedge rst_n)
     begin
        //at reset, assign 15 to 0 physical reg to 15 to 0 logical reg as default
        if (~rst_n)
          mid_hed_map <= { {1'b1,6'd15},{1'b1,6'd14},{1'b1,6'd13},{1'b1,6'd12},{1'b1,6'd11},{1'b1,6'd10},{1'b1,6'd9},{1'b1,6'd8},{1'b1,6'd7},{1'b1,6'd6},{1'b1,6'd5},{1'b1,6'd4},{1'b1,6'd3},{1'b1,6'd2},{1'b1,6'd1},{1'b1,6'd0} };
        else if (mid_hed_map_en)
          mid_hed_map[TPU_MAP_WIDTH-1:0] <=cur_map[(ISQ_DEPTH/2)-1][TPU_MAP_WIDTH-1:0];
     end


   /////////////////////////////////
   // grasp all valid and wat bits
   // from inst
   ////////////////////////////////
   generate
      genvar                                      inst_vld_i;
      for (inst_vld_i=0; inst_vld_i<ISQ_DEPTH; inst_vld_i=inst_vld_i+1) 
        begin : inst_vld_gen
           assign inst_vld[inst_vld_i]= isq_lin[inst_vld_i][BIT_INST_VLD];
           assign inst_wat[inst_vld_i]= isq_lin[inst_vld_i][BIT_INST_WAT];
           assign inst_brn_wat[inst_vld_i]= isq_lin[inst_vld_i][BIT_INST_BRN_WAT];
           assign inst_done[inst_vld_i]= (inst_vld[inst_vld_i])? ( (~inst_wat[inst_vld_i]) && (~inst_brn_wat[inst_vld_i]) ):1'b1;
        end
   endgenerate


   ///////////////////////////////////////////////
   // grab cur mapping from idx 31 line and idx 63 line
   /////////////////////////////////////////////////
   wire[15:0] bf_mid_map_rdy;
   wire[15:0] bf_top_map_rdy;   
   generate
      genvar bf_i;
      for (bf_i=0; bf_i<16; bf_i= bf_i +1)
        begin : bf_gen
           //before middle segment is idx 31
           assign bf_mid_map_rdy[bf_i]  = cur_map[ISQ_DEPTH/2-1][7*(bf_i+1)-1];
           //before top segment is idx 63
           assign bf_top_map_rdy[bf_i]  = cur_map[ISQ_DEPTH-1][7*(bf_i+1)-1];           
        end
   endgenerate
   wire bf_mid_map_all_rdy;
   wire bf_top_map_all_rdy;   
   assign bf_mid_map_all_rdy = (&bf_mid_map_rdy[15:0]);
   assign bf_top_map_all_rdy = (&bf_top_map_rdy[15:0]);   
   
   // architecture switch happens when all following criteria is satisfied
   // 1. region below current header wat=0 for all valid insts ( invalid insts may exist )
   // 2. counter's value is outside of region below current header
   // 3. region below current header needs to be all resolved (no pdest is invalid)
   assign arch_swt= (  (~arch) && (counter > ((ISQ_DEPTH/2)/4-1) ) && ( &(inst_done[ISQ_DEPTH/2-1:0])) && bf_mid_map_all_rdy ) || (  (arch) && (counter < (ISQ_DEPTH/2)/4 ) && ( &(inst_done[(ISQ_DEPTH-1):(ISQ_DEPTH/2)])) && bf_top_map_all_rdy );
   assign isq_ful = ((~arch) && (counter == ((ISQ_DEPTH)/4)-1) ) || ((arch) && (counter == (ISQ_DEPTH/2)/4 -1)); 

   //architecture recorder
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          begin
             arch<=1'b0;
          end
        else if (arch_swt)
          begin
             arch<=~arch;
          end
     end

   //switching between two segment headers
   // when arch_swt goes high, and previous arch is 0, then middle segment header should
   // load in current mapping and serve as arch state
   assign top_hed_map_en = (arch) && arch_swt;
   assign mid_hed_map_en = (~arch) && arch_swt;

   //clr old instructions in the region to make mapping clean
   assign arch_swt_fls = (~arch_swt)? {ISQ_DEPTH{1'b0}}:
                         // flsh 0 --31 when header 0 --> 1                         
                         (~arch )? { {ISQ_DEPTH/2{1'b0}},{ISQ_DEPTH/2{1'b1}} }:
                         // flsh 32 --63 when header 1 --> 0
                         {{ISQ_DEPTH/2{1'b1}},{ISQ_DEPTH/2{1'b0}} };
   
endmodule // isq_lin
