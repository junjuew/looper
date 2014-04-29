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
   output reg 			fnsh_unrll_out;
   output reg 			stll_ftch_out;
   output 			loop_strt_out;
   output [3:0] 		inst_valid_out;

   /*assign lbd_state_out = 2'b00;
    assign fnsh_unrll_out = 1'b0;
    assign stll_ftch_out = 1'b0;
    assign loop_strt_out = 1'b0;
    assign inst_valid_out = 4'h0;
    */

   reg [1:0] 			state, nxt_state;
   reg 				tbl_entry_en1, tbl_entry_en2, tbl_entry_en3, tbl_entry_en4;
   reg [1:0] 			LAT_pointer;
   reg [46:0] 			train_content;	// [46]: valid bit, [45:30]: start_addr, [29:14]: fallthrough_addr, [13:7]: num_insts, [6:0]: max_unroll
   reg [46:0] 			LAT[3:0];

   // LAT fields
   reg [6:0] 			num_of_inst_train, stll_ftch_cnt;
   reg [15:0] 			fallthrough_addr_train, start_addr, fallthrough_addr_dispatch, temp_addr;
   reg [63:0] 			pc_in_test;
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



   //*
   //assign lbd_state_out = IDLE;
   //assign fnsh_unrll_out = 0;
   //assign stll_ftch_out = 0;
   //assign loop_strt_out = 0;
   //assign inst_valid_out = 4'bzzzz;
   //*/
   always @(posedge clk,posedge rst)
     begin
    	// on reset
        if (rst)
	  begin
	     state <= IDLE;
	  end
	else
	  begin
	     state <= nxt_state;
	  end				
     end
   //
   always @(/*autosense*/ 
	    LAT[0][46:0] or LAT[1][46:0] or LAT[2][46:0] or LAT[3][46:0]
	    or bck_lp_bus_in
	    or dispatch1 or dispatch2 or dispatch3 or dispatch4
	    or end_lp1_dispatch or end_lp1_train
	    or end_lp2_dispatch or end_lp2_train
	    or end_lp3_dispatch or end_lp3_train
	    or end_lp4_dispatch or end_lp4_train or loop_strt_out
	    or mis_pred_in or num_of_inst_train or pc_in or rst
	    or state or stll_ftch_cnt)
     begin
	//	if (rst)
	//		begin
	nxt_state = IDLE;
	train_content = 45'b0;
	num_of_inst_train_type = 3'b0;
	fallthrough_addr_train = 16'b0;
	fallthrough_addr_dispatch = 16'b0;
	inst_valid_out_type = 4'b1111;
	fnsh_unrll_out = 1'b0;
	stll_ftch_out = 1'b0;
	stll_ftch_cnt_type = 3'b0;
	write2LAT = 1'b0;
	write2LAT_en = 1'b0;
	if (state == IDLE)
	  begin
	     num_of_inst_train_type = 3'b0;
	     //num_of_inst_cnt = 7'b0;
	     inst_valid_out_type = 4'b1111;
	     fnsh_unrll_out = 1'b0;
	     stll_ftch_out = 1'b0;
	     stll_ftch_cnt_type = 3'b0;
	     write2LAT = 1'b0;
	     write2LAT_en = 1'b0;
	     if (bck_lp_bus_in & 4'b1111 != 4'b0)
	       begin
		  casex(bck_lp_bus_in)
		    4'b1xxx: begin  fallthrough_addr_train = pc_in[63:48] + 1; nxt_state = TRAIN; end
		    4'bx1xx: begin  fallthrough_addr_train = pc_in[47:32] + 1; nxt_state = TRAIN; end
		    4'bxx1x: begin  fallthrough_addr_train = pc_in[31:16] + 1; nxt_state = TRAIN; end
		    4'bxxx1: begin  fallthrough_addr_train = pc_in[15:0] + 1; nxt_state = TRAIN; end
		  endcase
	       end
	     if (loop_strt_out == 1'b1)
	       begin
		  nxt_state = DISPATCH;
		  casex({dispatch1, dispatch2, dispatch3, dispatch4})
		    4'b1xxx: begin max_unroll_dispatch = LAT[0][6:0]; fallthrough_addr_dispatch = LAT[0][29:14]; end
		    4'bx1xx: begin max_unroll_dispatch = LAT[1][6:0]; fallthrough_addr_dispatch = LAT[1][29:14]; end
		    4'bxx1x: begin max_unroll_dispatch = LAT[2][6:0]; fallthrough_addr_dispatch = LAT[2][29:14]; end
		    4'bxxx1: begin max_unroll_dispatch = LAT[3][6:0]; fallthrough_addr_dispatch = LAT[3][29:14]; end
		  endcase
		  casex ({end_lp1_dispatch, end_lp2_dispatch, end_lp3_dispatch, end_lp4_dispatch})
		    4'b1xxx: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b00; stll_ftch_cnt_type = 3'b001; end
		    4'bx1xx: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b01; stll_ftch_cnt_type = 3'b010; end
		    4'bxx1x: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b10; stll_ftch_cnt_type = 3'b011; end
		    4'bxxx1: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		    4'b0000: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		  endcase
	       end
	  end // end IDLE
	if (state == TRAIN)
	  begin
	     if (loop_strt_out == 1'b1)
	       begin
		  nxt_state = DISPATCH;
		  casex({dispatch1, dispatch2, dispatch3, dispatch4})
		    4'b1xxx: begin max_unroll_dispatch = LAT[0][6:0]; fallthrough_addr_dispatch = LAT[0][29:14]; end
		    4'bx1xx: begin max_unroll_dispatch = LAT[1][6:0]; fallthrough_addr_dispatch = LAT[1][29:14]; end
		    4'bxx1x: begin max_unroll_dispatch = LAT[2][6:0]; fallthrough_addr_dispatch = LAT[2][29:14]; end
		    4'bxxx1: begin max_unroll_dispatch = LAT[3][6:0]; fallthrough_addr_dispatch = LAT[3][29:14]; end
		  endcase
		  casex ({end_lp1_train, end_lp2_train, end_lp3_train, end_lp4_train})
		    4'b1xxx: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b00; stll_ftch_cnt_type = 3'b001; end
		    4'bx1xx: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b01; stll_ftch_cnt_type = 3'b010; end
		    4'bxx1x: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b10; stll_ftch_cnt_type = 3'b011; end
		    4'bxxx1: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		    4'b0000: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		  endcase
	       end
	     else
	       begin
		  if (num_of_inst_train == 0)
		    begin
		       start_addr = pc_in[63:48];
		    end
		  casex ({end_lp1_train, end_lp2_train, end_lp3_train, end_lp4_train, write2LAT_en})
		    5'b1xxx_0: begin num_of_inst_train_type = 3'b001; nxt_state = TRAIN; write2LAT_en = 1'b1; end
		    5'bx1xx_0: begin num_of_inst_train_type = 3'b010; nxt_state = TRAIN; write2LAT_en = 1'b1; end
		    5'bxx1x_0: begin num_of_inst_train_type = 3'b011; nxt_state = TRAIN; write2LAT_en = 1'b1; end
		    5'bxxx1_0: begin num_of_inst_train_type = 3'b100; nxt_state = TRAIN; write2LAT_en = 1'b1; end
		    5'b1xxx_1: begin num_of_inst_train_type = 3'b001; nxt_state = IDLE; write2LAT = 1'b1; end
		    5'bx1xx_1: begin num_of_inst_train_type = 3'b010; nxt_state = IDLE; write2LAT = 1'b1; end
		    5'bxx1x_1: begin num_of_inst_train_type = 3'b011; nxt_state = IDLE; write2LAT = 1'b1; end
		    5'bxxx1_1: begin num_of_inst_train_type = 3'b100; nxt_state = IDLE; write2LAT = 1'b1; end
		    5'b0000_x: begin num_of_inst_train_type = 3'b100; nxt_state = TRAIN; end
		  endcase

	       end	
	  end // end TRAIN
	//
	if (state == DISPATCH)
	  begin
	     casex ({end_lp1_dispatch, end_lp2_dispatch, end_lp3_dispatch, end_lp4_dispatch})
	       4'b1xxx: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b00; stll_ftch_cnt_type = 3'b001; end
	       4'bx1xx: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b01; stll_ftch_cnt_type = 3'b010; end
	       4'bxx1x: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b10; stll_ftch_cnt_type = 3'b011; end
	       4'bxxx1: begin max_unroll_dispatch = max_unroll_dispatch - 1; inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
	       4'b0000: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
	     endcase
	     write2LAT = 1'b0;
    	     num_of_inst_train_type = 3'b0;
	     if (mis_pred_in != 1'b1)
	       begin
		  nxt_state = DISPATCH;
		  if (max_unroll_dispatch == 7'd0)
		    begin
		       fnsh_unrll_out = 1'b1;
		    end
		  if (stll_ftch_cnt != 7'd64)
		    begin
		       stll_ftch_out = 1'b0;
		    end
		  else 
		    begin
		       stll_ftch_out = 1'b1;
		    end
	       end
	     else 
	       begin
		  nxt_state = IDLE;
	       end
	  end
     end 
   //
   assign end_lp1_dispatch = (pc_in[63:48] - fallthrough_addr_dispatch + 1 == 16'b0) ? 1 : 0;
   assign end_lp2_dispatch = (pc_in[47:32] - fallthrough_addr_dispatch + 1 == 16'b0) ? 1 : 0;
   assign end_lp3_dispatch = (pc_in[31:16] - fallthrough_addr_dispatch + 1 == 16'b0) ? 1 : 0;
   assign end_lp4_dispatch = (pc_in[15:0] - fallthrough_addr_dispatch + 1 == 16'b0) ? 1 : 0;
   //
   assign end_lp1_train = (pc_in[63:48] - fallthrough_addr_train + 1 == 16'b0) ? 1 : 0;
   assign end_lp2_train = (pc_in[47:32] - fallthrough_addr_train + 1 == 16'b0) ? 1 : 0;
   assign end_lp3_train = (pc_in[31:16] - fallthrough_addr_train + 1 == 16'b0) ? 1 : 0;
   assign end_lp4_train = (pc_in[15:0] - fallthrough_addr_train + 1 == 16'b0) ? 1 : 0;
   //
   assign dispatch1 = (pc_in[63:48] == LAT[0][45:30]) ? 1 : 0;
   assign dispatch2 = (pc_in[63:48] == LAT[1][45:30]) ? 1 : 0;
   assign dispatch3 = (pc_in[63:48] == LAT[2][45:30]) ? 1 : 0;
   assign dispatch4 = (pc_in[63:48] == LAT[3][45:30]) ? 1 : 0;
   assign loop_strt_out = (state == 2'b10) ? 0 : (dispatch1 || dispatch2 || dispatch3 || dispatch4);
   //
   // update inst_valid_out
   assign inst_valid_out = (inst_valid_out_type == 2'b00) ? 4'b1000 :
			   (inst_valid_out_type == 2'b01) ? 4'b1100 :
			   (inst_valid_out_type == 2'b10) ? 4'b1110 : 4'b1111;
   //
   //
   /*always @(end_lp1_dispatch, end_lp2_dispatch, end_lp3_dispatch, end_lp4_dispatch)
    //
    begin
    if (state == DISPATCH)
    begin
			end
	end*/
   //
   // update num_of_inst_train

   always@(posedge clk, posedge rst)
     begin
	if(rst)
	  num_of_inst_train <= 7'b0;
	else if(num_of_inst_train_type == 3'b000)
	  num_of_inst_train <= 7'b0;
	else if(num_of_inst_train_type == 3'b001)
	  num_of_inst_train <= num_of_inst_train + 1;
	else if(num_of_inst_train_type == 3'b010)
	  num_of_inst_train <= num_of_inst_train + 2;
	else if(num_of_inst_train_type == 3'b011)
	  num_of_inst_train <= num_of_inst_train + 3;
	else if(num_of_inst_train_type == 3'b100)
	  num_of_inst_train <= num_of_inst_train + 4;
	else
	  num_of_inst_train <= num_of_inst_train;
     end // always@ (posedge clk, negedge rst_n)
   
   

/* -----\/----- EXCLUDED -----\/-----
   always @(/-*autosense*-/num_of_inst_train_type)
     begin
	case(num_of_inst_train_type)
	  3'b001: begin num_of_inst_train = num_of_inst_train + 1; end
	  3'b010: begin num_of_inst_train = num_of_inst_train + 2; end
	  3'b011: begin num_of_inst_train = num_of_inst_train + 3; end
	  3'b100: begin num_of_inst_train = num_of_inst_train + 4; end
	  default: begin num_of_inst_train = 7'b0;				  end
	endcase
     end
 -----/\----- EXCLUDED -----/\----- */

   //


   always@(posedge clk, posedge rst)
     begin
	if(rst)
	  stll_ftch_cnt <= 7'b0;
	else if(stll_ftch_cnt_type == 3'b000)
	  stll_ftch_cnt <= 7'b0;
	
	else if(stll_ftch_cnt_type == 3'b001)
	  stll_ftch_cnt <= stll_ftch_cnt + 1;
	else if(stll_ftch_cnt_type == 3'b010)
	  stll_ftch_cnt <= stll_ftch_cnt + 2;
	else if(stll_ftch_cnt_type == 3'b011)
	  stll_ftch_cnt <= stll_ftch_cnt + 3;
	else if(stll_ftch_cnt_type == 3'b100)
	  stll_ftch_cnt <= stll_ftch_cnt + 4;
	else
	  stll_ftch_cnt <= stll_ftch_cnt;
     end // always@ (posedge clk, negedge rst_n)

   
   

/* -----\/----- EXCLUDED -----\/-----
   always @(stll_ftch_cnt_type)
     begin
	case (stll_ftch_cnt_type)
	  3'b001: begin stll_ftch_cnt = stll_ftch_cnt + 1; end
	  3'b010: begin stll_ftch_cnt = stll_ftch_cnt + 2; end
	  3'b011: begin stll_ftch_cnt = stll_ftch_cnt + 3; end
	  3'b100: begin stll_ftch_cnt = stll_ftch_cnt + 4; end
	  default: begin stll_ftch_cnt = 7'b0; end
	endcase
     end
 -----/\----- EXCLUDED -----/\----- */

   //
   always @(num_of_inst_train)
     begin
	// generate max unroll
	casex(num_of_inst_train)
	  7'b0000001: begin max_unroll_train <= 7'd1; end 	// 1
	  7'b0000010: begin max_unroll_train <= 7'd1; end 	// 2
	  7'b0000011: begin max_unroll_train <= 7'd1; end 	// 3
	  7'b0000100: begin max_unroll_train <= 7'd1; end 	// 4
	  7'b0000101: begin max_unroll_train <= 7'd1; end 	// 5
	  7'b0000110: begin max_unroll_train <= 7'd1; end 	// 6
	  7'b0000111: begin max_unroll_train <= 7'd1; end 	// 7
	  7'b0001000: begin max_unroll_train <= 7'd1; end 	// 8
	  7'b0001001: begin max_unroll_train <= 7'd1; end 	// 9
	  7'b0001010: begin max_unroll_train <= 7'd1; end 	// 10
	  7'b0001011: begin max_unroll_train <= 7'd1; end 	// 11
	  7'b0001100: begin max_unroll_train <= 7'd1; end 	// 12
	  7'b0001101: begin max_unroll_train <= 7'd1; end 	// 13
	  7'b000111x: begin max_unroll_train <= 7'd1; end 	// 14, 15
	  7'b0010000: begin max_unroll_train <= 7'd1; end 	// 16
	  7'b0010001: begin max_unroll_train <= 7'd1; end 	// 17
	  7'b001001x: begin max_unroll_train <= 7'd1; end 	// 18, 19
	  7'b001010x: begin max_unroll_train <= 7'd1; end 	// 20, 21
	  7'b001011x: begin max_unroll_train <= 7'd1; end 	// 22, 23
	  7'b0011xxx: begin max_unroll_train <= 7'd1; end 	// 24, 25, 26, 27, 28, 29, 30, 31
	  7'b01xxxxx: begin max_unroll_train <= 7'd1; end 	// 32 ~ 63
	  7'b1000000: begin max_unroll_train <= 7'd1; end   // 64
	  default: begin max_unroll_train <= 7'd0; end
	endcase
     end
   //
   //
   always @(/*autosense*/fallthrough_addr_train
	    or max_unroll_train or num_of_inst_train or rst
	    or start_addr or write2LAT)
     //
     begin
	if (rst)
	  begin
	     LAT[0] <= {47{1'b1}};
	     LAT[1] <= {47{1'b1}};
	     LAT[2] <= {47{1'b1}};
	     LAT[3] <= {47{1'b1}};
	     LAT_pointer <= 2'b0;
	  end
	if (write2LAT)
	  begin
	     casex(LAT_pointer)
	       2'b00: begin LAT[0] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	       2'b01: begin LAT[1] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	       2'b10: begin LAT[2] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	       2'b11: begin LAT[3] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	     endcase
	     LAT_pointer <= LAT_pointer + 1;
	  end	
     end
   //*/

endmodule
