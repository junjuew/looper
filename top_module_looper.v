module top_module_looper(clk, rst_n, extern_pc, extern_pc_en);
input clk, rst_n;
input [15:0] extern_pc;
input extern_pc_en;

// IF output wires
wire [63:0] pc_to_dec,inst_to_dec,recv_pc_to_dec;
wire [3:0] pred_result_to_dec;

// IF_ID wires
wire [63:0] pc_if_id_out, inst_if_id_out, recv_pc_if_id_out;
wire [3:0] pred_result_if_id_out;

// ID output wires
wire [65:0]	dcd_inst1_out_to_AL, dcd_inst2_out_to_AL, dcd_inst3_out_to_AL, dcd_inst4_out_to_AL;
wire [1:0]	lbd_state_out_to_AL;
wire fnsh_unrll_out_to_AL, stll_ftch_out_to_IF;
wire loop_strt_out_to_AL;

// ID_AL output wires
wire [65:0] inst0_id_al_out, inst1_id_al_out, inst2_id_al_out, inst3_id_al_out;
wire [1:0] lbd_state_id_al_out;
wire fnsh_unrll_id_al_out;
wire loop_strt_id_al_out;

// AL output wires
wire [55:0] inst_out_to_SCH0,inst_out_to_SCH1,inst_out_to_SCH2,inst_out_to_SCH3;
wire 	    no_empt_preg_to_IF;
wire [63:0] rcvr_pc_to_CMT;
wire [3:0]  reg_wrt_to_CMT,st_en_to_CMT,ld_en_to_CMT,spec_to_CMT;
wire [7:0]  brch_mode_to_CMT;
wire [3:0]  brch_pred_res_to_CMT;
wire [31:0] ld_indx_to_WB,st_indx_to_WB;
wire 	    all_nop_to_CMTIS;
wire [1:0]  lbd_state_out_to_SCH;
wire 	    fnsh_unrll_out_to_SCH;
wire 	    loop_strt_to_SCH;

// IS output wires
wire ful_to_al_is_out;
wire [65:0] mul_ins_to_rf_is_out;
wire [65:0] alu1_ins_to_rf_is_out; 
wire [65:0] alu2_ins_to_rf_is_out;
wire [65:0] adr_ins_to_rf_is_out;

// IS_RF output wires
wire [65:0] mult_inst_pkg_is_rf_out;
wire [65:0] alu1_inst_pkg_is_rf_out;
wire [65:0] alu2_inst_pkg_is_rf_out; 
wire [65:0] addr_inst_pkg_is_rf_out;

// RF output wires
wire   [15:0]          mult_op1_data_rf_out;
wire   [15:0]          mult_op2_data_rf_out;
wire   [15:0]          alu1_op1_data_rf_out;
wire   [15:0]          alu1_op2_data_rf_out;
wire   [15:0]          alu2_op1_data_rf_out;
wire   [15:0]          alu2_op2_data_rf_out;
wire   [15:0]          addr_op1_data_rf_out;
wire   [15:0]          addr_op2_data_rf_out;
wire   [15:0]          data_str_rf_out;

// RF_EX output wires
wire   [15:0]          mult_op1_data_rf_ex_out;
wire   [15:0]          mult_op2_data_rf_ex_out;
wire   [15:0]          alu1_op1_data_rf_ex_out;
wire   [15:0]          alu1_op2_data_rf_ex_out;
wire   [15:0]          alu2_op1_data_rf_ex_out;
wire   [15:0]          alu2_op2_data_rf_ex_out;
wire   [15:0]          addr_op1_data_rf_ex_out;
wire   [15:0]          data_str_rf_ex_out;

wire   [15:0]          alu1_imm_rf_ex_out;
wire   [15:0]          alu2_imm_rf_ex_out;
wire   [15:0]          mult_imm_rf_ex_out;
wire   [15:0]          addr_imm_rf_ex_out;
wire                   alu1_imm_vld_rf_ex_out;
wire                   alu2_imm_vld_rf_ex_out;
wire                   mult_imm_vld_rf_ex_out;
wire                   addr_imm_vld_rf_ex_out;

wire                   alu1_inst_vld_rf_ex_out;
wire                   alu2_inst_vld_rf_ex_out;
wire                   mult_inst_vld_rf_ex_out;
wire                   addr_inst_vld_rf_ex_out;

wire                   alu1_mem_wrt_rf_ex_out;
wire                   alu2_mem_wrt_rf_ex_out;
wire                   mult_mem_wrt_rf_ex_out;
wire                   addr_mem_wrt_rf_ex_out;

wire                   alu1_mem_rd_rf_ex_out;
wire                   alu2_mem_rd_rf_ex_out;
wire                   mult_mem_rd_rf_ex_out;
wire                   addr_mem_rd_rf_ex_out;

wire                   alu1_en_rf_ex_out;
wire                   alu2_en_rf_ex_out;
wire                   mult_en_rf_ex_out; 
wire                   addr_en_rf_ex_out;

wire                   alu1_ldi_rf_ex_out;
wire                   alu2_ldi_rf_ex_out;
wire                   mult_ldi_rf_ex_out;
wire                   addr_ldi_rf_ex_out;

wire   [2:0]           alu1_mode_rf_ex_out;
wire   [2:0]           alu2_mode_rf_ex_out;

wire   [5:0]           alu1_done_idx_rf_ex_out;
wire   [5:0]           alu2_done_idx_rf_ex_out;
wire   [5:0]           mult_done_idx_rf_ex_out;
wire   [5:0]           addr_done_idx_rf_ex_out;
wire   [1:0]           brn_cmp_rslt_rf_out;

