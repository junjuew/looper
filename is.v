//`default_nettype none

  ///////////////////////////
  // issue stage top module
  //
  // when the prg_rdy_frm_exe goes high, issue stage will clear
  // the dependency in next cycle
  ////////////////////////
  module is(/*autoarg*/
   // Outputs
   ful_to_al, mul_ins_to_rf, alu1_ins_to_rf, alu2_ins_to_rf,
   adr_ins_to_rf,
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
   parameter ISQ_LINE_WIDTH=INST_WIDTH + ISQ_IDX_BITS_NUM + 2;
   parameter BIT_INST_BRN =21;
   
   //counter
   parameter BITS_IN_COUNT = 4;//=log2(ISQ_DEPTH/INST_PORT)

   //tpu
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   //psrc1 and psrc2 need two more bits than lsrc1, lsrc2, no ldest
   parameter TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5;
   parameter BIT_INST_VLD = INST_WIDTH  - 1 ;
   parameter BIT_INST_WAT= INST_WIDTH;
   parameter BIT_LSRC1_VLD = INST_WIDTH   -1 -1  ;   
   parameter BIT_LSRC2_VLD = INST_WIDTH  - 1 - 11;      
   parameter BIT_LDST_VLD = INST_WIDTH  - 1 - 6;
   parameter BIT_INST_BRN_WAT = INST_WIDTH +1;   
   

   //pdc
   // which bit is representing each function unit
   parameter FUN_MULT_BIT= 0;
   parameter FUN_ADD1_BIT= 1;
   parameter FUN_ADD2_BIT= 2;
   parameter FUN_ADDR_BIT= 3;
   parameter BIT_IDX= ISQ_LINE_WIDTH-1;
   
   //tpu bit
   parameter TPU_BIT_IDX= 62;
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

   parameter IS_BIT_INST_VLD= IS_INST_WIDTH -1;
   parameter IS_BIT_IDX= IS_INST_WIDTH -1 -1;
   parameter IS_BIT_CTRL_BR= 20;
   parameter IS_BIT_CTRL_JMP_VLD= 18;

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


   /******************** in-module wire****************/
   //isq
   wire [4 * INST_WIDTH-1:0] inst_in_flat;
   assign inst_in_flat=inst_frm_al;
   wire                                        isq_en;
   wire [ISQ_DEPTH-1:0]                        clr_inst_wat;
   wire [ISQ_DEPTH-1:0]                        clr_inst_brn_wat;   
   
   wire [ISQ_LINE_WIDTH*ISQ_DEPTH-1:0]          isq_out_flat;
   
   //counter
   wire [BITS_IN_COUNT-1:0]                     counter;
   wire                                        set;
   wire [ISQ_IDX_BITS_NUM-1:0]                 val;   
   assign set=fls_frm_rob[BRN_WIDTH-1];
   assign val=fls_frm_rob[ISQ_IDX_BITS_NUM-1:0];
   //valid bits from al port
   wire [3:0]                                  inst_vld;
   assign inst_vld[0] = inst_frm_al[BIT_INST_VLD];
   assign inst_vld[1] = inst_frm_al[2*INST_WIDTH -1];
   assign inst_vld[2] = inst_frm_al[3*INST_WIDTH -1];
   assign inst_vld[3] = inst_frm_al[4*INST_WIDTH -1];   
   
   wire                                        isq_ful;
   assign isq_en=~isq_ful;
   assign ful_to_al = isq_ful;
   
   wire[ISQ_DEPTH-1:0]                         isq_lin_en;
   
   //tpu
   wire[ISQ_DEPTH-1:0]                                        dst_reg_rdy;
   wire[ISQ_DEPTH-1:0]                                        dst_rdy_reg_en;
   
   wire[ISQ_DEPTH-1:0]                                        tpu_inst_rdy;
   wire [TPU_INST_WIDTH*ISQ_DEPTH-1:0]                        tpu_out_reo_flat;
   wire [7*ISQ_DEPTH-1:0]                                     fre_preg_out_flat;
   wire                                                       arch;
   
   
   //pdc
   wire [ISQ_DEPTH-1:0]                                       pdc_clr_inst_wat;


   /*************** handle physical register ready *************/
   //unflat first
   wire[PRG_SIG_WIDTH-1:0]                                                       prg_rdy[3:0];
   // dst_rdy_en decoded from signal from execution stage
   wire[ISQ_DEPTH-1:0]                                                       prg_dst_rdy_en[3:0];   
   generate
      genvar                                                                     prg_i;
      begin
         for (prg_i=0; prg_i<4; prg_i=prg_i+1)
           begin
              assign prg_rdy[prg_i][PRG_SIG_WIDTH-1:0] = prg_rdy_frm_exe[PRG_SIG_WIDTH*(prg_i+1)-1:PRG_SIG_WIDTH*prg_i];
              //if valid, decode; otherwise set 0
              assign prg_dst_rdy_en[prg_i][ISQ_DEPTH-1:0] = ( prg_rdy[prg_i][PRG_SIG_WIDTH-1] )? (1<<prg_rdy[prg_i][PRG_SIG_WIDTH-2:0]) : {ISQ_DEPTH{1'b0}};
           end
      end 
   endgenerate
   //for dst_rdy_reg
   // enable when first loading inst or prg_rdy_frm_exe is valid
   assign dst_rdy_reg_en[ISQ_DEPTH -1: 0] = isq_lin_en[ISQ_DEPTH-1:0] | prg_dst_rdy_en[3][ISQ_DEPTH-1:0] | prg_dst_rdy_en[2][ISQ_DEPTH-1:0] | prg_dst_rdy_en[1][ISQ_DEPTH-1:0] | prg_dst_rdy_en[0][ISQ_DEPTH-1:0];
   //assign dst_reg_rdy
   //when first loading, dst_reg_rdy is 0; for prg_rdy_frm_exe, dst_reg_rdy is one
   // prg_dst_rdy_en have the same behavior as dst_reg_rdy
   assign dst_reg_rdy= prg_dst_rdy_en[3][ISQ_DEPTH-1:0] | prg_dst_rdy_en[2][ISQ_DEPTH-1:0] | prg_dst_rdy_en[1][ISQ_DEPTH-1:0] | prg_dst_rdy_en[0][ISQ_DEPTH-1:0];



   /*********** handle branch cmt *********/

   // if valid
   assign clr_inst_brn_wat[ISQ_DEPTH-1:0] = (cmt_frm_rob[BRN_WIDTH-1])? (1<<cmt_frm_rob[BRN_WIDTH-2:0]):{ISQ_DEPTH{1'b0}};
   assign clr_inst_wat[ISQ_DEPTH-1:0] = pdc_clr_inst_wat[ISQ_DEPTH-1:0];


   /*********** handle mis-branch *********/
   wire [ISQ_DEPTH-1:0] fls_inst;
   wire [ISQ_DEPTH-1:0] fls_inst_below;
   generate
      genvar            fls_inst_i;
      begin
         for (fls_inst_i=0; fls_inst_i<ISQ_DEPTH;fls_inst_i=fls_inst_i+1)
           begin
              //arch=0, flsh all inst >= fls_inst
              //arch=1, if fls_inst<=31, keep inst 32-63 and inst < fls_inst, flsh (inst<=31 and inst>=fls_inst)
              //arch=1, if fls_inst > 31, fls inst 0-31 and inst>=fls_inst
              assign fls_inst_below[fls_inst_i] = (~arch)? (fls_inst_i >= fls_frm_rob[BRN_WIDTH-2:0])? 1'b1:1'b0
                                                          : (fls_frm_rob[BRN_WIDTH-2:0] <=31)? 
                                                             (fls_inst_i<=31 && fls_inst_i>=fls_frm_rob[BRN_WIDTH-2:0])? 1'b1: 1'b0
                                                             : (fls_inst_i<31 || fls_inst_i>=fls_frm_rob[BRN_WIDTH-2:0])? 1'b1:1'b0;
           end
      end 
   endgenerate
   
   // if valid, then flsh the branch inst and all insts below
   assign fls_inst[ISQ_DEPTH-1:0] = (fls_frm_rob[BRN_WIDTH-1])? fls_inst_below:{ISQ_DEPTH{1'b0}};

   
   
   /**************** module instatiation **********************/
   
   isq #(/*AUTOINSTPARAM*/
         // Parameters
         .ISQ_DEPTH                     (ISQ_DEPTH),
         .ISQ_IDX_BITS_NUM              (ISQ_IDX_BITS_NUM),
         .INST_PORT                     (INST_PORT),
         .INST_WIDTH                    (INST_WIDTH),
         .ISQ_LINE_WIDTH                (ISQ_LINE_WIDTH),
         .BIT_INST_VLD                  (BIT_INST_VLD),
         .BIT_INST_BRN                  (BIT_INST_BRN)) 

   is_isq (/*autoinst*/
           // Outputs
           .isq_out_flat                (isq_out_flat[ISQ_LINE_WIDTH*ISQ_DEPTH-1:0]),
           // Inputs
           .inst_in_flat                (inst_in_flat[INST_WIDTH*INST_PORT-1:0]),
           .isq_en                      (isq_en),
           .rst_n                       (rst_n),
           .clk                         (clk),
           .isq_lin_en                  (isq_lin_en[ISQ_DEPTH-1:0]),
           .clr_inst_wat                (clr_inst_wat[ISQ_DEPTH-1:0]),
           .clr_inst_brn_wat            (clr_inst_brn_wat[ISQ_DEPTH-1:0]),
           .fls_inst                    (fls_inst[ISQ_DEPTH-1:0]));

   
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
         .BIT_INST_BRN_WAT              (BIT_INST_BRN_WAT),
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
           .arch                        (arch),
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
         .IS_BIT_INST_VLD               (IS_BIT_INST_VLD),
         .IS_BIT_IDX                    (IS_BIT_IDX),
         .IS_BIT_CTRL_BR                (IS_BIT_CTRL_BR),
         .IS_BIT_CTRL_JMP_VLD           (IS_BIT_CTRL_JMP_VLD),
         .TPU_INST_WIDTH                (TPU_INST_WIDTH)) 

   is_pdc (/*autoinst*/
           // Outputs
           .pdc_clr_inst_wat            (pdc_clr_inst_wat[ISQ_DEPTH-1:0]),
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
