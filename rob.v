module rob(
    input clk, 
    input rst_n,
    
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

    input loop_strt,
    //input [3:0] no_exec_in, //?
    //input [3:0] jr_in,      //?
    //input [3:0] loop_end,   //?

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
    output [6:0] next_idx,            // to Allocation
	output signed_comp,               // to WB Store Queue
    output mis_pred,                  // to IF, ID, AL
    output flush, 
    output [5:0] mis_pred_brnc_idx,   // to AL-freelist and IS-issue_queue
    output cmt_brnc,                  // to AL-freelist and IS-issue_queue
    output [5:0] cmt_brnc_idx,        // to AL-freelist and IS-issue_queue
	output decr_brnc_num,             // to IF, num of brnc to decrease
    output [15:0] rcvr_PC_out,        // to IF 
    output brnc_pred_log,             // to IF, the brnc was preded as T/N 
    output rob_full_stll,             // to IF, ID, AL
    output rob_empt,				  // to IS for final reg-map outputting
    output cmmt_st,                   // to Store Queue
    output [4:0] mis_pred_ld_ptr_num, // to Load Queue
    output [3:0] mis_pred_st_ptr_num, // to Store Queue
    output [4:0] cmmt_ld_ptr_num,     // to Load Queue
    output [5:0] free_preg_num1,      // to AL-freelist
    output [5:0] free_preg_num2,      // to AL-freelist
    output [5:0] free_preg_num3,      // to AL-freelist
    output [5:0] free_preg_num4,      // to AL-freelist
    output [2:0] free_preg_cnt,        // to AL-freelist: number of freed physical regs
	output [5:0] rob_head_out_for_flsh,   // to IS/RF and RF/EX stage pipeline registers
	output [5:0] rob_tail_out_for_flsh   // to IS/RF and RF/EX stage pipeline registers

);

