module LAT_not_unroll(
		      // input
		      bck_lp_bus_in,
		      inst_in,
		      pc_in,
		      mis_pred_in,
		      clk,
		      rst,
		      // output
		      lbd_state_out,
		      fnsh_unrll_out,	// output to interpretor
		      stll_ftch_out,	// output to IF
		      loop_strt_out,	// output to next stage
		      inst_valid_out // output to interpretor
		      );

   input		[3:0]	bck_lp_bus_in;
   input [63:0] 		inst_in, pc_in;
   input 			mis_pred_in;
   input 			clk, rst;


   output [1:0] 		lbd_state_out;
   output  			fnsh_unrll_out;
   output  			stll_ftch_out;
   output 			loop_strt_out;
   output [3:0] 		inst_valid_out;


   reg [1:0] 			state, nxt_state;
   reg 				tbl_entry_en1, tbl_entry_en2, tbl_entry_en3, tbl_entry_en4;
   reg [1:0] 			LAT_pointer;
//   reg [46:0] 			train_content;	// [46]: valid bit, [45:30]: start_addr, [29:14]: fallthrough_addr, [13:7]: num_insts, [6:0]: max_unroll
   reg [46:0] 			LAT[3:0];

   // LAT fields
   reg [6:0] 			num_of_inst_train, stll_ftch_cnt;
   reg [15:0] 			fallthrough_addr_train, start_addr, fallthrough_addr_dispatch, temp_addr;
   reg 				fallthrough_addr_train_en;
				
  // reg [63:0] 			pc_in_test;
   reg [6:0] 			max_unroll_train, max_unroll_dispatch;

   // control signals
   reg [1:0] 			inst_valid_out_type;
   reg [2:0] 			num_of_inst_train_type;
   reg 				write2LAT, write2LAT_en;
   
   reg [2:0] 			stll_ftch_cnt_type;

   wire 			end_lp1_train, end_lp2_train, end_lp3_train, end_lp4_train, end_lp1_dispatch, end_lp2_dispatch, end_lp3_dispatch, end_lp4_dispatch;
   wire 			dispatch1, dispatch2, dispatch3, dispatch4;

   parameter			IDLE = 2'b00;
   parameter			TRAIN = 2'b01;
   parameter			DISPATCH = 2'b10;

	assign lbd_state_out = 2'b00;
	assign fnsh_unrll_out = 1'b0;
	assign stll_ftch_out = 1'b0;
	assign loop_strt_out = 1'b0;
	assign inst_valid_out = 4'h0;

   

endmodule

