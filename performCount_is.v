module performCount_is(/*autoarg*/
   // Outputs
   instruction_cnt,
   // Inputs
   inst_valid0, inst_valid1, inst_valid2, inst_valid3, enable, clr,
   clk, rst_n
   );

   input inst_valid0, inst_valid1, inst_valid2, inst_valid3;

   input enable;
   input clr;
   input clk,rst_n;
   wire [1:0] valid_inst;
   
   output [15:0] instruction_cnt;


   reg [15:0] 	 inst_count;

   assign valid_inst = inst_valid0 + inst_valid1 + inst_valid2 + inst_valid3;
 
   
   
   always@(posedge clk, negedge rst_n)
     begin
	if(!rst_n)
	  inst_count <= 16'b0;
	else if(clr)
	  inst_count <= 16'b0;
	else if( enable)
	  inst_count <= inst_count + valid_inst;
	else
	  inst_count <= inst_count;
     end

endmodule // performCount_is
