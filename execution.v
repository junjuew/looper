//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:	21/03/2014
// Design Name: execution
// Module Name: execution
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: Top level of execution, also handle 
//
//
// Revision 1.0 - initial version
// Additional Comments: Not finished, some questions remain
//
//////////////////////////////////////////////////////////////////////////////////
module execution (mult_op1, mult_op2, alu1_op1, alu1_op2, alu2_op1, alu2_op2, addr_op1, addr_op2,mult_en, alu1_en, alu2_en, addr_en, clk, rst,
	alu1_inv_Rt, alu2_inv_Rt,
	// output
	alu1_mode, alu2_mode, mult_out, alu1_out, alu2_out, addr_out, mult_valid_wb, mult_free, reg_wrt_mul, );
input  [15:0] mult_op1, mult_op2, alu1_op1, alu1_op2, alu2_op1, alu2_op2, addr_op1, addr_op2;
input         mult_en, alu1_en, alu2_en, addr_en, clk, rst;
input         alu1_inv_Rt, alu2_inv_Rt;
//input  [5:0]  mult_indx, alu1_indx, alu2_indx, ldst_indx;
input  [2:0]  alu1_mode, alu2_mode;
output [15:0] mult_out, alu1_out, alu2_out, addr_out;
output        mult_valid_wb, mult_free, reg_wrt_mul;
// output [5:0]  mult_indx_out, alu1_indx_out, alu2_indx_out, ldst_indx_out;



multiplier mult( .mult_op1(mult_op1), .mult_op2(mult_op2), .mult_out(mult_out), .mult_en(mult_en), .mult_valid_wb(mult_valid_wb), .mult_free(mult_free) ,.clk(clk), .rst(rst));
ALU        alu1( .alu_op1(alu1_op1), .alu_op2(alu1_op2), .alu_mode(alu1_mode), .alu_en(alu1_en), .alu_inv_Rt(alu1_inv_Rt), .alu_out(alu1_out));
ALU        alu2( .alu_op1(alu2_op1), .alu_op2(alu2_op2), .alu_mode(alu2_mode), .alu_en(alu2_en), .alu_inv_Rt(alu2_inv_Rt), .alu_out(alu2_out));
adr_add    addr( .addr_op1(addr_op1), .addr_op2(addr_op2), .addr_en(addr_en), .addr_out(addr_out));

/////////////////////////////////////////////
//    index contributor
/////////////////////////////////////////////
assign reg_wrt_mul_out = mult_valid_wb;// when there is a valid output of product, the reg_wrt must be 1

//addr_free will be used by pipeline register
//
endmodule