/*
ROB per entry:
+-----+------+-------------------------------------+-------------------------+----------------------+
| Vld | Done | Brnc | BrncPred | BrncCond | RcvrPC | Store | St_Ptr | Ld_Ptr | RegWrite | FrPRegNum |
+-----+------+-------------------------------------+-------------------------+----------------------+
|   0 |    1 |    2 |        3 |    4 - 5 | 6 - 21 |    22 |  23-26 |  27-31 |       32 |     33-38 |
+-----+------+-------------------------------------+-------------------------+----------------------+
*/ 
	// rob Body
    reg [63:0] rob_vld;
    reg [63:0] rob_done;
    reg [63:0] rob_brnc;
    reg [63:0] rob_brnc_pred;
    reg [63:0] rob_signed_comp;
    reg [1:0]  rob_brnc_cond [63:0];
    reg [15:0] rob_rcvr_PC   [63:0];
    reg [63:0] rob_st;
    reg [3:0]  rob_st_ptr    [63:0];
    reg [4:0]  rob_ld_ptr    [63:0];
    reg [63:0] rob_reg_wrt;
    reg [5:0]  rob_free_preg_num [63:0];
	
	// other counters
    reg [6:0] rob_head; // one extra big ahead to enable overflow comparison
    wire [2:0] rob_head_cmmt_num; //
    wire [2:0] rob_head_cmmt_num_st;
    wire [2:0] rob_head_cmmt_num_free_preg;
    wire [2:0] rob_head_cmmt_num_brnc;
    wire [2:0] rob_head_cmmt_num_vld;
    wire [2:0] rob_head_cmmt_num_pair1;
    wire [2:0] rob_head_cmmt_num_pair2;
    reg [6:0] rob_tail; // one extra big ahead to enable overflow comparison
	//wire [5:0] rob_head_out_for_flsh;
	//wire [5:0] rob_tail_out_for_flsh;

    reg [3:0] rob_st_cntr;
    reg [4:0] rob_ld_cntr;

    wire [5:0] rob_tail_when_mis_pred;

    reg  inverting_bit;
	wire [4:0] rob_ld_cntr_add1;
	wire [4:0] rob_ld_cntr_add2;
	wire [4:0] rob_ld_cntr_add3;
	wire [4:0] rob_ld_cntr_add4;

    /********************************************/
    /*********** Combinational Blocks ***********/
    /********************************************/

	// head and tail out to flush IS/RF and RF/EX pipeline regs
	assign rob_head_out_for_flsh = rob_head[5:0];
	assign rob_tail_out_for_flsh = rob_tail[5:0];

	// signed_comp to WB store queue
	assign signed_comp = rob_signed_comp[rob_head[5:0]];

    // next_idx to Allocation stage is tail
    assign next_idx = { inverting_bit, {(mis_pred) ? rob_tail_when_mis_pred : rob_tail[5:0]}};

    // when tail catch up with head, and that one's vld is 1, that means ROB is full
    assign rob_full_stll = ((rob_tail[5:0] < rob_head[5:0]) && ((rob_tail[5:0] + 6'd4) >= rob_head[5:0])) ? 1
                         : ((rob_tail[5:0] > rob_head[5:0]) && (rob_tail[5:0] > 59) && (rob_tail[5:0] - 6'd60 >= rob_head[5:0])) ? 1 
                         : 0;

    // when head catch up with tail, and that one's vld is 0, that means ROB is empty 
    assign rob_empt = ((rob_head[5:0] == rob_tail[5:0]) && (rob_vld[rob_head[5:0]] == 0)) ? 1:0;

    // misprediction
    assign mis_pred = ((brnc_cmp_rslt != 0) && rob_brnc[brnc_idx] && 
                      // here comes a branch result read from RegFile and this rob entry is branch
                      (rob_brnc_pred[brnc_idx] != (rob_brnc_cond[brnc_idx] == brnc_cmp_rslt)));
                      // and the predicted behavior is incorrect
    assign flush = mis_pred;
    assign mis_pred_brnc_idx = brnc_idx;
    assign rcvr_PC_out = rob_rcvr_PC[brnc_idx];

	assign rob_tail_when_mis_pred = (|mis_pred_brnc_idx[1:0]) ? {{mis_pred_brnc_idx[5:2]+1},2'b00} : {mis_pred_brnc_idx[5:2],2'b00};
    
    // commit a correct prediction
    assign cmt_brnc = ((brnc_cmp_rslt != 0) && rob_brnc[brnc_idx] && 
                      // here comes a branch result read from RegFile and this rob entry is branch
                      (rob_brnc_pred[brnc_idx] == (rob_brnc_cond[brnc_idx] == brnc_cmp_rslt)));
                      // and the predicted behavior is incorrect
    assign cmt_brnc_idx = brnc_idx;

    // brnc pred for IF
    assign brnc_pred_log = (mis_pred) ? rob_brnc_pred[mis_pred_brnc_idx] 
                         : (cmt_brnc) ? rob_brnc_pred[cmt_brnc_idx]
                         : 1'b0;
    
    // head is pointing to a store instruction
    assign cmmt_st = (rob_st[rob_head[5:0]]) ? 1:0;

    // for load and store head and tail updation
    assign mis_pred_ld_ptr_num = (mis_pred) ? rob_ld_ptr[mis_pred_brnc_idx] : 5'd0;
    assign mis_pred_st_ptr_num = (mis_pred) ? rob_st_ptr[mis_pred_brnc_idx] : 5'd0;

    assign cmmt_ld_ptr_num = (rob_done[rob_head[5:0]]) ? rob_ld_ptr[rob_head[5:0]] : ((rob_head[5:0]!=0) ? rob_ld_ptr[rob_head[5:0]-5'd1] : rob_ld_ptr[63]);

    // rob_head_cmmt_number
    wire [5:0] rob_head_1, rob_head_2, rob_head_3, rob_head_4, rob_head_5, rob_head_6, rob_head_7;
    assign rob_head_1 = rob_head[5:0] + 5'd1;
    assign rob_head_2 = rob_head[5:0] + 5'd2;
    assign rob_head_3 = rob_head[5:0] + 5'd3;
    assign rob_head_4 = rob_head[5:0] + 5'd4;
    assign rob_head_5 = rob_head[5:0] + 5'd5;
    assign rob_head_6 = rob_head[5:0] + 5'd6;
    assign rob_head_7 = rob_head[5:0] + 5'd7;

    assign rob_head_cmmt_num_st = (rob_st[rob_head[5:0]] && (!st_iss)) ? 3'd0 
                                : (rob_st[rob_head_1]) ? 3'd1
                                : (rob_st[rob_head_2]) ? 3'd2
                                : (rob_st[rob_head_3]) ? 3'd3
                                : (rob_st[rob_head_4]) ? 3'd4
                                : (rob_st[rob_head_5]) ? 3'd5
                                : (rob_st[rob_head_6]) ? 3'd6
                                : (rob_st[rob_head_7]) ? 3'd7
                                : 3'd7;
    
    assign rob_head_cmmt_num_brnc = (rob_brnc[rob_head[5:0]]   && (!rob_done[rob_head[5:0]]))   ? 3'd0 
                                  : (rob_brnc[rob_head_1] && (!rob_done[rob_head_1])) ? 3'd1
                                  : (rob_brnc[rob_head_2] && (!rob_done[rob_head_2])) ? 3'd2
                                  : (rob_brnc[rob_head_3] && (!rob_done[rob_head_3])) ? 3'd3
                                  : (rob_brnc[rob_head_4] && (!rob_done[rob_head_4])) ? 3'd4
                                  : (rob_brnc[rob_head_5] && (!rob_done[rob_head_5])) ? 3'd5
                                  : (rob_brnc[rob_head_6] && (!rob_done[rob_head_6])) ? 3'd6
                                  : (rob_brnc[rob_head_7] && (!rob_done[rob_head_7])) ? 3'd7
                                  : 3'd7;

    wire [3:0] sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7, sum_8;
    assign sum_1 = rob_reg_wrt[rob_head[5:0]];
    assign sum_2 = rob_reg_wrt[rob_head[5:0]]
                 + rob_reg_wrt[rob_head_1];
    assign sum_3 = rob_reg_wrt[rob_head[5:0]]
                 + rob_reg_wrt[rob_head_1]
                 + rob_reg_wrt[rob_head_2];
    assign sum_4 = rob_reg_wrt[rob_head[5:0]]
                 + rob_reg_wrt[rob_head_1]
                 + rob_reg_wrt[rob_head_2]
                 + rob_reg_wrt[rob_head_3];
    assign sum_5 = sum_4 + rob_reg_wrt[rob_head_4];
    assign sum_6 = sum_5 + rob_reg_wrt[rob_head_5];
    assign sum_7 = sum_6 + rob_reg_wrt[rob_head_6];
    assign sum_8 = sum_7 + rob_reg_wrt[rob_head_7];

    assign rob_head_cmmt_num_free_preg = (sum_5 == 5) ? 3'd4
                                       : (sum_6 == 5) ? 3'd5
                                       : (sum_7 == 5) ? 3'd6
                                       : (sum_8 == 5) ? 3'd7
                                       : 3'd7;
    
    assign rob_head_cmmt_num_vld = ((rob_reg_wrt[rob_head[5:0]]   || rob_brnc[rob_head[5:0]])   && (!rob_done[rob_head[5:0]])   || (!rob_vld[rob_head[5:0]]))   ? 3'd0
                                 : ((rob_reg_wrt[rob_head_1] || rob_brnc[rob_head_1]) && (!rob_done[rob_head_1]) || (!rob_vld[rob_head_1])) ? 3'd1
                                 : ((rob_reg_wrt[rob_head_2] || rob_brnc[rob_head_2]) && (!rob_done[rob_head_2]) || (!rob_vld[rob_head_2])) ? 3'd2
                                 : ((rob_reg_wrt[rob_head_3] || rob_brnc[rob_head_3]) && (!rob_done[rob_head_3]) || (!rob_vld[rob_head_3])) ? 3'd3
                                 : ((rob_reg_wrt[rob_head_4] || rob_brnc[rob_head_4]) && (!rob_done[rob_head_4]) || (!rob_vld[rob_head_4])) ? 3'd4
                                 : ((rob_reg_wrt[rob_head_5] || rob_brnc[rob_head_5]) && (!rob_done[rob_head_5]) || (!rob_vld[rob_head_5])) ? 3'd5
                                 : ((rob_reg_wrt[rob_head_6] || rob_brnc[rob_head_6]) && (!rob_done[rob_head_6]) || (!rob_vld[rob_head_6])) ? 3'd6
                                 : ((rob_reg_wrt[rob_head_7] || rob_brnc[rob_head_7]) && (!rob_done[rob_head_7]) || (!rob_vld[rob_head_7])) ? 3'd7
                                 : 3'd7;
    assign rob_head_cmmt_num_pair1 = (rob_head_cmmt_num_st <= rob_head_cmmt_num_brnc) ? 
                                      rob_head_cmmt_num_st :  rob_head_cmmt_num_brnc;
    assign rob_head_cmmt_num_pair2 = (rob_head_cmmt_num_free_preg <= rob_head_cmmt_num_vld) ? 
                                      rob_head_cmmt_num_free_preg :  rob_head_cmmt_num_vld;
    assign rob_head_cmmt_num = (rob_head_cmmt_num_pair1 <= rob_head_cmmt_num_pair2) ? 
                                rob_head_cmmt_num_pair1 :  rob_head_cmmt_num_pair2;
    
    assign free_preg_cnt = (rob_head_cmmt_num == 0) ? 3'd0
                         : (rob_head_cmmt_num == 1) ? sum_1
                         : (rob_head_cmmt_num == 2) ? sum_2
                         : (rob_head_cmmt_num == 3) ? sum_3
                         : (rob_head_cmmt_num == 4) ? sum_4
                         : (rob_head_cmmt_num == 5) ? sum_5
                         : (rob_head_cmmt_num == 6) ? sum_6
                         : (rob_head_cmmt_num == 7) ? sum_7
                         : 3'd0;

    assign free_preg_num1 = (sum_8 == 0) ? 6'd0
                          : (sum_7 == 0) ? rob_free_preg_num[rob_head_7]
                          : (sum_6 == 0) ? rob_free_preg_num[rob_head_6]
                          : (sum_5 == 0) ? rob_free_preg_num[rob_head_5]
                          : (sum_4 == 0) ? rob_free_preg_num[rob_head_4]
                          : (sum_3 == 0) ? rob_free_preg_num[rob_head_3]
                          : (sum_2 == 0) ? rob_free_preg_num[rob_head_2]
                          : (sum_1 == 0) ? rob_free_preg_num[rob_head_1]
                          : rob_free_preg_num[rob_head[5:0]];

    assign free_preg_num2 = (sum_8 == 1) ? 6'd0
                          : (sum_7 == 1) ? rob_free_preg_num[rob_head_7]
                          : (sum_6 == 1) ? rob_free_preg_num[rob_head_6]
                          : (sum_5 == 1) ? rob_free_preg_num[rob_head_5]
                          : (sum_4 == 1) ? rob_free_preg_num[rob_head_4]
                          : (sum_3 == 1) ? rob_free_preg_num[rob_head_3]
                          : (sum_2 == 1) ? rob_free_preg_num[rob_head_2]
                          : (sum_1 == 1) ? rob_free_preg_num[rob_head_1]
                          : 6'd0;

    assign free_preg_num3 = (sum_8 == 2) ? 6'd0
                          : (sum_7 == 2) ? rob_free_preg_num[rob_head_7]
                          : (sum_6 == 2) ? rob_free_preg_num[rob_head_6]
                          : (sum_5 == 2) ? rob_free_preg_num[rob_head_5]
                          : (sum_4 == 2) ? rob_free_preg_num[rob_head_4]
                          : (sum_3 == 2) ? rob_free_preg_num[rob_head_3]
                          : (sum_2 == 2) ? rob_free_preg_num[rob_head_2]
                          : 6'd0;

    assign free_preg_num4 = (sum_8 == 3) ? 6'd0
                          : (sum_7 == 3) ? rob_free_preg_num[rob_head_7]
                          : (sum_6 == 3) ? rob_free_preg_num[rob_head_6]
                          : (sum_5 == 3) ? rob_free_preg_num[rob_head_5]
                          : (sum_4 == 3) ? rob_free_preg_num[rob_head_4]
                          : (sum_3 == 3) ? rob_free_preg_num[rob_head_3]
                          : 6'd0;

	assign rob_ld_cntr_add1 = (rob_ld_cntr == 23) ? rob_ld_cntr - 5'd23 : rob_ld_cntr + 5'd1;
	assign rob_ld_cntr_add2 = (rob_ld_cntr >= 22) ? rob_ld_cntr - 5'd22 : rob_ld_cntr + 5'd2;
	assign rob_ld_cntr_add3 = (rob_ld_cntr >= 21) ? rob_ld_cntr - 5'd21 : rob_ld_cntr + 5'd3;
	assign rob_ld_cntr_add4 = (rob_ld_cntr >= 20) ? rob_ld_cntr - 5'd20 : rob_ld_cntr + 5'd4;

    /********************************************/
    /************ Sequential Blocks *************/
    /********************************************/

    /*
    * head movement
    */
    always@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            rob_head <= 7'd0;
        else if ((rob_head + rob_head_cmmt_num) <= 63)
            rob_head <= rob_head + rob_head_cmmt_num;
        else if ((rob_head + rob_head_cmmt_num) > 63)
            rob_head <= rob_head + rob_head_cmmt_num - 7'd64;
        else
            rob_head <= rob_head;
    end
    
    /*
    * tail movement
    */
    always@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            rob_tail <= 7'd0;
		else if(mis_pred)begin
			if (rob_tail < rob_tail_when_mis_pred)
				rob_tail <= {~inverting_bit,rob_tail_when_mis_pred};
			else
				rob_tail <= {inverting_bit,rob_tail_when_mis_pred};
		end
        else if(!all_nop)
            rob_tail <= (rob_tail[5:0] < 60) ? rob_tail+7'd4
                      : rob_tail - 7'd60;
        else
            rob_tail <= rob_tail;
    end

	/*
	* inverting_bit
	*/
    always@(posedge clk, negedge rst_n)begin
		if(!rst_n)
			inverting_bit <= 1'b0;
		else if (mis_pred)begin
			if (rob_tail[5:0] < rob_tail_when_mis_pred)
				inverting_bit <= ~inverting_bit;
			else
				inverting_bit <= inverting_bit;
		end
		else if ((!all_nop) && (rob_tail[5:0] == 60))
			inverting_bit <= ~inverting_bit;
		else
			inverting_bit <= inverting_bit;
	end	

    /*
    * store counter updation
    */
    always@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            rob_st_cntr <= 4'd0;
		else if(mis_pred)begin
			rob_st_cntr <= rob_st_ptr[mis_pred_brnc_idx];
		end
        else if((!all_nop) && (st_in == 0))begin
            rob_st_cntr <= rob_st_cntr;
        end
        else if((!all_nop) && (
				(st_in == 4'd1 ) || 
                (st_in == 4'd2 ) ||
                (st_in == 4'd4 ) ||
                (st_in == 4'd8 )))begin
            rob_st_cntr <= rob_st_cntr + 4'd1;
        end
        else if((!all_nop) && (
				(st_in == 4'd3 ) || 
                (st_in == 4'd5 ) ||
                (st_in == 4'd9 ) ||
                (st_in == 4'd6 ) ||
                (st_in == 4'd10) ||
                (st_in == 4'd12)))begin
            rob_st_cntr <= rob_st_cntr + 4'd2;
        end
        else if((!all_nop) && (
				(st_in == 4'd7 ) || 
                (st_in == 4'd11) ||
                (st_in == 4'd13) ||
                (st_in == 4'd14)))begin
            rob_st_cntr <= rob_st_cntr + 4'd3;
        end
        else if((!all_nop) && (
				st_in == 4'd15))begin
            rob_st_cntr <= rob_st_cntr + 4'd4;
        end
        else begin
            rob_st_cntr <= rob_st_cntr;
        end
    end

    /*
    * load counter updation
    */
    always@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            rob_ld_cntr <= 5'd0;
		else if(mis_pred)begin
			rob_ld_cntr <= rob_ld_ptr[mis_pred_brnc_idx];
		end
        else if((!all_nop) && (
				ld_in == 0))begin
            rob_ld_cntr <= rob_ld_cntr;
        end
        else if((!all_nop) && (
				(ld_in == 4'd1 ) || 
                (ld_in == 4'd2 ) ||
                (ld_in == 4'd4 ) ||
                (ld_in == 4'd8 )))begin
            rob_ld_cntr <= rob_ld_cntr_add1;
        end
        else if((!all_nop) && (
				(ld_in == 4'd3 ) || 
                (ld_in == 4'd5 ) ||
                (ld_in == 4'd9 ) ||
                (ld_in == 4'd6 ) ||
                (ld_in == 4'd10) ||
                (ld_in == 4'd12)))begin
            rob_ld_cntr <= rob_ld_cntr_add2;
        end
        else if((!all_nop) && (
				(ld_in == 4'd7 ) || 
                (ld_in == 4'd11) ||
                (ld_in == 4'd13) ||
                (ld_in == 4'd14)))begin
            rob_ld_cntr <= rob_ld_cntr_add3;
        end
        else if((!all_nop) && (
				ld_in == 4'd15))begin
            rob_ld_cntr <= rob_ld_cntr_add4;
        end
        else begin
            rob_ld_cntr <= rob_ld_cntr;
        end
    end

    /*
    * Each entry updation : valid
    */
    // write section
    generate
    genvar rob_vld_idx;
    for(rob_vld_idx = 0; rob_vld_idx < 64; rob_vld_idx = rob_vld_idx + 1)
    begin : rob_vld_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n)
                rob_vld[rob_vld_idx] <= 0;
            // adding into ROB
            else if ((!all_nop) && (rob_vld_idx >= rob_tail[5:0] && rob_vld_idx <= (rob_tail[5:0]+3))) 
                rob_vld[rob_vld_idx] <= 1;
            else if ((!all_nop) && (rob_tail[5:0] == 63 && (rob_vld_idx == 0||rob_vld_idx == 1||rob_vld_idx == 2)))
                rob_vld[rob_vld_idx] <= 1;
            else if ((!all_nop) && (rob_tail[5:0] == 62 && (rob_vld_idx == 0||rob_vld_idx == 1)))
                rob_vld[rob_vld_idx] <= 1;
            else if ((!all_nop) && (rob_tail[5:0] == 61 && (rob_vld_idx == 0)))
                rob_vld[rob_vld_idx] <= 1;
            // commiting out ROB
            else if ((rob_vld_idx >= rob_head[5:0]) && (rob_vld_idx < (rob_head[5:0] + rob_head_cmmt_num))) 
                rob_vld[rob_vld_idx] <= 0;
            else if (((rob_head + rob_head_cmmt_num) >= 64) && 
                    (rob_vld_idx < (rob_head + rob_head_cmmt_num - 64)))
                rob_vld[rob_vld_idx] <= 0;
            // misprediction
            else if (mis_pred && (rob_tail_when_mis_pred < rob_tail[5:0]) && 
                    (rob_vld_idx >= rob_tail_when_mis_pred) && (rob_vld_idx < rob_tail[5:0]))
                rob_vld[rob_vld_idx] <= 0;
            else if (mis_pred && (rob_tail_when_mis_pred > rob_tail[5:0]) && 
                    ((rob_vld_idx >= rob_tail_when_mis_pred) || (rob_vld_idx < rob_tail[5:0])))
                rob_vld[rob_vld_idx] <= 0;
            // default
            else begin
                rob_vld[rob_vld_idx] <= rob_vld[rob_vld_idx];
            end
        end
    end
    endgenerate

    /*
    * Each entry updation : done
    */
    // write section
    generate
    genvar rob_done_idx;
    for(rob_done_idx = 0; rob_done_idx < 64; rob_done_idx = rob_done_idx + 1)
    begin : rob_done_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n)
                rob_done[rob_done_idx] <= 0;
            // set the done bit by all valid FU finish, and branch result
            // misprediction
            else if (mis_pred && (rob_tail_when_mis_pred < rob_tail[5:0]) && 
                    (rob_done_idx >= rob_tail_when_mis_pred) && (rob_done_idx < rob_tail[5:0]))
                rob_done[rob_done_idx] <= 0;
            else if (mis_pred && (rob_tail_when_mis_pred > rob_tail[5:0]) && 
                    ((rob_done_idx >= rob_tail_when_mis_pred) || (rob_done_idx < rob_tail[5:0])))
                rob_done[rob_done_idx] <= 0;
            else if((mult_done_vld && (rob_done_idx == mult_done_idx)) || 
                    (alu1_done_vld && (rob_done_idx == alu1_done_idx)) || 
                    (alu2_done_vld && (rob_done_idx == alu2_done_idx)) || 
                    (  ld_done_vld && (rob_done_idx ==   ld_done_idx))) 
                rob_done[rob_done_idx] <= 1;
            else if((brnc_cmp_rslt != 0) && // here comes a branch result read from RegFile
                    rob_brnc[rob_done_idx] && (rob_done_idx == brnc_idx) && // and this rob entry is that branch
                    (rob_brnc_pred[rob_done_idx] == ((rob_brnc_cond[rob_done_idx] ^ brnc_cmp_rslt) == 0)))
                    // and the predicted behavior is correct
                rob_done[rob_done_idx] <= 1;
            // clear the done bit by the head
            else if (rob_head_cmmt_num) begin
                if(rob_done_idx >= rob_head && rob_done_idx < (rob_head + rob_head_cmmt_num)) 
                    rob_done[rob_done_idx] <= 0;
                else if((rob_head + rob_head_cmmt_num) >= 64 && 
                        rob_done_idx < (rob_head + rob_head_cmmt_num - 64))
                    rob_done[rob_done_idx] <= 0;
                else begin
                    rob_done[rob_done_idx] <= rob_done[rob_done_idx];
                end
            end
            else begin
                rob_done[rob_done_idx] <= rob_done[rob_done_idx];
            end
        end
    end
    endgenerate

    /*
    * Each entry updation : rob_brnc, rob_brnc_cond, rob_brnc_pred, rob_rcvr_PC
    */
    // write section
    generate
    genvar rob_brnc_idx;
    for(rob_brnc_idx = 0; rob_brnc_idx < 64; rob_brnc_idx = rob_brnc_idx + 1)
    begin : rob_brnc_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n) begin
                rob_brnc     [rob_brnc_idx] <= 0;
                rob_brnc_pred[rob_brnc_idx] <= 0;
                rob_brnc_cond[rob_brnc_idx] <= 0;
                rob_rcvr_PC  [rob_brnc_idx] <= 0;
            end
            // misprediction
            else if (mis_pred && (mis_pred_brnc_idx <= rob_tail_when_mis_pred) && 
					(rob_brnc_idx >= mis_pred_brnc_idx) && (rob_brnc_idx < rob_tail_when_mis_pred))begin
                rob_brnc[rob_brnc_idx] <= 0;
                rob_brnc_pred[rob_brnc_idx] <= 0;
                rob_brnc_cond[rob_brnc_idx] <= 0;
                rob_rcvr_PC  [rob_brnc_idx] <= 0;
			end
            else if (mis_pred && (mis_pred_brnc_idx > rob_tail_when_mis_pred) && 
					((rob_brnc_idx >= mis_pred_brnc_idx)))begin
                rob_brnc[rob_brnc_idx] <= 0;
                rob_brnc_pred[rob_brnc_idx] <= 0;
                rob_brnc_cond[rob_brnc_idx] <= 0;
                rob_rcvr_PC  [rob_brnc_idx] <= 0;
			end
            // adding into ROB
            else if ((!all_nop) && (rob_brnc_idx == rob_tail[5:0])) begin 
                if(brnc_in[0])begin
                    rob_brnc     [rob_brnc_idx] <= 1;
                    rob_brnc_pred[rob_brnc_idx] <= brnc_pred[0];
                    rob_brnc_cond[rob_brnc_idx] <= brnc_cond[1:0];
                    rob_rcvr_PC  [rob_brnc_idx] <= rcvr_PC[15:0];
                end
                else begin
                    rob_brnc     [rob_brnc_idx] <= 0;
					rob_brnc_pred[rob_brnc_idx] <= 0;
					rob_brnc_cond[rob_brnc_idx] <= 0;
					rob_rcvr_PC  [rob_brnc_idx] <= 0;
                end
            end
            else if ((!all_nop) && 
                    ((rob_brnc_idx == rob_tail[5:0] + 1) || ((rob_tail[5:0]>=63) && (rob_brnc_idx == (rob_tail[5:0]-63))))) begin
                if(brnc_in[1])begin
                    rob_brnc     [rob_brnc_idx] <= 1;
                    rob_brnc_pred[rob_brnc_idx] <= brnc_pred[1];
                    rob_brnc_cond[rob_brnc_idx] <= brnc_cond[3:2];
                    rob_rcvr_PC  [rob_brnc_idx] <= rcvr_PC[31:16];
                end
                else begin
                    rob_brnc     [rob_brnc_idx] <= 0;
					rob_brnc_pred[rob_brnc_idx] <= 0;
					rob_brnc_cond[rob_brnc_idx] <= 0;
					rob_rcvr_PC  [rob_brnc_idx] <= 0;
                end
            end
            else if ((!all_nop) && 
                    ((rob_brnc_idx == rob_tail[5:0] + 2) || ((rob_tail[5:0]>=62) && (rob_brnc_idx == (rob_tail[5:0]-62))))) begin
                if(brnc_in[2])begin
                    rob_brnc     [rob_brnc_idx] <= 1;
                    rob_brnc_pred[rob_brnc_idx] <= brnc_pred[2];
                    rob_brnc_cond[rob_brnc_idx] <= brnc_cond[5:4];
                    rob_rcvr_PC  [rob_brnc_idx] <= rcvr_PC[47:32];
                end
                else begin
                    rob_brnc     [rob_brnc_idx] <= 0;
					rob_brnc_pred[rob_brnc_idx] <= 0;
					rob_brnc_cond[rob_brnc_idx] <= 0;
					rob_rcvr_PC  [rob_brnc_idx] <= 0;
                end
            end
            else if ((!all_nop) && 
                    ((rob_brnc_idx == rob_tail[5:0] + 3) || ((rob_tail[5:0]>=61) && (rob_brnc_idx == (rob_tail[5:0]-61))))) begin
                if(brnc_in[3])begin
                    rob_brnc     [rob_brnc_idx] <= 1;
                    rob_brnc_pred[rob_brnc_idx] <= brnc_pred[3];
                    rob_brnc_cond[rob_brnc_idx] <= brnc_cond[7:6];
                    rob_rcvr_PC  [rob_brnc_idx] <= rcvr_PC[63:48];
                end
                else begin
                    rob_brnc     [rob_brnc_idx] <= 0;
					rob_brnc_pred[rob_brnc_idx] <= 0;
					rob_brnc_cond[rob_brnc_idx] <= 0;
					rob_rcvr_PC  [rob_brnc_idx] <= 0;
                end
            end
            else begin
                rob_brnc     [rob_brnc_idx] <= rob_brnc     [rob_brnc_idx];
                rob_brnc_pred[rob_brnc_idx] <= rob_brnc_pred[rob_brnc_idx];
                rob_brnc_cond[rob_brnc_idx] <= rob_brnc_cond[rob_brnc_idx];
                rob_rcvr_PC  [rob_brnc_idx] <= rob_rcvr_PC  [rob_brnc_idx];
            end
        end
    end
    endgenerate

    /*
    * Each entry updation : rob_reg_wrt 
    */
    // write section
    generate
    genvar rob_reg_wrt_idx;
    for(rob_reg_wrt_idx = 0; rob_reg_wrt_idx < 64; rob_reg_wrt_idx = rob_reg_wrt_idx + 1)
    begin : rob_reg_wrt_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n) begin
                rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            end
            // misprediction
            else if (mis_pred && (mis_pred_brnc_idx <= rob_tail_when_mis_pred) && 
                    (rob_reg_wrt_idx >= mis_pred_brnc_idx) && (rob_reg_wrt_idx < rob_tail_when_mis_pred))
                rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            else if (mis_pred && (mis_pred_brnc_idx > rob_tail_when_mis_pred) && 
                    ((rob_reg_wrt_idx >= mis_pred_brnc_idx)))
                rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            // adding into ROB
            else if ((!all_nop) && (rob_reg_wrt_idx == rob_tail[5:0])) begin 
				if(reg_wrt_in[0])
					rob_reg_wrt[rob_reg_wrt_idx] <= 1;
				else
					rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            end
            else if ((!all_nop) && 
                    ((rob_reg_wrt_idx == rob_tail[5:0] + 1) || ((rob_tail[5:0]>=63) && (rob_reg_wrt_idx == (rob_tail[5:0]-63))))) begin
				if(reg_wrt_in[1])
					rob_reg_wrt[rob_reg_wrt_idx] <= 1;
				else
					rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            end
            else if ((!all_nop) && 
                    ((rob_reg_wrt_idx == rob_tail[5:0] + 2) || ((rob_tail[5:0]>=62) && (rob_reg_wrt_idx == (rob_tail[5:0]-62))))) begin
				if(reg_wrt_in[2])
					rob_reg_wrt[rob_reg_wrt_idx] <= 1;
				else
					rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            end
            else if ((!all_nop) && 
                    ((rob_reg_wrt_idx == rob_tail[5:0] + 3) || ((rob_tail[5:0]>=61) && (rob_reg_wrt_idx == (rob_tail[5:0]-61))))) begin
				if(reg_wrt_in[3])
					rob_reg_wrt[rob_reg_wrt_idx] <= 1;
				else
					rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            end
            // commiting out ROB
            else if ((rob_reg_wrt_idx >= rob_head) && (rob_reg_wrt_idx < (rob_head + rob_head_cmmt_num))) 
                rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            else if (((rob_head + rob_head_cmmt_num) >= 64) && 
                    (rob_reg_wrt_idx < (rob_head + rob_head_cmmt_num - 64)))
                rob_reg_wrt[rob_reg_wrt_idx] <= 0;
            else begin
                rob_reg_wrt[rob_reg_wrt_idx] <= rob_reg_wrt[rob_reg_wrt_idx];
            end
        end
    end
    endgenerate

    /*
    * Each entry updation : rob_free_preg_num
    */
    // write section
    generate
    genvar rob_free_preg_idx;
    for(rob_free_preg_idx = 0; rob_free_preg_idx < 64; rob_free_preg_idx = rob_free_preg_idx + 1)
    begin : rob_free_preg_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n) begin
                rob_free_preg_num[rob_free_preg_idx] <= 6'd0;
            end
            // adding into ROB
            else if (mult_inst_vld && mult_reg_wrt && (rob_free_preg_idx == mult_idx)) begin 
                rob_free_preg_num[rob_free_preg_idx] <= mult_free_preg_num;
            end
            else if (alu1_inst_vld && alu1_reg_wrt && (rob_free_preg_idx == alu1_idx)) begin 
                rob_free_preg_num[rob_free_preg_idx] <= alu1_free_preg_num;
            end
            else if (alu2_inst_vld && alu2_reg_wrt && (rob_free_preg_idx == alu2_idx)) begin 
                rob_free_preg_num[rob_free_preg_idx] <= alu2_free_preg_num;
            end
            else if (addr_inst_vld && addr_reg_wrt && (rob_free_preg_idx == addr_idx)) begin 
                rob_free_preg_num[rob_free_preg_idx] <= addr_free_preg_num;
            end
            else begin
                rob_free_preg_num[rob_free_preg_idx] <= rob_free_preg_num[rob_free_preg_idx];
            end
        end
    end
    endgenerate

    /*
    * Each entry updation : rob_st, rob_st_ptr
    */
    // write section
    generate
    genvar rob_st_idx;
    for(rob_st_idx = 0; rob_st_idx < 64; rob_st_idx = rob_st_idx + 1)
    begin : rob_st_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n) begin
                rob_st    [rob_st_idx] <= 0;
                rob_st_ptr[rob_st_idx] <= 5'd0;
            end
            // misprediction
            else if (mis_pred && (mis_pred_brnc_idx <= rob_tail_when_mis_pred) && 
				    (rob_st_idx >= mis_pred_brnc_idx) && (rob_st_idx < rob_tail_when_mis_pred)) begin
				rob_st[rob_st_idx] <= 0;
                rob_st_ptr[rob_st_idx] <= rob_st_ptr[mis_pred_brnc_idx];
			end
            else if (mis_pred && (mis_pred_brnc_idx > rob_tail_when_mis_pred) && 
				    ((rob_st_idx >= mis_pred_brnc_idx))) begin
                rob_st[rob_st_idx] <= 0;
                rob_st_ptr[rob_st_idx] <= rob_st_ptr[mis_pred_brnc_idx];
			end
            // adding into ROB
            else if ((!all_nop) && (rob_st_idx == rob_tail[5:0])) begin 
                rob_st    [rob_st_idx] <= (st_in[0]) ? 1:0;
                rob_st_ptr[rob_st_idx] <= (st_in[0]) ? rob_st_cntr + 5'd1
                                        : rob_st_cntr;
            end
            else if ((!all_nop) && 
                    ((rob_st_idx == rob_tail[5:0] + 1) || ((rob_tail[5:0]>=63) && (rob_st_idx == (rob_tail[5:0]-63))))) begin
                rob_st    [rob_st_idx] <= (st_in[1]) ? 1:0;
                rob_st_ptr[rob_st_idx] <= (st_in[1:0] == 2'b11) ? rob_st_cntr + 5'd2
                                        : (st_in[1:0] == 2'b01) ? rob_st_cntr + 5'd1
                                        : (st_in[1:0] == 2'b10) ? rob_st_cntr + 5'd1
                                        : rob_st_cntr;
            end
            else if ((!all_nop) && 
                    ((rob_st_idx == rob_tail[5:0] + 2) || ((rob_tail[5:0]>=62) && (rob_st_idx == (rob_tail[5:0]-62))))) begin
                rob_st    [rob_st_idx] <= (st_in[2]) ? 1:0;
                rob_st_ptr[rob_st_idx] <= (st_in[2:0] == 3'b111) ? rob_st_cntr + 5'd3
                                        : (st_in[2:0] == 3'b011) ? rob_st_cntr + 5'd2
                                        : (st_in[2:0] == 3'b110) ? rob_st_cntr + 5'd2
                                        : (st_in[2:0] == 3'b101) ? rob_st_cntr + 5'd2
                                        : (st_in[2:0] == 3'b001) ? rob_st_cntr + 5'd1
                                        : (st_in[2:0] == 3'b010) ? rob_st_cntr + 5'd1
                                        : (st_in[2:0] == 3'b100) ? rob_st_cntr + 5'd1
                                        : rob_st_cntr;
            end
            else if ((!all_nop) && 
                    ((rob_st_idx == rob_tail[5:0] + 3) || ((rob_tail[5:0]>=61) && (rob_st_idx == (rob_tail[5:0]-61))))) begin
                rob_st    [rob_st_idx] <= (st_in[3]) ? 1:0;
                if (st_in[3]) begin
                    rob_st_ptr[rob_st_idx] <= (st_in[2:0] == 3'b111) ? rob_st_cntr + 5'd4
                                            : (st_in[2:0] == 3'b011) ? rob_st_cntr + 5'd3
                                            : (st_in[2:0] == 3'b110) ? rob_st_cntr + 5'd3
                                            : (st_in[2:0] == 3'b101) ? rob_st_cntr + 5'd3
                                            : (st_in[2:0] == 3'b001) ? rob_st_cntr + 5'd2
                                            : (st_in[2:0] == 3'b010) ? rob_st_cntr + 5'd2
                                            : (st_in[2:0] == 3'b100) ? rob_st_cntr + 5'd2
                                            : rob_st_cntr + 5'd1;
                end
                else begin
                    rob_st_ptr[rob_st_idx] <= (st_in[2:0] == 3'b111) ? rob_st_cntr + 5'd3
                                            : (st_in[2:0] == 3'b011) ? rob_st_cntr + 5'd2
                                            : (st_in[2:0] == 3'b110) ? rob_st_cntr + 5'd2
                                            : (st_in[2:0] == 3'b101) ? rob_st_cntr + 5'd2
                                            : (st_in[2:0] == 3'b001) ? rob_st_cntr + 5'd1
                                            : (st_in[2:0] == 3'b010) ? rob_st_cntr + 5'd1
                                            : (st_in[2:0] == 3'b100) ? rob_st_cntr + 5'd1
                                            : rob_st_cntr;
                end
            end
            // commiting out ROB
			else if ((rob_st_idx >= rob_head) && (rob_st_idx < (rob_head + rob_head_cmmt_num)))begin 
                rob_st[rob_st_idx] <= 0;
                rob_st_ptr[rob_st_idx] <= 5'd0;
			end
            else if (((rob_head + rob_head_cmmt_num) >= 64) && 
					(rob_st_idx < (rob_head + rob_head_cmmt_num - 7'd64)))begin
                rob_st[rob_st_idx] <= 0;
                rob_st_ptr[rob_st_idx] <= 5'd0;
			end
            else begin
                rob_st    [rob_st_idx] <= rob_st    [rob_st_idx];
                rob_st_ptr[rob_st_idx] <= rob_st_ptr[rob_st_idx];
            end
        end
    end
    endgenerate

    /*
    * Each entry updation : rob_ld_ptr
    */
    // write section
    generate
    genvar rob_ld_idx;
    for(rob_ld_idx = 0; rob_ld_idx < 64; rob_ld_idx = rob_ld_idx + 1)
    begin : rob_ld_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n) begin
                rob_ld_ptr[rob_ld_idx] <= 5'd0;
            end
            // misprediction
            else if (mis_pred && (mis_pred_brnc_idx <= rob_tail_when_mis_pred) && 
				    (rob_ld_idx >= mis_pred_brnc_idx) && (rob_ld_idx < rob_tail_when_mis_pred))
                rob_ld_ptr[rob_ld_idx] <= rob_ld_ptr[mis_pred_brnc_idx];
            else if (mis_pred && (mis_pred_brnc_idx > rob_tail_when_mis_pred) && 
				    ((rob_ld_idx >= mis_pred_brnc_idx)))
                rob_ld_ptr[rob_ld_idx] <= rob_ld_ptr[mis_pred_brnc_idx];
            // adding into ROB
            else if ((!all_nop) && (rob_ld_idx == rob_tail[5:0])) begin 
                rob_ld_ptr[rob_ld_idx] <= (ld_in[0]) ? rob_ld_cntr_add1
                                        : rob_ld_cntr;
            end
            else if ((!all_nop) && 
                    ((rob_ld_idx == rob_tail[5:0] + 6'd1) || ((rob_tail[5:0]>=63) && (rob_ld_idx == (rob_tail[5:0]-6'd63))))) begin
                rob_ld_ptr[rob_ld_idx] <= (ld_in[1:0] == 2'b11) ? rob_ld_cntr_add2
                                        : (ld_in[1:0] == 2'b01) ? rob_ld_cntr_add1
                                        : (ld_in[1:0] == 2'b10) ? rob_ld_cntr_add1
                                        : rob_ld_cntr;
            end
            else if ((!all_nop) && 
                    ((rob_ld_idx == rob_tail[5:0] + 6'd2) || ((rob_tail[5:0]>=62) && (rob_ld_idx == (rob_tail[5:0]-6'd62))))) begin
                rob_ld_ptr[rob_ld_idx] <= (ld_in[2:0] == 3'b111) ? rob_ld_cntr_add3
                                        : (ld_in[2:0] == 3'b011) ? rob_ld_cntr_add2
                                        : (ld_in[2:0] == 3'b110) ? rob_ld_cntr_add2
                                        : (ld_in[2:0] == 3'b101) ? rob_ld_cntr_add2
                                        : (ld_in[2:0] == 3'b001) ? rob_ld_cntr_add1
                                        : (ld_in[2:0] == 3'b010) ? rob_ld_cntr_add1
                                        : (ld_in[2:0] == 3'b100) ? rob_ld_cntr_add1
                                        : rob_ld_cntr;
            end
            else if ((!all_nop) && 
                    ((rob_ld_idx == rob_tail[5:0] + 6'd3) || ((rob_tail[5:0]>=61) && (rob_ld_idx == (rob_tail[5:0]-6'd61))))) begin
                if (ld_in[3]) begin
                    rob_ld_ptr[rob_ld_idx] <= (ld_in[2:0] == 3'b111) ? rob_ld_cntr_add4
                                            : (ld_in[2:0] == 3'b011) ? rob_ld_cntr_add3
                                            : (ld_in[2:0] == 3'b110) ? rob_ld_cntr_add3
                                            : (ld_in[2:0] == 3'b101) ? rob_ld_cntr_add3
                                            : (ld_in[2:0] == 3'b001) ? rob_ld_cntr_add2
                                            : (ld_in[2:0] == 3'b010) ? rob_ld_cntr_add2
                                            : (ld_in[2:0] == 3'b100) ? rob_ld_cntr_add2
                                            : rob_ld_cntr_add1;
                end
                else begin
                    rob_ld_ptr[rob_ld_idx] <= (ld_in[2:0] == 3'b111) ? rob_ld_cntr_add3
                                            : (ld_in[2:0] == 3'b011) ? rob_ld_cntr_add2
                                            : (ld_in[2:0] == 3'b110) ? rob_ld_cntr_add2
                                            : (ld_in[2:0] == 3'b101) ? rob_ld_cntr_add2
                                            : (ld_in[2:0] == 3'b001) ? rob_ld_cntr_add1
                                            : (ld_in[2:0] == 3'b010) ? rob_ld_cntr_add1
                                            : (ld_in[2:0] == 3'b100) ? rob_ld_cntr_add1
                                            : rob_ld_cntr;
                end
            end
            /*/ commiting out ROB
			else if ((rob_ld_idx >= rob_head) && (rob_ld_idx < (rob_head + rob_head_cmmt_num)))begin 
                rob_ld_ptr[rob_ld_idx] <= 0;
			end
            else if (((rob_head + rob_head_cmmt_num) >= 64) && 
					(rob_ld_idx < (rob_head + rob_head_cmmt_num - 64)))begin
                rob_ld_ptr[rob_ld_idx] <= 0;
			end*/
            else begin
                rob_ld_ptr[rob_ld_idx] <= rob_ld_ptr[rob_ld_idx];
            end
        end
    end
    endgenerate

	/*
    * Each entry updation : valid
    */
    // write section
    generate
    genvar rob_signed_comp_idx;
    for(rob_signed_comp_idx = 0; rob_signed_comp_idx < 64; rob_signed_comp_idx = rob_signed_comp_idx + 1)
    begin : rob_signed_comp_idx_gen
        always@(posedge clk, negedge rst_n)begin
            if(!rst_n)
                rob_signed_comp[rob_signed_comp_idx] <= 0;
            // adding into ROB
            else if ((!all_nop) && (rob_signed_comp_idx >= rob_tail[5:0] && rob_signed_comp_idx <= (rob_tail[5:0]+3))) 
                rob_signed_comp[rob_signed_comp_idx] <= inverting_bit;
            // default
            else begin
                rob_signed_comp[rob_signed_comp_idx] <= rob_signed_comp[rob_signed_comp_idx];
            end
        end
    end
    endgenerate


	branch_fifo branch_fifo_DUT(
	// Outputs
	.decr_brnc_num(decr_brnc_num),
	// Inputs
	.brnc_in(brnc_in), 
	.rob_tail(rob_tail[5:0]), 
	.mis_pred(mis_pred), 
	.cmt_brnc(cmt_brnc), 
	.mis_pred_brnc_indx(mis_pred_brnc_idx),
	.cmt_brnc_indx(cmt_brnc_idx), 
	.clk(clk), 
	.rst_n(rst_n)
	);

endmodule
