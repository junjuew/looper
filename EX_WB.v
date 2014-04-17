//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 05/04/2014
// Design Name: pipeline register EX_WB stage
// Module Name: EX_WB
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: This is a general pipeline registers in X_WB stage
//
// Revision 1.0 - initial version
// Additional Comments: vaild signal for alu1 alu2 and addr_adder could be enable
//                      situations such as ldst queue full needed to be considered
//////////////////////////////////////////////////////////////////////////////////
module EX_WB (
    input 	  clk, 
    input 	  rst_n,
    input 	  stall,
    input [15:0]  mult_out_ex_wb_in,
    input [15:0]  alu1_out_ex_wb_in, 
    input [15:0]  alu2_out_ex_wb_in,
    input [15:0]  addr_out_ex_wb_in,
    input [15:0]  data_str_ex_wb_in,

    input 	  mult_valid_wb_ex_wb_in, //for WB stage
    input 	  mult_free_ex_wb_in, //for issue stage

    input 	  alu1_mem_wrt_ex_wb_in, //
    input 	  alu2_mem_wrt_ex_wb_in, //
    input 	  mult_mem_wrt_ex_wb_in, //
    input 	  addr_mem_wrt_ex_wb_in, //

    input 	  alu1_mem_rd_ex_wb_in, //
    input 	  alu2_mem_rd_ex_wb_in, //
    input 	  mult_mem_rd_ex_wb_in, //
    input 	  addr_mem_rd_ex_wb_in, //

    input 	  alu1_done_vld_ex_wb_in,
    input 	  alu2_done_vld_ex_wb_in,
    input 	  mult_done_vld_ex_wb_in,
    input 	  addr_done_vld_ex_wb_in,
 
    input [5:0]   alu1_done_idx_ex_wb_in,
    input [5:0]   alu2_done_idx_ex_wb_in,
    input [5:0]   mult_done_idx_ex_wb_in,
    input [5:0]   addr_done_idx_ex_wb_in,


    input [5:0]   phy_addr_alu1_ex_wb_in,
    input [5:0]   phy_addr_alu2_ex_wb_in,
    input [5:0]   phy_addr_mult_ex_wb_in,
    input [5:0]   phy_addr_ld_ex_wb_in,

    input 	  reg_wrt_mul_ex_wb_in,
    input 	  reg_wrt_alu1_ex_wb_in,
    input 	  reg_wrt_alu2_ex_wb_in,
    input 	  reg_wrt_ld_ex_wb_in,

    output [15:0] alu1_out_ex_wb_out,
    output [15:0] alu2_out_ex_wb_out,
    output [15:0] mult_out_ex_wb_out,
    output [15:0] addr_out_ex_wb_out,
    output [15:0] data_str_ex_wb_out, 

    output 	  reg_wrt_mul_ex_wb_out,
    output 	  reg_wrt_alu1_ex_wb_out,
    output 	  reg_wrt_alu2_ex_wb_out,
    output 	  reg_wrt_ld_ex_wb_out,

    output 	  mult_valid_wb_ex_wb_out,
    output 	  mult_free_ex_wb_out,

    output 	  alu1_mem_wrt_ex_wb_out, //
    output 	  alu2_mem_wrt_ex_wb_out, //
    output 	  mult_mem_wrt_ex_wb_out, //
    output 	  addr_mem_wrt_ex_wb_out, //

    output 	  alu1_mem_rd_ex_wb_out, //
    output 	  alu2_mem_rd_ex_wb_out, //
    output 	  mult_mem_rd_ex_wb_out, //
    output 	  addr_mem_rd_ex_wb_out, //

    output 	  alu1_done_vld_ex_wb_out,
    output 	  alu2_done_vld_ex_wb_out,
    output 	  mult_done_vld_ex_wb_out,
    output 	  addr_done_vld_ex_wb_out,
 
    output [5:0]  alu1_done_idx_ex_wb_out,
    output [5:0]  alu2_done_idx_ex_wb_out,
    output [5:0]  mult_done_idx_ex_wb_out,
    output [5:0]  addr_done_idx_ex_wb_out,

    output [5:0]  phy_addr_alu1_ex_wb_out,
    output [5:0]  phy_addr_alu2_ex_wb_out,
    output [5:0]  phy_addr_mult_ex_wb_out,
    output [5:0]  phy_addr_ld_ex_wb_out
);
    
    wire enable;   // ~stall
    wire mult_rf_en;

    assign mult_rf_en = enable & mult_valid_wb_ex_wb_in;

    //data
    rf_enable mult     [15:0]    ( .q(mult_out_ex_wb_out), .d(mult_out_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable alu1     [15:0]    ( .q(alu1_out_ex_wb_out), .d(alu1_out_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable alu2     [15:0]    ( .q(alu2_out_ex_wb_out), .d(alu2_out_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable addr     [15:0]    ( .q(addr_out_ex_wb_out), .d(addr_out_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable str_data [15:0]    ( .q(data_str_ex_wb_out), .d(data_str_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));

    //reg_write
    rf_enable reg_wrt_alu1       ( .q(reg_wrt_alu1_ex_wb_out), .d(reg_wrt_alu1_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable reg_wrt_alu2       ( .q(reg_wrt_alu2_ex_wb_out), .d(reg_wrt_alu2_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable reg_wrt_mult       ( .q(reg_wrt_mul_ex_wb_out), .d(reg_wrt_mul_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable reg_wrt_ld         ( .q(reg_wrt_ld_ex_wb_out), .d(reg_wrt_ld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));


    //mem write
    rf_enable alu1_mem_wrt           ( .q(alu1_mem_wrt_ex_wb_out), .d(alu1_mem_wrt_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable alu2_mem_wrt           ( .q(alu2_mem_wrt_ex_wb_out), .d(alu2_mem_wrt_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable mult_mem_wrt           ( .q(mult_mem_wrt_ex_wb_out), .d(mult_mem_wrt_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable addr_mem_wrt           ( .q(addr_mem_wrt_ex_wb_out), .d(addr_mem_wrt_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));

    //mem read
    rf_enable alu1_mem_rd            ( .q(alu1_mem_rd_ex_wb_out), .d(alu1_mem_rd_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable alu2_mem_rd            ( .q(alu2_mem_rd_ex_wb_out), .d(alu2_mem_rd_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable mult_mem_rd            ( .q(mult_mem_rd_ex_wb_out), .d(mult_mem_rd_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable addr_mem_rd            ( .q(addr_mem_rd_ex_wb_out), .d(addr_mem_rd_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));

    //multiplier vaild signal 
    rf_enable free_wb            ( .q(mult_valid_wb_ex_wb_out), .d(mult_valid_wb_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable free_is            ( .q(mult_free_ex_wb_out), .d(mult_free_ex_wb_in), .wrt_en(mult_rf_en), .clk(clk), .rst(rst_n));

    rf_enable alu1_done_vld      ( .q(alu1_done_vld_ex_wb_out), .d(alu1_done_vld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable alu2_done_vld      ( .q(alu2_done_vld_ex_wb_out), .d(alu2_done_vld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable mult_done_vld      ( .q(mult_done_vld_ex_wb_out), .d(mult_done_vld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable addr_done_vld      ( .q(mult_done_vld_ex_wb_out), .d(mult_done_vld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable alu1_done_idx[5:0] ( .q(alu1_done_idx_ex_wb_out), .d(alu1_done_idx_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable alu2_done_idx[5:0] ( .q(alu2_done_idx_ex_wb_out), .d(alu2_done_idx_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable mult_done_idx[5:0] ( .q(mult_done_vld_ex_wb_out), .d(mult_done_vld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable addr_done_idx[5:0] ( .q(mult_done_vld_ex_wb_out), .d(mult_done_vld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));

    //phy_addr
    rf_enable phy_addr_alu1 [5:0]( .q(phy_addr_alu1_ex_wb_out), .d(phy_addr_alu1_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable phy_addr_alu2 [5:0]( .q(phy_addr_alu2_ex_wb_out), .d(phy_addr_alu2_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable phy_addr_mult [5:0]( .q(phy_addr_mult_ex_wb_out), .d(phy_addr_mult_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));
    rf_enable phy_addr_ld   [5:0]( .q(phy_addr_ld_ex_wb_out), .d(phy_addr_ld_ex_wb_in), .wrt_en(enable), .clk(clk), .rst(rst_n));

endmodule
    
