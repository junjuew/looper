module tb_branchfifo();

   wire decr_brnc_num;
   reg [3:0] brnc_in;
   reg [5:0] rob_tail;
   reg 	     mis_pred,cmt_brnc;
   reg [5:0] mis_pred_brnc_indx,cmt_brnc_indx;
   reg 	     clk,rst_n;
   
   
   
   branch_fifo DUT(/*autoinst*/
		   // Outputs
		   .decr_brnc_num	(decr_brnc_num),
		   // Inputs
		   .brnc_in		(brnc_in[3:0]),
		   .rob_tail		(rob_tail[5:0]),
		   .mis_pred		(mis_pred),
		   .cmt_brnc		(cmt_brnc),
		   .mis_pred_brnc_indx	(mis_pred_brnc_indx[5:0]),
		   .cmt_brnc_indx	(cmt_brnc_indx[5:0]),
		   .clk			(clk),
		   .rst_n		(rst_n));

   
   initial begin
      $wlfdumpvars(0,tb_branchfifo);
      clk = 0;
      forever #5 clk = ~clk;
   end

   initial begin
      rst_n = 1'b0;
      #7 rst_n = 1'b1;
   end


   always@(posedge clk)
     begin
	#2;
	$display("%t, fifo content: first reg val is %d, second reg val is %d \n",$time, DUT.fifo[0],DUT.fifo[1]);
	$display("%t, control signals: clear head is %b, decrement tail is %b, increment_tail1 is %b, increment_tail2 is %d, increment_head is %b \n", $time, DUT.clear_head,DUT.decrement_tail,DUT.increment_tail1,DUT.increment_tail2,DUT.increment_head);
	$display("%t, fifo enable signal: fifo enable 0 is %b, fifo enable 1 is %b \n",$time, DUT.fifo_enable[0], DUT.fifo_enable[1]);
	$display("%t, decrement count number is %d \n",$time,decr_brnc_num);
	$display("%t, current head is %b, current tail is %b \n",$time,DUT.head,DUT.tail);
	$display("/////////////////////////////////////////////////////////////////////////\n");
	
     end


   always @ (brnc_in)
     begin
	if(brnc_in != 4'b0)
	  begin
	     $display("////////////////////////brnc come in///////////////////////////////\n");
	     $display("brnc signal is %b \n",brnc_in);
	     $display("current tail position is %d \n", rob_tail);
	     
	  end
     end
   
   always @(mis_pred,cmt_brnc)
     begin
	if(mis_pred == 1'b1 || cmt_brnc == 1'b1)
	  begin
	     #2;
	     $display("////////////////////////////count out here//////////////////////////////\n");
	     $display("counter decrement is %b\n",decr_brnc_num);
	  end
	
     end

   
   
   always@(negedge clk, negedge rst_n)
     begin
	if(!rst_n)
	  rob_tail = 6'b0;
	else
	  rob_tail = rob_tail + 4;
     end
   
   
   initial begin
      brnc_in = 4'b0;
      rob_tail = 6'b0;
      mis_pred = 1'b0;
      cmt_brnc = 1'b0;
      mis_pred_brnc_indx = 6'b0;
      cmt_brnc_indx = 6'b0;


      @(negedge clk);
      repeat(2) @(negedge clk);

      @(negedge clk)
	brnc_in = 4'b1000; //indx is 19

      @(negedge clk)
	begin
	   brnc_in = 4'b0;
	end


      @(negedge clk)
	begin
	   brnc_in = 4'b0010;//indx is 25
	end

      @(negedge clk)
	begin
	   brnc_in = 4'b0000;
	end

      //check the second one is commit
      @(negedge clk)
	begin
	   cmt_brnc = 1'b1;
	   cmt_brnc_indx = 6'd25;
	end

      @(negedge clk)
	cmt_brnc = 1'b0;

      //cmt the first one and at the same time, the second brnc comes in
      @(negedge clk)
	begin
	   cmt_brnc = 1'b1;
	   cmt_brnc_indx = 6'd19;
	   brnc_in = 4'b0001; //indx is 40
	end

      @(negedge clk)
	begin
	   cmt_brnc = 1'b0;
	   brnc_in = 4'b0;
	end

      //cmt the head brnc
      @(negedge clk)
	begin
	   cmt_brnc = 1'b1;
	   cmt_brnc_indx = 6'd40;
	end

      //insert two branch at the same time
      @(negedge clk)
	begin
	   cmt_brnc = 1'b0;
	   brnc_in = 4'b1001;//brnc index is 52 and 55
	   
	end

      @(negedge clk)
	brnc_in = 4'b0;
      

      //misprediction test
      //first test first branch mis
      @(negedge clk)
	begin
	   mis_pred = 1'b1;
	   mis_pred_brnc_indx = 6'd52;
	end

      @(negedge clk)
	begin
	   mis_pred = 1'b0;
	end
      
      @(negedge clk)
	brnc_in = 4'b1100;//branch indx is 6 and 7

      @(negedge clk)
	begin
	   brnc_in = 4'b0;
	   mis_pred = 1'b1;
	   mis_pred_brnc_indx = 4'd7;
	end

      @(negedge clk)
	begin
	   mis_pred = 1'b0;
	end
      
      //test for one mis predict and there is another branch comes in
      @(negedge clk)
	begin
	   mis_pred = 1'b1;
	   mis_pred_brnc_indx = 4'd6;
	   brnc_in = 4'b0100;
	end

      @(negedge clk)
	begin
	   mis_pred = 1'b0;
	   brnc_in = 4'b0;
	end
      

      
   end // initial begin
   


   initial begin
      #300;
      $finish;
   end
   
endmodule // tb_branchfifo
