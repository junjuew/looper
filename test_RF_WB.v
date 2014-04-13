module test_RF_WB(
    input clk, 
    input rst_n,


    
    // read section
    input [5:0]            read_mult_op1_pnum,
    input [5:0]            read_mult_op2_pnum,
    input [5:0]            read_alu1_op1_pnum,
    input [5:0]            read_alu1_op2_pnum, 
    input [5:0]            read_alu2_op1_pnum, 
    input [5:0]            read_alu2_op2_pnum, 
    input [5:0]            read_addr_bas_pnum, 
    input [5:0]            read_addr_reg_pnum, 
    input [1:0]            brn, // detecting !(2'b00) => branch instruction


    input  [15:0]          alu1_imm_rf_ex_in, //
    input  [15:0]          alu2_imm_rf_ex_in, //
    input  [15:0]          mult_imm_rf_ex_in, //
    input  [15:0]          addr_imm_rf_ex_in, //
    input                  alu1_imm_vld_rf_ex_in, //
    input                  alu2_imm_vld_rf_ex_in, //
    input                  mult_imm_vld_rf_ex_in, //
    input                  addr_imm_vld_rf_ex_in, //

    input                  alu1_inst_vld_rf_ex_in, //
    input                  alu2_inst_vld_rf_ex_in, //
    input                  mult_inst_vld_rf_ex_in, //
    input                  addr_inst_vld_rf_ex_in, //

    input                  alu1_mem_wrt_rf_ex_in, //
    input                  alu2_mem_wrt_rf_ex_in, //
    input                  mult_mem_wrt_rf_ex_in, //
    input                  addr_mem_wrt_rf_ex_in, //

    input                  alu1_mem_rd_rf_ex_in, //
    input                  alu2_mem_rd_rf_ex_in, //
    input                  mult_mem_rd_rf_ex_in, //
    input                  addr_mem_rd_rf_ex_in, //

    input                  alu1_ldi_rf_ex_in, // 
    input                  alu2_ldi_rf_ex_in, //
    input                  mult_ldi_rf_ex_in, // 
    input                  addr_ldi_rf_ex_in, // 

    input  [2:0]           alu1_mode_rf_ex_in,
    input  [2:0]           alu2_mode_rf_ex_in,

    input  [5:0]           alu1_done_idx_rf_ex_in, // 
    input  [5:0]           alu2_done_idx_rf_ex_in, // 
    input  [5:0]           mult_done_idx_rf_ex_in, //
    input  [5:0]           addr_done_idx_rf_ex_in, //

    input  [5:0]           phy_addr_alu1_rf_ex_in, //
    input  [5:0]           phy_addr_alu2_rf_ex_in, //
    input  [5:0]           phy_addr_mult_rf_ex_in, //
    input  [5:0]           phy_addr_ld_rf_ex_in, //

    input                  reg_wrt_mul_rf_ex_in, //
    input                  reg_wrt_alu1_rf_ex_in, //
    input                  reg_wrt_alu2_rf_ex_in, //
    input                  reg_wrt_ld_rf_ex_in, //

    input                  alu1_invtRt_rf_ex_in, //
    input                  alu2_invtRt_rf_ex_in, //
    input                  mult_invtRt_rf_ex_in, //
    input                  addr_invtRt_rf_ex_in, //


    //output [15:0]          alu1_out_ex_wb_out,
    //output [15:0]          alu2_out_ex_wb_out,
    //output [15:0]          mult_out_ex_wb_out,
    //output [15:0]          addr_out_ex_wb_out,
    output [15:0]          data_str_ex_wb_out, 

    //output                 reg_wrt_mul_ex_wb_out,
    //output                 reg_wrt_alu1_ex_wb_out,
    //output                 reg_wrt_alu2_ex_wb_out,
    //output                 reg_wrt_ld_ex_wb_out,

    output                 mult_valid_wb_ex_wb_out,
    output                 mult_free_ex_wb_out,

    output                 alu1_mem_wrt_ex_wb_out, //
    output                 alu2_mem_wrt_ex_wb_out, //
    output                 mult_mem_wrt_ex_wb_out, //
    output                 addr_mem_wrt_ex_wb_out, //

    output                 alu1_mem_rd_ex_wb_out, //
    output                 alu2_mem_rd_ex_wb_out, //
    output                 mult_mem_rd_ex_wb_out, //
    output                 addr_mem_rd_ex_wb_out, //

    output                 alu1_done_vld_ex_wb_out,
    output                 alu2_done_vld_ex_wb_out,
    output                 mult_done_vld_ex_wb_out,
    output                 addr_done_vld_ex_wb_out,
 
    output [5:0]           alu1_done_idx_ex_wb_out,
    output [5:0]           alu2_done_idx_ex_wb_out,
    output [5:0]           mult_done_idx_ex_wb_out,
    output [5:0]           addr_done_idx_ex_wb_out
 
    //output [5:0]           phy_addr_alu1_ex_wb_out,
    //output [5:0]           phy_addr_alu2_ex_wb_out,
    //output [5:0]           phy_addr_mult_ex_wb_out,
    //output [5:0]           phy_addr_ld_ex_wb_out
);
    //reg_file
    wire   [15:0]          mult_op1_data_rf_out;
    wire   [15:0]          mult_op2_data_rf_out;
    wire   [15:0]          alu1_op1_data_rf_out;
    wire   [15:0]          alu1_op2_data_rf_out;
    wire   [15:0]          alu2_op1_data_rf_out;
    wire   [15:0]          alu2_op2_data_rf_out;
    wire   [15:0]          addr_op1_data_rf_out;
    wire   [15:0]          addr_op2_data_rf_out;
    wire   [15:0]          data_str_rf_out;
    //rf_ex
    wire   [15:0]          mult_op1_data_rf_ex_out;
    wire   [15:0]          mult_op2_data_rf_ex_out;
    wire   [15:0]          alu1_op1_data_rf_ex_out;
    wire   [15:0]          alu1_op2_data_rf_ex_out;
    wire   [15:0]          alu2_op1_data_rf_ex_out;
    wire   [15:0]          alu2_op2_data_rf_ex_out;
    wire   [15:0]          addr_op1_data_rf_ex_out;
    wire   [15:0]          data_str_rf_ex_out;

    wire   [15:0]          alu1_imm_rf_ex_out;
    wire   [15:0]          alu2_imm_rf_ex_out;
    wire   [15:0]          mult_imm_rf_ex_out;
    wire   [15:0]          addr_imm_rf_ex_out;
    wire                   alu1_imm_vld_rf_ex_out;
    wire                   alu2_imm_vld_rf_ex_out;
    wire                   mult_imm_vld_rf_ex_out;
    wire                   addr_imm_vld_rf_ex_out;

    wire                   alu1_inst_vld_rf_ex_out;
    wire                   alu2_inst_vld_rf_ex_out;
    wire                   mult_inst_vld_rf_ex_out;
    wire                   addr_inst_vld_rf_ex_out;

    wire                   alu1_mem_wrt_rf_ex_out;
    wire                   alu2_mem_wrt_rf_ex_out;
    wire                   mult_mem_wrt_rf_ex_out;
    wire                   addr_mem_wrt_rf_ex_out;

    wire                   alu1_mem_rd_rf_ex_out;
    wire                   alu2_mem_rd_rf_ex_out;
    wire                   mult_mem_rd_rf_ex_out;
    wire                   addr_mem_rd_rf_ex_out;

    wire                   alu1_en_rf_ex_out;
    wire                   alu2_en_rf_ex_out;
    wire                   mult_en_rf_ex_out; 
    wire                   addr_en_rf_ex_out;

    wire                   alu1_ldi_rf_ex_out;
    wire                   alu2_ldi_rf_ex_out;
    wire                   mult_ldi_rf_ex_out;
    wire                   addr_ldi_rf_ex_out;

    wire   [2:0]           alu1_mode_rf_ex_out;
    wire   [2:0]           alu2_mode_rf_ex_out;

    wire   [5:0]           alu1_done_idx_rf_ex_out;
    wire   [5:0]           alu2_done_idx_rf_ex_out;
    wire   [5:0]           mult_done_idx_rf_ex_out;
    wire   [5:0]           addr_done_idx_rf_ex_out;
   // wire   [1:0]           brn_cmp_rslt_rf_out;

    wire   [5:0]           phy_addr_alu1_rf_ex_out;
    wire   [5:0]           phy_addr_alu2_rf_ex_out;
    wire   [5:0]           phy_addr_mult_rf_ex_out;
    wire   [5:0]           phy_addr_ld_rf_ex_out;


    wire                   reg_wrt_mul_rf_ex_out;
    wire                   reg_wrt_alu1_rf_ex_out;
    wire                   reg_wrt_alu2_rf_ex_out;
    wire                   reg_wrt_ld_rf_ex_out;

    wire                   alu1_invtRt_rf_ex_out; //
    wire                   alu2_invtRt_rf_ex_out; //
    wire                   mult_invtRt_rf_ex_out; //
    wire                   addr_invtRt_rf_ex_out; //


    // ex
    wire [15:0]            alu1_data_ex_out;
    wire [15:0]            alu2_data_ex_out;
    wire [15:0]            mult_data_ex_out;
    wire [15:0]            addr_data_ex_out;

    wire                   mult_valid_ex_out;
    wire                   mult_free_ex_is_out;

    // ex_wb   



    wire [5:0]             wrt_mult_dst_pnum;
    wire [15:0]            wrt_mult_data;
    wire                   reg_wrt_alu1_wb_rf;
    wire [5:0]             wrt_alu1_dst_pnum;
    wire [15:0]            wrt_alu1_data;
    wire                   reg_wrt_alu2_wb_rf; 
    wire [5:0]             wrt_alu2_dst_pnum;
    wire [15:0]            wrt_alu2_data;
    wire                   reg_wrt_addr_wb_rf;
    wire [5:0]             wrt_addr_dst_pnum;
    wire [15:0]            wrt_addr_data;

	reg_file RF ( 
		.clk(clk),
		.rst_n(rst_n),
    	.read_mult_op1_pnum(read_mult_op1_pnum),
   		.read_mult_op2_pnum(read_mult_op2_pnum),
 		.read_alu1_op1_pnum(read_alu1_op1_pnum),
   		.read_alu1_op2_pnum(read_alu1_op2_pnum), 
  		.read_alu2_op1_pnum(read_alu2_op1_pnum), 
		.read_alu2_op2_pnum(read_alu1_op2_pnum), 
  		.read_addr_bas_pnum(read_addr_bas_pnum), 
 		.read_addr_reg_pnum(read_addr_reg_pnum), 
		.brn(brn), // detecting !(2'b00) => branch instruction
		//output
		.read_mult_op1_data(mult_op1_data_rf_out),
		.read_mult_op2_data(mult_op2_data_rf_out),
		.read_alu1_op1_data(alu1_op1_data_rf_out),
		.read_alu1_op2_data(alu1_op2_data_rf_out), 
		.read_alu2_op1_data(alu2_op1_data_rf_out), 
		.read_alu2_op2_data(alu2_op2_data_rf_out), 
		.read_addr_bas_data(addr_op1_data_rf_out), 
		.read_addr_reg_data(data_str_rf_out), 
 		.brn_cmp_rslt(), // tell ROB the real brn result

    // write section input
		.wrt_mult_vld(reg_wrt_mul_wb_rf),
		.wrt_mult_dst_pnum(wrt_mult_dst_pnum),
 		.wrt_mult_data(wrt_mult_data),
		.wrt_alu1_vld(reg_wrt_alu1_wb_rf),
		.wrt_alu1_dst_pnum(wrt_alu1_dst_pnum),
		.wrt_alu1_data(wrt_alu1_data),
		.wrt_alu2_vld(reg_wrt_alu2_wb_rf), 
		.wrt_alu2_dst_pnum(wrt_alu2_dst_pnum),
		.wrt_alu2_data(wrt_alu2_data),
		.wrt_addr_vld(reg_wrt_addr_wb_rf),
		.wrt_addr_dst_pnum(wrt_addr_dst_pnum),
		.wrt_addr_data(wrt_addr_data)
	);
	RF_EX rf_ex (
        .clk(clk), 
        .rst_n(rst_n),
    
        .alu1_op1_rf_ex_in(alu1_op1_data_rf_out), //
        .alu1_op2_rf_ex_in(alu1_op2_data_rf_out), //
        .alu2_op1_rf_ex_in(alu2_op1_data_rf_out), //
        .alu2_op2_rf_ex_in(alu2_op2_data_rf_out), //
        .mult_op1_rf_ex_in(mult_op1_data_rf_out), //
        .mult_op2_rf_ex_in(mult_op2_data_rf_out), //
        .addr_op1_rf_ex_in(addr_op1_data_rf_out), //
        .data_str_rf_ex_in(data_str_rf_out), //

        .alu1_imm_rf_ex_in(alu1_imm_rf_ex_in), //
        .alu2_imm_rf_ex_in(alu2_imm_rf_ex_in), //
        .mult_imm_rf_ex_in(mult_imm_rf_ex_in), //
        .addr_imm_rf_ex_in(addr_imm_rf_ex_in), //
        .alu1_imm_vld_rf_ex_in(alu1_imm_vld_rf_ex_in), //
        .alu2_imm_vld_rf_ex_in(alu2_imm_vld_rf_ex_in), //
        .mult_imm_vld_rf_ex_in(mult_imm_vld_rf_ex_in), //
        .addr_imm_vld_rf_ex_in(addr_imm_vld_rf_ex_in), //

        .alu1_inst_vld_rf_ex_in(alu1_inst_vld_rf_ex_in), //
        .alu2_inst_vld_rf_ex_in(alu2_inst_vld_rf_ex_in), //
        .mult_inst_vld_rf_ex_in(mult_inst_vld_rf_ex_in), //
        .addr_inst_vld_rf_ex_in(addr_inst_vld_rf_ex_in), //

        .alu1_mem_wrt_rf_ex_in(alu1_mem_wrt_rf_ex_in), //
        .alu2_mem_wrt_rf_ex_in(alu2_mem_wrt_rf_ex_in), //
        .mult_mem_wrt_rf_ex_in(mult_mem_wrt_rf_ex_in), //
        .addr_mem_wrt_rf_ex_in(addr_mem_wrt_rf_ex_in), //

        .alu1_mem_rd_rf_ex_in(alu1_mem_rd_rf_ex_in), //
        .alu2_mem_rd_rf_ex_in(alu2_mem_rd_rf_ex_in), //
        .mult_mem_rd_rf_ex_in(mult_mem_rd_rf_ex_in), //
        .addr_mem_rd_rf_ex_in(addr_mem_rd_rf_ex_in), //

        .alu1_ldi_rf_ex_in(alu1_ldi_rf_ex_in), // 
        .alu2_ldi_rf_ex_in(alu2_ldi_rf_ex_in), //
        .mult_ldi_rf_ex_in(mult_ldi_rf_ex_in), // 
        .addr_ldi_rf_ex_in(addr_ldi_rf_ex_in), // 

        .alu1_mode_rf_ex_in(alu1_mode_rf_ex_in),
        .alu2_mode_rf_ex_in(alu2_mode_rf_ex_in),

        .alu1_done_idx_rf_ex_in(alu1_done_idx_rf_ex_in), // 
        .alu2_done_idx_rf_ex_in(alu2_done_idx_rf_ex_in), // 
        .mult_done_idx_rf_ex_in(mult_done_idx_rf_ex_in), //
        .addr_done_idx_rf_ex_in(addr_done_idx_rf_ex_in), //

        .phy_addr_alu1_rf_ex_in(phy_addr_alu1_rf_ex_in), //
        .phy_addr_alu2_rf_ex_in(phy_addr_alu2_rf_ex_in), //
        .phy_addr_mult_rf_ex_in(phy_addr_mult_rf_ex_in), //
        .phy_addr_ld_rf_ex_in(phy_addr_ld_rf_ex_in), //

        .reg_wrt_mul_rf_ex_in(reg_wrt_mul_rf_ex_in), //
        .reg_wrt_alu1_rf_ex_in(reg_wrt_alu1_rf_ex_in), //
        .reg_wrt_alu2_rf_ex_in(reg_wrt_alu2_rf_ex_in), //
        .reg_wrt_ld_rf_ex_in(reg_wrt_ld_rf_ex_in), //

        .alu1_invtRt_rf_ex_in(alu1_invtRt_rf_ex_in), //
        .alu2_invtRt_rf_ex_in(alu2_invtRt_rf_ex_in), //
        .mult_invtRt_rf_ex_in(mult_invtRt_rf_ex_in), //
        .addr_invtRt_rf_ex_in(addr_invtRt_rf_ex_in), //



        .alu1_op1_rf_ex_out(alu1_op1_data_rf_ex_out),
        .alu1_op2_rf_ex_out(alu1_op2_data_rf_ex_out),
        .alu2_op1_rf_ex_out(alu2_op1_data_rf_ex_out),
        .alu2_op2_rf_ex_out(alu2_op2_data_rf_ex_out),
        .mult_op1_rf_ex_out(mult_op1_data_rf_ex_out),
        .mult_op2_rf_ex_out(mult_op2_data_rf_ex_out),
        .addr_op1_rf_ex_out(addr_op1_data_rf_ex_out),
        .data_str_rf_ex_out(data_str_rf_ex_out),

        .alu1_imm_rf_ex_out(alu1_imm_rf_ex_out),
        .alu2_imm_rf_ex_out(alu2_imm_rf_ex_out),
        .mult_imm_rf_ex_out(mult_imm_rf_ex_out),
        .addr_imm_rf_ex_out(addr_imm_rf_ex_out),
        .alu1_imm_vld_rf_ex_out(alu1_imm_vld_rf_ex_out),
        .alu2_imm_vld_rf_ex_out(alu2_imm_vld_rf_ex_out),
        .mult_imm_vld_rf_ex_out(mult_imm_vld_rf_ex_out),
        .addr_imm_vld_rf_ex_out(addr_imm_vld_rf_ex_out),

        .alu1_inst_vld_rf_ex_out(alu1_inst_vld_rf_ex_out), //
        .alu2_inst_vld_rf_ex_out(alu2_inst_vld_rf_ex_out), //
        .mult_inst_vld_rf_ex_out(mult_inst_vld_rf_ex_out), //
        .addr_inst_vld_rf_ex_out(addr_inst_vld_rf_ex_out), //

        .alu1_mem_wrt_rf_ex_out(alu1_mem_wrt_rf_ex_out), //
        .alu2_mem_wrt_rf_ex_out(alu2_mem_wrt_rf_ex_out), //
        .mult_mem_wrt_rf_ex_out(mult_mem_wrt_rf_ex_out), //
        .addr_mem_wrt_rf_ex_out(addr_mem_wrt_rf_ex_out), //

        .alu1_mem_rd_rf_ex_out(alu1_mem_rd_rf_ex_out),
        .alu2_mem_rd_rf_ex_out(alu2_mem_rd_rf_ex_out),
        .mult_mem_rd_rf_ex_out(mult_mem_rd_rf_ex_out),
        .addr_mem_rd_rf_ex_out(addr_mem_rd_rf_ex_out),

        .alu1_en_rf_ex_out(alu1_en_rf_ex_out),
        .alu2_en_rf_ex_out(alu2_en_rf_ex_out),
        .mult_en_rf_ex_out(mult_en_rf_ex_out), 
        .addr_en_rf_ex_out(addr_en_rf_ex_out),

        .alu1_ldi_rf_ex_out(alu1_ldi_rf_ex_out), 
        .alu2_ldi_rf_ex_out(alu2_ldi_rf_ex_out), 
        .mult_ldi_rf_ex_out(mult_ldi_rf_ex_out), 
        .addr_ldi_rf_ex_out(addr_ldi_rf_ex_out), 

        .alu1_mode_rf_ex_out(alu1_mode_rf_ex_out),
        .alu2_mode_rf_ex_out(alu2_mode_rf_ex_out),

        .alu1_done_idx_rf_ex_out(alu1_done_idx_rf_ex_out),
        .alu2_done_idx_rf_ex_out(alu2_done_idx_rf_ex_out),
        .mult_done_idx_rf_ex_out(mult_done_idx_rf_ex_out),
        .addr_done_idx_rf_ex_out(addr_done_idx_rf_ex_out),

        .phy_addr_alu1_rf_ex_out(phy_addr_alu1_rf_ex_out),
        .phy_addr_alu2_rf_ex_out(phy_addr_alu2_rf_ex_out),
        .phy_addr_mult_rf_ex_out(phy_addr_mult_rf_ex_out),
        .phy_addr_ld_rf_ex_out(phy_addr_ld_rf_ex_out),

        .reg_wrt_mul_rf_ex_out(reg_wrt_mul_rf_ex_out),
        .reg_wrt_alu1_rf_ex_out(reg_wrt_alu1_rf_ex_out),
        .reg_wrt_alu2_rf_ex_out(reg_wrt_alu2_rf_ex_out),
        .reg_wrt_ld_rf_ex_out(reg_wrt_ld_rf_ex_out),

        .alu1_invtRt_rf_ex_out(alu1_invtRt_rf_ex_out),
        .alu2_invtRt_rf_ex_out(alu2_invtRt_rf_ex_out),
        .mult_invtRt_rf_ex_out(mult_invtRt_rf_ex_out),
        .addr_invtRt_rf_ex_out(addr_invtRt_rf_ex_out)
    );

	execution ex (
        .mult_op1(mult_op1_data_rf_ex_out), 
        .mult_op2(mult_op2_data_rf_ex_out), 
        .alu1_op1(alu1_op1_data_rf_ex_out), 
        .alu1_op2(alu1_op2_data_rf_ex_out), 
        .alu2_op1(alu2_op1_data_rf_ex_out), 
        .alu2_op2(alu2_op2_data_rf_ex_out), 
        .addr_op1(addr_op1_data_rf_ex_out), 
        .addr_op2(addr_imm_rf_ex_out),
        .mult_en(mult_en_rf_ex_out), 
        .alu1_en(alu1_en_rf_ex_out), 
        .alu2_en(alu2_en_rf_ex_out), 
        .addr_en(addr_en_rf_ex_out), 
        .clk(clk), 
        .rst(!rst_n),
        .alu1_inv_Rt(alu1_invtRt_rf_ex_out), 
        .alu2_inv_Rt(alu2_invtRt_rf_ex_out), 
        .alu1_ldi(alu1_ldi_rf_ex_out), 
        .alu2_ldi(alu2_ldi_rf_ex_out), 
        .alu1_imm(alu1_imm_rf_ex_out), 
        .alu2_imm(alu2_imm_rf_ex_out),
        .alu1_mode(alu1_mode_rf_ex_out), 
        .alu2_mode(alu2_mode_rf_ex_out), 
        // output
        .mult_out(mult_data_ex_out), 
        .alu1_out(alu1_data_ex_out), 
        .alu2_out(alu2_data_ex_out), 
        .addr_out(addr_data_ex_out), 
        .mult_valid_wb(mult_valid_ex_out), 
        .mult_free(mult_free_ex_is_out)
    );



