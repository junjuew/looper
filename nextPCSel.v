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
    output reg [2:0] PC_select
);

wire stall;
assign stall=(stall_fetch==1) || (stall_for_jump==1);


//assign PC_select=(!rst_n)?3'd7:(stall?3'd6:
//   (has_mispredict?3'd3:(jump_for_pcsel?3'd2:
//   ((|pred_to_pcsel)?(pred_to_pcsel[1]?3'd0:3'd1)://check which branch tkn
//   (pcsel_from_bhndlr?3'd4:3'd5)))));



always @(*)begin
    if(!rst_n)
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
