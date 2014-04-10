`default_nettype none
module branchUnit(/*autoarg*/
   // Outputs
   flush_pos, flush,
   // Inputs
   inst0, inst1, inst2, inst3, nxt_indx, brch_mis_indx, curr_pos,
   pr_need_inst, mis_pred, cmt_brch_indx, cmt_brch, clk, rst_n
   );
   input wire [65:0] inst0,inst1, inst2, inst3;
   input wire [5:0] 	nxt_indx;
   input wire [5:0] 	brch_mis_indx;
   input wire [5:0] 	curr_pos;
   input wire [3:0] 	pr_need_inst;
   input wire 		mis_pred;
   input wire [5:0] 	cmt_brch_indx;
   input wire 		cmt_brch;
   output wire [6:0] 	flush_pos;
   output reg 		flush; 		
   input wire 		clk,rst_n;
   
   wire 	     indx1,indx2,indx3;
   wire [5:0] 	     curr_pos1,curr_pos2,curr_pos3;
   reg [13:0] 	     pos_reg0,pos_reg1; // {free|brch_indx|pointer_pos}
   wire 	     brch0,brch1,brch2,brch3;
   reg 		     pos_reg0_en,pos_reg1_en;
   reg [13:0]	     pos_reg0_input,pos_reg1_input;
   reg 		     pos_reg0_clr,pos_reg1_clr;
   reg 		     flush_pos_sel;
   
   
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

   //when a branch instruction comes in
   always@(brch0,brch1,brch2,brch3)
     begin
	pos_reg0_en = 1'b0;
	pos_reg1_en = 1'b0;
	pos_reg0_input = 13'b0;
	pos_reg1_input = 13'b0;
	
	if(brch0) 
	  begin
	     if(pos_reg0[0])
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
	     if(!pos_reg0[0] ||  pos_reg0_en)
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
	     if(!pos_reg0[0] ||  pos_reg0_en)
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
	     if(!pos_reg0[0] ||  pos_reg0_en)
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

   always@(/*autosense*/cmt_brch or cmt_brch_indx or pos_reg0
	   or pos_reg1)
     begin
	pos_reg0_clr = 1'b0;
	pos_reg1_clr = 1'b0;
 
	if(cmt_brch)
	  begin
	     if(cmt_brch_indx == pos_reg0[11:6])
	       pos_reg0_clr = 1'b1;
	     else if(cmt_brch_indx == pos_reg1[11:6])
	       pos_reg1_clr = 1'b1;
	     else
	       begin
		  pos_reg0_clr = 1'b0;
		  pos_reg1_clr = 1'b0;
	       end
	     
	  end
     end // always@ (...
   

   always@(/*autosense*/brch_mis_indx or mis_pred or pos_reg0
	   or pos_reg1)
     begin
	flush = 1'b0;
	if(mis_pred)
	  begin
	     flush = 1'b1;
	     if(brch_mis_indx == pos_reg0[11:6])
	       flush_pos_sel = 1'b0;
	     else if(brch_mis_indx == pos_reg1[11:6])
	       flush_pos_sel = 1'b1;
	     else
	       flush_pos_sel = 1'b0;
	  end
     end // always@ (...
   
	
   
   //pos_register 0
   always@(posedge clk,negedge rst_n)
     begin
	if(!rst_n)
	  pos_reg0 <= 13'b0;
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
	  pos_reg1 <= 13'b0;
	else if (pos_reg1_clr)
	  pos_reg1 <= {1'b1,13'b0};
	else if (pos_reg1_en)
	  pos_reg1 <= pos_reg1_input;
	else
	  pos_reg1 <= pos_reg1;
     end
   
   assign flush_pos = flush_pos_sel ? pos_reg1:pos_reg0;
   

   
   
endmodule // branchUnit