EX_WB (
    .clk(clk), 
    .rst_n(rst_n),
    
    .mult_out_ex_wb_in(mult_data_ex_out),
    .alu1_out_ex_wb_in(alu1_data_ex_out), 
    .alu2_out_ex_wb_in(alu2_data_ex_out),
    .addr_out_ex_wb_in(addr_data_ex_out),
    .data_str_ex_wb_in(data_str_rf_ex_out),

    .mult_valid_wb_ex_wb_in(mult_valid_ex_out),         //for WB stage
    .mult_free_ex_wb_in(mult_free_ex_is_out),             //for issue stage

    .alu1_mem_wrt_ex_wb_in(alu1_mem_wrt_rf_ex_out), //
    .alu2_mem_wrt_ex_wb_in(alu2_mem_wrt_rf_ex_out), //
    .mult_mem_wrt_ex_wb_in(mult_mem_wrt_rf_ex_out), //
    .addr_mem_wrt_ex_wb_in(addr_mem_wrt_rf_ex_out), //

    .alu1_mem_rd_ex_wb_in(alu1_mem_rd_rf_ex_out), //
    .alu2_mem_rd_ex_wb_in(alu2_mem_rd_rf_ex_out), //
    .mult_mem_rd_ex_wb_in(mult_mem_rd_rf_ex_out), //
    .addr_mem_rd_ex_wb_in(addr_mem_rd_rf_ex_out), //

    // be careful here
    .alu1_done_vld_ex_wb_in(alu1_en_rf_ex_out),
    .alu2_done_vld_ex_wb_in(alu2_en_rf_ex_out),
    .mult_done_vld_ex_wb_in(mult_valid_ex_out),
    .addr_done_vld_ex_wb_in(addr_en_rf_ex_out),
 
    .alu1_done_idx_ex_wb_in(alu1_done_idx_rf_ex_out),
    .alu2_done_idx_ex_wb_in(alu2_done_idx_rf_ex_out),
    .mult_done_idx_ex_wb_in(mult_done_idx_rf_ex_out),
    .addr_done_idx_ex_wb_in(addr_done_idx_rf_ex_out),


    .phy_addr_alu1_ex_wb_in(phy_addr_alu1_rf_ex_out),
    .phy_addr_alu2_ex_wb_in(phy_addr_alu2_rf_ex_out),
    .phy_addr_mult_ex_wb_in(phy_addr_mult_rf_ex_out),
    .phy_addr_ld_ex_wb_in(phy_addr_ld_rf_ex_out),

    .reg_wrt_mul_ex_wb_in(reg_wrt_mul_rf_ex_out),
    .reg_wrt_alu1_ex_wb_in(reg_wrt_alu1_rf_ex_out),
    .reg_wrt_alu2_ex_wb_in(reg_wrt_alu2_rf_ex_out),
    .reg_wrt_ld_ex_wb_in(reg_wrt_ld_rf_ex_out),

    .alu1_out_ex_wb_out(wrt_alu1_data),
    .alu2_out_ex_wb_out(wrt_alu2_data),
    .mult_out_ex_wb_out(wrt_mult_data),
    .addr_out_ex_wb_out(wrt_addr_data),
    .data_str_ex_wb_out(data_str_ex_wb_out), 

    .reg_wrt_mul_ex_wb_out(reg_wrt_mul_wb_rf),
    .reg_wrt_alu1_ex_wb_out(reg_wrt_alu1_wb_rf),
    .reg_wrt_alu2_ex_wb_out(reg_wrt_alu2_wb_rf),
    .reg_wrt_ld_ex_wb_out(reg_wrt_addr_wb_rf),

    .mult_valid_wb_ex_wb_out(mult_valid_wb_ex_wb_out),
    .mult_free_ex_wb_out(mult_free_ex_wb_out),

    .alu1_mem_wrt_ex_wb_out(alu1_mem_wrt_ex_wb_out), //
    .alu2_mem_wrt_ex_wb_out(alu2_mem_wrt_ex_wb_out), //
    .mult_mem_wrt_ex_wb_out(mult_mem_wrt_ex_wb_out), //
    .addr_mem_wrt_ex_wb_out(addr_mem_wrt_ex_wb_out), //

    .alu1_mem_rd_ex_wb_out(alu1_mem_rd_ex_wb_out), //
    .alu2_mem_rd_ex_wb_out(alu2_mem_rd_ex_wb_out), //
    .mult_mem_rd_ex_wb_out(mult_mem_rd_ex_wb_out), //
    .addr_mem_rd_ex_wb_out(addr_mem_rd_ex_wb_out), //

    .alu1_done_vld_ex_wb_out(alu1_done_vld_ex_wb_out),
    .alu2_done_vld_ex_wb_out(alu2_done_vld_ex_wb_out),
    .mult_done_vld_ex_wb_out(mult_done_vld_ex_wb_out),
    .addr_done_vld_ex_wb_out(addr_done_vld_ex_wb_out),
 
    .alu1_done_idx_ex_wb_out(alu1_done_idx_ex_wb_out),
    .alu2_done_idx_ex_wb_out(alu2_done_idx_ex_wb_out),
    .mult_done_idx_ex_wb_out(mult_done_idx_ex_wb_out),
    .addr_done_idx_ex_wb_out(addr_done_idx_ex_wb_out),

    .phy_addr_alu1_ex_wb_out(wrt_alu1_dst_pnum),
    .phy_addr_alu2_ex_wb_out(wrt_alu2_dst_pnum),
    .phy_addr_mult_ex_wb_out(wrt_mult_dst_pnum),
    .phy_addr_ld_ex_wb_out(wrt_addr_dst_pnum)
);





endmodule