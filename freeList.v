`default_nettype none
module freeList(/*autoarg*/
   // Outputs
   pr_num_out0, pr_num_out1, pr_num_out2, pr_num_out3, list_empty,
   curr_pos,
   // Inputs
   free_pr_num_in0, free_pr_num_in1, free_pr_num_in2, free_pr_num_in3,
   flush_pos, flush, pr_need_inst_in, free_pr_num, clk, rst_n, stall
   );

   input wire [5:0] free_pr_num_in0,free_pr_num_in1,free_pr_num_in2,free_pr_num_in3;
   input wire [6:0] flush_pos;
   input wire 	    flush;
   input wire [3:0] pr_need_inst_in;
   input wire [2:0] free_pr_num;
   
   input wire 	    clk,rst_n,stall;

   output wire [5:0] pr_num_out0,pr_num_out1,pr_num_out2,pr_num_out3;
   output wire 	     list_empty;
   output wire [6:0] curr_pos;
   

   reg [5:0] 	     list[0:63];
   wire [5:0] 	     update[0:63];
   wire 	     list_commit_en[0:63];
   wire 	     list_empty0, list_empty1,list_empty2,list_empty3;  //help to generate the list empty signal
   wire [6:0] 	     alloc_ptr1,alloc_ptr2,alloc_ptr3;
   
   
   reg [6:0] 	     alloc_ptr, cmt_ptr;
   
   
   wire [6:0] 	     alloc_pos,cmt_pos;
   wire [5:0] 	     cmt_val[0:3];
   wire [5:0] 	     free_pr_value[0:3];
   wire [5:0] 	     next_pr1,next_pr2,next_pr3;
	     
   
   assign cmt_pos = cmt_ptr + free_pr_num;
   

   assign free_pr_value[0] = free_pr_num_in0;
   assign free_pr_value[1] = free_pr_num_in1;
   assign free_pr_value[2] = free_pr_num_in2;
   assign free_pr_value[3] = free_pr_num_in3;
   
   assign next_pr1 = (alloc_ptr[5:0] + 1 >=64) ? (alloc_ptr[5:0] + 1 -64) : alloc_ptr[5:0] + 1;
   assign next_pr2 = (alloc_ptr[5:0] + 2 >=64) ? (alloc_ptr[5:0] + 2 -64) : alloc_ptr[5:0] + 2;
   assign next_pr3 = (alloc_ptr[5:0] + 3 >=64) ? (alloc_ptr[5:0] + 3 -64) : alloc_ptr[5:0] + 3;
   
   
   generate
      genvar 	     i;
      for(i = 0; i < 64; i = i + 1)
	begin
	   assign update[i] = (cmt_pos[5:0] > cmt_ptr[5:0]) ? (((i >= cmt_ptr[5:0]) && (i < cmt_pos[5:0])) ? free_pr_value[i-cmt_ptr[5:0]]:6'b0):
			      (cmt_pos[5:0] < cmt_ptr[5:0]) ? (((i >= cmt_ptr[5:0]) || (i < cmt_pos[5:0])) ? ((i >= cmt_ptr[5:0]) ? free_pr_value[i-cmt_ptr[5:0]]:
															      free_pr_value[i + 64 - cmt_ptr[5:0]]):6'b0):
			      6'b0;
	end
   endgenerate
   
 /* -----\/----- EXCLUDED -----\/-----
   //cmt value
   generate
      genvar 	     i, pos;
      pos = 0;
      for(i = 0; i < 4; i = i + 1)
	begin
	   assign cmt_val[pos] = free_pr_valid[i] ? free_pr_value[i] ? 5'b0;
 -----/\----- EXCLUDED -----/\----- */
	   
   
   //fifo_enable
   generate
      genvar 	     fifo_en_i;
      for(fifo_en_i = 0; fifo_en_i < 64; fifo_en_i = fifo_en_i + 1)
      begin
	assign list_commit_en[fifo_en_i] = (cmt_pos[5:0] > cmt_ptr[5:0]) ? (((fifo_en_i >= cmt_ptr[5:0]) && (fifo_en_i < cmt_pos[5:0])) ? 1:0):
					   (cmt_pos[5:0] < cmt_ptr[5:0]) ? (((fifo_en_i >= cmt_ptr[5:0]) || (fifo_en_i < cmt_pos[5:0])) ? 1:0):
					   0;
		end
   endgenerate

   
   
   //fifo
   generate
      genvar 	     fifo_i;
      for(fifo_i = 0; fifo_i < 64; fifo_i = fifo_i + 1)
	begin
	   always@(posedge clk, negedge rst_n)
	     begin
		if(!rst_n)
		  list[fifo_i] <= fifo_i;
		else if (stall)
		  list[fifo_i] <= list[fifo_i];
		else if(list_commit_en[fifo_i])
		  list[fifo_i] <= update[fifo_i];
		else
		  list[fifo_i] <= list[fifo_i];
	     end
	end // for (fifo_i = 0; fifo_i < 64; fifo_i = fifo_i + 1)
   endgenerate
   
   
   assign alloc_pos = alloc_ptr + pr_need_inst_in[0] + pr_need_inst_in[1] + pr_need_inst_in[2] + pr_need_inst_in[3];
   //assign alloc_pos = (alloc_pos >=48) ? (alloc_pos - 48) : alloc_pos;
   


   //allocation pointer register
   always@(posedge clk, negedge rst_n)
     begin
	if(!rst_n)
	  alloc_ptr <= 7'h10;
	else if (stall)
	  alloc_ptr <= alloc_ptr;
	else if (flush)
	  alloc_ptr <= flush_pos;
	else if (list_empty)
	  alloc_ptr <= alloc_ptr;
	else 
	  alloc_ptr <= alloc_pos;
     end

   //commit pointer register
   always@(posedge clk,negedge rst_n)
     begin
	if(!rst_n)
	  cmt_ptr <= 7'b0;
	else if(stall)
	  cmt_ptr <= cmt_ptr;
	else if(list_empty)
	  cmt_ptr <= cmt_ptr;
	
	else
	  cmt_ptr <= cmt_pos;
     end

   //output current position for other unit
   assign curr_pos = alloc_ptr;

   //output the list empty signal
   assign alloc_ptr1 = alloc_ptr + 1;
   assign alloc_ptr2 = alloc_ptr + 2;
   assign alloc_ptr3 = alloc_ptr + 3;
   
   assign list_empty0 = ((alloc_ptr[5:0] == cmt_ptr[5:0]) && alloc_ptr[6] != cmt_ptr[6]) ? 1:0;
   assign list_empty1 = ((alloc_ptr1[5:0] == cmt_ptr[5:0]) && alloc_ptr1[6] != cmt_ptr[6]) ? 1:0;
   assign list_empty2 = ((alloc_ptr2[5:0] == cmt_ptr[5:0]) && alloc_ptr2[6] != cmt_ptr[6]) ? 1:0;
   assign list_empty3 = ((alloc_ptr3[5:0] == cmt_ptr[5:0]) && alloc_ptr3[6] != cmt_ptr[6]) ? 1:0;
 
   assign list_empty = list_empty0 | list_empty1 | list_empty2 | list_empty3;
   
		      
   assign pr_num_out0 = pr_need_inst_in[0] ? list[alloc_ptr[5:0]] : 6'b0;
   assign pr_num_out1 = pr_need_inst_in[1] ? (pr_need_inst_in[0] ? list[next_pr1] : list[alloc_ptr[5:0]]) : 6'b0;
   assign pr_num_out2 = pr_need_inst_in[2] ? ((pr_need_inst_in[0] && pr_need_inst_in[1]) ? list[next_pr2] : (pr_need_inst_in[0] || pr_need_inst_in[1]) ? list[next_pr1] : list[alloc_ptr[5:0]]) : 6'b0;
   assign pr_num_out3 = pr_need_inst_in[3] ? ((pr_need_inst_in[0] && pr_need_inst_in[1] && pr_need_inst_in[2]) ? list[next_pr3]: 
					      ((pr_need_inst_in[0] && pr_need_inst_in[1]) || (pr_need_inst_in[0] && pr_need_inst_in[2])||(pr_need_inst_in[1] && pr_need_inst_in[2])? list[next_pr2]:
					       (pr_need_inst_in[0] || pr_need_inst_in[1] || pr_need_inst_in[2]) ? list[next_pr1] : list[alloc_ptr[5:0]])) : 6'b0;
   


   
endmodule // freeList