wire   [5:0]           phy_addr_alu1_rf_ex_out;
wire   [5:0]           phy_addr_alu2_rf_ex_out;
wire   [5:0]           phy_addr_mult_rf_ex_out;
wire   [5:0]           phy_addr_ld_rf_ex_out;

wire                   reg_wrt_mul_rf_ex_out;
wire                   reg_wrt_alu1_rf_ex_out;
wire                   reg_wrt_alu2_rf_ex_out;
wire                   reg_wrt_ld_rf_ex_out;

wire                   alu1_invtRt_rf_ex_out; //
wire                   alu2_invtRt_rf_ex_out; //
wire                   mult_invtRt_rf_ex_out; //
wire                   addr_invtRt_rf_ex_out; //

// EX output wires
wire [15:0]            alu1_data_ex_out;
wire [15:0]            alu2_data_ex_out;
wire [15:0]            mult_data_ex_out;
wire [15:0]            addr_data_ex_out;

wire                   mult_valid_ex_out;
wire                   mult_free_ex_is_out;

// EX_WB output wires
wire				   reg_wrt_mul_wb_rf;
wire [5:0]             wrt_mult_dst_pnum;
wire [15:0]            wrt_mult_data;
wire                   reg_wrt_alu1_wb_rf;
wire [5:0]             wrt_alu1_dst_pnum;
wire [15:0]            wrt_alu1_data;
wire                   reg_wrt_alu2_wb_rf; 
wire [5:0]             wrt_alu2_dst_pnum;
wire [15:0]            wrt_alu2_data;
wire                   reg_wrt_addr_wb_rf;
wire [5:0]             wrt_addr_dst_pnum;
wire [15:0]            wrt_addr_data;

wire [15:0]            data_str_ex_wb_out;
wire mult_valid_wb_ex_wb_out;
wire mult_free_ex_wb_out;

wire alu1_mem_wrt_ex_wb_out; //?
wire alu2_mem_wrt_ex_wb_out; //?
wire mult_mem_wrt_ex_wb_out; //?
wire addr_mem_wrt_ex_wb_out; //

wire alu1_mem_rd_ex_wb_out; //?
wire alu2_mem_rd_ex_wb_out; //?
wire mult_mem_rd_ex_wb_out; //?
wire addr_mem_rd_ex_wb_out; //

wire alu1_done_vld_ex_wb_out;
wire alu2_done_vld_ex_wb_out;
wire mult_done_vld_ex_wb_out;
wire addr_done_vld_ex_wb_out;
 
wire [5:0] alu1_done_idx_ex_wb_out;
wire [5:0] alu2_done_idx_ex_wb_out;
wire [5:0] mult_done_idx_ex_wb_out;
wire [5:0] addr_done_idx_ex_wb_out;

// WB output wires
wire stll_wb_out;
wire vld_ld_wb_out;
wire reg_wrt_ld_wb_out;
wire str_iss_wb_out;
wire [5:0] indx_ld_wb_out;
wire [5:0] phy_addr_ld_wb_out;
wire [15:0] data_ld_wb_out;

// ROB output wires
wire [6:0] next_idx_ROB_out;
wire mis_pred_ROB_out;
wire flush_ROB_out; 
wire [5:0] mis_pred_brnc_idx_ROB_out;
wire cmt_brnc_ROB_out;
wire [5:0] cmt_brnc_idx_ROB_out;
wire decr_brnc_num_ROB_out;
wire [15:0] rcvr_PC_out_ROB_out;
wire brnc_pred_ROB_out;
wire rob_full_stll_ROB_out;
wire rob_empt_ROB_out;
wire cmmt_st_ROB_out;
wire [4:0] mis_pred_ld_ptr_num_ROB_out;
wire [3:0] mis_pred_st_ptr_num_ROB_out;
wire [4:0] cmmt_ld_ptr_num_ROB_out;
wire [5:0] free_preg_num1_ROB_out;
wire [5:0] free_preg_num2_ROB_out;
wire [5:0] free_preg_num3_ROB_out;
wire [5:0] free_preg_num4_ROB_out;
wire [2:0] free_preg_cnt_ROB_out; 

