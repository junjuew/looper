//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 05/04/2014
// Design Name: pipeline register IF_ID stage
// Module Name: IF_ID
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: This is a general pipeline registers in IF_ID stage
//
// Revision 1.0 - initial version
// Additional Comments: 
//                      stall signal need to be reconsidered
//////////////////////////////////////////////////////////////////////////////////
module IF_ID (
    input clk, 
    input rst_n,

    
    input  [63:0]          pc_if_id_in,             // pc_to_dec
    input  [63:0]          inst_if_id_in,           // inst_to_dec
    input  [63:0]          recv_pc_if_id_in,        // recv_pc_to_dec
    input  [3:0]           pred_result_if_id_in,    // pred_result_to_dec
    input                  stall,




    output [63:0]          pc_if_id_out,             // pc_to_dec
    output [63:0]          inst_if_id_out,           // inst_to_dec
    output [63:0]          recv_pc_if_id_out,        // recv_pc_to_dec
    output [3:0]           pred_result_if_id_out    // pred_result_to_dec
);
    
    wire enable;   // ~stall
    assign enable = ~stall;
    //data
    rf_enable pc           [63:0]    ( .q(pc_if_id_out), .d(pc_if_id_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable inst         [63:0]    ( .q(inst_if_id_out), .d(inst_if_id_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable recv_pc      [63:0]    ( .q(recv_pc_if_id_out), .d(recv_pc_if_id_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable pred_result  [3:0]    ( .q(pred_result_if_id_out), .d(pred_result_if_id_in), .wrt_en(enable), .clk(clk), .rst_n(
rst_n));


endmodule
    
