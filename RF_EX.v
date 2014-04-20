//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 05/04/2014
// Design Name: pipeline register RF_EX stage
// Module Name: RF_EX
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: This is a general pipeline registers in RF_EX stage
//
// Revision 1.0 - initial version
// Additional Comments: indeces needed to be add
//                      stall signal need to be reconsidered
//////////////////////////////////////////////////////////////////////////////////
module RF_EX (
    input 	  clk, 
    input 	  rst_n,
    input 	  stall,
    input [15:0]  alu1_op1_rf_ex_in, //
    input [15:0]  alu1_op2_rf_ex_in, //
    input [15:0]  alu2_op1_rf_ex_in, //
    input [15:0]  alu2_op2_rf_ex_in, //
    input [15:0]  mult_op1_rf_ex_in, //
    input [15:0]  mult_op2_rf_ex_in, //
    input [15:0]  addr_op1_rf_ex_in, //
    input [15:0]  data_str_rf_ex_in, //

    input [15:0]  alu1_imm_rf_ex_in, //
    input [15:0]  alu2_imm_rf_ex_in, //
    input [15:0]  mult_imm_rf_ex_in, //
    input [15:0]  addr_imm_rf_ex_in, //
    input 	  alu1_imm_vld_rf_ex_in, //
    input 	  alu2_imm_vld_rf_ex_in, //
    input 	  mult_imm_vld_rf_ex_in, //
    input 	  addr_imm_vld_rf_ex_in, //

    input 	  alu1_inst_vld_rf_ex_in, //
    input 	  alu2_inst_vld_rf_ex_in, //
    input 	  mult_inst_vld_rf_ex_in, //
    input 	  addr_inst_vld_rf_ex_in, //

    input 	  alu1_mem_wrt_rf_ex_in, //
    input 	  alu2_mem_wrt_rf_ex_in, //
    input 	  mult_mem_wrt_rf_ex_in, //
    input 	  addr_mem_wrt_rf_ex_in, //

    input 	  alu1_mem_rd_rf_ex_in, //
    input 	  alu2_mem_rd_rf_ex_in, //
    input 	  mult_mem_rd_rf_ex_in, //
    input 	  addr_mem_rd_rf_ex_in, //

    input 	  alu1_ldi_rf_ex_in, // 
    input 	  alu2_ldi_rf_ex_in, //
    input 	  mult_ldi_rf_ex_in, // 
    input 	  addr_ldi_rf_ex_in, // 

    input [2:0]   alu1_mode_rf_ex_in,
    input [2:0]   alu2_mode_rf_ex_in,

    input [5:0]   alu1_done_idx_rf_ex_in, // 
    input [5:0]   alu2_done_idx_rf_ex_in, // 
    input [5:0]   mult_done_idx_rf_ex_in, //
    input [5:0]   addr_done_idx_rf_ex_in, //

    input [5:0]   phy_addr_alu1_rf_ex_in, //
    input [5:0]   phy_addr_alu2_rf_ex_in, //
    input [5:0]   phy_addr_mult_rf_ex_in, //
    input [5:0]   phy_addr_ld_rf_ex_in, //

    input 	  reg_wrt_mul_rf_ex_in, //
    input 	  reg_wrt_alu1_rf_ex_in, //
    input 	  reg_wrt_alu2_rf_ex_in, //
    input 	  reg_wrt_ld_rf_ex_in, //

    input 	  alu1_invtRt_rf_ex_in, //
    input 	  alu2_invtRt_rf_ex_in, //
    input 	  mult_invtRt_rf_ex_in, //
    input 	  addr_invtRt_rf_ex_in, //

    input 	  alu1_en_rf_ex_in,
    input 	  alu2_en_rf_ex_in,
    input 	  mult_en_rf_ex_in, 
    input 	  addr_en_rf_ex_in,


    output [15:0] alu1_op1_rf_ex_out,
    output [15:0] alu1_op2_rf_ex_out,
    output [15:0] alu2_op1_rf_ex_out,
    output [15:0] alu2_op2_rf_ex_out,
    output [15:0] mult_op1_rf_ex_out,
    output [15:0] mult_op2_rf_ex_out,
    output [15:0] addr_op1_rf_ex_out,
    output [15:0] data_str_rf_ex_out,

    output [15:0] alu1_imm_rf_ex_out,
    output [15:0] alu2_imm_rf_ex_out,
    output [15:0] mult_imm_rf_ex_out,
    output [15:0] addr_imm_rf_ex_out,
    output 	  alu1_imm_vld_rf_ex_out,
    output 	  alu2_imm_vld_rf_ex_out,
    output 	  mult_imm_vld_rf_ex_out,
    output 	  addr_imm_vld_rf_ex_out,

    output 	  alu1_inst_vld_rf_ex_out, //
    output 	  alu2_inst_vld_rf_ex_out, //
    output 	  mult_inst_vld_rf_ex_out, //
    output 	  addr_inst_vld_rf_ex_out, //

    output 	  alu1_mem_wrt_rf_ex_out, //
    output 	  alu2_mem_wrt_rf_ex_out, //
    output 	  mult_mem_wrt_rf_ex_out, //
    output 	  addr_mem_wrt_rf_ex_out, //

    output 	  alu1_mem_rd_rf_ex_out,
    output 	  alu2_mem_rd_rf_ex_out,
    output 	  mult_mem_rd_rf_ex_out,
    output 	  addr_mem_rd_rf_ex_out,

    output 	  alu1_en_rf_ex_out,
    output 	  alu2_en_rf_ex_out,
    output 	  mult_en_rf_ex_out, 
    output 	  addr_en_rf_ex_out,

    output 	  alu1_ldi_rf_ex_out, 
    output 	  alu2_ldi_rf_ex_out, 
    output 	  mult_ldi_rf_ex_out, 
    output 	  addr_ldi_rf_ex_out, 

    output [2:0]  alu1_mode_rf_ex_out,
    output [2:0]  alu2_mode_rf_ex_out,

    output [5:0]  alu1_done_idx_rf_ex_out,
    output [5:0]  alu2_done_idx_rf_ex_out,
    output [5:0]  mult_done_idx_rf_ex_out,
    output [5:0]  addr_done_idx_rf_ex_out,

    output [5:0]  phy_addr_alu1_rf_ex_out,
    output [5:0]  phy_addr_alu2_rf_ex_out,
    output [5:0]  phy_addr_mult_rf_ex_out,
    output [5:0]  phy_addr_ld_rf_ex_out,

    output 	  reg_wrt_mul_rf_ex_out,
    output 	  reg_wrt_alu1_rf_ex_out,
    output 	  reg_wrt_alu2_rf_ex_out,
    output 	  reg_wrt_ld_rf_ex_out,

    output 	  alu1_invtRt_rf_ex_out,
    output 	  alu2_invtRt_rf_ex_out,
    output 	  mult_invtRt_rf_ex_out,
    output 	  addr_invtRt_rf_ex_out

);
    
    wire enable;   // ~stall
   assign enable = ~stall;
   

    //data
    rf_enable alu1_op1     [15:0]    ( .q(alu1_op1_rf_ex_out), .d(alu1_op1_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu1_op2     [15:0]    ( .q(alu1_op2_rf_ex_out), .d(alu1_op2_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_op1     [15:0]    ( .q(alu2_op1_rf_ex_out), .d(alu2_op1_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_op2     [15:0]    ( .q(alu2_op2_rf_ex_out), .d(alu2_op2_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_op1     [15:0]    ( .q(mult_op1_rf_ex_out), .d(mult_op1_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_op2     [15:0]    ( .q(mult_op2_rf_ex_out), .d(mult_op2_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_op1     [15:0]    ( .q(addr_op1_rf_ex_out), .d(addr_op1_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable str_data     [15:0]    ( .q(data_str_rf_ex_out), .d(data_str_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //imm
    rf_enable alu1_imm     [15:0]    ( .q(alu1_imm_rf_ex_out), .d(alu1_imm_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_imm     [15:0]    ( .q(alu2_imm_rf_ex_out), .d(alu2_imm_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_imm     [15:0]    ( .q(mult_imm_rf_ex_out), .d(mult_imm_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_imm     [15:0]    ( .q(addr_imm_rf_ex_out), .d(addr_imm_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //imm valid
    rf_enable alu1_imm_vld           ( .q(alu1_imm_vld_rf_ex_out), .d(alu1_imm_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
   rf_enable alu2_imm_vld           ( .q(alu2_imm_vld_rf_ex_out), .d(alu2_imm_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_imm_vld           ( .q(mult_imm_vld_rf_ex_out), .d(mult_imm_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
   rf_enable addr_imm_vld           ( .q(addr_imm_vld_rf_ex_out), .d(addr_imm_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //instruction valid (function unit enable)
    rf_enable alu1_inst_vld          ( .q(alu1_inst_vld_rf_ex_out), .d(alu1_inst_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_inst_vld          ( .q(alu2_inst_vld_rf_ex_out), .d(alu2_inst_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_inst_vld          ( .q(mult_inst_vld_rf_ex_out), .d(mult_inst_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_inst_vld          ( .q(addr_inst_vld_rf_ex_out), .d(addr_inst_vld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));


    //reg_write
    rf_enable reg_wrt_alu1           ( .q(reg_wrt_alu1_rf_ex_out), .d(reg_wrt_alu1_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable reg_wrt_alu2           ( .q(reg_wrt_alu2_rf_ex_out), .d(reg_wrt_alu2_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable reg_wrt_mult           ( .q(reg_wrt_mul_rf_ex_out), .d(reg_wrt_mul_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable reg_wrt_ld             ( .q(reg_wrt_ld_rf_ex_out), .d(reg_wrt_ld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //mem write
    rf_enable alu1_mem_wrt           ( .q(alu1_mem_wrt_rf_ex_out), .d(alu1_mem_wrt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_mem_wrt           ( .q(alu2_mem_wrt_rf_ex_out), .d(alu2_mem_wrt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_mem_wrt           ( .q(mult_mem_wrt_rf_ex_out), .d(mult_mem_wrt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_mem_wrt           ( .q(addr_mem_wrt_rf_ex_out), .d(addr_mem_wrt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //mem read
    rf_enable alu1_mem_rd            ( .q(alu1_mem_rd_rf_ex_out), .d(alu1_mem_rd_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_mem_rd            ( .q(alu2_mem_rd_rf_ex_out), .d(alu2_mem_rd_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_mem_rd            ( .q(mult_mem_rd_rf_ex_out), .d(mult_mem_rd_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_mem_rd            ( .q(addr_mem_rd_rf_ex_out), .d(addr_mem_rd_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));



    //ldi
    rf_enable alu1_ldi               ( .q(alu1_ldi_rf_ex_out), .d(alu1_ldi_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_ldi               ( .q(alu2_ldi_rf_ex_out), .d(alu2_ldi_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_ldi               ( .q(mult_ldi_rf_ex_out), .d(mult_ldi_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_ldi               ( .q(addr_ldi_rf_ex_out), .d(addr_ldi_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //alu mode
    rf_enable alu1_mode     [2:0]    ( .q(alu1_mode_rf_ex_out), .d(alu1_mode_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_mode     [2:0]    ( .q(alu2_mode_rf_ex_out), .d(alu2_mode_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    //index
    rf_enable alu1_idx      [5:0]    ( .q(alu1_done_idx_rf_ex_out), .d(alu1_done_idx_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_idx      [5:0]    ( .q(alu2_done_idx_rf_ex_out), .d(alu2_done_idx_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_idx      [5:0]    ( .q(mult_done_idx_rf_ex_out), .d(mult_done_idx_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_idx      [5:0]    ( .q(addr_done_idx_rf_ex_out), .d(addr_done_idx_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //phy_addr
    rf_enable phy_addr_alu1 [5:0]    ( .q(phy_addr_alu1_rf_ex_out), .d(phy_addr_alu1_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable phy_addr_alu2 [5:0]    ( .q(phy_addr_alu2_rf_ex_out), .d(phy_addr_alu2_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable phy_addr_mult [5:0]    ( .q(phy_addr_mult_rf_ex_out), .d(phy_addr_mult_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable phy_addr_ld   [5:0]    ( .q(phy_addr_ld_rf_ex_out), .d(phy_addr_ld_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    //invtRt
    rf_enable alu1_invtRt            ( .q(alu1_invtRt_rf_ex_out), .d(alu1_invtRt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_invtRt            ( .q(alu2_invtRt_rf_ex_out), .d(alu2_invtRt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_invtRt            ( .q(mult_invtRt_rf_ex_out), .d(mult_invtRt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_invtRt            ( .q(addr_invtRt_rf_ex_out), .d(addr_invtRt_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

    // FU enable
    rf_enable alu1_en            ( .q(alu1_en_rf_ex_out), .d(alu1_en_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_en            ( .q(alu2_en_rf_ex_out), .d(alu2_en_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable mult_en            ( .q(mult_en_rf_ex_out), .d(mult_en_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_en            ( .q(addr_en_rf_ex_out), .d(addr_en_rf_ex_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));

endmodule
    
