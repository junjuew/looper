`timescale 1ns / 1ps
module IF_ID_tb();
reg clk, rst_n;

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



fetch fetch_DUT(.clk(clk),.rst_n(rst_n),
	//input	
	.stall_fetch(stll_ftch_out_to_IF),
	.loop_start(loop_strt_out_to_AL),
	.decr_count_brnch(1'b0),
	.has_mispredict(1'b0),
	.jump_base_rdy_from_rf(1'b0), 
	.pc_recovery(16'b0),
	.jump_base_from_rf(16'b0),
	.exter_pc(16'b0),
	.exter_pc_en(1'b0),
	.mispred_num(1'b0),
	//output
	.pc_to_dec(pc_to_dec),
	.inst_to_dec(inst_to_dec), 
    .recv_pc_to_dec(recv_pc_to_dec), 
	.pred_result_to_dec(pred_result_to_dec) 
);

IF_ID IF_ID_DUT(.clk(clk), .rst_n(rst_n),
	//input	
	.pc_if_id_in(pc_to_dec),
	.inst_if_id_in(inst_to_dec),
    .recv_pc_if_id_in(recv_pc_to_dec),
	.pred_result_if_id_in(pred_result_to_dec),
	//output
	.pc_if_id_out(pc_if_id_out),
	.inst_if_id_out(inst_if_id_out), 
    .recv_pc_if_id_out(recv_pc_if_id_out), 
	.pred_result_if_id_out(pred_result_if_id_out),
	.stall(1'b0)
);

ID_top ID_top_DUT(.clk(clk), .rst(~rst_n),
	// input
	.inst_in_frm_IF(inst_if_id_out),
	.pc_in_frm_IF(pc_if_id_out),
	.mis_pred_in_frm_ROB(1'b0),
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
    $wlfdumpvars(0, IF_ID_tb);
    clk=0;
    
    forever begin
        #5 clk= ~clk;
   end
end
initial begin
	rst_n = 0;
 #7 rst_n = 1;
end

always@(posedge clk)begin
      #2;

	$display("%t, LAT: LAT entry1: %b\n",$time,ID_top_DUT.LAT_DUT.LAT[0]);
	$display("%t, LAT: LAT entry2: %b\n",$time,ID_top_DUT.LAT_DUT.LAT[1]);
	$display("%t, LAT: LAT entry3: %b\n",$time,ID_top_DUT.LAT_DUT.LAT[2]);
	$display("%t, LAT: LAT entry4: %b\n",$time,ID_top_DUT.LAT_DUT.LAT[3]);
end
endmodule
