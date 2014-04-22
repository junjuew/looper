module branchUnit(/*autoarg*/
   // Outputs
   flush_pos, flush, all_nop_from_branchUnit,
   // Inputs
   inst0, inst1, inst2, inst3, nxt_indx, brch_mis_indx, curr_pos,
   pr_need_inst, mis_pred, cmt_brch_indx, cmt_brch, clk, rst_n
   );
   input wire [65:0] inst0,inst1, inst2, inst3;
   input wire [6:0] 	nxt_indx;
   input wire [5:0] 	brch_mis_indx;
   input wire [6:0] 	curr_pos;
   input wire [3:0] 	pr_need_inst;
   input wire 		mis_pred;
   input wire [5:0] 	cmt_brch_indx;
   input wire 		cmt_brch;
   output reg [6:0] 	flush_pos;
   output reg 		flush; 		
   input wire 		clk,rst_n;
   output wire 		all_nop_from_branchUnit;
   
   
   wire [5:0]	     indx1,indx2,indx3;
   wire [6:0] 	     curr_pos1,curr_pos2,curr_pos3;
//   reg [13:0] 	     pos_reg0,pos_reg1; // {free|brch_indx|pointer_pos}
   wire 	     brch0,brch1,brch2,brch3;
   //reg 		     pos_reg0_en,pos_reg1_en;
  // reg [13:0]	     pos_reg0_input,pos_reg1_input;
   //reg 		     pos_reg0_clr,pos_reg1_clr;
   //reg 		     flush_pos_sel;
   reg [12:0] 	     fifo[0:1];// {brch_indx|pointer_pos}
   reg [12:0] 	     fifo_update_val[0:1];
   reg 		     head,tail;
   reg 		     clear_head,decrement_tail,increment_tail1,increment_tail2,increment_head;
   reg 		     fifo_enable[0:1];
   wire [1:0] 	     brnc_count;
   
   
   assign indx1 = nxt_indx + 1;
   assign indx2 = nxt_indx + 2;
   assign indx3 = nxt_indx + 3;
   
   
   assign curr_pos1 = curr_pos + pr_need_inst[0];
   assign curr_pos2 = curr_pos + pr_need_inst[1] + pr_need_inst[0];
   assign curr_pos3 = curr_pos + pr_need_inst[2] + pr_need_inst[1] + pr_need_inst[0];
   

   assign brch0 = (inst0[31:30] == 2'b00) ? 0:1;
   assign brch1 = (inst1[31:30] == 2'b00) ? 0:1;
   assign brch2 = (inst2[31:30] == 2'b00) ? 0:1;
   assign brch3 = (inst3[31:30] == 2'b00) ? 0:1;

   assign brnc_count = brch0 + brch1 + brch2 + brch3;

   always@(/*autosense*/brch0 or brch1 or brch2 or brch3 or brnc_count
	   or curr_pos or curr_pos1 or curr_pos2 or curr_pos3 or indx1
	   or indx2 or indx3 or nxt_indx or tail)
     begin
	fifo_update_val[0] = 13'b0;
	fifo_update_val[1] = 13'b0;
	if(brch0)
	  fifo_update_val[tail] = {nxt_indx,curr_pos};
	else if(brch1)
	  fifo_update_val[tail] = {indx1,curr_pos1};
	else if(brch2)
	  fifo_update_val[tail] = {indx2,curr_pos2};
	else if(brch3)
	  fifo_update_val[tail] = {indx3,curr_pos3};

	if(brnc_count == 2'b10)
	  begin
	     if(brch3)
	       fifo_update_val[tail + 1] = {indx3,curr_pos3};
	     else if(brch2)
	       fifo_update_val[tail + 1] = {indx2,curr_pos2};
	     else
	       fifo_update_val[tail + 1] = {indx1,curr_pos1};
	  end
     end // always@ (...

   //control signal
   always@(/*autosense*/ /*memory or*/ brch_mis_indx or brnc_count
	   or cmt_brch or cmt_brch_indx or head or mis_pred or tail)
     begin
	clear_head = 1'b0;
	decrement_tail = 1'b0;
	increment_tail1 = 1'b0;
	increment_tail2 = 1'b0;
	increment_head = 1'b0;
	fifo_enable[0] = 1'b0;
	fifo_enable[1] = 1'b0;
	flush_pos = 7'b0;
	flush = 1'b0;
	
	if(mis_pred)
	  begin
	     flush = 1'b1;
	     if(brch_mis_indx == fifo[head][12:7])
	       begin
		  flush_pos = fifo[head][6:0];
		  clear_head = 1'b1;		  
	       end
	     else
	       begin
		  flush_pos = fifo[head + 1][6:0];
		  decrement_tail = 1'b1;
	       end
	  end // if (mis_pred)

	if(cmt_brch)
	  begin
	     if(cmt_brch_indx == fifo[head][12:7])
	       begin
		  increment_head = 1'b1;
	       end
	     else
	       decrement_tail = 1'b1;
	  end

	if(brnc_count == 2'b01)
	  begin
	     increment_tail1 = 1'b1;
	     fifo_enable[tail] = 1'b1;
	  end
	
	
	if(brnc_count == 2'b10)
	  begin
	     increment_tail2 = 1'b1;
	     fifo_enable[0] = 1'b1;
	     fifo_enable[1] = 1'b1;
	  end
	
     end
   //fifo update
   generate
      genvar i;
      for(i = 0; i < 2; i = i + 1)
	begin
	   always@(posedge clk,negedge rst_n)
	     begin
		if(!rst_n)
		  fifo[i] <= 13'b0;
		else if(clear_head)
		  fifo[i] <= 13'b0;
		else if(fifo_enable[i])
		  fifo[i] <= fifo_update_val[i];
		else
		  fifo[i] <= fifo[i];
	     end
	end // for (i = 0; i < 2; i = i + 1;)
   endgenerate
   

   
   //head reg
   always@(posedge clk,negedge rst_n)
     begin
	if(!rst_n)
	  head <= 1'b0;
	else if(clear_head)
	  head <= 1'b0;
	else if(increment_head)
	  head <= head + 1'b1;
	else
	  head <= head;
     end // always@ (posedge clk,negedge rst_n)

   always@(posedge clk, negedge rst_n)
     begin
	if(!rst_n)
	  tail <= 1'b0;
	else if(clear_head)
	  tail <= 1'b0;
	else if(decrement_tail)
	  tail <= tail - 1'b1;
	else if(increment_tail1)
	  tail <= tail - 1'b1;
	else if(increment_tail2)
	  tail <= tail - 2'b10;
	else
	  tail <= tail;
     end // always@ (posedge clk, negedge rst_n)

   
/* -----\/----- EXCLUDED -----\/-----
   //old code
   //when a branch instruction comes in
   always@(brch0,brch1,brch2,brch3)
     begin
	pos_reg0_en = 1'b0;
	pos_reg1_en = 1'b0;
	pos_reg0_input = 13'b0;
	pos_reg1_input = 13'b0;
	
	if(brch0) 
	  begin
	     if(pos_reg0[13])
	       begin
		  pos_reg0_en = 1'b1;
		  pos_reg0_input = {1'b0,nxt_indx,curr_pos};
	       end
	     else
	       begin
		  pos_reg1_en = 1'b1;
		  pos_reg1_input = {1'b0,nxt_indx,curr_pos};
	       end
	  end
   
	if(brch1)
	  begin
	     if(!pos_reg0[13] ||  pos_reg0_en)
	       begin
		  pos_reg1_en = 1'b1;
		  pos_reg1_input = {1'b0,indx1,curr_pos1};
	       end
	     else
	       begin
		  pos_reg0_en = 1'b1;
		  pos_reg0_input = {1'b0,indx1,curr_pos1};
	       end
	  end // if (brch1)

	if(brch2)
	  begin
	     if(!pos_reg0[13] ||  pos_reg0_en)
	       begin
		  pos_reg1_en = 1'b1;
		  pos_reg1_input = {1'b0,indx2,curr_pos2};
	       end
	     else
	       begin
		  pos_reg0_en = 1'b1;
		  pos_reg0_input = {1'b0,indx2,curr_pos2};
	       end
	  end // if (brch2)
	
	if(brch3)
	  begin
	     if(!pos_reg0[13] ||  pos_reg0_en)
	       begin
		  pos_reg1_en = 1'b1;
		  pos_reg1_input = {1'b0,indx3,curr_pos3};
	       end
	     else
	       begin
		  pos_reg0_en = 1'b1;
		  pos_reg0_input = {1'b0,indx3,curr_pos3};
	       end
	  end // if (brch3)
     end // always@ (brch0,brch1,brch2,brch3)

   always@(/-*autosense*-/cmt_brch or cmt_brch_indx or pos_reg0
	   or pos_reg1)
     begin
	pos_reg0_clr = 1'b0;
	pos_reg1_clr = 1'b0;
 
	if(cmt_brch)
	  begin
	     if(cmt_brch_indx == pos_reg0[12:7])
	       pos_reg0_clr = 1'b1;
	     else if(cmt_brch_indx == pos_reg1[12:7])
	       pos_reg1_clr = 1'b1;
	     else
	       begin
		  pos_reg0_clr = 1'b0;
		  pos_reg1_clr = 1'b0;
	       end
	     
	  end
     end // always@ (...
   

   always@(/-*autosense*-/brch_mis_indx or mis_pred or pos_reg0
	   or pos_reg1)
     begin
	flush_pos_sel = 1'b0;
	flush = 1'b0;
	
	if(mis_pred)
	  begin
	     flush = 1'b1;
	     if(brch_mis_indx == pos_reg0[12:7])
	       flush_pos_sel = 1'b0;
	     else if(brch_mis_indx == pos_reg1[12:7])
	       flush_pos_sel = 1'b1;
	     else
	       flush_pos_sel = 1'b0;
	  end
     end // always@ (...
   
	
   
   //pos_register 0
   always@(posedge clk,negedge rst_n)
     begin
	if(!rst_n)
	  pos_reg0 <= {1'b1,13'b0};
	else if (pos_reg0_clr)
	  pos_reg0 <= {1'b1,13'b0};
	else if (pos_reg0_en)
	  pos_reg0 <= pos_reg0_input;
	else
	  pos_reg0 <= pos_reg0;
     end

   //pos_register 1
   always@(posedge clk,negedge rst_n)
     begin
	if(!rst_n)
	  pos_reg1 <= {1'b1,13'b0};
	else if (pos_reg1_clr)
	  pos_reg1 <= {1'b1,13'b0};
	else if (pos_reg1_en)
	  pos_reg1 <= pos_reg1_input;
	else
	  pos_reg1 <= pos_reg1;
     end
 -----/\----- EXCLUDED -----/\----- */
   
//   assign flush_pos = flush_pos_sel ? pos_reg1:pos_reg0;
   
   assign all_nop_from_branchUnit = (mis_pred) ? 1: 0;
   
   
   
endmodule // branchUnit