wire jump_base_rdy_from_rf;
assign jump_base_rdy_from_rf = (alu1_inst_pkg_is_rf_out[18:16] == 3'b101) ? 1:0;


// implementation of all the modules
fetch fetch_DUT(.clk(clk),.rst_n(rst_n),
	//input	
	.stall_fetch(stll_ftch_out_to_IF),
/* -----\/----- EXCLUDED -----\/-----
	.loop_start(loop_strt_out_to_AL),
 -----/\----- EXCLUDED -----/\----- */
	.loop_start(1'b0),	
	.decr_count_brnch(cmt_brnc_ROB_out),
	.has_mispredict(mis_pred_ROB_out),
	.jump_base_rdy_from_rf(jump_base_rdy_from_rf),
	.pc_recovery(rcvr_PC_out_ROB_out),
	.jump_base_from_rf(alu1_op1_data_rf_out),
	.exter_pc(extern_pc),
	.exter_pc_en(extern_pc_en),
	.mispred_num(decr_brnc_num_ROB_out),
    .brnc_pred_log(brnc_pred_ROB_out),
	//output
	.pc_to_dec(pc_to_dec),
	.inst_to_dec(inst_to_dec), 
    .recv_pc_to_dec(recv_pc_to_dec), 
	.pred_result_to_dec(pred_result_to_dec) 
);

IF_ID IF_ID_DUT(.clk(clk), .rst_n(rst_n), .stall(1'b0),
	//input	
	.pc_if_id_in(pc_to_dec),
	.inst_if_id_in(inst_to_dec),
    .recv_pc_if_id_in(recv_pc_to_dec),
	.pred_result_if_id_in(pred_result_to_dec),
	//output
	.pc_if_id_out(pc_if_id_out),
	.inst_if_id_out(inst_if_id_out), 
    .recv_pc_if_id_out(recv_pc_if_id_out), 
	.pred_result_if_id_out(pred_result_if_id_out)
);

ID_top ID_top_DUT(.clk(clk), .rst(~rst_n),
	// input
	.inst_in_frm_IF(inst_if_id_out),
	.pc_in_frm_IF(pc_if_id_out),
	.mis_pred_in_frm_ROB(mis_pred_ROB_out),
	.recv_pc_in_frm_IF(recv_pc_if_id_out),
	.pred_result_frm_IF(pred_result_if_id_out),

	// output
	.dcd_inst1_out_to_AL(dcd_inst1_out_to_AL),
	.dcd_inst2_out_to_AL(dcd_inst2_out_to_AL),
	.dcd_inst3_out_to_AL(dcd_inst3_out_to_AL),
	.dcd_inst4_out_to_AL(dcd_inst4_out_to_AL),
	.lbd_state_out_to_AL(lbd_state_out_to_AL),
	.fnsh_unrll_out_to_AL(fnsh_unrll_out_to_AL),
	.stll_ftch_out_to_IF(stll_ftch_out_to_IF),
	.loop_strt_out_to_AL(loop_strt_out_to_AL)
);

ID_AL ID_AL_DUT(.clk(clk), .rst_n(rst_n), .stall(1'b0),
	// input
	.inst0_id_al_in(dcd_inst1_out_to_AL),
	.inst1_id_al_in(dcd_inst2_out_to_AL),
	.inst2_id_al_in(dcd_inst3_out_to_AL),
	.inst3_id_al_in(dcd_inst4_out_to_AL),
	.lbd_state_id_al_in(lbd_state_out_to_AL),
	.fnsh_unrll_id_al_in(fnsh_unrll_out_to_AL),
	.loop_strt_id_al_in(loop_strt_out_to_AL),

	// output
	.inst0_id_al_out(inst0_id_al_out), 
	.inst1_id_al_out(inst1_id_al_out),  
	.inst2_id_al_out(inst2_id_al_out),  
	.inst3_id_al_out(inst3_id_al_out), 
	.lbd_state_id_al_out(lbd_state_id_al_out),
	.fnsh_unrll_id_al_out(fnsh_unrll_id_al_out),
	.loop_strt_id_al_out(loop_strt_id_al_out)
);

al al_DUT(.clk(clk), .rst_n(rst_n),
	// Inputs
	.free_pr_from_SCH0(free_preg_num1_ROB_out), 
	.free_pr_from_SCH1(free_preg_num2_ROB_out), 
	.free_pr_from_SCH2(free_preg_num3_ROB_out),
	.free_pr_from_SCH3(free_preg_num4_ROB_out), 
	.inst_from_ID0(inst0_id_al_out), 
	.inst_from_ID1(inst1_id_al_out), 
	.inst_from_ID2(inst2_id_al_out),
	.inst_from_ID3(inst3_id_al_out), 
	.nxt_indx_from_CMT(next_idx_ROB_out),
	.stall(rob_full_stll_ROB_out), 
	.lbd_state_out_from_ID(lbd_state_id_al_out), 
	.fnsh_unrll_out_from_ID(fnsh_unrll_id_al_out), 
	.loop_strt_from_ID(loop_strt_id_al_out),
	.full_signal_from_SCH(ful_to_al_is_out), 
	.mis_pred_from_CMT(mis_pred_ROB_out), 
	.mis_pred_indx_from_CMT(mis_pred_brnc_idx_ROB_out),
	.cmt_brch_from_CMT(cmt_brnc_ROB_out), 
	.cmt_brch_indx_from_CMT(cmt_brnc_idx_ROB_out),
	.free_pr_num_from_CMT(free_preg_cnt_ROB_out),
	// Outputs
	.inst_out_to_SCH0(inst_out_to_SCH0), 
	.inst_out_to_SCH1(inst_out_to_SCH1), 
	.inst_out_to_SCH2(inst_out_to_SCH2),
	.inst_out_to_SCH3(inst_out_to_SCH3), 
	.no_empt_preg_to_IF(no_empt_preg_to_IF), 
	.rcvr_pc_to_CMT(rcvr_pc_to_CMT),
	.reg_wrt_to_CMT(reg_wrt_to_CMT), 
	.st_en_to_CMT(st_en_to_CMT), 
	.ld_en_to_CMT(ld_en_to_CMT), 
	.spec_to_CMT(spec_to_CMT), 
	.brch_mode_to_CMT(brch_mode_to_CMT),
	.brch_pred_res_to_CMT(brch_pred_res_to_CMT), 
	.ld_indx_to_WB(ld_indx_to_WB), 
	.st_indx_to_WB(st_indx_to_WB),
	.all_nop_to_CMTIS(all_nop_to_CMTIS), 
	.lbd_state_out_to_SCH(lbd_state_out_to_SCH), 
	.fnsh_unrll_out_to_SCH(fnsh_unrll_out_to_SCH),
	.loop_strt_to_SCH(loop_strt_to_SCH)
);

is is_DUT(.clk(clk), .rst_n(rst_n),
	// Inputs
	.inst_frm_al({inst_out_to_SCH3,inst_out_to_SCH2,inst_out_to_SCH1,inst_out_to_SCH0}), 
	.fls_frm_rob({flush_ROB_out,mis_pred_brnc_idx_ROB_out}), 
	.cmt_frm_rob({cmt_brnc_ROB_out,cmt_brnc_idx_ROB_out}), 
	.fun_rdy_frm_exe({3'b111,mult_free_ex_is_out}),
	.prg_rdy_frm_exe({reg_wrt_mul_wb_rf,mult_done_idx_ex_wb_out,reg_wrt_alu1_wb_rf,alu1_done_idx_ex_wb_out,reg_wrt_alu2_wb_rf,alu2_done_idx_ex_wb_out,reg_wrt_ld_wb_out,indx_ld_wb_out}), 
	.lop_sta(loop_strt_to_SCH), 
	// Outputs
	.ful_to_al(ful_to_al_is_out), 
	.mul_ins_to_rf(mul_ins_to_rf_is_out), 
	.alu1_ins_to_rf(alu1_ins_to_rf_is_out), 
	.alu2_ins_to_rf(alu2_ins_to_rf_is_out),
	.adr_ins_to_rf(adr_ins_to_rf_is_out) 
);

IS_RF IS_RF(.clk(clk), .rst_n(rst_n), .stall(1'b0),
	// Inputs
	.mult_inst_pkg_in(mul_ins_to_rf_is_out),
	.alu1_inst_pkg_in(alu1_ins_to_rf_is_out),
	.alu2_inst_pkg_in(alu2_ins_to_rf_is_out),
	.addr_inst_pkg_in(adr_ins_to_rf_is_out),
	// Outputs
	.mult_inst_pkg_out(mult_inst_pkg_is_rf_out),
	.alu1_inst_pkg_out(alu1_inst_pkg_is_rf_out),
	.alu2_inst_pkg_out(alu2_inst_pkg_is_rf_out),
	.addr_inst_pkg_out(addr_inst_pkg_is_rf_out)
);

reg_file reg_file_DUT(.clk(clk), .rst_n(rst_n),
	// Inputs
	.read_mult_op1_pnum(mult_inst_pkg_is_rf_out[57:52]),
	.read_mult_op2_pnum(mult_inst_pkg_is_rf_out[50:45]),
	.read_alu1_op1_pnum(alu1_inst_pkg_is_rf_out[57:52]),
	.read_alu1_op2_pnum(alu1_inst_pkg_is_rf_out[50:45]), 
	.read_alu2_op1_pnum(alu2_inst_pkg_is_rf_out[57:52]),
	.read_alu2_op2_pnum(alu2_inst_pkg_is_rf_out[50:45]), 
	.read_addr_bas_pnum(addr_inst_pkg_is_rf_out[57:52]), 
	.read_addr_reg_pnum(addr_inst_pkg_is_rf_out[50:45]), 
	.brn(alu1_inst_pkg_is_rf_out[20:19]), 

	// Outputs
	.read_mult_op1_data(mult_op1_data_rf_out),
	.read_mult_op2_data(mult_op2_data_rf_out),
	.read_alu1_op1_data(alu1_op1_data_rf_out),
	.read_alu1_op2_data(alu1_op2_data_rf_out), 
	.read_alu2_op1_data(alu2_op1_data_rf_out), 
	.read_alu2_op2_data(alu2_op2_data_rf_out), 
	.read_addr_bas_data(addr_op1_data_rf_out), 
	.read_addr_reg_data(data_str_rf_out), 
	.brn_cmp_rslt(brn_cmp_rslt_rf_out), 

	// Inputs
	// write section input
	.wrt_mult_vld(reg_wrt_mul_wb_rf),
	.wrt_mult_dst_pnum(wrt_mult_dst_pnum),
	.wrt_mult_data(wrt_mult_data),
	.wrt_alu1_vld(reg_wrt_alu1_wb_rf),
	.wrt_alu1_dst_pnum(wrt_alu1_dst_pnum),
	.wrt_alu1_data(wrt_alu1_data),
	.wrt_alu2_vld(reg_wrt_alu2_wb_rf), 
	.wrt_alu2_dst_pnum(wrt_alu2_dst_pnum),
	.wrt_alu2_data(wrt_alu2_data),
	.wrt_addr_vld(reg_wrt_ld_wb_out),
	.wrt_addr_dst_pnum(phy_addr_ld_wb_out),
	.wrt_addr_data(data_ld_wb_out)
);

RF_EX RF_EX_DUT(.clk(clk), .rst_n(rst_n), .stall(1'b0),
	// Inputs
	.alu1_op1_rf_ex_in(alu1_op1_data_rf_out), //
	.alu1_op2_rf_ex_in(alu1_op2_data_rf_out), //
	.alu2_op1_rf_ex_in(alu2_op1_data_rf_out), //
	.alu2_op2_rf_ex_in(alu2_op2_data_rf_out), //
	.mult_op1_rf_ex_in(mult_op1_data_rf_out), //
	.mult_op2_rf_ex_in(mult_op2_data_rf_out), //
	.addr_op1_rf_ex_in(addr_op1_data_rf_out), //
	.data_str_rf_ex_in(data_str_rf_out), //

	.alu1_imm_rf_ex_in(alu1_inst_pkg_is_rf_out[37:22]), //
	.alu2_imm_rf_ex_in(alu2_inst_pkg_is_rf_out[37:22]), //
	.mult_imm_rf_ex_in(mult_inst_pkg_is_rf_out[37:22]), //
	.addr_imm_rf_ex_in(addr_inst_pkg_is_rf_out[37:22]), //
	.alu1_imm_vld_rf_ex_in(alu1_inst_pkg_is_rf_out[38]), //
	.alu2_imm_vld_rf_ex_in(alu2_inst_pkg_is_rf_out[38]), //
	.mult_imm_vld_rf_ex_in(mult_inst_pkg_is_rf_out[38]), //
	.addr_imm_vld_rf_ex_in(addr_inst_pkg_is_rf_out[38]), //

	.alu1_inst_vld_rf_ex_in(alu1_inst_pkg_is_rf_out[65]), //
	.alu2_inst_vld_rf_ex_in(alu2_inst_pkg_is_rf_out[65]), //
	.mult_inst_vld_rf_ex_in(mult_inst_pkg_is_rf_out[65]), //
	.addr_inst_vld_rf_ex_in(addr_inst_pkg_is_rf_out[65]), //

	.alu1_mem_wrt_rf_ex_in(alu1_inst_pkg_is_rf_out[14]), //
	.alu2_mem_wrt_rf_ex_in(alu2_inst_pkg_is_rf_out[14]), //
	.mult_mem_wrt_rf_ex_in(mult_inst_pkg_is_rf_out[14]), //
	.addr_mem_wrt_rf_ex_in(addr_inst_pkg_is_rf_out[14]), //

	.alu1_mem_rd_rf_ex_in(alu1_inst_pkg_is_rf_out[15]), //
	.alu2_mem_rd_rf_ex_in(alu2_inst_pkg_is_rf_out[15]), //
	.mult_mem_rd_rf_ex_in(mult_inst_pkg_is_rf_out[15]), //
	.addr_mem_rd_rf_ex_in(addr_inst_pkg_is_rf_out[15]), //

	.alu1_ldi_rf_ex_in(alu1_inst_pkg_is_rf_out[21]), // 
	.alu2_ldi_rf_ex_in(alu2_inst_pkg_is_rf_out[21]), //
	.mult_ldi_rf_ex_in(mult_inst_pkg_is_rf_out[21]), // 
	.addr_ldi_rf_ex_in(addr_inst_pkg_is_rf_out[21]), // 

	.alu1_mode_rf_ex_in(alu1_inst_pkg_is_rf_out[13:11]),
	.alu2_mode_rf_ex_in(alu2_inst_pkg_is_rf_out[13:11]),

	.alu1_done_idx_rf_ex_in(alu1_inst_pkg_is_rf_out[64:59]), // 
	.alu2_done_idx_rf_ex_in(alu2_inst_pkg_is_rf_out[64:59]), // 
	.mult_done_idx_rf_ex_in(mult_inst_pkg_is_rf_out[64:59]), //
	.addr_done_idx_rf_ex_in(addr_inst_pkg_is_rf_out[64:59]), //

	.phy_addr_alu1_rf_ex_in(alu1_inst_pkg_is_rf_out[44:39]), //
	.phy_addr_alu2_rf_ex_in(alu2_inst_pkg_is_rf_out[44:39]), //
	.phy_addr_mult_rf_ex_in(mult_inst_pkg_is_rf_out[44:39]), //
	.phy_addr_ld_rf_ex_in(addr_inst_pkg_is_rf_out[44:39]), //

	.reg_wrt_mul_rf_ex_in(mult_inst_pkg_is_rf_out[6]), //
	.reg_wrt_alu1_rf_ex_in(alu1_inst_pkg_is_rf_out[6]), //
	.reg_wrt_alu2_rf_ex_in(alu2_inst_pkg_is_rf_out[6]), //
	.reg_wrt_ld_rf_ex_in(addr_inst_pkg_is_rf_out[6]), //

	.alu1_invtRt_rf_ex_in(alu1_inst_pkg_is_rf_out[7]), //
	.alu2_invtRt_rf_ex_in(alu2_inst_pkg_is_rf_out[7]), //
	.mult_invtRt_rf_ex_in(mult_inst_pkg_is_rf_out[7]), //
	.addr_invtRt_rf_ex_in(addr_inst_pkg_is_rf_out[7]), //

    .alu1_en_rf_ex_in(alu1_inst_pkg_is_rf_out[10]),
    .alu2_en_rf_ex_in(alu2_inst_pkg_is_rf_out[10]),
    .mult_en_rf_ex_in(mult_inst_pkg_is_rf_out[9]), 
    .addr_en_rf_ex_in(addr_inst_pkg_is_rf_out[8]),

	// Outputs
	.alu1_op1_rf_ex_out(alu1_op1_data_rf_ex_out),
	.alu1_op2_rf_ex_out(alu1_op2_data_rf_ex_out),
	.alu2_op1_rf_ex_out(alu2_op1_data_rf_ex_out),
	.alu2_op2_rf_ex_out(alu2_op2_data_rf_ex_out),
	.mult_op1_rf_ex_out(mult_op1_data_rf_ex_out),
	.mult_op2_rf_ex_out(mult_op2_data_rf_ex_out),
	.addr_op1_rf_ex_out(addr_op1_data_rf_ex_out),
	.data_str_rf_ex_out(data_str_rf_ex_out),

	.alu1_imm_rf_ex_out(alu1_imm_rf_ex_out),
	.alu2_imm_rf_ex_out(alu2_imm_rf_ex_out),
	.mult_imm_rf_ex_out(mult_imm_rf_ex_out),
	.addr_imm_rf_ex_out(addr_imm_rf_ex_out),
	.alu1_imm_vld_rf_ex_out(alu1_imm_vld_rf_ex_out),
	.alu2_imm_vld_rf_ex_out(alu2_imm_vld_rf_ex_out),
	.mult_imm_vld_rf_ex_out(mult_imm_vld_rf_ex_out),
	.addr_imm_vld_rf_ex_out(addr_imm_vld_rf_ex_out),

	.alu1_inst_vld_rf_ex_out(alu1_inst_vld_rf_ex_out), //
	.alu2_inst_vld_rf_ex_out(alu2_inst_vld_rf_ex_out), //
	.mult_inst_vld_rf_ex_out(mult_inst_vld_rf_ex_out), //
	.addr_inst_vld_rf_ex_out(addr_inst_vld_rf_ex_out), //

	.alu1_mem_wrt_rf_ex_out(alu1_mem_wrt_rf_ex_out), //
	.alu2_mem_wrt_rf_ex_out(alu2_mem_wrt_rf_ex_out), //
	.mult_mem_wrt_rf_ex_out(mult_mem_wrt_rf_ex_out), //
	.addr_mem_wrt_rf_ex_out(addr_mem_wrt_rf_ex_out), //

	.alu1_mem_rd_rf_ex_out(alu1_mem_rd_rf_ex_out),
	.alu2_mem_rd_rf_ex_out(alu2_mem_rd_rf_ex_out),
	.mult_mem_rd_rf_ex_out(mult_mem_rd_rf_ex_out),
	.addr_mem_rd_rf_ex_out(addr_mem_rd_rf_ex_out),

	.alu1_en_rf_ex_out(alu1_en_rf_ex_out),
	.alu2_en_rf_ex_out(alu2_en_rf_ex_out),
	.mult_en_rf_ex_out(mult_en_rf_ex_out), 
	.addr_en_rf_ex_out(addr_en_rf_ex_out),

	.alu1_ldi_rf_ex_out(alu1_ldi_rf_ex_out), 
	.alu2_ldi_rf_ex_out(alu2_ldi_rf_ex_out), 
	.mult_ldi_rf_ex_out(mult_ldi_rf_ex_out), 
	.addr_ldi_rf_ex_out(addr_ldi_rf_ex_out), 

	.alu1_mode_rf_ex_out(alu1_mode_rf_ex_out),
	.alu2_mode_rf_ex_out(alu2_mode_rf_ex_out),

	.alu1_done_idx_rf_ex_out(alu1_done_idx_rf_ex_out),
	.alu2_done_idx_rf_ex_out(alu2_done_idx_rf_ex_out),
	.mult_done_idx_rf_ex_out(mult_done_idx_rf_ex_out),
	.addr_done_idx_rf_ex_out(addr_done_idx_rf_ex_out),

	.phy_addr_alu1_rf_ex_out(phy_addr_alu1_rf_ex_out),
	.phy_addr_alu2_rf_ex_out(phy_addr_alu2_rf_ex_out),
	.phy_addr_mult_rf_ex_out(phy_addr_mult_rf_ex_out),
	.phy_addr_ld_rf_ex_out(phy_addr_ld_rf_ex_out),

	.reg_wrt_mul_rf_ex_out(reg_wrt_mul_rf_ex_out),
	.reg_wrt_alu1_rf_ex_out(reg_wrt_alu1_rf_ex_out),
	.reg_wrt_alu2_rf_ex_out(reg_wrt_alu2_rf_ex_out),
	.reg_wrt_ld_rf_ex_out(reg_wrt_ld_rf_ex_out),

	.alu1_invtRt_rf_ex_out(alu1_invtRt_rf_ex_out),
	.alu2_invtRt_rf_ex_out(alu2_invtRt_rf_ex_out),
	.mult_invtRt_rf_ex_out(mult_invtRt_rf_ex_out),
	.addr_invtRt_rf_ex_out(addr_invtRt_rf_ex_out)
);

execution execution_DUT(.clk(clk), .rst(~rst_n),
	// Inputs
	.mult_op1(mult_op1_data_rf_ex_out), 
	.mult_op2(mult_op2_data_rf_ex_out), 
	.alu1_op1(alu1_op1_data_rf_ex_out), 
	.alu1_op2(alu1_op2_data_rf_ex_out), 
	.alu2_op1(alu2_op1_data_rf_ex_out), 
	.alu2_op2(alu2_op2_data_rf_ex_out), 
	.addr_op1(addr_op1_data_rf_ex_out), 
	.addr_op2(addr_imm_rf_ex_out),
	.mult_en(mult_en_rf_ex_out), 
	.alu1_en(alu1_en_rf_ex_out), 
	.alu2_en(alu2_en_rf_ex_out), 
	.addr_en(addr_en_rf_ex_out), 

	.alu1_inv_Rt(alu1_invtRt_rf_ex_out), 
	.alu2_inv_Rt(alu2_invtRt_rf_ex_out), 
	.alu1_ldi(alu1_ldi_rf_ex_out), 
	.alu2_ldi(alu2_ldi_rf_ex_out), 
	.alu1_imm(alu1_imm_rf_ex_out), 
	.alu2_imm(alu2_imm_rf_ex_out),
	.alu1_mode(alu1_mode_rf_ex_out), 
	.alu2_mode(alu2_mode_rf_ex_out), 

	// Outputs
	.mult_out(mult_data_ex_out), 
	.alu1_out(alu1_data_ex_out), 
	.alu2_out(alu2_data_ex_out), 
	.addr_out(addr_data_ex_out), 
	.mult_valid_wb(mult_valid_ex_out), 
	.mult_free(mult_free_ex_is_out)
);



EX_WB EX_WB_DUT(.clk(clk), .rst_n(rst_n), .stall(1'b0),
	// Inputs
    .mult_out_ex_wb_in(mult_data_ex_out),
    .alu1_out_ex_wb_in(alu1_data_ex_out), 
    .alu2_out_ex_wb_in(alu2_data_ex_out),
    .addr_out_ex_wb_in(addr_data_ex_out),
    .data_str_ex_wb_in(data_str_rf_ex_out),

    .mult_valid_wb_ex_wb_in(mult_valid_ex_out),   //for WB stage
    .mult_free_ex_wb_in(mult_free_ex_is_out),     //for issue stage

    .alu1_mem_wrt_ex_wb_in(alu1_mem_wrt_rf_ex_out), //
    .alu2_mem_wrt_ex_wb_in(alu2_mem_wrt_rf_ex_out), //
    .mult_mem_wrt_ex_wb_in(mult_mem_wrt_rf_ex_out), //
    .addr_mem_wrt_ex_wb_in(addr_mem_wrt_rf_ex_out), //

    .alu1_mem_rd_ex_wb_in(alu1_mem_rd_rf_ex_out), //
    .alu2_mem_rd_ex_wb_in(alu2_mem_rd_rf_ex_out), //
    .mult_mem_rd_ex_wb_in(mult_mem_rd_rf_ex_out), //
    .addr_mem_rd_ex_wb_in(addr_mem_rd_rf_ex_out), //

    // be careful here
    .alu1_done_vld_ex_wb_in(alu1_en_rf_ex_out),
    .alu2_done_vld_ex_wb_in(alu2_en_rf_ex_out),
    .mult_done_vld_ex_wb_in(mult_valid_ex_out),
    .addr_done_vld_ex_wb_in(addr_en_rf_ex_out),
 
    .alu1_done_idx_ex_wb_in(alu1_done_idx_rf_ex_out),
    .alu2_done_idx_ex_wb_in(alu2_done_idx_rf_ex_out),
    .mult_done_idx_ex_wb_in(mult_done_idx_rf_ex_out),
    .addr_done_idx_ex_wb_in(addr_done_idx_rf_ex_out),


    .phy_addr_alu1_ex_wb_in(phy_addr_alu1_rf_ex_out),
    .phy_addr_alu2_ex_wb_in(phy_addr_alu2_rf_ex_out),
    .phy_addr_mult_ex_wb_in(phy_addr_mult_rf_ex_out),
    .phy_addr_ld_ex_wb_in(phy_addr_ld_rf_ex_out),

    .reg_wrt_mul_ex_wb_in(reg_wrt_mul_rf_ex_out),
    .reg_wrt_alu1_ex_wb_in(reg_wrt_alu1_rf_ex_out),
    .reg_wrt_alu2_ex_wb_in(reg_wrt_alu2_rf_ex_out),
    .reg_wrt_ld_ex_wb_in(reg_wrt_ld_rf_ex_out),

	// Outputs
    .alu1_out_ex_wb_out(wrt_alu1_data),
    .alu2_out_ex_wb_out(wrt_alu2_data),
    .mult_out_ex_wb_out(wrt_mult_data),
    .addr_out_ex_wb_out(wrt_addr_data),
    .data_str_ex_wb_out(data_str_ex_wb_out), 

    .reg_wrt_mul_ex_wb_out(reg_wrt_mul_wb_rf),
    .reg_wrt_alu1_ex_wb_out(reg_wrt_alu1_wb_rf),
    .reg_wrt_alu2_ex_wb_out(reg_wrt_alu2_wb_rf),
    .reg_wrt_ld_ex_wb_out(reg_wrt_addr_wb_rf),

    .mult_valid_wb_ex_wb_out(mult_valid_wb_ex_wb_out),
    .mult_free_ex_wb_out(mult_free_ex_wb_out),

    .alu1_mem_wrt_ex_wb_out(alu1_mem_wrt_ex_wb_out), //?
    .alu2_mem_wrt_ex_wb_out(alu2_mem_wrt_ex_wb_out), //?
    .mult_mem_wrt_ex_wb_out(mult_mem_wrt_ex_wb_out), //?
    .addr_mem_wrt_ex_wb_out(addr_mem_wrt_ex_wb_out), //

    .alu1_mem_rd_ex_wb_out(alu1_mem_rd_ex_wb_out), //?
    .alu2_mem_rd_ex_wb_out(alu2_mem_rd_ex_wb_out), //?
    .mult_mem_rd_ex_wb_out(mult_mem_rd_ex_wb_out), //?
    .addr_mem_rd_ex_wb_out(addr_mem_rd_ex_wb_out), //

    .alu1_done_vld_ex_wb_out(alu1_done_vld_ex_wb_out),
    .alu2_done_vld_ex_wb_out(alu2_done_vld_ex_wb_out),
    .mult_done_vld_ex_wb_out(mult_done_vld_ex_wb_out),
    .addr_done_vld_ex_wb_out(addr_done_vld_ex_wb_out),
 
    .alu1_done_idx_ex_wb_out(alu1_done_idx_ex_wb_out),
    .alu2_done_idx_ex_wb_out(alu2_done_idx_ex_wb_out),
    .mult_done_idx_ex_wb_out(mult_done_idx_ex_wb_out),
    .addr_done_idx_ex_wb_out(addr_done_idx_ex_wb_out),

    .phy_addr_alu1_ex_wb_out(wrt_alu1_dst_pnum),
    .phy_addr_alu2_ex_wb_out(wrt_alu2_dst_pnum),
    .phy_addr_mult_ex_wb_out(wrt_mult_dst_pnum),
    .phy_addr_ld_ex_wb_out(wrt_addr_dst_pnum)
);

top_level_wb top_level_WB_DUT(.clk(clk), .rst(rst_n),
	// Inputs
	.flsh(flush_ROB_out),
	.mem_rd(addr_mem_rd_ex_wb_out), 
	.cmmt_str(cmmt_st_ROB_out), 
	.mem_wrt(addr_mem_wrt_ex_wb_out), 
	.fnsh_unrll(fnsh_unrll_out_to_SCH),
	.loop_strt(loop_strt_to_SCH),
	.indx_ld_al(ld_indx_to_WB), 
	.indx_str_al(st_indx_to_WB), 
	.mis_pred_ld_ptr(mis_pred_ld_ptr_num_ROB_out) , 
	.cmmt_ld_ptr(cmmt_ld_ptr_num_ROB_out),
	.mis_pred_str_ptr(mis_pred_st_ptr_num_ROB_out), 
	.phy_addr_ld_in(wrt_addr_dst_pnum), 
	.indx_ls(addr_done_idx_ex_wb_out),
	.data_str(data_str_ex_wb_out), 
	.addr_ls(wrt_addr_data),
							 
	// Outputs
	.stll(stll_wb_out),
	.vld_ld(vld_ld_wb_out),
	.reg_wrt_ld(reg_wrt_ld_wb_out),
	.str_iss(str_iss_wb_out),
	.indx_ld(indx_ld_wb_out),
	.phy_addr_ld(phy_addr_ld_wb_out),
	.data_ld(data_ld_wb_out)
);
 
rob rob_DUT(.clk(clk), .rst_n(rst_n),
    // Inputs 
    // from AL
    .all_nop(all_nop_to_CMTIS),
    .st_in(st_en_to_CMT),
    .ld_in(ld_en_to_CMT),
    .brnc_in(spec_to_CMT),
    .brnc_cond(brch_mode_to_CMT),
    .brnc_pred(brch_pred_res_to_CMT),
    .rcvr_PC(rcvr_pc_to_CMT),
    .reg_wrt_in(reg_wrt_to_CMT),
    .loop_strt(loop_strt_to_SCH),

    // from IS Issue Queue
    .mult_inst_vld(mul_ins_to_rf_is_out[65]),
    .mult_reg_wrt(mul_ins_to_rf_is_out[6]),
    .mult_idx(mul_ins_to_rf_is_out[64:59]),
    .mult_free_preg_num(mul_ins_to_rf_is_out[5:0]),
    .alu1_inst_vld(alu1_ins_to_rf_is_out[65]),
    .alu1_reg_wrt(alu1_ins_to_rf_is_out[6]),
    .alu1_idx(alu1_ins_to_rf_is_out[64:59]),
    .alu1_free_preg_num(alu1_ins_to_rf_is_out[5:0]),
    .alu2_inst_vld(alu2_ins_to_rf_is_out[65]),
    .alu2_reg_wrt(alu2_ins_to_rf_is_out[6]),
    .alu2_idx(alu2_ins_to_rf_is_out[64:59]),
    .alu2_free_preg_num(alu2_ins_to_rf_is_out[5:0]),
    .addr_inst_vld(adr_ins_to_rf_is_out[65]),
    .addr_reg_wrt(adr_ins_to_rf_is_out[6]),
    .addr_idx(adr_ins_to_rf_is_out[64:59]),
    .addr_free_preg_num(adr_ins_to_rf_is_out[5:0]),

    // from EX/WB pipeline regs
    .mult_done_idx(mult_done_idx_ex_wb_out),
    .alu1_done_idx(alu1_done_idx_ex_wb_out),
    .alu2_done_idx(alu2_done_idx_ex_wb_out),
    .mult_done_vld(mult_done_vld_ex_wb_out),
    .alu1_done_vld(alu1_done_vld_ex_wb_out),
    .alu2_done_vld(alu2_done_vld_ex_wb_out),

    // from RF
    .brnc_idx(alu1_ins_to_rf_is_out[64:59]),
    .brnc_cmp_rslt(brn_cmp_rslt_rf_out),

    // from WB
    .ld_done_idx(indx_ld_wb_out),
    .ld_done_vld(vld_ld_wb_out), 
    .st_iss(str_iss_wb_out), 

    // Outputs
    .next_idx(next_idx_ROB_out),// to Allocation
    .mis_pred(mis_pred_ROB_out),// to IF, ID, AL
    .flush(flush_ROB_out), 
    .mis_pred_brnc_idx(mis_pred_brnc_idx_ROB_out),
	// to AL-freelist and IS-issue_queue
    .cmt_brnc(cmt_brnc_ROB_out),// to IF, AL-freelist and IS-issue_queue
    .cmt_brnc_idx(cmt_brnc_idx_ROB_out),
	// to AL-freelist and IS-issue_queue
	.decr_brnc_num(decr_brnc_num_ROB_out),
    .rcvr_PC_out(rcvr_PC_out_ROB_out),// to IF 
    .brnc_pred_log(brnc_pred_ROB_out),// to IF, the brnc was preded as T/N 
    .rob_full_stll(rob_full_stll_ROB_out),// to IF, ID, AL
    .rob_empt(rob_empt_ROB_out),// to IS for final reg-map outputting
    .cmmt_st(cmmt_st_ROB_out),// to Store Queue
    .mis_pred_ld_ptr_num(mis_pred_ld_ptr_num_ROB_out), // to Load Queue
    .mis_pred_st_ptr_num(mis_pred_st_ptr_num_ROB_out), // to Store Queue
    .cmmt_ld_ptr_num(cmmt_ld_ptr_num_ROB_out),// to Load Queue
    .free_preg_num1(free_preg_num1_ROB_out),// to AL-freelist
    .free_preg_num2(free_preg_num2_ROB_out),// to AL-freelist
    .free_preg_num3(free_preg_num3_ROB_out),// to AL-freelist
    .free_preg_num4(free_preg_num4_ROB_out),// to AL-freelist
    .free_preg_cnt(free_preg_cnt_ROB_out)
	// to AL-freelist: number of freed physical regs
);

endmodule
