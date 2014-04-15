`default_nettype none

  ///////////////////////////
  // issue stage top module
  ////////////////////////
  module is(/*autoarg*/
   // Outputs
   ful_to_al, mul_ins_to_rf, alu1_ins_to_rf, alu2_ins_to_rf,
   adr_ins_to_rf, fre_prg_to_rob,
   // Inputs
   clk, rst_n, inst_frm_al, lop_sta, fls_frm_rob, cmt_frm_rob,
   fun_rdy_frm_exe, prg_rdy_frm_exe
   );

   /*********** param for stage inputs ***************/
   //vld + 6 bit idx
   parameter BRN_WIDTH=7;
   //vld + 6 bit indx
   parameter PRG_SIG_WIDTH=7;
   parameter INST_WIDTH=56;
   parameter IS_INST_WIDTH = 66;   
   
   //isq
   parameter ISQ_DEPTH = 64;
   // 6 is just an arbitrary value for widths of idx bit   
   parameter ISQ_IDX_BITS_NUM= 6;
   parameter INST_PORT=4;
   parameter ISQ_LINE_WIDTH=INST_WIDTH + ISQ_IDX_BITS_NUM + 1;
   
   //counter
   parameter BITS_IN_COUNT = 4;//=log2(ISQ_DEPTH/INST_PORT)

   //tpu
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   //psrc1 and psrc2 need two more bits than lsrc1, lsrc2, no ldest
   parameter TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5;
   parameter BIT_INST_VLD = INST_WIDTH  - 1 ;
   parameter BIT_INST_WAT= INST_WIDTH + 1;
   parameter BIT_LSRC1_VLD = INST_WIDTH   -1 -1  ;   
   parameter BIT_LSRC2_VLD = INST_WIDTH  - 1 - 11;      
   parameter BIT_LDST_VLD = INST_WIDTH  - 1 - 6;

   //pdc
   // which bit is representing each function unit
   parameter FUN_MULT_BIT= 0;
   parameter FUN_ADD1_BIT= 1;
   parameter FUN_ADD2_BIT= 2;
   parameter FUN_ADDR_BIT= 3;
   parameter BIT_IDX= ISQ_LINE_WIDTH-1;
   
   //tpu bit
   parameter TPU_BIT_IDX= 61;
   parameter TPU_BIT_INST_VLD= 54;
   parameter TPU_BIT_INST_WAT= 55;
   parameter TPU_BIT_PDEST= 6;         
   parameter TPU_BIT_CTRL_START= 39;
   parameter TPU_BIT_CTRL_END= TPU_BIT_PDEST + 1;   
   parameter TPU_BIT_CTRL_MULT= 10;
   parameter TPU_BIT_CTRL_ADD= 11;
   parameter TPU_BIT_CTRL_ADDR= 9;
   parameter TPU_BIT_CTRL_BR= 21;
   parameter TPU_BIT_CTRL_JMP_VLD= 19;      
   

   /********************** input **********************/
   //global input signals
   input wire clk, rst_n;
   
   //input from allocation stage
   input wire [4 * INST_WIDTH-1:0] inst_frm_al;
   input wire                      lop_sta; //loop start
   
   //input from ROB
   input wire [BRN_WIDTH-1:0]         fls_frm_rob;
   input wire [BRN_WIDTH-1:0]         cmt_frm_rob; //commit signal for branch
   
   
   //input from execution
   //function rdy
   input wire [3:0]                   fun_rdy_frm_exe;
   //physcial register rdy
   input wire [4 * PRG_SIG_WIDTH-1:0] prg_rdy_frm_exe;
   
   /********************** output **********************/
   //to al
   output wire                        ful_to_al;
   //to rf
   output wire [IS_INST_WIDTH-1:0]    mul_ins_to_rf;
   output wire [IS_INST_WIDTH-1:0]    alu1_ins_to_rf;
   output wire [IS_INST_WIDTH-1:0]    alu2_ins_to_rf;
   output wire [IS_INST_WIDTH-1:0]    adr_ins_to_rf;   
   //to rob
   output wire [4* PRG_SIG_WIDTH -1 :0] fre_prg_to_rob;


   /******************** in-module wire****************/
   //isq
   wire [4 * INST_WIDTH-1:0] inst_in_flat;
   assign inst_in_flat=inst_frm_al;
   wire                                        isq_en;
   
   wire [ISQ_LINE_WIDTH*ISQ_DEPTH-1:0]          isq_out_flat;
   
   //counter
   wire [BITS_IN_COUNT-1:0]                     counter;
   wire                                        set;
   wire [ISQ_IDX_BITS_NUM-1:0]                 val;   
   assign set=fls_frm_rob[BRN_WIDTH-1];
   assign val=fls_frm_rob[ISQ_IDX_BITS_NUM-1:0];
   //valid bits from al port
   wire [3:0]                                  inst_vld;
   wire                                        isq_ful;
   
   wire[ISQ_DEPTH-1:0]                         isq_lin_en;
   
   //tpu
   wire[ISQ_DEPTH-1:0]                                        dst_reg_rdy;
   wire[ISQ_DEPTH-1:0]                                        dst_rdy_reg_en;
   wire                                                       arch_swt;
   
   wire[ISQ_DEPTH-1:0]                                        tpu_inst_rdy;
   wire [TPU_INST_WIDTH*ISQ_DEPTH-1:0]                        tpu_out_reo_flat;
   wire [7*ISQ_DEPTH-1:0]                                     fre_preg_out_flat;
   
   //pdc
   wire [ISQ_DEPTH-1:0]                                       clr_inst_wat;


   /**************** module instatiation **********************/
   
   isq #(/*AUTOINSTPARAM*/
         // Parameters
         .ISQ_DEPTH                     (ISQ_DEPTH),
         .ISQ_IDX_BITS_NUM              (ISQ_IDX_BITS_NUM),
         .INST_PORT                     (INST_PORT),
         .INST_WIDTH                    (INST_WIDTH),
         .ISQ_LINE_WIDTH                (ISQ_LINE_WIDTH)) 

   is_isq (/*autoinst*/
           // Outputs
           .isq_out_flat                (isq_out_flat[ISQ_LINE_WIDTH*ISQ_DEPTH-1:0]),
           // Inputs
           .inst_in_flat                (inst_in_flat[INST_WIDTH*INST_PORT-1:0]),
           .isq_en                      (isq_en),
           .rst_n                       (rst_n),
           .clk                         (clk),
           .isq_lin_en                  (isq_lin_en[ISQ_DEPTH-1:0]),
           .clr_inst_wat                (clr_inst_wat[ISQ_DEPTH-1:0]));

   
   counter #(/*AUTOINSTPARAM*/
             // Parameters
             .ISQ_DEPTH                 (ISQ_DEPTH),
             .ISQ_IDX_BITS_NUM          (ISQ_IDX_BITS_NUM),
             .INST_PORT                 (INST_PORT),
             .BITS_IN_COUNT             (BITS_IN_COUNT))
   
   is_counter (/*autoinst*/
               // Outputs
               .isq_lin_en              (isq_lin_en[ISQ_DEPTH-1:0]),
               .counter                 (counter[BITS_IN_COUNT-1:0]),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .set                     (set),
               .val                     (val[ISQ_IDX_BITS_NUM-1:0]),
               .inst_vld                (inst_vld[INST_PORT-1:0]),
               .isq_ful                 (isq_ful));

   
   tpu #(/*AUTOINSTPARAM*/
         // Parameters
         .ISQ_DEPTH                     (ISQ_DEPTH),
         .INST_WIDTH                    (INST_WIDTH),
         .TPU_MAP_WIDTH                 (TPU_MAP_WIDTH),
         .ISQ_IDX_BITS_NUM              (ISQ_IDX_BITS_NUM),
         .ISQ_LINE_WIDTH                (ISQ_LINE_WIDTH),
         .TPU_INST_WIDTH                (TPU_INST_WIDTH),
         .BIT_INST_VLD                  (BIT_INST_VLD),
         .BIT_INST_WAT                  (BIT_INST_WAT),
         .BIT_LSRC1_VLD                 (BIT_LSRC1_VLD),
         .BIT_LSRC2_VLD                 (BIT_LSRC2_VLD),
         .BIT_LDST_VLD                  (BIT_LDST_VLD),
         .BITS_IN_COUNT                 (BITS_IN_COUNT)) 

   is_tpu (/*autoinst*/
           // Outputs
           .tpu_inst_rdy                (tpu_inst_rdy[ISQ_DEPTH-1:0]),
           .tpu_out_reo_flat            (tpu_out_reo_flat[TPU_INST_WIDTH*ISQ_DEPTH-1:0]),
           .fre_preg_out_flat           (fre_preg_out_flat[7*ISQ_DEPTH-1:0]),
           .isq_ful                     (isq_ful),
           // Inputs
           .clk                         (clk),
           .rst_n                       (rst_n),
           .isq_out_flat                (isq_out_flat[ISQ_LINE_WIDTH*ISQ_DEPTH-1:0]),
           .dst_reg_rdy                 (dst_reg_rdy[ISQ_DEPTH-1:0]),
           .dst_rdy_reg_en              (dst_rdy_reg_en[ISQ_DEPTH-1:0]),
           .counter                     (counter[BITS_IN_COUNT-1:0]));

   
   pdc #(/*AUTOINSTPARAM*/
         // Parameters
         .ISQ_DEPTH                     (ISQ_DEPTH),
         .INST_WIDTH                    (INST_WIDTH),
         .TPU_MAP_WIDTH                 (TPU_MAP_WIDTH),
         .ISQ_IDX_BITS_NUM              (ISQ_IDX_BITS_NUM),
         .ISQ_LINE_WIDTH                (ISQ_LINE_WIDTH),
         .FUN_MULT_BIT                  (FUN_MULT_BIT),
         .FUN_ADD1_BIT                  (FUN_ADD1_BIT),
         .FUN_ADD2_BIT                  (FUN_ADD2_BIT),
         .FUN_ADDR_BIT                  (FUN_ADDR_BIT),
         .TPU_BIT_IDX                   (TPU_BIT_IDX),
         .TPU_BIT_INST_VLD              (TPU_BIT_INST_VLD),
         .TPU_BIT_INST_WAT              (TPU_BIT_INST_WAT),
         .TPU_BIT_PDEST                 (TPU_BIT_PDEST),
         .TPU_BIT_CTRL_START            (TPU_BIT_CTRL_START),
         .TPU_BIT_CTRL_END              (TPU_BIT_CTRL_END),
         .TPU_BIT_CTRL_MULT             (TPU_BIT_CTRL_MULT),
         .TPU_BIT_CTRL_ADD              (TPU_BIT_CTRL_ADD),
         .TPU_BIT_CTRL_ADDR             (TPU_BIT_CTRL_ADDR),
         .TPU_BIT_CTRL_BR               (TPU_BIT_CTRL_BR),
         .TPU_BIT_CTRL_JMP_VLD          (TPU_BIT_CTRL_JMP_VLD),
         .IS_INST_WIDTH                 (IS_INST_WIDTH),
         .TPU_INST_WIDTH                (TPU_INST_WIDTH)) 

   is_pdc (/*autoinst*/
           // Outputs
           .clr_inst_wat                (clr_inst_wat[ISQ_DEPTH-1:0]),
           .mul_ins_to_rf               (mul_ins_to_rf[IS_INST_WIDTH-1:0]),
           .alu1_ins_to_rf              (alu1_ins_to_rf[IS_INST_WIDTH-1:0]),
           .alu2_ins_to_rf              (alu2_ins_to_rf[IS_INST_WIDTH-1:0]),
           .adr_ins_to_rf               (adr_ins_to_rf[IS_INST_WIDTH-1:0]),
           // Inputs
           .fun_rdy_frm_exe             (fun_rdy_frm_exe[3:0]),
           .tpu_out_reo_flat            (tpu_out_reo_flat[TPU_INST_WIDTH*ISQ_DEPTH-1:0]),
           .tpu_inst_rdy                (tpu_inst_rdy[ISQ_DEPTH-1:0]),
           .fre_preg_out_flat           (fre_preg_out_flat[7*ISQ_DEPTH-1:0]));   
   
   
endmodule 
