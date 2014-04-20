onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /IF_ID_tb/IF_ID_DUT/clk
add wave -noupdate /IF_ID_tb/IF_ID_DUT/rst_n
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pc_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/inst_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/recv_pc_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pred_result_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/stall
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pc_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/inst_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/recv_pc_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pred_result_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/enable
add wave -noupdate -divider ID
add wave -noupdate -radix hexadecimal /IF_ID_tb/ID_top_DUT/pc_in_frm_IF
add wave -noupdate /IF_ID_tb/ID_top_DUT/recv_pc_in_frm_IF
add wave -noupdate /IF_ID_tb/ID_top_DUT/pred_result_frm_IF
add wave -noupdate /IF_ID_tb/ID_top_DUT/mis_pred_in_frm_ROB
add wave -noupdate /IF_ID_tb/ID_top_DUT/clk
add wave -noupdate /IF_ID_tb/ID_top_DUT/rst
add wave -noupdate /IF_ID_tb/ID_top_DUT/dcd_inst1_out_to_AL
add wave -noupdate /IF_ID_tb/ID_top_DUT/dcd_inst2_out_to_AL
add wave -noupdate /IF_ID_tb/ID_top_DUT/dcd_inst3_out_to_AL
add wave -noupdate /IF_ID_tb/ID_top_DUT/dcd_inst4_out_to_AL
add wave -noupdate /IF_ID_tb/ID_top_DUT/lbd_state_out_to_AL
add wave -noupdate /IF_ID_tb/ID_top_DUT/fnsh_unrll_out_to_AL
add wave -noupdate /IF_ID_tb/ID_top_DUT/stll_ftch_out_to_IF
add wave -noupdate /IF_ID_tb/ID_top_DUT/loop_strt_out_to_AL
add wave -noupdate /IF_ID_tb/ID_top_DUT/bits11_8_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/bits7_4_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/bits3_0_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/opco_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_off_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/LDI_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/LDI_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/LDI_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/LDI_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemRd_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemRd_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemRd_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemRd_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemWr_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemWr_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemWr_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/MemWr_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/invRt_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/invRt_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/invRt_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/invRt_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rs_v_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rs_v_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rs_v_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rs_v_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rd_v_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rd_v_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rd_v_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rd_v_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rt_v_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rt_v_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rt_v_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/Rt_v_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/im_v_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/im_v_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/im_v_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/im_v_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_v_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_v_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_v_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_v_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/RegWr_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/RegWr_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/RegWr_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/RegWr_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_add_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_add_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_add_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_add_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_mult_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_mult_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_mult_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_mult_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_addr_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_addr_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_addr_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_to_addr_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/brn_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/brn_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/brn_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/brn_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/jmp_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_ctrl_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_ctrl_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_ctrl_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/ALU_ctrl_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/bck_lp_bus
add wave -noupdate /IF_ID_tb/ID_top_DUT/inst_vld_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/inst_vld_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/inst_vld_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/inst_vld_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/fnsh_unrll_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/bck_lp_out1
add wave -noupdate /IF_ID_tb/ID_top_DUT/bck_lp_out2
add wave -noupdate /IF_ID_tb/ID_top_DUT/bck_lp_out3
add wave -noupdate /IF_ID_tb/ID_top_DUT/bck_lp_out4
add wave -noupdate /IF_ID_tb/ID_top_DUT/inst_valid_in
add wave -noupdate -divider LAT
add wave -noupdate -radix hexadecimal /IF_ID_tb/ID_top_DUT/inst_in_frm_IF
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/bck_lp_bus_in
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/inst_in
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/pc_in
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/mis_pred_in
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/clk
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/rst
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/lbd_state_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/fnsh_unrll_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/stll_ftch_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/loop_strt_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/inst_valid_out
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/state
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/nxt_state
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/tbl_entry_en1
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/tbl_entry_en2
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/tbl_entry_en3
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/tbl_entry_en4
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/LAT_pointer
add wave -noupdate -radix binary /IF_ID_tb/ID_top_DUT/LAT_DUT/train_content
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/num_of_inst_train
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/stll_ftch_cnt
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/fallthrough_addr_train
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/start_addr
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/fallthrough_addr_dispatch
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/temp_addr
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/pc_in_test
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/max_unroll_train
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/max_unroll_dispatch
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/inst_valid_out_type
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/num_of_inst_train_type
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/write2LAT
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/stll_ftch_cnt_type
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp1_train
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp2_train
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp3_train
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp4_train
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp1_dispatch
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp2_dispatch
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp3_dispatch
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/end_lp4_dispatch
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/dispatch1
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/dispatch2
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/dispatch3
add wave -noupdate /IF_ID_tb/ID_top_DUT/LAT_DUT/dispatch4
add wave -noupdate -divider IF_ID
add wave -noupdate /IF_ID_tb/IF_ID_DUT/clk
add wave -noupdate /IF_ID_tb/IF_ID_DUT/rst_n
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pc_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/inst_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/recv_pc_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pred_result_if_id_in
add wave -noupdate /IF_ID_tb/IF_ID_DUT/stall
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pc_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/inst_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/recv_pc_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/pred_result_if_id_out
add wave -noupdate /IF_ID_tb/IF_ID_DUT/enable
add wave -noupdate -divider IF
add wave -noupdate /IF_ID_tb/fetch_DUT/clk
add wave -noupdate /IF_ID_tb/fetch_DUT/rst_n
add wave -noupdate /IF_ID_tb/fetch_DUT/stall_fetch
add wave -noupdate /IF_ID_tb/fetch_DUT/loop_start
add wave -noupdate /IF_ID_tb/fetch_DUT/decr_count_brnch
add wave -noupdate /IF_ID_tb/fetch_DUT/has_mispredict
add wave -noupdate /IF_ID_tb/fetch_DUT/jump_base_rdy_from_rf
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_recovery
add wave -noupdate /IF_ID_tb/fetch_DUT/jump_base_from_rf
add wave -noupdate /IF_ID_tb/fetch_DUT/exter_pc
add wave -noupdate /IF_ID_tb/fetch_DUT/exter_pc_en
add wave -noupdate /IF_ID_tb/fetch_DUT/mispred_num
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_to_dec
add wave -noupdate /IF_ID_tb/fetch_DUT/inst_to_dec
add wave -noupdate /IF_ID_tb/fetch_DUT/recv_pc_to_dec
add wave -noupdate /IF_ID_tb/fetch_DUT/pred_result_to_dec
add wave -noupdate /IF_ID_tb/fetch_DUT/brnch_addr_pc0
add wave -noupdate /IF_ID_tb/fetch_DUT/brnch_addr_pc1
add wave -noupdate /IF_ID_tb/fetch_DUT/jump_addr_pc
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_plus4
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_bhndlr
add wave -noupdate /IF_ID_tb/fetch_DUT/pc
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_plus1
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_plus2
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_plus3
add wave -noupdate /IF_ID_tb/fetch_DUT/inst0
add wave -noupdate /IF_ID_tb/fetch_DUT/inst1
add wave -noupdate /IF_ID_tb/fetch_DUT/inst2
add wave -noupdate /IF_ID_tb/fetch_DUT/inst3
add wave -noupdate /IF_ID_tb/fetch_DUT/instruction0
add wave -noupdate /IF_ID_tb/fetch_DUT/instruction1
add wave -noupdate /IF_ID_tb/fetch_DUT/instruction2
add wave -noupdate /IF_ID_tb/fetch_DUT/instruction3
add wave -noupdate /IF_ID_tb/fetch_DUT/brnch_inst0
add wave -noupdate /IF_ID_tb/fetch_DUT/brnch_inst1
add wave -noupdate /IF_ID_tb/fetch_DUT/brnch_pc_sel_from_bhndlr
add wave -noupdate /IF_ID_tb/fetch_DUT/isImJmp
add wave -noupdate /IF_ID_tb/fetch_DUT/PC_select
add wave -noupdate /IF_ID_tb/fetch_DUT/pred_to_pcsel
add wave -noupdate /IF_ID_tb/fetch_DUT/pc_from_mux
add wave -noupdate /IF_ID_tb/fetch_DUT/stall_for_jump
add wave -noupdate /IF_ID_tb/fetch_DUT/update_bpred
add wave -noupdate /IF_ID_tb/fetch_DUT/pcsel_from_bhndlr
add wave -noupdate /IF_ID_tb/fetch_DUT/jump_for_pcsel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9515 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 286
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {105 ns}
