module top_module_looper(clk,rst_n);
input clk, rst_n;

//fetch outputs
wire [63:0] pc_to_dec,inst_to_dec,recv_pc_to_dec;
wire [3:0] pred_result_to_dec;

//IF_ID outputs
wire [63:0] pc_if_id_out, inst_if_id_out, recv_pc_if_id_out;
wire [3:0] pred_result_if_id_out;


fetch fetch(.clk(clk),.rst_n(rst_n),
	//input	
	stall_fetch,loop_start,decr_count_brnch,has_mispredict,
	jump_base_rdy_from_rf, pc_recovery,jump_base_from_rf,
	exter_pc,exter_pc_en,mispred_num,
	//output
	.pc_to_dec(pc_to_dec),.inst_to_dec(inst_to_dec), 
    .recv_pc_to_dec(recv_pc_to_dec), .pred_result_to_dec(pred_result_to_dec) );

IF_ID IF_ID(.clk(clk), .rst_n(rst_n),
	.pc_if_id_in(pc_to_dec),.inst_if_id_in(inst_to_dec),
    .recv_pc_if_id_in(recv_pc_to_dec),.pred_result_if_id_in(pred_result_to_dec),
	.pc_if_id_out(pc_if_id_out),.inst_if_id_out(inst_if_id_out), 
    .recv_pc_if_id_out(recv_pc_if_id_out), .pred_result_if_id_out(pred_result_if_id_out)
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


 al al(/*autoarg*/
   // Outputs
   inst_out_to_SCH0, inst_out_to_SCH1, inst_out_to_SCH2,
   inst_out_to_SCH3, no_empt_preg_to_IF, rcvr_pc_to_CMT,
   reg_wrt_to_CMT, st_en_to_CMT, spec_to_CMT, brch_mode_to_CMT,
   brch_pred_res_to_CMT, ld_indx_to_WB, st_indx_to_WB,
   all_nop_to_CMTIS, lbd_state_out_to_SCH, fnsh_unrll_out_to_SCH,
   loop_strt_to_SCH,
   // Inputs
   free_pr_from_SCH0, free_pr_from_SCH1, free_pr_from_SCH2,
   free_pr_from_SCH3, inst_from_ID0, inst_from_ID1, inst_from_ID2,
   inst_from_ID3, nxt_indx_from_CMT,
   .clk(clk), .rst_n(rst_n),
   stall, lbd_state_out_from_ID, fnsh_unrll_out_from_ID, loop_strt_from_ID,
   full_signal_from_SCH, mis_pred_from_CMT, mis_pred_indx_from_CMT,
   cmt_brch_from_CMT, cmt_brch_indx_from_CMT,free_pr_num_from_CMT
   );



IS_RF IS_RF(
    .clk(clk), 
    .rst_n(rst_n),
    
    input  [65:0]          mult_inst_pkg_in,             // pc_to_dec
    input  [65:0]          alu1_inst_pkg_in,           // inst_to_dec
    input  [65:0]          alu2_inst_pkg_in,        // recv_pc_to_dec
    input  [65:0]           addr_inst_pkg_in,    // pred_result_to_dec




    output [65:0]          mult_inst_pkg_out,             // pc_to_dec
    output [65:0]          alu1_inst_pkg_out,           // inst_to_dec
    output [65:0]          alu2_inst_pkg_out,        // recv_pc_to_dec
    output [65:0]           addr_inst_pkg_out,    // pred_result_to_dec
);
    



reg_file reg_file(
    .clk(clk), 
    .rst_n(rst_n),
    
    // read section
    input [5:0] read_mult_op1_pnum,
    input [5:0] read_mult_op2_pnum,
    input [5:0] read_alu1_op1_pnum,
    input [5:0] read_alu1_op2_pnum, 
    input [5:0] read_alu2_op1_pnum, 
    input [5:0] read_alu2_op2_pnum, 
    input [5:0] read_addr_bas_pnum, 
    input [5:0] read_addr_reg_pnum, 
    input [1:0] brn, // detecting !(2'b00) => branch instruction
    output [15:0] read_mult_op1_data,
    output [15:0] read_mult_op2_data,
    output [15:0] read_alu1_op1_data,
    output [15:0] read_alu1_op2_data, 
    output [15:0] read_alu2_op1_data, 
    output [15:0] read_alu2_op2_data, 
    output [15:0] read_addr_bas_data, 
    output [15:0] read_addr_reg_data, 
    output [1:0] brn_cmp_rslt, // tell ROB the real brn result

    // write section
    input        wrt_mult_vld,
    input [5:0]  wrt_mult_dst_pnum,
    input [15:0] wrt_mult_data,
    input        wrt_alu1_vld,
    input [5:0]  wrt_alu1_dst_pnum,



//////////////////////////////////////////////////////////////////////

RF_EX RF_EX (
    .clk(clk),
    .rst_n(rst_n),
    
    input  [15:0]          alu1_op1_rf_ex_in, //
    input  [15:0]          alu1_op2_rf_ex_in, //
    input  [15:0]          alu2_op1_rf_ex_in, //
    input  [15:0]          alu2_op2_rf_ex_in, //
    input  [15:0]          mult_op1_rf_ex_in, //
    input  [15:0]          mult_op2_rf_ex_in, //
    input  [15:0]          addr_op1_rf_ex_in, //
    input  [15:0]          data_str_rf_wb_in, //

    input  [15:0]          alu1_imm_rf_ex_in, //
    input  [15:0]          alu2_imm_rf_ex_in, //
    input  [15:0]          mult_imm_rf_ex_in, //
    input  [15:0]          addr_imm_rf_ex_in, //
    input                  alu1_imm_vld_rf_ex_in, //
    input                  alu2_imm_vld_rf_ex_in, //
    input                  mult_imm_vld_rf_ex_in, //
    input                  addr_imm_vld_rf_ex_in, //

    input                  alu1_inst_vld_rf_ex_in, //
    input                  alu2_inst_vld_rf_ex_in, //
    input                  mult_inst_vld_rf_ex_in, //
    input                  addr_inst_vld_rf_ex_in, //

    input                  alu1_mem_wrt_rf_ex_in, //
    input                  alu2_mem_wrt_rf_ex_in, //
    input                  mult_mem_wrt_rf_ex_in, //
    input                  addr_mem_wrt_rf_ex_in, //

    input                  alu1_mem_rd_rf_ex_in, //
    input                  alu2_mem_rd_rf_ex_in, //
    input                  mult_mem_rd_rf_ex_in, //
    input                  addr_mem_rd_rf_ex_in, //

    input                  alu1_ldi_rf_ex_in, // 
    input                  alu2_ldi_rf_ex_in, //
    input                  mult_ldi_rf_ex_in, // 
    input                  addr_ldi_rf_ex_in, // 

    input  [2:0]           alu1_mode_rf_ex_in,
    input  [2:0]           alu2_mode_rf_ex_in,

    input  [5:0]           alu1_done_idx_rf_ex_in, // 
    input  [5:0]           alu2_done_idx_rf_ex_in, // 
    input  [5:0]           mult_done_idx_rf_ex_in, //
    input  [5:0]           addr_done_idx_rf_ex_in, //

    input  [5:0]           phy_addr_alu1_rf_ex_in, //
    input  [5:0]           phy_addr_alu2_rf_ex_in, //
    input  [5:0]           phy_addr_mult_rf_ex_in, //
    input  [5:0]           phy_addr_ld_rf_ex_in, //

    input                  reg_wrt_mul_rf_ex_in, //
    input                  reg_wrt_alu1_rf_ex_in, //
    input                  reg_wrt_alu2_rf_ex_in, //
    input                  reg_wrt_ld_rf_ex_in, //

    input                  alu1_invtRt_rf_ex_in, //
    input                  alu2_invtRt_rf_ex_in, //
    input                  mult_invtRt_rf_ex_in, //
    input                  addr_invtRt_rf_ex_in, //



    output  [15:0]         alu1_op1_rf_ex_out,
    output  [15:0]         alu1_op2_rf_ex_out,
    output  [15:0]         alu2_op1_rf_ex_out,
    output  [15:0]         alu2_op2_rf_ex_out,
    output  [15:0]         mult_op1_rf_ex_out,
    output  [15:0]         mult_op2_rf_ex_out,
    output  [15:0]         addr_op1_rf_ex_out,
    output  [15:0]         data_str_rf_wb_out,


    output  [15:0]         alu1_imm_rf_ex_out,
    output  [15:0]         alu2_imm_rf_ex_out,
    output  [15:0]         mult_imm_rf_ex_out,
    output  [15:0]         addr_imm_rf_ex_out,
    output                 alu1_imm_vld_rf_ex_out,
    output                 alu2_imm_vld_rf_ex_out,
    output                 mult_imm_vld_rf_ex_out,
    output                 addr_imm_vld_rf_ex_out,

    output                 alu1_inst_vld_rf_ex_out, //
    output                 alu2_inst_vld_rf_ex_out, //
    output                 mult_inst_vld_rf_ex_out, //
    output                 addr_inst_vld_rf_ex_out, //

    output                 alu1_mem_wrt_rf_ex_out, //
    output                 alu2_mem_wrt_rf_ex_out, //
    output                 mult_mem_wrt_rf_ex_out, //
    output                 addr_mem_wrt_rf_ex_out, //

    output                 alu1_mem_rd_rf_ex_out,
    output                 alu2_mem_rd_rf_ex_out,
    output                 mult_mem_rd_rf_ex_out,
    output                 addr_mem_rd_rf_ex_out,

    output                 alu1_en_rf_ex_out,
    output                 alu2_en_rf_ex_out,
    output                 mult_en_rf_ex_out, 
    output                 addr_en_rf_ex_out,

    output                 alu1_ldi_rf_ex_out, 
    output                 alu2_ldi_rf_ex_out, 
    output                 mult_ldi_rf_ex_out, 
    output                 addr_ldi_rf_ex_out, 

    output  [2:0]          alu1_mode_rf_ex_out,
    output  [2:0]          alu2_mode_rf_ex_out,

    output  [5:0]          alu1_done_idx_rf_ex_out,
    output  [5:0]          alu2_done_idx_rf_ex_out,
    output  [5:0]          mult_done_idx_rf_ex_out,
    output  [5:0]          addr_done_idx_rf_ex_in,

    output  [5:0]          phy_addr_alu1_rf_ex_out,
    output  [5:0]          phy_addr_alu2_rf_ex_out,
    output  [5:0]          phy_addr_mult_rf_ex_out,
    output  [5:0]          phy_addr_ld_rf_ex_out,

    output                 reg_wrt_mul_rf_ex_out,
    output                 reg_wrt_alu1_rf_ex_out,
    output                 reg_wrt_alu2_rf_ex_out,
    output                 reg_wrt_ld_rf_ex_out,



    output                 alu1_invtRt_rf_ex_out,
    output                 alu2_invtRt_rf_ex_out,
    output                 mult_invtRt_rf_ex_out,
    output                 addr_invtRt_rf_ex_out
);

//////////////////////////////////////////////////////////////////////


execution execution (mult_op1, mult_op2,
        alu1_op1, alu1_op2, alu2_op1,
        alu2_op2, addr_op1, addr_op2,
        mult_en, alu1_en, alu2_en, addr_en,
        .clk(clk), .rst(~rst_n),
	    alu1_inv_Rt, alu2_inv_Rt,
	// output
	    alu1_mode, alu2_mode, 
        mult_out, alu1_out, alu2_out, addr_out,
        mult_valid_wb, mult_free, reg_wrt_mul );


/////////////////////////////////////////////////////////////
EX_WB EX_WB(
    .clk(clk), 
    .rst_n(rst_n),
    
    input  [15:0]          mult_out_ex_wb_in,
    input  [15:0]          alu1_out_ex_wb_in, 
    input  [15:0]          alu2_out_ex_wb_in,
    input  [15:0]          addr_out_ex_wb_in,
    input  [15:0]          data_str_ex_wb_in,

    input                  mult_valid_wb_ex_wb_in,         //for WB stage
    input                  mult_free_ex_wb_in,             //for issue stage

    input                  alu1_mem_wrt_ex_wb_in, //
    input                  alu2_mem_wrt_ex_wb_in, //
    input                  mult_mem_wrt_ex_wb_in, //
    input                  addr_mem_wrt_ex_wb_in, //

    input                  alu1_mem_rd_ex_wb_in, //
    input                  alu2_mem_rd_ex_wb_in, //
    input                  mult_mem_rd_ex_wb_in, //
    input                  addr_mem_rd_ex_wb_in, //

    input                  alu1_done_vld_ex_wb_in,
    input                  alu2_done_vld_ex_wb_in,
    input                  mult_done_vld_ex_wb_in,
    input                  addr_done_vld_ex_wb_in,
 
    input  [5:0]           alu1_done_idx_ex_wb_in,
    input  [5:0]           alu2_done_idx_ex_wb_in,
    input  [5:0]           mult_done_idx_ex_wb_in,
    input  [5:0]           addr_done_idx_ex_wb_in,


    input  [5:0]           phy_addr_alu1_ex_wb_in,
    input  [5:0]           phy_addr_alu2_ex_wb_in,
    input  [5:0]           phy_addr_mult_ex_wb_in,
    input  [5:0]           phy_addr_ld_ex_wb_in,

    input                  reg_wrt_mul_ex_wb_in,
    input                  reg_wrt_alu1_ex_wb_in,
    input                  reg_wrt_alu2_ex_wb_in,
    input                  reg_wrt_ld_ex_wb_in,

    output [15:0]          alu1_out_ex_wb_out,
    output [15:0]          alu2_out_ex_wb_out,
    output [15:0]          mult_out_ex_wb_out,
    output [15:0]          addr_out_ex_wb_out,
    output [15:0]          data_str_ex_wb_out, 

////////////////////////////////////////////////////////////////////

top_level_wb top_level_wb( .clk(clk),
                     .rst(rst_n),
                     flsh,
							mis_pred_ld_ptr ,  
							indx_ld_al, 
							mem_rd, 
							phy_addr_ld_in, 
							mis_pred_str_ptr, 
							cmmt_str, 
							indx_str_al, 
							mem_wrt, 
							data_str, 
							indx_ls,
							addr_ls,
							fnsh_unrll,

////////////////////////////////////////////////////////////////////

rob rob(
    .clk(clk), 
    .rst_n(rst_n),
    
    // inputs: 
    // from AL
    input all_nop,
    input [3:0] st_in,
    input [3:0] ld_in,
    input [3:0] brnc_in,
    input [7:0] brnc_cond,
    input [3:0] brnc_pred,
    input [63:0] rcvr_PC,
    input [3:0] reg_wrt_in,
    input [3:0] no_exec_in, //?
    input [3:0] jr_in,      //?
    input loop_strt,        //?
    input [3:0] loop_end,   //?

    // from IS Issue Queue
    input mult_inst_vld,
    input mult_reg_wrt,
    input [5:0] mult_idx,
    input [5:0] mult_free_preg_num,
    input alu1_inst_vld,
    input alu1_reg_wrt,
    input [5:0] alu1_idx,
    input [5:0] alu1_free_preg_num,
    input alu2_inst_vld,
    input alu2_reg_wrt,
    input [5:0] alu2_idx,
    input [5:0] alu2_free_preg_num,
    input addr_inst_vld,
    input addr_reg_wrt,
    input [5:0] addr_idx,
    input [5:0] addr_free_preg_num,

    // from EX/WB pipeline regs
    input [5:0] mult_done_idx,
    input [5:0] alu1_done_idx,
    input [5:0] alu2_done_idx,
    input mult_done_vld,
    input alu1_done_vld,
    input alu2_done_vld,

    // from RF
    input [5:0] brnc_idx,
    input [1:0] brnc_cmp_rslt,

    // from WB
    input [5:0] ld_done_idx,
    input ld_done_vld, 
    input st_iss, 

    // outputs:
    output [5:0] next_idx,            // to Allocation
    output mis_pred,                  // to IF, ID, AL
    output flush, 
    output [5:0] mis_pred_brnc_idx,   // to AL-freelist and IS-issue_queue
    output cmt_brnc,                  // to AL-freelist and IS-issue_queue
    output [5:0] cmt_brnc_idx,        // to AL-freelist and IS-issue_queue
    output [15:0] rcvr_PC_out,        // to IF 
    output rob_full_stll,             // to IF, ID, AL
    output rob_empt,
    output cmmt_st,                   // to Store Queue
    output [4:0] mis_pred_ld_ptr_num, // to Load Queue
    output [3:0] mis_pred_st_ptr_num, // to Store Queue
    output [4:0] cmmt_ld_ptr_num,     // to Load Queue
    output [5:0] free_preg_num1,      // to AL-freelist
    output [5:0] free_preg_num2,      // to AL-freelist
    output [5:0] free_preg_num3,      // to AL-freelist
    output [5:0] free_preg_num4,      // to AL-freelist
    output [2:0] free_preg_cnt        // to AL-freelist: number of freed physical regs



endmodule
