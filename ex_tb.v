module ex_tb();
 
	reg     	clk,rst;
	reg     	mult_en, alu1_en, alu2_en, addr_en;
	reg             alu1_inv_Rt, alu2_inv_Rt, alu1_ldi, alu2_ldi;
	reg  [2:0]      alu1_mode, alu2_mode;
	reg  [15:0]	mult_op1, mult_op2, alu1_op1, alu1_op2, alu2_op1, alu2_op2, addr_op1, addr_op2, alu1_imm, alu2_imm;

	wire [15:0]    mult_out, alu1_out, alu2_out, addr_out;
	wire mult_valid_wb, mult_free;
	execution ex (
		.mult_op1(mult_op1),
		.mult_op2(mult_op2), 
		.alu1_op1(alu1_op1), 
		.alu1_op2(alu1_op2), 
		.alu2_op1(alu2_op1),
		.alu2_op2(alu2_op2), 
		.addr_op1(addr_op1), 
		.addr_op2(addr_op2),
		.mult_en(mult_en), 
		.alu1_en(alu1_en), 
		.alu2_en(alu2_en), 
		.addr_en(addr_en), 
		.clk(clk), 
		.rst(rst),
		.alu1_inv_Rt(alu1_inv_Rt), 
		.alu2_inv_Rt(alu2_inv_Rt), 
		.alu1_ldi(alu1_ldi), 
		.alu2_ldi(alu2_ldi), 
		.alu1_imm(alu1_imm), 
		.alu2_imm(alu2_imm),
		.alu1_mode(alu1_mode), 
		.alu2_mode(alu2_mode),
		// output 
		.mult_out(mult_out), 
		.alu1_out(alu1_out), 
		.alu2_out(alu2_out), 
		.addr_out(addr_out), 
		.mult_valid_wb(mult_valid_wb), 
		.mult_free(mult_free));
always
    #2 clk = ~ clk;
    
   initial
      begin
        clk = 1;
        rst = 1;
        #1;
        rst = 0;
	alu1_en = 1;
	alu1_op1= 16'b1010101010101010;
	alu1_op2= 16'b0101010101010101;
    alu1_inv_Rt = 0;
    alu1_mode = 3'd6;
	alu1_ldi = 0;
	alu1_imm = 16'd99;
	mult_en  = 1;
	mult_op1 = 16'd12;
	mult_op2 = 16'd15;
	alu2_op1 = 16'b1011001010110100;
	alu2_op2 = 16'b0101000100010011;
	alu2_mode = 3'd5;
	alu2_en  = 1;
	alu2_ldi = 0;
	//alu2_mode = 3'd0;
	alu2_inv_Rt = 0;
      end
endmodule