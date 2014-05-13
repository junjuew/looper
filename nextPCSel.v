`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:13:22 03/22/2014 
// Design Name: 
// Module Name:    nextPCSel 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module nextPCSel(
    input 	     clk,
    input 	     rst_n,
    input 	     stall_fetch,
    input 	     has_mispredict,
    input [1:0]      pred_to_pcsel,
    input 	     jump_for_pcsel,
    input 	     pcsel_from_bhndlr,
    input 	     stall_for_jump,
    input            brch_full,	     
   // input loop_start,
    output reg [2:0] PC_select,
    output   reg      start
);

wire stall;
assign stall=(stall_fetch==1) || (stall_for_jump==1);


   //add start signal so that only when rst is done, can the instructions 
   //be read from imemory and send to the next stages
   always@(posedge clk or negedge rst_n)
	if(!rst_n)
		start<=1'b1;
   else
     start<=1'b0;

   always @(*)begin
      if(start==1'b1)
        PC_select=3'd7;
      else if(has_mispredict==1)
        PC_select=3'd3;//pc_recovery
      else if(stall==1'b1 || brch_full == 1'b1)
        PC_select=3'd6;
      else if(jump_for_pcsel==1)
        PC_select=3'd2;
      else if(|pred_to_pcsel==1)
        begin
           if(pred_to_pcsel[1]==1)
             PC_select=3'd0;
           else
             PC_select=3'd1;
        end
      else if(pcsel_from_bhndlr==1)//if more than two branches, third got flushed
        PC_select=3'd4;//pc_new=pc_bhndlr;
      else 
        PC_select=3'd5;
   end

endmodule
