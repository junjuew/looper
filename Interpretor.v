module Interpretor(
	// input
	bits11_8_in,
	bits7_4_in,
	bits3_0_in,
	LDI_in,
	brn_in,
	jmp_in,
	MemRd_in,
	MemWr_in,
	invRt_in,
	ALU_ctrl_in,
	Rs_v_in,
	Rd_v_in,
	Rt_v_in,
	im_v_in,
	RegWr_in,
	jmp_v_in,
	ALU_to_add_in,
	ALU_to_mult_in,
	ALU_to_addr_in,
	pred_result_in,
	fnsh_unrll_in,
	recv_PC_in,
	inst_valid_in,		
	// output
	dcd_inst_out,
	bck_lp_out);

	input	[15:0]	recv_PC_in;
	input	[3:0]	bits11_8_in, bits7_4_in, bits3_0_in;
	input		LDI_in, MemRd_in, MemWr_in, invRt_in, Rs_v_in, Rd_v_in, Rt_v_in, im_v_in, RegWr_in, jmp_v_in, ALU_to_add_in, ALU_to_mult_in, ALU_to_addr_in, pred_result_in, fnsh_unrll_in, inst_valid_in;
	input	[1:0]	brn_in, jmp_in;
	input	[2:0]	ALU_ctrl_in;

	output	[65:0]	dcd_inst_out;
	output		bck_lp_out;

	wire 	[3:0]	Rs, Rd, Rt;
	wire	[15:0]	immediate;

	
	assign Rs = (brn_in == 2'b00 && LDI_in == 1'b0 && jmp_v_in == 1'b0) ? bits7_4_in : bits11_8_in; 
	assign Rt = bits3_0_in;
	//changed from  assign Rd = bits11_8_in; to:
	assign Rd = (jmp_in[1] == 1'b1) ? 5'd15 : bits11_8_in;
	assign immediate = (brn_in != 2'b00 || LDI_in == 1'b1) ? {{8{bits7_4_in[3]}}, bits7_4_in, bits3_0_in} : 
			   (MemRd_in == 1'b1 || MemWr_in == 1'b1) ? {{12{bits3_0_in[3]}}, bits3_0_in} :
			   (jmp_in[0] == 1'b1) ? {{6{bits7_4_in[3]}},bits7_4_in, bits3_0_in[3:2]} : {{6{bits11_8_in[3]}}, bits11_8_in, bits7_4_in, bits3_0_in[3:2]};
	assign dcd_inst_out = (fnsh_unrll_in == 1'b1) ? 66'b0 : (inst_valid_in) ? {inst_valid_in, Rs_v_in, Rs, Rd_v_in, Rd, Rt_v_in, Rt, im_v_in, immediate, LDI_in, brn_in, jmp_v_in, jmp_in, MemRd_in, MemWr_in, ALU_ctrl_in, ALU_to_add_in, ALU_to_mult_in, ALU_to_addr_in, invRt_in, RegWr_in, pred_result_in, recv_PC_in} : 66'b0;
	assign bck_lp_out = (brn_in != 2'b00 && bits7_4_in[3] == 1'b1) ? 1 : 0;




endmodule
