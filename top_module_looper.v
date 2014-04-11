module top_module_looper(clk,rst_n);
input clk, rst_n;






fetch fetch(.clk(clk),.rst_n(rst_n),
	//input	
	stall_fetch,loop_start,decr_count_brnch,has_mispredict,
	jump_base_rdy_from_rf, pc_recovery,jump_base_from_rf,
	exter_pc,exter_pc_en,mispred_num,
	//output
	pc_to_dec,inst_to_dec, recv_pc_to_dec,pred_result_to_dec);

IF_ID IF_ID(.clk(clk), .rst_n(rst_n),
	pc_if_id_in,inst_if_id_in,recv_pc_if_id_in,pred_result_if_id_in,
	pc_if_id_out,inst_if_id_out, recv_pc_if_id_out,pred_result_if_id_out
	);


ID_top ID_top(
	// input
	inst_valid_in_frm_IF,
	inst_in_frm_IF,
	pc_in_frm_IF,
	mis_pred_in_frm_ROB,
	recv_pc_in_frm_IF,
	pred_result_frm_IF,
	.clk(clk),
	.rst(~rst_n),

	// output
	dcd_inst1_out_to_AL,
	dcd_inst2_out_to_AL,
	dcd_inst3_out_to_AL,
	dcd_inst4_out_to_AL,
	lbd_state_out_to_AL,
	fnsh_unrll_out_to_AL,
	stll_ftch_out_to_IF,
	loop_strt_out_to_AL
	);









endmodule
