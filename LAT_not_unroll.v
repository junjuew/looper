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
//   reg [46:0] 			train_content;	// [46]: valid bit, [45:30]: start_addr, [29:14]: fallthrough_addr, [13:7]: num_insts, [6:0]: max_unroll
   reg [46:0] 			LAT[3:0];

   // LAT fields
   reg [6:0] 			num_of_inst_train, stll_ftch_cnt;
   reg [15:0] 			fallthrough_addr_train, start_addr, fallthrough_addr_dispatch, temp_addr;
   reg 				fallthrough_addr_train_en;
				
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
	    or state or stll_ftch_cnt or max_unroll_dispatch)
     begin
	//	if (rst)
	//		begin
	nxt_state = IDLE;
//	train_content = 45'b0;
	num_of_inst_train_type = 3'b0;
	

	inst_valid_out_type = 2'b11;
	fnsh_unrll_out = 1'b0;
	stll_ftch_out = 1'b0;
	stll_ftch_cnt_type = 3'b0;
	write2LAT_en = 1'b0;
	fallthrough_addr_train_en = 1'b0;

	 if (state == IDLE)
	   begin
	      num_of_inst_train_type = 3'b0;
	      //num_of_inst_cnt = 7'b0;
	      inst_valid_out_type = 2'b11;
	      fnsh_unrll_out = 1'b0;
	      stll_ftch_out = 1'b0;
	      stll_ftch_cnt_type = 3'b0;
	      if (bck_lp_bus_in != 4'b0)
		begin
		   fallthrough_addr_train_en = 1'b1;
		   nxt_state = TRAIN;

		end
	      if (loop_strt_out == 1'b1)
		begin
		   nxt_state = DISPATCH;
		   casex ({end_lp1_dispatch, end_lp2_dispatch, end_lp3_dispatch, end_lp4_dispatch})
		     4'b1xxx: begin inst_valid_out_type = 2'b00; stll_ftch_cnt_type = 3'b001; end
		     4'bx1xx: begin inst_valid_out_type = 2'b01; stll_ftch_cnt_type = 3'b010; end
		     4'bxx1x: begin inst_valid_out_type = 2'b10; stll_ftch_cnt_type = 3'b011; end
		     4'bxxx1: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		     4'b0000: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		   endcase
		end
	   end // end IDLE
	 if (state == TRAIN)
	   begin
	      if (loop_strt_out == 1'b1)
		begin
		   nxt_state = DISPATCH;
		   casex ({end_lp1_train, end_lp2_train, end_lp3_train, end_lp4_train})
		     4'b1xxx: begin inst_valid_out_type = 2'b00; stll_ftch_cnt_type = 3'b001; end
		     4'bx1xx: begin inst_valid_out_type = 2'b01; stll_ftch_cnt_type = 3'b010; end
		     4'bxx1x: begin inst_valid_out_type = 2'b10; stll_ftch_cnt_type = 3'b011; end
		     4'bxxx1: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		     4'b0000: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		   endcase
		end
	      else
		begin
			
		   casex ({end_lp1_train, end_lp2_train, end_lp3_train, end_lp4_train})
		     5'b1xxx: begin num_of_inst_train_type = 3'b001; nxt_state = IDLE; write2LAT_en = 1'b1; end
		     5'bx1xx: begin num_of_inst_train_type = 3'b010; nxt_state = IDLE; write2LAT_en = 1'b1; end
		     5'bxx1x: begin num_of_inst_train_type = 3'b011; nxt_state = IDLE; write2LAT_en = 1'b1; end
		     5'bxxx1: begin num_of_inst_train_type = 3'b100; nxt_state = IDLE; write2LAT_en = 1'b1; end
		     5'b0000: begin num_of_inst_train_type = 3'b100; nxt_state = TRAIN; end
		   endcase

		end	
	   end // end TRAIN
	 //
	 if (state == DISPATCH)
	   begin
	      casex ({end_lp1_dispatch, end_lp2_dispatch, end_lp3_dispatch, end_lp4_dispatch})
		4'b1xxx: begin inst_valid_out_type = 2'b00; stll_ftch_cnt_type = 3'b001; end
		4'bx1xx: begin inst_valid_out_type = 2'b01; stll_ftch_cnt_type = 3'b010; end
		4'bxx1x: begin inst_valid_out_type = 2'b10; stll_ftch_cnt_type = 3'b011; end
		4'bxxx1: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
		4'b0000: begin inst_valid_out_type = 2'b11; stll_ftch_cnt_type = 3'b100; end
	      endcase
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
      end // always @ (...



    always@(posedge clk, posedge rst)
      begin
	 if(rst)
	   fallthrough_addr_train <= 16'b0;
	 else if(fallthrough_addr_train_en)
	   begin
	      if(bck_lp_bus_in[3] == 1'b1)
		fallthrough_addr_train <= pc_in[63:48] + 1;
	      else if(bck_lp_bus_in[2] == 1'b1)
		fallthrough_addr_train <= pc_in[47:32] + 1;
	      else if(bck_lp_bus_in[1] == 1'b1)
		fallthrough_addr_train <= pc_in[31:16] + 1;
	      else if(bck_lp_bus_in[0] == 1'b1)
		fallthrough_addr_train <= pc_in[15:0] + 1;
	      else
		fallthrough_addr_train <= fallthrough_addr_train;
	   end // if (fallthrough_addr_train_en)
	 else
	   fallthrough_addr_train <= fallthrough_addr_train;
      end // always@ (posedge clk, posedge rst)



    always@(posedge clk, posedge rst)
      begin
	 if(rst)
	   fallthrough_addr_dispatch <= 16'b0;
	 else if(loop_strt_out)
	   begin
	      if(dispatch1 == 1'b1)
		fallthrough_addr_dispatch <= LAT[0][29:14];
	      else if(dispatch2 == 1'b1)
		fallthrough_addr_dispatch <= LAT[1][29:14];
	      else if(dispatch3 == 1'b1)
		fallthrough_addr_dispatch <= LAT[2][29:14];
	      else if(dispatch4 == 1'b1)
		fallthrough_addr_dispatch <= LAT[3][29:14];
	      else
		fallthrough_addr_dispatch <= fallthrough_addr_dispatch;
	   end // if (fallthrough_addr_dispatch_en)
	 else
	   fallthrough_addr_dispatch <= fallthrough_addr_dispatch;
      end // always@ (posedge clk, posedge rst)   

    always@(posedge clk, posedge rst)
      begin
	 if(rst)
	   max_unroll_dispatch <= 7'b0;
	 else if(loop_strt_out || (state == DISPATCH))
	   begin
	      if((dispatch1 | dispatch2 | dispatch3 | dispatch4) && (end_lp1_dispatch | end_lp2_dispatch | end_lp3_dispatch | end_lp4_dispatch))
		max_unroll_dispatch <= 7'b0;
	      else if(dispatch1)
		if (write2LAT)
		  max_unroll_dispatch <= max_unroll_train;
		else
		  max_unroll_dispatch <= LAT[0][6:0];
	      else if(dispatch2)
		if (write2LAT)
		  max_unroll_dispatch <= max_unroll_train;
		else
		  max_unroll_dispatch <= LAT[1][6:0];
	      else if(dispatch3)
		if (write2LAT)
		  max_unroll_dispatch <= max_unroll_train;
		else
		  max_unroll_dispatch <= LAT[2][6:0];
	      else if(dispatch4)
		if (write2LAT)
		  max_unroll_dispatch <= max_unroll_train;
		else
		  max_unroll_dispatch <= LAT[3][6:0];
	      else if(end_lp1_dispatch | end_lp2_dispatch | end_lp3_dispatch | end_lp4_dispatch)
		max_unroll_dispatch <= max_unroll_dispatch - 7'h1;
	      else
		max_unroll_dispatch <= max_unroll_dispatch;
	   end // if (loop_strt_out || (state == DISPATCH))
	 else
	   max_unroll_dispatch <= max_unroll_dispatch;
      end // always@ (posedge clk, posedge rst)
   
	

      
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
   assign dispatch1 = (write2LAT == 1'b1) ? ((pc_in[63:48] == start_addr && LAT_pointer == 2'b00) ? 1'b1 : 1'b0) : (pc_in[63:48] == LAT[0][45:30]) ? 1 : 0;
   assign dispatch2 = (write2LAT == 1'b1) ? ((pc_in[63:48] == start_addr && LAT_pointer == 2'b01) ? 1'b1 : 1'b0) : (pc_in[63:48] == LAT[1][45:30]) ? 1 : 0;
   assign dispatch3 = (write2LAT == 1'b1) ? ((pc_in[63:48] == start_addr && LAT_pointer == 2'b10) ? 1'b1 : 1'b0) : (pc_in[63:48] == LAT[2][45:30]) ? 1 : 0;
   assign dispatch4 = (write2LAT == 1'b1) ? ((pc_in[63:48] == start_addr && LAT_pointer == 2'b11) ? 1'b1 : 1'b0) : (pc_in[63:48] == LAT[3][45:30]) ? 1 : 0;
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
	  start_addr <= 16'b0;
	else if((state == TRAIN) && (num_of_inst_train == 0))
	  start_addr <= pc_in[63:48];
	else 
	  start_addr <= start_addr;	
    end 



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



   always@(posedge clk, posedge rst)
     begin
	if(rst)
	  write2LAT <= 1'b0;
	else
	  write2LAT <= write2LAT_en;
	
     end // always@ (posedge clk, posedge rst)
   
   

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
	  7'b0000001: begin max_unroll_train = 7'd1; end 	// 1
	  7'b0000010: begin max_unroll_train = 7'd1; end 	// 2
	  7'b0000011: begin max_unroll_train = 7'd1; end 	// 3
	  7'b0000100: begin max_unroll_train = 7'd1; end 	// 4
	  7'b0000101: begin max_unroll_train = 7'd1; end 	// 5
	  7'b0000110: begin max_unroll_train = 7'd1; end 	// 6
	  7'b0000111: begin max_unroll_train = 7'd1; end 	// 7
	  7'b0001000: begin max_unroll_train = 7'd1; end 	// 8
	  7'b0001001: begin max_unroll_train = 7'd1; end 	// 9
	  7'b0001010: begin max_unroll_train = 7'd1; end 	// 10
	  7'b0001011: begin max_unroll_train = 7'd1; end 	// 11
	  7'b0001100: begin max_unroll_train = 7'd1; end 	// 12
	  7'b0001101: begin max_unroll_train = 7'd1; end 	// 13
	  7'b000111x: begin max_unroll_train = 7'd1; end 	// 14, 15
	  7'b0010000: begin max_unroll_train = 7'd1; end 	// 16
	  7'b0010001: begin max_unroll_train = 7'd1; end 	// 17
	  7'b001001x: begin max_unroll_train = 7'd1; end 	// 18, 19
	  7'b001010x: begin max_unroll_train = 7'd1; end 	// 20, 21
	  7'b001011x: begin max_unroll_train = 7'd1; end 	// 22, 23
	  7'b0011xxx: begin max_unroll_train = 7'd1; end 	// 24, 25, 26, 27, 28, 29, 30, 31
	  7'b01xxxxx: begin max_unroll_train = 7'd1; end 	// 32 ~ 63
	  7'b1000000: begin max_unroll_train = 7'd1; end   // 64
	  default: begin max_unroll_train = 7'd0; end
	endcase
     end
   //
   //
   always @(posedge clk,posedge rst)
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
	
	else if (write2LAT)
	  begin
	     case(LAT_pointer)
	       2'b00: begin LAT[1] <= LAT[1]; LAT[2] <= LAT[2]; LAT[3] <= LAT[3]; LAT[0] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	       2'b01: begin LAT[0] <= LAT[0]; LAT[2] <= LAT[2]; LAT[3] <= LAT[3]; LAT[1] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	       2'b10: begin LAT[1] <= LAT[1]; LAT[0] <= LAT[0]; LAT[3] <= LAT[3]; LAT[2] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	       2'b11: begin LAT[1] <= LAT[1]; LAT[2] <= LAT[2]; LAT[0] <= LAT[0]; LAT[3] <= {1'b1, start_addr, fallthrough_addr_train, num_of_inst_train, max_unroll_train}; end
	     endcase
	     LAT_pointer <= LAT_pointer + 1;
	  end	
	else 
		begin
		  LAT[0] <= LAT[0];
	     LAT[1] <= LAT[1];
	     LAT[2] <= LAT[2];
	     LAT[3] <= LAT[3];
	     LAT_pointer <= LAT_pointer;
		  end
   end
   //*/

endmodule

