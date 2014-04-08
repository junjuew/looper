`default_nettype none

  //TODO: output all the bits in the tpu_inst?? some may not be needed for next stage. need to strip those bits off

   ////////////////////////////
   // instruction format used for testing:
   // inst idx | inst vld | inst wat | BR | JMP | MULT| ADD | ADDR | lsrc1 | ldst | lsrc2 | pdest
   //     2         1           1      2     1     1     1     1       5       5      5       6
   ///////////////////////////
  
  ///////////////////////////
  // priority decoder
  ////////////////////////
  module pdc(/*autoarg*/
   // Outputs
   clr_inst_wat, mul_ins_to_rf, alu1_ins_to_rf, alu2_ins_to_rf,
   adr_ins_to_rf,
   // Inputs
   fun_rdy_frm_exe, tpu_out_reo_flat, tpu_inst_rdy
   );

   parameter ISQ_DEPTH = 64;
   parameter INST_WIDTH= 56;
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   // 6 is just an arbitrary value for widths of idx bit   
   parameter ISQ_IDX_BITS_NUM= 6;
   // +2 : 1 for vld, 1 for wat
   parameter ISQ_LINE_WIDTH=INST_WIDTH + ISQ_IDX_BITS_NUM + 2;
   // which bit is representing each function unit
   parameter FUN_MULT_BIT= 0;
   parameter FUN_ADD1_BIT= 1;
   parameter FUN_ADD2_BIT= 2;
   parameter FUN_ADDR_BIT= 3;
   //tpu bit
   parameter TPU_BIT_IDX= ISQ_LINE_WIDTH-1;
   parameter TPU_BIT_INST_VLD= ISQ_LINE_WIDTH -1 -ISQ_IDX_BITS_NUM;
   parameter TPU_BIT_INST_WAT= ISQ_LINE_WIDTH -1 -ISQ_IDX_BITS_NUM -1;   
   parameter TPU_BIT_CTRL_MULT= 10;
   parameter TPU_BIT_CTRL_ADD= 11;
   parameter TPU_BIT_CTRL_ADDR= 9;
   parameter TPU_BIT_CTRL_BR= 21;
   parameter TPU_BIT_CTRL_JMP_VLD= 19;      
   //output format
   parameter IS_INST_WIDTH = INST_WIDTH;   
   
   //psrc1 and psrc2 need two more bits than lsrc1, lsrc2, no ldest
   parameter TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5; 
   
   //function unit ready bit
   input wire [3:0] fun_rdy_frm_exe;
   //instructions coming from tpu
   input wire [TPU_INST_WIDTH * ISQ_DEPTH-1:0] tpu_out_reo_flat;
   input wire [ISQ_DEPTH-1:0]                  tpu_inst_rdy;

   output wire [ISQ_DEPTH-1:0]                 clr_inst_wat;

   //output instruction to rf stage
   output wire [TPU_INST_WIDTH -1 :0]          mul_ins_to_rf;
   output wire [TPU_INST_WIDTH -1 :0]          alu1_ins_to_rf;
   output wire [TPU_INST_WIDTH -1 :0]          alu2_ins_to_rf;
   output wire [TPU_INST_WIDTH -1 :0]          adr_ins_to_rf;         
   
   
   //wires decoding flat line from tpu
   wire [TPU_INST_WIDTH-1:0]                                        tpu_out[ISQ_DEPTH-1:0];
   
   ////////////////////////////
   //unflat input tpu wire
   //////////////////////////
   generate
      genvar                                      tpu_lin_i;
      for (tpu_lin_i=0; tpu_lin_i<ISQ_DEPTH; tpu_lin_i=tpu_lin_i+1) 
        begin
           assign tpu_out[tpu_lin_i][TPU_INST_WIDTH-1:0] = tpu_out_reo_flat[TPU_INST_WIDTH*(tpu_lin_i+1)-1 : TPU_INST_WIDTH*tpu_lin_i];
        end
   endgenerate

   //////////////////////////
   // port 1 multiplier
   ////////////////////////
   // whether such line is qualified to be sent through multiplier line
   // condition: 0. multiplier function unit ready
   //            1. such line use multiplier
   //            2. inst valid
   //            3. inst rdy
   //            4. inst wait
   //           
   wire mult_rdy[ISQ_DEPTH -1 : 0];
   wire[TPU_INST_WIDTH-1:0] mult_out[ISQ_DEPTH -1 :0];
   generate
      genvar                                      mult_rdy_i;
      for (mult_rdy_i=0; mult_rdy_i<ISQ_DEPTH; mult_rdy_i=mult_rdy_i+1) 
        begin
           assign mult_rdy[mult_rdy_i] = fun_rdy_frm_exe[FUN_MULT_BIT] && tpu_out[mult_rdy_i][TPU_BIT_CTRL_MULT] && tpu_out[mult_rdy_i][TPU_BIT_INST_VLD] && tpu_inst_rdy[mult_rdy_i] && tpu_out[mult_rdy_i][TPU_BIT_INST_WAT];
        end
   endgenerate
   // priority decoder
   generate
      genvar                                      mult_pdc_i;
      for (mult_pdc_i=0; mult_pdc_i<ISQ_DEPTH; mult_pdc_i=mult_pdc_i+1) 
        begin
           if (mult_pdc_i < ISQ_DEPTH -1 )
             assign mult_out[mult_pdc_i][TPU_INST_WIDTH-1:0] = ( mult_rdy[mult_pdc_i] )? tpu_out[mult_pdc_i][TPU_INST_WIDTH -1 : 0] : mult_out[mult_pdc_i +1][TPU_INST_WIDTH-1:0];
           else // the last line mult_pdc_i == ISQ_DEPTH -1
             assign mult_out[mult_pdc_i][TPU_INST_WIDTH-1:0] = ( mult_rdy[mult_pdc_i] )? tpu_out[mult_pdc_i][TPU_INST_WIDTH -1 : 0] : { (TPU_INST_WIDTH) {1'b0} };
        end
   endgenerate
   // the final output value is output from 0
   assign mul_ins_to_rf[TPU_INST_WIDTH -1 :0] = mult_out[0][TPU_INST_WIDTH -1 :0];
   
   
   //////////////////////////
   // port 2 adder 1
   ////////////////////////
   // whether such line is qualified to be sent through adder1 line
   // condition: 0. adder 1 function unit ready
   //            1. such line use adder 1: branch/JR or ( add + use add1)
   //            2. inst valid
   //            3. inst rdy
   //            4. inst wait
   //
   // add1 and add2 cannot send the same inst
   // currently use genvar to control which add to go to
   // add1_rdy_i %3 dictates
   wire add1_rdy[ISQ_DEPTH -1 : 0];
   wire[TPU_INST_WIDTH-1:0] add1_out[ISQ_DEPTH -1 :0];
   generate
      genvar                                      add1_rdy_i;
      for (add1_rdy_i=0; add1_rdy_i<ISQ_DEPTH; add1_rdy_i=add1_rdy_i+1) 
        begin
           assign add1_rdy[add1_rdy_i] = fun_rdy_frm_exe[FUN_ADD1_BIT] && ( (tpu_out[add1_rdy_i][TPU_BIT_CTRL_ADD] && (add1_rdy_i % 3 == 0)) ||  (tpu_out[add1_rdy_i][TPU_BIT_CTRL_BR:TPU_BIT_CTRL_BR-1] != 2'b00) || tpu_out[add1_rdy_i][TPU_BIT_CTRL_JMP_VLD] ) && tpu_out[add1_rdy_i][TPU_BIT_INST_VLD] && tpu_inst_rdy[add1_rdy_i] && tpu_out[add1_rdy_i][TPU_BIT_INST_WAT];
        end
   endgenerate
   // priority decoder
   generate
      genvar                                      add1_pdc_i;
      for (add1_pdc_i=0; add1_pdc_i<ISQ_DEPTH; add1_pdc_i=add1_pdc_i+1) 
        begin
           if (add1_pdc_i < ISQ_DEPTH -1 )
             assign add1_out[add1_pdc_i][TPU_INST_WIDTH-1:0] = ( add1_rdy[add1_pdc_i] )? tpu_out[add1_pdc_i][TPU_INST_WIDTH -1 : 0] : add1_out[add1_pdc_i +1][TPU_INST_WIDTH-1:0];
           else // the last line add1_pdc_i == ISQ_DEPTH -1
             assign add1_out[add1_pdc_i][TPU_INST_WIDTH-1:0] = ( add1_rdy[add1_pdc_i] )? tpu_out[add1_pdc_i][TPU_INST_WIDTH -1 : 0] :  { (TPU_INST_WIDTH) {1'b0} };
        end
   endgenerate
   // the final output value is output from 0
   assign alu1_ins_to_rf[TPU_INST_WIDTH -1 :0] = add1_out[0][TPU_INST_WIDTH -1 :0];


   
   //////////////////////////
   // port 3 adder 2
   ////////////////////////
   // whether such line is qualified to be sent through adder2 line
   // condition: 0. adder 2 function unit ready
   //            1. such line use adder 1: branch or ( add + use add2)
   //            2. inst valid
   //            3. inst rdy
   //            4. inst wait
   //
   // add1 and add2 cannot send the same inst
   // currently use genvar to control which add to go to
   // add1_rdy_i %3 dictates
   wire add2_rdy[ISQ_DEPTH -1 : 0];
   wire[TPU_INST_WIDTH-1:0] add2_out[ISQ_DEPTH -1 :0];
   generate
      genvar                                      add2_rdy_i;
      for (add2_rdy_i=0; add2_rdy_i<ISQ_DEPTH; add2_rdy_i=add2_rdy_i+1) 
        begin
           assign add2_rdy[add2_rdy_i] = fun_rdy_frm_exe[FUN_ADD2_BIT] && ( tpu_out[add2_rdy_i][TPU_BIT_CTRL_ADD] && (add2_rdy_i % 3 != 0) ) && tpu_out[add2_rdy_i][TPU_BIT_INST_VLD] && tpu_inst_rdy[add2_rdy_i] && tpu_out[add2_rdy_i][TPU_BIT_INST_WAT];
        end
   endgenerate
   // priority decoder
   generate
      genvar                                      add2_pdc_i;
      for (add2_pdc_i=0; add2_pdc_i<ISQ_DEPTH; add2_pdc_i=add2_pdc_i+1) 
        begin
           if (add2_pdc_i < ISQ_DEPTH -1 )
             assign add2_out[add2_pdc_i][TPU_INST_WIDTH-1:0] = ( add2_rdy[add2_pdc_i] )? tpu_out[add2_pdc_i][TPU_INST_WIDTH -1 : 0] : add2_out[add2_pdc_i +1][TPU_INST_WIDTH-1:0];
           else // the last line add2_pdc_i == ISQ_DEPTH -1
             assign add2_out[add2_pdc_i][TPU_INST_WIDTH-1:0] = ( add2_rdy[add2_pdc_i] )? tpu_out[add2_pdc_i][TPU_INST_WIDTH -1 : 0] :  { (TPU_INST_WIDTH) {1'b0} };
        end
   endgenerate
   // the final output value is output from 0
   assign alu2_ins_to_rf[TPU_INST_WIDTH -1 :0] = add2_out[0][TPU_INST_WIDTH -1 :0];


   //////////////////////////
   // port 4 address adder
   ////////////////////////
   // whether such line is qualified to be sent through addr adder line
   // condition: 0. address adder function unit ready
   //            1. such line use address addr
   //            2. inst valid
   //            3. inst rdy
   //            4. inst wait                                                                    
   //
   wire addr_rdy[ISQ_DEPTH -1 : 0];
   wire[TPU_INST_WIDTH-1:0] addr_out[ISQ_DEPTH -1 :0];
   generate
      genvar                                      addr_rdy_i;
      for (addr_rdy_i=0; addr_rdy_i<ISQ_DEPTH; addr_rdy_i=addr_rdy_i+1) 
        begin
           assign addr_rdy[addr_rdy_i] = fun_rdy_frm_exe[FUN_ADDR_BIT] && tpu_out[addr_rdy_i][TPU_BIT_CTRL_ADDR] && tpu_out[addr_rdy_i][TPU_BIT_INST_VLD] && tpu_inst_rdy[addr_rdy_i] && tpu_out[addr_rdy_i][TPU_BIT_INST_WAT];
        end
   endgenerate
   // priority decoder
   generate
      genvar                                      addr_pdc_i;
      for (addr_pdc_i=0; addr_pdc_i<ISQ_DEPTH; addr_pdc_i=addr_pdc_i+1) 
        begin
           if (addr_pdc_i < ISQ_DEPTH -1 )
             assign addr_out[addr_pdc_i][TPU_INST_WIDTH-1:0] = ( addr_rdy[addr_pdc_i] )? tpu_out[addr_pdc_i][TPU_INST_WIDTH -1 : 0] : addr_out[addr_pdc_i +1][TPU_INST_WIDTH-1:0];
           else // the last line addr_pdc_i == ISQ_DEPTH -1
             assign addr_out[addr_pdc_i][TPU_INST_WIDTH-1:0] = ( addr_rdy[addr_pdc_i] )? tpu_out[addr_pdc_i][TPU_INST_WIDTH -1 : 0] :  { (TPU_INST_WIDTH) {1'b0} };
        end
   endgenerate
   // the final output value is output from 0
   assign adr_ins_to_rf[TPU_INST_WIDTH -1 :0] = addr_out[0][TPU_INST_WIDTH -1 :0];



   // send signals out to set wait bit of each instruction to 0
   wire[ISQ_DEPTH -1 :0]  clr_inst_wat_mult;
   wire[ISQ_DEPTH -1 :0]  clr_inst_wat_add1;
   wire[ISQ_DEPTH -1 :0]  clr_inst_wat_add2;
   wire [ISQ_DEPTH -1 :0] clr_inst_wat_addr;
   
   assign clr_inst_wat_mult[ISQ_DEPTH -1 :0] = (mul_ins_to_rf[TPU_BIT_INST_VLD])? (1<<mul_ins_to_rf[TPU_BIT_IDX: TPU_BIT_IDX - (ISQ_IDX_BITS_NUM -1) ]):{(ISQ_DEPTH){1'b0}};
   // only set the wait bit when it's an add
   // branch and jump instruction doesn't set wait bit immediately.
   assign clr_inst_wat_add1[ISQ_DEPTH -1 :0] = (alu1_ins_to_rf[TPU_BIT_INST_VLD] && (2'b00 == alu1_ins_to_rf[TPU_BIT_CTRL_BR:TPU_BIT_CTRL_BR-1]) && (~alu1_ins_to_rf[TPU_BIT_CTRL_JMP_VLD]) )? (1<<alu1_ins_to_rf[TPU_BIT_IDX: TPU_BIT_IDX - (ISQ_IDX_BITS_NUM -1) ]):{(ISQ_DEPTH){1'b0}};
   assign clr_inst_wat_add2[ISQ_DEPTH -1 :0] = (alu2_ins_to_rf[TPU_BIT_INST_VLD])? (1<<alu2_ins_to_rf[TPU_BIT_IDX: TPU_BIT_IDX - (ISQ_IDX_BITS_NUM -1) ]):{(ISQ_DEPTH){1'b0}};
   assign clr_inst_wat_addr[ISQ_DEPTH -1 :0] = (adr_ins_to_rf[TPU_BIT_INST_VLD])? (1<<adr_ins_to_rf[TPU_BIT_IDX: TPU_BIT_IDX - (ISQ_IDX_BITS_NUM -1) ]):{(ISQ_DEPTH){1'b0}};   
   //or these signals to get a sum of what instrcutions' wait to set in one time instance
   assign clr_inst_wat[ISQ_DEPTH -1 :0] = clr_inst_wat_mult[ISQ_DEPTH -1:0] |  clr_inst_wat_add1[ISQ_DEPTH -1:0] |  clr_inst_wat_add2[ISQ_DEPTH -1:0] |  clr_inst_wat_addr[ISQ_DEPTH -1:0];
   
endmodule // isq_lin
