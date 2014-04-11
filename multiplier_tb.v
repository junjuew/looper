module multplier_tb();
  
  reg					  clk;
	reg 				  rst;
	reg 	[15:0] 	inA, inB;
	reg	        	mult_en;


	wire 	[15:0] 	out;
  wire          mult_valid_wb, mult_free;
  integer i;
	
	multiplier a (.clk(clk), .rst(rst), .mult_op1(inA), .mult_op2(inB), .mult_en(mult_en), .mult_out(out), .mult_valid_wb(mult_valid_wb), .mult_free(mult_free) );

	 always
    #2 clk = ~ clk;
    
   initial
      begin
        clk = 1;
        rst = 1;
        #1;
        rst = 0;
        mult_en = 1;
      
        //inA= 16'd2;
       // inB= 16'd2;


      end
      always@(posedge clk)
      begin 
        

        if(a.nstate == 2'b0) begin
            inA = $random%64;
            inB = $random%64;

        end
      end
      
    endmodule