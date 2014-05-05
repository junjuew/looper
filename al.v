//`default_nettype none
/**
 * top level module of allocation stage 
 */
  module al(/*autoarg*/
   // Outputs
   inst_out_to_SCH0, inst_out_to_SCH1, inst_out_to_SCH2,
   inst_out_to_SCH3, no_empt_preg_to_IF, rcvr_pc_to_CMT,
   reg_wrt_to_CMT, st_en_to_CMT, spec_to_CMT, brch_mode_to_CMT,ld_en_to_CMT,
   brch_pred_res_to_CMT, ld_indx_to_WB, st_indx_to_WB,
   all_nop_to_CMTIS, lbd_state_out_to_SCH, fnsh_unrll_out_to_SCH,
   loop_strt_to_SCH,
   // Inputs
   free_pr_from_SCH0, free_pr_from_SCH1, free_pr_from_SCH2,
   free_pr_from_SCH3, inst_from_ID0, inst_from_ID1, inst_from_ID2,
   inst_from_ID3, nxt_indx_from_CMT, clk, rst_n, stall,
   lbd_state_out_from_ID, fnsh_unrll_out_from_ID, loop_strt_from_ID,
   full_signal_from_SCH, mis_pred_from_CMT, mis_pred_indx_from_CMT,
   cmt_brch_from_CMT, cmt_brch_indx_from_CMT,free_pr_num_from_CMT
   );
   
   
   input wire [5:0] free_pr_from_SCH0,free_pr_from_SCH1,free_pr_from_SCH2,free_pr_from_SCH3;
   input wire [65:0] inst_from_ID0,inst_from_ID1,inst_from_ID2,inst_from_ID3;
   input wire [6:0]  nxt_indx_from_CMT;
   input wire 	     clk,rst_n,stall;
   input wire [1:0]  lbd_state_out_from_ID;
   input wire 	     fnsh_unrll_out_from_ID,loop_strt_from_ID;
   input wire 	     full_signal_from_SCH;
   input wire 	     mis_pred_from_CMT;
   input wire [5:0]  mis_pred_indx_from_CMT;
   input wire 	     cmt_brch_from_CMT;
   input wire [5:0]  cmt_brch_indx_from_CMT;
   input wire [2:0]  free_pr_num_from_CMT;
   
   

   output wire [55:0] inst_out_to_SCH0,inst_out_to_SCH1,inst_out_to_SCH2,inst_out_to_SCH3;
   output wire 	      no_empt_preg_to_IF;
   output wire [63:0] rcvr_pc_to_CMT;
   output wire [3:0]  reg_wrt_to_CMT,st_en_to_CMT,spec_to_CMT,ld_en_to_CMT;
   output wire [7:0]  brch_mode_to_CMT;
   output wire [3:0]  brch_pred_res_to_CMT;
   output wire [31:0] ld_indx_to_WB,st_indx_to_WB;
   output wire 	      all_nop_to_CMTIS;

   output wire [1:0]  lbd_state_out_to_SCH;
   output wire 	      fnsh_unrll_out_to_SCH;
   output wire 	      loop_strt_to_SCH;

   // for output package
   wire [55:0] inst_out_to_SCH0_iner;
   wire [55:0] inst_out_to_SCH1_iner;
   wire [55:0] inst_out_to_SCH2_iner;
   wire [55:0] inst_out_to_SCH3_iner;

   wire [31:0] ld_indx_to_lsq,st_indx_to_lsq;
   
   // for instruction checker
   wire 	      all_nop_from_instChecker;
   wire 	      all_nop_from_branchUnit;
   wire [3:0] 	      pr_need_inst;
   
   
   //for branchUnit
   wire [6:0] 	      flush_pos;
   wire 	      flush;

   // for freelist
   wire [5:0] 	      pr_num0,pr_num1,pr_num2,pr_num3;
   wire [6:0] 	      curr_pos;
   
   //instruction checker
   instChecker ic0(/*autoinst*/
		   // Outputs
		   .pr_need_inst_out	(pr_need_inst),
		   .rcvr_pc_to_rob	(rcvr_pc_to_CMT),
		   .str_en_to_rob	(st_en_to_CMT),
		   .ld_en_to_rob	(ld_en_to_CMT),
		   .spec_brch_to_rob	(spec_to_CMT),
		   .brch_mode_to_rob	(brch_mode_to_CMT),
		   .brch_pred_res_to_rob(brch_pred_res_to_CMT),
		   .reg_write_to_rob    (reg_wrt_to_CMT),
		   .all_nop_from_instChecker(all_nop_from_instChecker),
		   // Inputs
		   .inst0_in		(inst_from_ID0),
		   .inst1_in		(inst_from_ID1),
		   .inst2_in		(inst_from_ID2),
		   .inst3_in		(inst_from_ID3));


   //branchUnit
   branchUnit br0(/*autoinst*/
		  // Outputs
		  .flush_pos		(flush_pos),
		  .flush		(flush),
		  .all_nop_from_branchUnit(all_nop_from_branchUnit),
		  // Inputs
		  .inst0		(inst_from_ID0),
		  .inst1		(inst_from_ID1),
		  .inst2		(inst_from_ID2),
		  .inst3		(inst_from_ID3),
		  .nxt_indx		(nxt_indx_from_CMT),
		  .brch_mis_indx	(mis_pred_indx_from_CMT),
		  .curr_pos		(curr_pos),
		  .pr_need_inst		(pr_need_inst),
		  .mis_pred		(mis_pred_from_CMT),
		  .cmt_brch_indx	(cmt_brch_indx_from_CMT),
		  .cmt_brch		(cmt_brch_from_CMT),
		  .clk			(clk),
		  .rst_n		(rst_n),
		  .stall                (stall | fnsh_unrll_out_from_ID | full_signal_from_SCH ));
   
   //freeList
   freeList f0(/*autoinst*/
	       // Outputs
	       .pr_num_out0		(pr_num0),
	       .pr_num_out1		(pr_num1),
	       .pr_num_out2		(pr_num2),
	       .pr_num_out3		(pr_num3),
	       .list_empty		(no_empt_preg_to_IF),
	       .curr_pos		(curr_pos),
	       // Inputs
	       .free_pr_num_in0		(free_pr_from_SCH0),
	       .free_pr_num_in1		(free_pr_from_SCH1),
	       .free_pr_num_in2		(free_pr_from_SCH2),
	       .free_pr_num_in3		(free_pr_from_SCH3),
	       .flush_pos		(flush_pos),
	       .flush			(flush),
	       .pr_need_inst_in		(pr_need_inst),
	       .free_pr_num		(free_pr_num_from_CMT),
	       .clk			(clk),
	       .rst_n			(rst_n),
	       .stall			(stall | fnsh_unrll_out_from_ID | full_signal_from_SCH ));

   
   //reorder Unit
   reorderUnit r0(/*autoinst*/
		  // Outputs
		  .ld_indx_to_lsq	(ld_indx_to_lsq),
		  .st_indx_to_lsq	(st_indx_to_lsq),
		  // Inputs
		  .inst_in0		(inst_from_ID0),
		  .inst_in1		(inst_from_ID1),
		  .inst_in2		(inst_from_ID2),
		  .inst_in3		(inst_from_ID3),
		  .nxt_indx		(nxt_indx_from_CMT));

   //instCombiner
   instCombiner iscb0(/*autoinst*/
		      // Outputs
		      .inst_out0	(inst_out_to_SCH0_iner),
		      .inst_out1	(inst_out_to_SCH1_iner),
		      .inst_out2	(inst_out_to_SCH2_iner),
		      .inst_out3	(inst_out_to_SCH3_iner),
		      // Inputs
		      .inst0		(inst_from_ID0),
		      .inst1		(inst_from_ID1),
		      .inst2		(inst_from_ID2),
		      .inst3		(inst_from_ID3),
		      .pr_num_in0	(pr_num0),
		      .pr_num_in1	(pr_num1),
		      .pr_num_in2	(pr_num2),
		      .pr_num_in3	(pr_num3),
		      .pr_need_list_in	(pr_need_inst));

   assign all_nop_to_CMTIS = all_nop_from_instChecker | all_nop_from_branchUnit | stall;

   assign ld_indx_to_WB = (stall) ? 32'b0 : ld_indx_to_lsq;
   assign st_indx_to_WB = (stall) ? 32'b0 : st_indx_to_lsq;
   
   
   assign inst_out_to_SCH0 = (stall) ? 56'b0 : inst_out_to_SCH0_iner;
   assign inst_out_to_SCH1 = (stall) ? 56'b0 : inst_out_to_SCH1_iner;
   assign inst_out_to_SCH2 = (stall) ? 56'b0 : inst_out_to_SCH2_iner;
   assign inst_out_to_SCH3 = (stall) ? 56'b0 : inst_out_to_SCH3_iner;

endmodule // al
