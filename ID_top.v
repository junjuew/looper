module ID_top(
	// input
	inst_in_frm_IF,
	pc_in_frm_IF,
	mis_pred_in_frm_ROB,
	recv_pc_in_frm_IF,
	pred_result_frm_IF,
	clk,
	rst,

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

	input	[63:0]	inst_in_frm_IF, pc_in_frm_IF, recv_pc_in_frm_IF;
	input	[3:0]	pred_result_frm_IF;
	input			mis_pred_in_frm_ROB, clk, rst;

	output	[65:0]	dcd_inst1_out_to_AL, dcd_inst2_out_to_AL, dcd_inst3_out_to_AL, dcd_inst4_out_to_AL;
	output	[1:0]	lbd_state_out_to_AL;
	output			fnsh_unrll_out_to_AL, stll_ftch_out_to_IF;
	output			loop_strt_out_to_AL;

	// wires for Divider
	wire	[15:0]	bits11_8_out, bits7_4_out, bits3_0_out, opco_out;
	wire	[7:0]	jmp_off_out;

	// wires for Control Units
	wire		LDI_out1, LDI_out2, LDI_out3, LDI_out4;
	wire		MemRd_out1, MemRd_out2, MemRd_out3, MemRd_out4;
	wire		MemWr_out1, MemWr_out2, MemWr_out3, MemWr_out4;
	wire		invRt_out1, invRt_out2, invRt_out3, invRt_out4;
	wire		Rs_v_out1, Rs_v_out2, Rs_v_out3, Rs_v_out4;
	wire		Rd_v_out1, Rd_v_out2, Rd_v_out3, Rd_v_out4; 
	wire		Rt_v_out1, Rt_v_out2, Rt_v_out3, Rt_v_out4;
	wire		im_v_out1, im_v_out2, im_v_out3, im_v_out4;
	wire		jmp_v_out1, jmp_v_out2, jmp_v_out3, jmp_v_out4;
	wire		RegWr_out1, RegWr_out2, RegWr_out3, RegWr_out4;
	wire		ALU_to_add_out1, ALU_to_add_out2, ALU_to_add_out3, ALU_to_add_out4;
	wire		ALU_to_mult_out1, ALU_to_mult_out2, ALU_to_mult_out3, ALU_to_mult_out4;
	wire		ALU_to_addr_out1, ALU_to_addr_out2, ALU_to_addr_out3, ALU_to_addr_out4;
	wire	[1:0]	brn_out1, brn_out2, brn_out3, brn_out4, jmp_out1, jmp_out2, jmp_out3, jmp_out4;
	wire	[2:0]	ALU_ctrl_out1, ALU_ctrl_out2, ALU_ctrl_out3, ALU_ctrl_out4;
	wire	[3:0]	bck_lp_bus;
	wire            inst_vld_out1, inst_vld_out2, inst_vld_out3, inst_vld_out4;

	// wires for Interpretor
	wire		fnsh_unrll_out, bck_lp_out1, bck_lp_out2, bck_lp_out3, bck_lp_out4;

	// wires for LAT
	wire 	[3:0]	inst_valid_in;
	Divider divider_DUT (
			// input
			.inst_in(inst_in_frm_IF),

			// output
			.bits11_8_out(bits11_8_out),

			.bits7_4_out(bits7_4_out),

			.bits3_0_out(bits3_0_out),

			.opco_out(opco_out),

			.jmp_off_out(jmp_off_out));

	Control_Unit ctrl_unit_DUT1 (
				// input signals
				.opco_in(opco_out[15:12]),

				.jmp_off_in(jmp_off_out[7:6]),

				// output signals

				.LDI_out(LDI_out1),

				.brn_out(brn_out1),

				.jmp_out(jmp_out1),

				.MemRd_out(MemRd_out1),

				.MemWr_out(MemWr_out1),

				.ALU_ctrl_out(ALU_ctrl_out1),

				.invRt_out(invRt_out1),

				.Rs_v_out(Rs_v_out1),

				.Rd_v_out(Rd_v_out1),

				.Rt_v_out(Rt_v_out1),

				.im_v_out(im_v_out1),

				.RegWr_out(RegWr_out1),

				.jmp_v_out(jmp_v_out1),

				.ALU_to_add_out(ALU_to_add_out1),

				.ALU_to_mult_out(ALU_to_mult_out1),

				.ALU_to_addr_out(ALU_to_addr_out1),

				.inst_vld_out(inst_vld_out1)
			);

	Control_Unit ctrl_unit_DUT2 (
				// input signals
				.opco_in(opco_out[11:8]),

				.jmp_off_in(jmp_off_out[5:4]),

				// output signals

				.LDI_out(LDI_out2),

				.brn_out(brn_out2),

				.jmp_out(jmp_out2),

				.MemRd_out(MemRd_out2),

				.MemWr_out(MemWr_out2),

				.ALU_ctrl_out(ALU_ctrl_out2),

				.invRt_out(invRt_out2),

				.Rs_v_out(Rs_v_out2),

				.Rd_v_out(Rd_v_out2),

				.Rt_v_out(Rt_v_out2),

				.im_v_out(im_v_out2),

				.RegWr_out(RegWr_out2),

				.jmp_v_out(jmp_v_out2),

				.ALU_to_add_out(ALU_to_add_out2),

				.ALU_to_mult_out(ALU_to_mult_out2),

				.ALU_to_addr_out(ALU_to_addr_out2),

				.inst_vld_out(inst_vld_out2)
			);

	Control_Unit ctrl_unit_DUT3 (
				// input signals
				.opco_in(opco_out[7:4]),

				.jmp_off_in(jmp_off_out[3:2]),

				// output signals

				.LDI_out(LDI_out3),

				.brn_out(brn_out3),

				.jmp_out(jmp_out3),

				.MemRd_out(MemRd_out3),

				.MemWr_out(MemWr_out3),

				.ALU_ctrl_out(ALU_ctrl_out3),

				.invRt_out(invRt_out3),

				.Rs_v_out(Rs_v_out3),

				.Rd_v_out(Rd_v_out3),

				.Rt_v_out(Rt_v_out3),

				.im_v_out(im_v_out3),

				.RegWr_out(RegWr_out3),

				.jmp_v_out(jmp_v_out3),

				.ALU_to_add_out(ALU_to_add_out3),

				.ALU_to_mult_out(ALU_to_mult_out3),

				.ALU_to_addr_out(ALU_to_addr_out3),

				.inst_vld_out(inst_vld_out3)
			);

	Control_Unit ctrl_unit_DUT4 (
				// input signals
				.opco_in(opco_out[3:0]),

				.jmp_off_in(jmp_off_out[1:0]),

				// output signals

				.LDI_out(LDI_out4),

				.brn_out(brn_out4),

				.jmp_out(jmp_out4),

				.MemRd_out(MemRd_out4),

				.MemWr_out(MemWr_out4),

				.ALU_ctrl_out(ALU_ctrl_out4),

				.invRt_out(invRt_out4),

				.Rs_v_out(Rs_v_out4),

				.Rd_v_out(Rd_v_out4),

				.Rt_v_out(Rt_v_out4),

				.im_v_out(im_v_out4),

				.RegWr_out(RegWr_out4),

				.jmp_v_out(jmp_v_out4),

				.ALU_to_add_out(ALU_to_add_out4),

				.ALU_to_mult_out(ALU_to_mult_out4),

				.ALU_to_addr_out(ALU_to_addr_out4),

				.inst_vld_out(inst_vld_out4)
			);

	Interpretor interpretor_DUT1(
				// input

				.bits11_8_in(bits11_8_out[15:12]),

				.bits7_4_in(bits7_4_out[15:12]),

				.bits3_0_in(bits3_0_out[15:12]),

				.LDI_in(LDI_out1),

				.brn_in(brn_out1),

				.jmp_in(jmp_out1),

				.MemRd_in(MemRd_out1),

				.MemWr_in(MemWr_out1),

				.invRt_in(invRt_out1),

				.ALU_ctrl_in(ALU_ctrl_out1),

				.Rs_v_in(Rs_v_out1),

				.Rd_v_in(Rd_v_out1),

				.Rt_v_in(Rt_v_out1),

				.im_v_in(im_v_out1),

				.RegWr_in(RegWr_out1),

				.jmp_v_in(jmp_v_out1),

				.ALU_to_add_in(ALU_to_add_out1),

				.ALU_to_mult_in(ALU_to_mult_out1),

				.ALU_to_addr_in(ALU_to_addr_out1),

				.pred_result_in(pred_result_frm_IF[3]),

				.fnsh_unrll_in(fnsh_unrll_out_to_AL),

				.recv_PC_in(recv_pc_in_frm_IF[63:48]),

				.inst_valid_in(inst_vld_out1),		// from IF

				// output

				.dcd_inst_out(dcd_inst1_out_to_AL),

				.bck_lp_out(bck_lp_out1)
			);

	Interpretor interpretor_DUT2(
				// input

				.bits11_8_in(bits11_8_out[11:8]),

				.bits7_4_in(bits7_4_out[11:8]),

				.bits3_0_in(bits3_0_out[11:8]),

				.LDI_in(LDI_out2),

				.brn_in(brn_out2),

				.jmp_in(jmp_out2),

				.MemRd_in(MemRd_out2),

				.MemWr_in(MemWr_out2),

				.invRt_in(invRt_out2),

				.ALU_ctrl_in(ALU_ctrl_out2),

				.Rs_v_in(Rs_v_out2),

				.Rd_v_in(Rd_v_out2),

				.Rt_v_in(Rt_v_out2),

				.im_v_in(im_v_out2),

				.RegWr_in(RegWr_out2),

				.jmp_v_in(jmp_v_out2),

				.ALU_to_add_in(ALU_to_add_out2),

				.ALU_to_mult_in(ALU_to_mult_out2),

				.ALU_to_addr_in(ALU_to_addr_out2),

				.pred_result_in(pred_result_frm_IF[2]),

				.fnsh_unrll_in(fnsh_unrll_out_to_AL),

				.recv_PC_in(recv_pc_in_frm_IF[47:32]),

				.inst_valid_in(inst_vld_out2),		// from IF

				// output

				.dcd_inst_out(dcd_inst2_out_to_AL),

				.bck_lp_out(bck_lp_out2)
			);

	Interpretor interpretor_DUT3(
				// input

				.bits11_8_in(bits11_8_out[7:4]),

				.bits7_4_in(bits7_4_out[7:4]),

				.bits3_0_in(bits3_0_out[7:4]),

				.LDI_in(LDI_out3),

				.brn_in(brn_out3),

				.jmp_in(jmp_out3),

				.MemRd_in(MemRd_out3),

				.MemWr_in(MemWr_out3),

				.invRt_in(invRt_out3),

				.ALU_ctrl_in(ALU_ctrl_out3),

				.Rs_v_in(Rs_v_out3),

				.Rd_v_in(Rd_v_out3),

				.Rt_v_in(Rt_v_out3),

				.im_v_in(im_v_out3),

				.RegWr_in(RegWr_out3),

				.jmp_v_in(jmp_v_out3),

				.ALU_to_add_in(ALU_to_add_out3),

				.ALU_to_mult_in(ALU_to_mult_out3),

				.ALU_to_addr_in(ALU_to_addr_out3),

				.pred_result_in(pred_result_frm_IF[1]),

				.fnsh_unrll_in(fnsh_unrll_out_to_AL),

				.recv_PC_in(recv_pc_in_frm_IF[31:16]),

				.inst_valid_in(inst_vld_out3),		// from IF

				// output

				.dcd_inst_out(dcd_inst3_out_to_AL),

				.bck_lp_out(bck_lp_out3)
			);

	Interpretor interpretor_DUT4(
				// input

				.bits11_8_in(bits11_8_out[3:0]),

				.bits7_4_in(bits7_4_out[3:0]),

				.bits3_0_in(bits3_0_out[3:0]),

				.LDI_in(LDI_out4),

				.brn_in(brn_out4),

				.jmp_in(jmp_out4),

				.MemRd_in(MemRd_out4),

				.MemWr_in(MemWr_out4),

				.invRt_in(invRt_out4),

				.ALU_ctrl_in(ALU_ctrl_out4),

				.Rs_v_in(Rs_v_out4),

				.Rd_v_in(Rd_v_out4),

				.Rt_v_in(Rt_v_out4),

				.im_v_in(im_v_out4),

				.RegWr_in(RegWr_out4),

				.jmp_v_in(jmp_v_out4),

				.ALU_to_add_in(ALU_to_add_out4),

				.ALU_to_mult_in(ALU_to_mult_out4),

				.ALU_to_addr_in(ALU_to_addr_out4),

				.pred_result_in(pred_result_frm_IF[0]),

				.fnsh_unrll_in(fnsh_unrll_out_to_AL),

				.recv_PC_in(recv_pc_in_frm_IF[15:0]),

				.inst_valid_in(inst_vld_out4),		// from IF

				// output

				.dcd_inst_out(dcd_inst4_out_to_AL),

				.bck_lp_out(bck_lp_out4)
			);

	/*LAT LAT_DUT(
			// input
			.bck_lp_bus_in(bck_lp_bus),

			.inst_in(inst_in_frm_IF),

			.pc_in(pc_in_frm_IF),

			.mis_pred_in(mis_pred_in_frm_ROB),
			
			.clk(clk),

			.rst(rst),

			// output
			.lbd_state_out(lbd_state_out_to_AL),

			.fnsh_unrll_out(fnsh_unrll_out_to_AL),	// output to interpretor

			.stll_ftch_out(stll_ftch_out_to_IF),	// output to IF

			.loop_strt_out(loop_strt_out_to_AL),	// output to next stage

			.inst_valid_out(inst_valid_in) // output to interpretor
			);*/

	LAT_not_unroll LAT_DUT(
			// input
			.bck_lp_bus_in(bck_lp_bus),

			.inst_in(inst_in_frm_IF),

			.pc_in(pc_in_frm_IF),

			.mis_pred_in(mis_pred_in_frm_ROB),
			
			.clk(clk),

			.rst(rst),

			// output
			.lbd_state_out(lbd_state_out_to_AL),

			.fnsh_unrll_out(fnsh_unrll_out_to_AL),	// output to interpretor

			.stll_ftch_out(stll_ftch_out_to_IF),	// output to IF

			.loop_strt_out(loop_strt_out_to_AL),	// output to next stage

			.inst_valid_out(inst_valid_in) // output to interpretor
			);

	assign bck_lp_bus = {bck_lp_out1, bck_lp_out2, bck_lp_out3, bck_lp_out4};

endmodule
