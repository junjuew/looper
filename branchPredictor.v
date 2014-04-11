`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:00:20 03/22/2014 
// Design Name: 
// Module Name:    branchPredictor 
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
module branchPredictor(
    input [3:0] brnch_pc_sel_from_bhndlr,
    input update_bpred,
    input loop_start,
    input [15:0] pc,
    input [15:0] pc_plus1,
    input [15:0] pc_plus2,
    input [15:0] pc_plus3,
    output [1:0] pred_to_pcsel
   
    );

///////////////////////////////////////
//=======always TAKEN branch=========//
///////////////////////////////////////
assign pred_to_pcsel=(update_bpred)?((loop_start)?2'b11:2'b01):2'b00;

//assign brnch_pc_sel_from_bhndlr=brnch_pc_sel_from_bhndlr;



///////////////////////////////////////
//======1level dynamic predictor=====//
///////////////////////////////////////




///////////////////////////////////////
//======1level dynamic predictor=====//
///////////////////////////////////////



endmodule
