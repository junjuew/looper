`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:28:56 03/21/2014 
// Design Name: 
// Module Name:    PC_MUX 
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
module PC_MUX(
    input [15:0] pc_hold,
    input [15:0] pc_recovery,
    input [15:0] brnch_addr_pc0,
    input [15:0] brnch_addr_pc1,
    input [15:0] jump_addr_pc,
    input [15:0] pc_next,
    input [15:0] pc_bhndlr,
    input [2:0]  PC_select,
    output reg[15:0] pc
   
);
 

always @(*)begin
    pc=16'b0;
    case(PC_select)
        3'd0:pc=brnch_addr_pc0;
        3'd1:pc=brnch_addr_pc1;
        3'd2:pc=jump_addr_pc;
        3'd3:pc=pc_recovery;
        3'd4:pc=pc_bhndlr;
        3'd5:pc=pc_next;//calculated by a adder
        3'd6:pc=pc_hold;
        default:pc=16'b0;//default
    endcase
end

endmodule
