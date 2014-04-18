module LAT(
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
	input		[63:0]	inst_in, pc_in;
	input				mis_pred_in;
	input				clk, rst;


	output		[1:0]	lbd_state_out;
	output				fnsh_unrll_out;
	output				stll_ftch_out;
	output				loop_strt_out;
	output       [3:0]  inst_valid_out;

	reg			[1:0]	state, nxt_state;
	reg					tbl_entry_en1, tbl_entry_en2, tbl_entry_en3, tbl_entry_en4;
	reg			[1:0]	LAT_pointer;
	reg			[46:0]	train_content;	// [46]: valid bit, [45:30]: start_addr, [29:14]: fallthrough_addr, [13:7]: num_insts, [6:0]: max_unroll
	reg			[44:0] 	LAT[3:0];

	// LAT fields
	reg			[6:0]	num_of_inst, stll_ftch_cnt;
	reg			[15:0]	fallthrough_addr, start_addr, temp_addr;
	reg			[63:0]	pc_in_test;
	reg 		[6:0]	max_unroll;

	wire 				end_lp1, end_lp2, end_lp3, end_lp4;
	wire 				dispatch1, dispatch2, dispatch3, dispatch4;

	parameter			IDLE = 2'b00;
	parameter			TRAIN = 2'b01;
	parameter			DISPATCH = 2'b10;



	assign lbd_state_out = IDLE;
	assign fnsh_unrll_out = 0;
	assign stll_ftch_out = 0;
	assign loop_strt_out = 0;
	assign inst_valid_out = 4'bzzzz;
/*
	always @(posedge clk)
	    begin
	        if (rst)
		    begin
		        state <= IDLE;
				nxt_state <= IDLE;
				train_content <= 45'b0;
				num_of_inst <= 6'b0;
				fallthrough_addr <= 6'b0;
				start_addr <= 6'b0;
				LAT_pointer <= 2'b0;
		    	//num_of_inst_cnt <= 7'b0;
		    	max_unroll <= 7'b0;
		    	inst_valid_out <= 4'b1111;
		    	fnsh_unrll_out <= 1'b0;
		    	stll_ftch_out <= 1'b0;
		    	stll_ftch_cnt <= 7'b0;
		    	LAT[0] <= {45{1'b1}};
		    	LAT[1] <= {45{1'b1}};
		    	LAT[2] <= {45{1'b1}};
		    	LAT[3] <= {45{1'b1}};
		    end
		else
            begin
				state <= nxt_state;
		    end				
	    end

	always @(*)
	    begin
			if (state == IDLE)
			    begin
			    	num_of_inst <= 7'b0;
			    	//num_of_inst_cnt <= 7'b0;
			    	max_unroll <= 7'b0;
			    	inst_valid_out <= 4'b1111;
		    		fnsh_unrll_out <= 1'b0;
		    		stll_ftch_out <= 1'b0;
		    		stll_ftch_cnt <= 7'b0;
					if (bck_lp_bus_in & 4'b1111 != 4'b0)
					    begin
			    	        casex(bck_lp_bus_in)
							    4'b1xxx: begin  fallthrough_addr <= pc_in[63:48] + 1; nxt_state <= TRAIN; end
							    4'bx1xx: begin  fallthrough_addr <= pc_in[47:32] + 1; nxt_state <= TRAIN; end
							    4'bxx1x: begin  fallthrough_addr <= pc_in[31:16] + 1; nxt_state <= TRAIN; end
							    4'bxxx1: begin  fallthrough_addr <= pc_in[15:0] + 1; nxt_state <= TRAIN; end
					        endcase
					    end
					if (loop_strt_out == 1'b1)
						begin
							nxt_state <= DISPATCH;
							casex({dispatch1, dispatch2, dispatch3, dispatch4})
								4'b1xxx: begin max_unroll <= LAT[0][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[0][29:14]; end
								4'bx1xx: begin max_unroll <= LAT[1][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[1][29:14]; end
								4'bxx1x: begin max_unroll <= LAT[2][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[2][29:14]; end
								4'bxxx1: begin max_unroll <= LAT[3][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[3][29:14]; end
							endcase
						    casex ({end_lp1, end_lp2, end_lp3, end_lp4})
						    	4'b1xxx: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1000; stll_ftch_cnt <= stll_ftch_cnt + 1; end
						    	4'bx1xx: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1100; stll_ftch_cnt <= stll_ftch_cnt + 2; end
						    	4'bxx1x: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1110; stll_ftch_cnt <= stll_ftch_cnt + 3; end
						    	4'bxxx1: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1111; stll_ftch_cnt <= stll_ftch_cnt + 4; end
						    	4'b0000: begin inst_valid_out <= 4'b1111; stll_ftch_cnt <= stll_ftch_cnt + 4; end
						    endcase
						end
			    end // end IDLE
			if (state == TRAIN)
			    begin
					if (loop_strt_out == 1'b1)
						begin
							nxt_state <= DISPATCH;
							casex({dispatch1, dispatch2, dispatch3, dispatch4})
								4'b1xxx: begin max_unroll <= LAT[0][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[0][29:14]; end
								4'bx1xx: begin max_unroll <= LAT[1][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[1][29:14]; end
								4'bxx1x: begin max_unroll <= LAT[2][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[2][29:14]; end
								4'bxxx1: begin max_unroll <= LAT[3][6:0]; num_of_inst <= LAT[0][13:7]; fallthrough_addr <= LAT[3][29:14]; end
							endcase
						    casex ({end_lp1, end_lp2, end_lp3, end_lp4})
						    	4'b1xxx: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1000; stll_ftch_cnt <= stll_ftch_cnt + 1; end
						    	4'bx1xx: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1100; stll_ftch_cnt <= stll_ftch_cnt + 2; end
						    	4'bxx1x: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1110; stll_ftch_cnt <= stll_ftch_cnt + 3; end
						    	4'bxxx1: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1111; stll_ftch_cnt <= stll_ftch_cnt + 4; end
						    	4'b0000: begin inst_valid_out <= 4'b1111; stll_ftch_cnt <= stll_ftch_cnt + 4; end
						    endcase
						end
					else
						begin
						    if (num_of_inst == 0)
							    begin
									start_addr <= pc_in[63:48];
							    end
						    casex ({end_lp1, end_lp2, end_lp3, end_lp4})
						    	4'b1xxx: begin num_of_inst <= num_of_inst + 1; nxt_state <= IDLE; LAT_pointer <= LAT_pointer + 1; end
						    	4'bx1xx: begin num_of_inst <= num_of_inst + 2; nxt_state <= IDLE; LAT_pointer <= LAT_pointer + 1; end
						    	4'bxx1x: begin num_of_inst <= num_of_inst + 3; nxt_state <= IDLE; LAT_pointer <= LAT_pointer + 1; end
						    	4'bxxx1: begin num_of_inst <= num_of_inst + 4; nxt_state <= IDLE; LAT_pointer <= LAT_pointer + 1; end
						    	4'b0000: begin num_of_inst <= num_of_inst + 4; nxt_state <= TRAIN; end
						    endcase
						    // generate max unroll
						    casex(num_of_inst)
						    	7'b0000001: begin max_unroll <= 7'd64; end 	// 1
						    	7'b0000010: begin max_unroll <= 7'd32; end 	// 2
						    	7'b0000011: begin max_unroll <= 7'd21; end 	// 3
						    	7'b0000100: begin max_unroll <= 7'd16; end 	// 4
						    	7'b0000101: begin max_unroll <= 7'd12; end 	// 5
						    	7'b0000110: begin max_unroll <= 7'd10; end 	// 6
						    	7'b0000111: begin max_unroll <= 7'd9; end 	// 7
						    	7'b0001000: begin max_unroll <= 7'd8; end 	// 8
						    	7'b0001001: begin max_unroll <= 7'd7; end 	// 9
						    	7'b0001010: begin max_unroll <= 7'd6; end 	// 10
						    	7'b0001011: begin max_unroll <= 7'd5; end 	// 11
						    	7'b0001100: begin max_unroll <= 7'd5; end 	// 12
						    	7'b0001101: begin max_unroll <= 7'd4; end 	// 13
						    	7'b000111x: begin max_unroll <= 7'd4; end 	// 14, 15
						    	7'b0010000: begin max_unroll <= 7'd4; end 	// 16
						    	7'b0010001: begin max_unroll <= 7'd3; end 	// 17
						    	7'b001001x: begin max_unroll <= 7'd3; end 	// 18, 19
						    	7'b001010x: begin max_unroll <= 7'd3; end 	// 20, 21
						    	7'b001011x: begin max_unroll <= 7'd2; end 	// 22, 23
						    	7'b0011xxx: begin max_unroll <= 7'd2; end 	// 24, 25, 26, 27, 28, 29, 30, 31
						    	7'b01xxxxx: begin max_unroll <= 7'd1; end 	// 32 ~ 63
						    	7'b1000000: begin max_unroll <= 7'd1; end   // 64
						    	default: begin max_unroll <= 7'd0; end
						    endcase

							if (max_unroll != 7'd0)
								begin
									train_content <= {1'b1, start_addr, fallthrough_addr, num_of_inst, max_unroll};
									casex(LAT_pointer)
										2'b00: begin LAT[0] <= train_content; end
										2'b01: begin LAT[1] <= train_content; end
										2'b10: begin LAT[2] <= train_content; end
										2'b11: begin LAT[3] <= train_content; end
									endcase
								end		
						end	
			    end // end TRAIN
			if (state == DISPATCH)
				begin
					if (mis_pred_in != 1'b1)
						begin
							nxt_state <= DISPATCH;
						    casex ({end_lp1, end_lp2, end_lp3, end_lp4})
						    	4'b1xxx: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1000; stll_ftch_cnt <= stll_ftch_cnt + 1; end
						    	4'bx1xx: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1100; stll_ftch_cnt <= stll_ftch_cnt + 2; end
						    	4'bxx1x: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1110; stll_ftch_cnt <= stll_ftch_cnt + 3; end
						    	4'bxxx1: begin max_unroll <= max_unroll - 1; inst_valid_out <= 4'b1111; stll_ftch_cnt <= stll_ftch_cnt + 4; end
						    	4'b0000: begin inst_valid_out <= 4'b1111; stll_ftch_cnt <= stll_ftch_cnt + 4; end
						    endcase
						    if (max_unroll == 7'd0)
						    	begin
						    		fnsh_unrll_out <= 1'b1;
						    	end
						    if (stll_ftch_cnt != 7'd64)
						    	begin
						    		stll_ftch_out <= 1'b0;
						    	end
						    else 
						    	begin
						    		stll_ftch_out <= 1'b1;
						    	end
				    	end
				    else 
					    begin
					    	nxt_state <= IDLE;
					    end
				end
    	end 

	assign end_lp1 = (pc_in[63:48] - fallthrough_addr + 1 == 16'b0) ? 1 : 0;
	assign end_lp2 = (pc_in[47:32] - fallthrough_addr + 1 == 16'b0) ? 1 : 0;
	assign end_lp3 = (pc_in[31:16] - fallthrough_addr + 1 == 16'b0) ? 1 : 0;
	assign end_lp4 = (pc_in[15:0] - fallthrough_addr + 1 == 16'b0) ? 1 : 0;

	assign dispatch1 = (pc_in[63:48] == LAT[0][45:30]) ? 1 : 0;
	assign dispatch2 = (pc_in[63:48] == LAT[1][45:30]) ? 1 : 0;
	assign dispatch3 = (pc_in[63:48] == LAT[2][45:30]) ? 1 : 0;
	assign dispatch4 = (pc_in[63:48] == LAT[3][45:30]) ? 1 : 0;
	assign loop_strt_out = dispatch1 || dispatch2 || dispatch3 || dispatch4;
	*/


endmodule
