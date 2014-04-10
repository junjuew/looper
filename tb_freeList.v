module tb_freeList();
   reg clk,rst_n,stall;
   reg [2:0] free_pr_num;
   reg [3:0] pr_need_inst_in;
   reg 	     flush;
   reg [6:0] flush_pos;
   reg [5:0] free_pr_num_in0,free_pr_num_in1,free_pr_num_in2,free_pr_num_in3;


   wire [5:0] pr_num_out0,pr_num_out1,pr_num_out2,pr_num_out3;
   wire       list_empty;
   wire [6:0] curr_pos;
   
   
   freeList DUT(/*autoinst*/
		// Outputs
		.pr_num_out0		(pr_num_out0[5:0]),
		.pr_num_out1		(pr_num_out1[5:0]),
		.pr_num_out2		(pr_num_out2[5:0]),
		.pr_num_out3		(pr_num_out3[5:0]),
		.list_empty		(list_empty),
		.curr_pos		(curr_pos[6:0]),
		// Inputs
		.free_pr_num_in0	(free_pr_num_in0[5:0]),
		.free_pr_num_in1	(free_pr_num_in1[5:0]),
		.free_pr_num_in2	(free_pr_num_in2[5:0]),
		.free_pr_num_in3	(free_pr_num_in3[5:0]),
		.flush_pos		(flush_pos[6:0]),
		.flush			(flush),
		.pr_need_inst_in	(pr_need_inst_in[3:0]),
		.free_pr_num		(free_pr_num[2:0]),
		.clk			(clk),
		.rst_n			(rst_n),
		.stall			(stall));


   initial begin
      $wlfdumpvars(0,tb_freeList);
      
      clk = 0;
      forever #5 clk = ~clk;
   end

   initial begin
      rst_n = 1'b0;
      #7 rst_n = 1'b1;
   end

   initial begin
      pr_need_inst_in = 4'b0000;
   end

   initial begin
      free_pr_num = 3'h0;
      stall = 1'b0;
      flush = 1'b0;
   end
   
   always@(negedge clk)
     pr_need_inst_in = pr_need_inst_in + 1;
   
   
   always@(posedge clk)
     begin
	#0;
	$display("%t, current pr_need_inst_in is %b\n",$time,pr_need_inst_in); 
	$display("%t, preg0 is %d, preg1 is %d, preg2 is %d, preg3 is %d, list empty is %b, curr pos is %d\n", $time,pr_num_out0,pr_num_out1,pr_num_out2,pr_num_out3,list_empty,curr_pos[5:0]);
	$display("%t, current alloc ptr is %b, cmt ptr is %b\n",$time,DUT.alloc_ptr,DUT.cmt_ptr);
	
     end

   initial begin
      free_pr_num_in0 = 6'h10;
      free_pr_num_in1 = 6'h1A;
      free_pr_num_in2 = 6'h1B;
      free_pr_num_in3 = 6'h1C;
   end

   initial begin
      free_pr_num = 3'h0;
   end
   
   always@(negedge clk)
     begin
	free_pr_num_in0 = free_pr_num_in0 + 6'h4;
	free_pr_num_in1 = free_pr_num_in1 + 6'h4;
	free_pr_num_in2 = free_pr_num_in2 + 6'h4;
	free_pr_num_in3 = free_pr_num_in3 + 6'h4;
	if(free_pr_num == 3'd4)
	  free_pr_num = 3'b0;
	else
	  free_pr_num = free_pr_num + 1;
     end

   always@(posedge clk)
     begin
	#0;
	$display("%t, current free number is  %d\n",$time,free_pr_num);
	$display("%t, current cmt ptr pos is %d\n", $time,DUT.cmt_ptr);
	$display("%t, cmt reg is a: %d, b: %d, c: %d, d: %d, cmt position is %d,%d,%d, %d\n",$time,free_pr_num_in0,free_pr_num_in1,free_pr_num_in2,free_pr_num_in3,DUT.cmt_ptr,DUT.cmt_ptr + 1, DUT.cmt_ptr + 2, DUT.cmt_ptr + 3);
	$display("%t, cmt reg check a:  %d, b: %d, c: %d, d: %d, cmt position is %d,%d,%d, %d\n", $time, DUT.list[DUT.cmt_ptr-4],DUT.list[DUT.cmt_ptr-3],DUT.list[DUT.cmt_ptr-2],DUT.list[DUT.cmt_ptr-1],DUT.cmt_ptr-4, DUT.cmt_ptr-3,DUT.cmt_ptr-2,DUT.cmt_ptr-1);
     
     end

   
     
   initial begin
      #100;
      $finish;
   end

   
endmodule // tb_freeList

