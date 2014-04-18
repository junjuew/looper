//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 05/04/2014
// Design Name: pipeline register ID_AL stage
// Module Name: ID_AL
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: This is a general pipeline registers in ID_AL stage
//
// Revision 1.0 - initial version
// Additional Comments: 
//                      stall signal need to be reconsidered
//////////////////////////////////////////////////////////////////////////////////
module ID_AL (
    input clk, 
    input rst_n,

    
    input  [65:0]          inst0_id_al_in,       
    input  [65:0]          inst1_id_al_in,      
    input  [65:0]          inst2_id_al_in,        
    input  [65:0]          inst3_id_al_in,  
    input  [1:0]           lbd_state_id_al_in,
    input                  fnsh_unrll_id_al_in,
    input                  loop_strt_id_al_in,
    input                  stall,

    output  [65:0]          inst0_id_al_out,    
    output  [65:0]          inst1_id_al_out,           
    output  [65:0]          inst2_id_al_out,    
    output  [65:0]          inst3_id_al_out,   
    output  [1:0]           lbd_state_id_al_out,
    output                  fnsh_unrll_id_al_out,
    output                  loop_strt_id_al_out
);
    
    wire enable;   // ~stall

   assign enable = ~stall;
   
    //data
    rf_enable inst0        [65:0]    ( .q(inst0_id_al_out), .d(inst0_id_al_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable inst1        [65:0]    ( .q(inst1_id_al_out), .d(inst1_id_al_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable inst2        [65:0]    ( .q(inst2_id_al_out), .d(inst2_id_al_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable inst3        [65:0]    ( .q(inst3_id_al_out), .d(inst3_id_al_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable lbd_state    [1:0]     ( .q(lbd_state_id_al_out), .d(lbd_state_id_al_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable fnsh_unrll             ( .q(fnsh_unrll_id_al_out), .d(fnsh_unrll_id_al_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable lloop_strt             ( .q(loop_strt_id_al_out), .d(loop_strt_id_al_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));


endmodule
    
