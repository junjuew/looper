`default_nettype none

  //////////////////////////////////////////////////
  //
  // isq line input format:
  // idx | inst vld | vld , lsrc1 | vld, ldst | vld, lsrc2 | controls... | pdest
  // tpu line out format:
  // idx | inst vld | vld, psrc1 | vld, psrc2 |  other control signals ... | pdest
  //
  //
  // tpu module:
  // an array of tpu lines (ISQ_DEPTH = 64)
  // two segment headers to record architecture state
  /////////////////////////////////////////////////// /
  module tpu(/*autoarg*/
   // Outputs
   tpu_inst_rdy, tpu_out_flat, fre_preg_out_flat,
   // Inputs
   clk, rst_n, isq_lin_flat, dst_reg_rdy, dst_rdy_reg_en, arch_swt
   );

   parameter ISQ_DEPTH = 64;
   parameter INST_WIDTH=67;
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   // 6 is just an arbitrary value for widths of idx bit   
   parameter ISQ_IDX_BITS_NUM= 6;
   localparam ISQ_LINE_WIDTH=INST_WIDTH + ISQ_IDX_BITS_NUM;
   //psrc1 and psrc2 need two more bits than lsrc1, lsrc2
   localparam TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5; 

   input wire clk, rst_n;
   input wire [ISQ_LINE_WIDTH*ISQ_DEPTH-1:0] isq_lin_flat;
   
   input wire [ISQ_DEPTH-1:0]               dst_reg_rdy;
   input wire [ISQ_DEPTH-1:0]               dst_rdy_reg_en;   
   //switch architecture state.
   //should happen when there is no branch instruction waiting to be cleared
   //and every inst in below section has 0 as wait bit
   input wire                      arch_swt; //switch architecture state

   output wire [ISQ_DEPTH-1:0]              tpu_inst_rdy;   
   output wire [TPU_INST_WIDTH * ISQ_DEPTH-1:0] tpu_out_flat;
   output wire [7 * ISQ_DEPTH-1:0] fre_preg_out_flat;

   
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

   reg                       arch;
   reg[TPU_MAP_WIDTH-1:0]    top_hed_map, mid_hed_map;
   wire                      top_hed_map_en,mid_hed_map_en;


   ////////////////////////////
   //unflat input wire
   //////////////////////////
   generate
      genvar                                      isq_lin_i;
      for (isq_lin_i=0; isq_lin_i<ISQ_DEPTH; isq_lin_i=isq_lin_i+1) 
        begin
           assign isq_lin[isq_lin_i][ISQ_LINE_WIDTH-1:0] = isq_lin_flat[ISQ_LINE_WIDTH*(isq_lin_i+1)-1 : ISQ_LINE_WIDTH*isq_lin_i];
        end
   endgenerate
   

   ////////////////////////////
   //flat output wire
   //////////////////////////
   generate
      genvar                                      out_i;
      for (out_i=0; out_i<ISQ_DEPTH; out_i=out_i+1) 
        begin
           assign tpu_out_flat[TPU_INST_WIDTH*(out_i+1)-1:TPU_INST_WIDTH*out_i]= tpu_out[out_i][TPU_INST_WIDTH-1:0];
           assign fre_preg_out_flat[7*(out_i+1)-1:7*out_i]= fre_preg[out_i][6:0];
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
        begin
           if (0 == tpu_lin_idx)
              //~arch true if top segment is arch
             assign prv_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]= (~arch)? top_hed_map[TPU_MAP_WIDTH-1:0]: cur_map[ISQ_DEPTH-1][TPU_MAP_WIDTH-1:0];
           else if ( (ISQ_DEPTH/2) == tpu_lin_idx)
             assign prv_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]= (~arch)? cur_map[(ISQ_DEPTH/2)-1][TPU_MAP_WIDTH-1:0]:mid_hed_map[TPU_MAP_WIDTH-1:0];
           else 
             assign prv_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]= cur_map[tpu_lin_idx-1][TPU_MAP_WIDTH-1:0];
           
           tpu_lin #(.INST_WIDTH(INST_WIDTH), .TPU_MAP_WIDTH(TPU_MAP_WIDTH),
                       .ISQ_IDX_BITS_NUM(ISQ_IDX_BITS_NUM) )
           tpu_mat(
                   // Outputs
                   .cur_map           (cur_map[tpu_lin_idx][TPU_MAP_WIDTH-1:0]),
                   .tpu_out           (tpu_out[tpu_lin_idx][TPU_INST_WIDTH-1:0]),
                   .tpu_inst_rdy      (tpu_inst_rdy[tpu_lin_idx]),
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
   
endmodule // isq_lin
