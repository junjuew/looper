module branch_fifo(/*autoarg*/
   // Outputs
   decr_brnc_num,
   // Inputs
   brnc_in, rob_tail, mis_pred, cmt_brnc, mis_pred_brnc_indx,
   cmt_brnc_indx, clk, rst_n
   );

   input [3:0]brnc_in;

   input [5:0] rob_tail;

   input       mis_pred,cmt_brnc;
   input [5:0] mis_pred_brnc_indx,cmt_brnc_indx;

   input       clk,rst_n;
   
   output      decr_brnc_num;

   reg [5:0]   fifo[0:1];

   reg 	       head,tail;

   reg 	       clear_head,decrement_tail,increment_tail1,increment_tail2,increment_head;

   reg 	       fifo_enable[0:1];
   
   reg 	       decr_brnc_num;
   
   
   wire [1:0]  brnc_count;

   wire [5:0]  indx1,indx2,indx3;
   reg [5:0]  fifo_update_val[0:1];
   
   
   assign indx1 = (rob_tail < 63) ? rob_tail + 1 : 0;
   assign indx2 = (rob_tail < 62) ? rob_tail + 2 : rob_tail - 62;
   assign indx3 = (rob_tail < 61) ? rob_tail + 3 : rob_tail - 61;

   assign brnc_count = brnc_in[0] + brnc_in[1] + brnc_in[2] + brnc_in[3];

   
/* -----\/----- EXCLUDED -----\/-----
   assign fifo_update_val[tail] = brnc_in[0] ? tail : (brnc_in[1] ? indx1: (brnc_in[2] ? indx2:(brnc_in[3] ? indx3 : 6'b0)));

   assign fifo_update_val[tail+1] = (brnc_count == 2'b10) ? (brnc_in[3] ? indx3:(brnc_in[2] ? indx2: indx1)):6'b0;
 -----/\----- EXCLUDED -----/\----- */



   always@(/*autosense*/brnc_count or brnc_in or indx1 or indx2
	   or indx3 or rob_tail or tail)
     begin
	fifo_update_val[0] = 6'b0;
	fifo_update_val[1] = 6'b0;
	if(brnc_in[0])
	  fifo_update_val[tail] = rob_tail;
	else if(brnc_in[1])
	  fifo_update_val[tail] = indx1;
	else if(brnc_in[2])
	  fifo_update_val[tail] = indx2;
	else if(brnc_in[3])
	  fifo_update_val[tail] = indx3;

	if(brnc_count == 2'b10)
	  begin
	     if(brnc_in[3])
	       fifo_update_val[tail + 1] = indx3;
	     else if(brnc_in[2])
	       fifo_update_val[tail + 1] = indx2;
	     else
	       fifo_update_val[tail + 1] = indx1;
	  end
     end // always@ (...
   
   
   
   
   always@(/*autosense*/ fifo[0] or fifo[1] or brnc_count or cmt_brnc
	   or cmt_brnc_indx or head or mis_pred or mis_pred_brnc_indx
	   or tail)
     begin
	clear_head = 1'b0;
	decrement_tail = 1'b0;
	increment_tail1 = 1'b0;
	increment_tail2 = 1'b0;
	increment_head = 1'b0;
	fifo_enable[0] = 1'b0;
	fifo_enable[1] = 1'b0;
	decr_brnc_num = 1'b0;
	
	if(mis_pred)
	  begin
	     if(mis_pred_brnc_indx == fifo[head])
	       begin
		  clear_head = 1'b1;
		  decr_brnc_num = 1'b1;
		  
	       end
	     else
	       begin
		  decrement_tail = 1'b1;
	       end
	  end // if (mis_pred)

	if(cmt_brnc)
	  begin
	     if(cmt_brnc_indx == fifo[head])
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
	begin : fifo_update_gen
	   always@(posedge clk,negedge rst_n)
	     begin
		if(!rst_n)
		  fifo[i] <= 6'b0;
		else if(clear_head)
		  fifo[i] <= 6'b0;
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

   
   
   
endmodule // scratch
