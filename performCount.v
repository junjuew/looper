module performCount(/*autoarg*/
   // Outputs
   cmt_brnch_cnt, mis_brnch_cnt,
   // Inputs
   cmt_brnch, mis_brnch, clk, rst_n, clr, enable
   );

   input 	cmt_brnch;
   input 	mis_brnch;
   input 	clk,rst_n;
   input 	clr,enable;


 
   output [15:0] cmt_brnch_cnt;
   output [15:0] mis_brnch_cnt;
   


   reg [15:0] 	 cmt_brnch_count;
   reg [15:0] 	 mis_brnch_count;


   always@(posedge clk, negedge rst_n)
     begin
	if(!rst_n)
	  cmt_brnch_count <= 16'b0;
	else if(clr)
	  cmt_brnch_count <= 16'b0;
	else if(cmt_brnch && enable)
	  cmt_brnch_count <= cmt_brnch_count + 16'h1;
	else
	  cmt_brnch_count <= cmt_brnch_count;
     end

   always@(posedge clk, negedge rst_n)
     begin
	if(!rst_n)
	  mis_brnch_count <= 16'b0;
	else if(clr)
	  mis_brnch_count <= 16'b0;
	else if(mis_brnch && enable)
	  mis_brnch_count <= mis_brnch_count + 16'h1;
	else
	  mis_brnch_count <= mis_brnch_count;
     end

   assign cmt_brnch_cnt = cmt_brnch_count;
   assign mis_brnch_cnt = mis_brnch_count;
   
   
endmodule // performCount
