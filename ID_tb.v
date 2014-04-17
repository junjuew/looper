`timescale 1ns / 1ps
module ID_tb();
reg clk, rst_n;
reg [63:0]   inst_if_id_out;
reg [63:0]   pc_if_id_out, recv_pc_if_id_out;
reg [3:0]    pred_result_if_id_out;

// ID output wires
wire [65:0]	dcd_inst1_out_to_AL, dcd_inst2_out_to_AL, dcd_inst3_out_to_AL, dcd_inst4_out_to_AL;
wire [1:0]	lbd_state_out_to_AL;
wire fnsh_unrll_out_to_AL, stll_ftch_out_to_IF;
wire loop_strt_out_to_AL;

ID_top ID_top_DUT(.clk(clk), .rst(~rst_n),
	// input
	.inst_in_frm_IF(inst_if_id_out),
	.pc_in_frm_IF(pc_if_id_out),
	.mis_pred_in_frm_ROB(),
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

initial begin
    clk=0;

    forever begin
        #1 clk= ~clk;
   end
end
initial begin
	rst_n = 0;
 #2 rst_n = 1;
 inst_if_id_out = 64'hc10fc21413120000;
end
endmodule