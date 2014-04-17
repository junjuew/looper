module test_RF_WB_tb();
	reg         clk,rst_n;
	reg [5:0]   read_mult_op1_pnum;
	reg [5:0]   read_mult_op2_pnum;
	reg         reg_wrt_mul_rf_ex_in;



    wire        mult_valid_wb_ex_wb_out;
    wire        mult_free_ex_wb_out;
	
	test_RF_WB DUT121(
	.clk(clk), 
    .rst_n(rst_n),   
    // read section
    .read_mult_op1_pnum(read_mult_op1_pnum),
    .read_mult_op2_pnum(read_mult_op2_pnum),
    .read_alu1_op1_pnum(),
    .read_alu1_op2_pnum(), 
    .read_alu2_op1_pnum(), 
    .read_alu2_op2_pnum(), 
    .read_addr_bas_pnum(), 
    .read_addr_reg_pnum(), 
    .brn(), // detecting !(2'b00) => branch instruction


    .alu1_imm_rf_ex_in(), //
    .alu2_imm_rf_ex_in(), //
    .mult_imm_rf_ex_in(), //
    .addr_imm_rf_ex_in(), //
    .alu1_imm_vld_rf_ex_in(), //
    .alu2_imm_vld_rf_ex_in(), //
    .mult_imm_vld_rf_ex_in(), //
    .addr_imm_vld_rf_ex_in(), //

    .alu1_inst_vld_rf_ex_in(), //
    .alu2_inst_vld_rf_ex_in(), //
    .mult_inst_vld_rf_ex_in(1'b1), //
    .addr_inst_vld_rf_ex_in(), //

    .alu1_mem_wrt_rf_ex_in(), //
    .alu2_mem_wrt_rf_ex_in(), //
    .mult_mem_wrt_rf_ex_in(1'b0), //
    .addr_mem_wrt_rf_ex_in(), //

    .alu1_mem_rd_rf_ex_in(), //
    .alu2_mem_rd_rf_ex_in(), //
    .mult_mem_rd_rf_ex_in(1'b0), //
    .addr_mem_rd_rf_ex_in(), //

    .alu1_ldi_rf_ex_in(), // 
    .alu2_ldi_rf_ex_in(), //
    .mult_ldi_rf_ex_in(), // 
    .addr_ldi_rf_ex_in(), // 

    .alu1_mode_rf_ex_in(),
    .alu2_mode_rf_ex_in(),

    .alu1_done_idx_rf_ex_in(), // 
    .alu2_done_idx_rf_ex_in(), // 
    .mult_done_idx_rf_ex_in(), //
    .addr_done_idx_rf_ex_in(), //

    .phy_addr_alu1_rf_ex_in(), //
    .phy_addr_alu2_rf_ex_in(), //
    .phy_addr_mult_rf_ex_in(6'd10), //
    .phy_addr_ld_rf_ex_in(), //

    .reg_wrt_mul_rf_ex_in(1'b1), //
    .reg_wrt_alu1_rf_ex_in(), //
    .reg_wrt_alu2_rf_ex_in(), //
    .reg_wrt_ld_rf_ex_in(), //

    .alu1_invtRt_rf_ex_in(), //
    .alu2_invtRt_rf_ex_in(), //
    .mult_invtRt_rf_ex_in(1'b0), //
    .addr_invtRt_rf_ex_in(), //


    //output [15:0]          alu1_out_ex_wb_out,
    //output [15:0]          alu2_out_ex_wb_out,
    //output [15:0]          mult_out_ex_wb_out,
    //output [15:0]          addr_out_ex_wb_out,
    .data_str_ex_wb_out(), 

    //output                 reg_wrt_mul_ex_wb_out,
    //output                 reg_wrt_alu1_ex_wb_out,
    //output                 reg_wrt_alu2_ex_wb_out,
    //output                 reg_wrt_ld_ex_wb_out,

    .mult_valid_wb_ex_wb_out(mult_valid_wb_ex_wb_out),
    .mult_free_ex_wb_out(mult_free_ex_wb_out),

    .alu1_mem_wrt_ex_wb_out(), //
    .alu2_mem_wrt_ex_wb_out(), //
    .mult_mem_wrt_ex_wb_out(), //
    .addr_mem_wrt_ex_wb_out(), //

    .alu1_mem_rd_ex_wb_out(), //
    .alu2_mem_rd_ex_wb_out(), //
    .mult_mem_rd_ex_wb_out(), //
    .addr_mem_rd_ex_wb_out(), //

    .alu1_done_vld_ex_wb_out(),
    .alu2_done_vld_ex_wb_out(),
    .mult_done_vld_ex_wb_out(),
    .addr_done_vld_ex_wb_out(),
 
    .alu1_done_idx_ex_wb_out(),
    .alu2_done_idx_ex_wb_out(),
    .mult_done_idx_ex_wb_out(),
    .addr_done_idx_ex_wb_out()
 
    //output [5:0]           phy_addr_alu1_ex_wb_out,
    //output [5:0]           phy_addr_alu2_ex_wb_out,
    //output [5:0]           phy_addr_mult_ex_wb_out,
    //output [5:0]           phy_addr_ld_ex_wb_out
);

initial begin
DUT121.RF.reg_file_body[5'd12] <= 16'd10 ;
DUT121.RF.reg_file_body[5'd13] <= 16'd10 ;
#2 
DUT121.RF.reg_file_body[5'd12] <= 16'd11 ;
DUT121.RF.reg_file_body[5'd13] <= 16'd11 ;
end

initial begin
$monitor("reg10: %d", DUT121.RF.reg_file_body[5'd10]);
    clk=0;
    forever begin
        #1 clk= ~clk;
   end
end


endmodule