`default_nettype none
module instCombiner(/*autoarg*/
   // Outputs
   inst_out0, inst_out1, inst_out2, inst_out3,
   // Inputs
   inst0, inst1, inst2, inst3, pr_num_in0, pr_num_in1, pr_num_in2,
   pr_num_in3, pr_need_list_in
   );

   input wire [65:0] inst0,inst1,inst2,inst3;
   input wire [5:0]  pr_num_in0,pr_num_in1,pr_num_in2,pr_num_in3;
   input wire [3:0]  pr_need_list_in;

   output wire [55:0] inst_out0,inst_out1,inst_out2,inst_out3;



   wire [5:0] 	      pr_num0,pr_num1,pr_num2,pr_num3;

   assign pr_num0 = pr_need_list_in[0] ? pr_num_in0 : 6'b0;
   assign pr_num1 = pr_need_list_in[1] ? pr_num_in1 : 6'b0;
   assign pr_num2 = pr_need_list_in[2] ? pr_num_in2 : 6'b0;
   assign pr_num3 = pr_need_list_in[3] ? pr_num_in3 : 6'b0;


   assign inst_out0 = {inst0[65:17],pr_need_list_in[0],pr_num0};
   assign inst_out1 = {inst1[65:17],pr_need_list_in[1],pr_num1};
   assign inst_out2 = {inst2[65:17],pr_need_list_in[2],pr_num2};
   assign inst_out3 = {inst3[65:17],pr_need_list_in[3],pr_num3};

   
   
endmodule // instCombiner
