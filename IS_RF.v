module IS_RF (
    input clk, 
    input rst_n,
    input stall,

    input mis_pred,
	input [5:0] mis_pred_indx,
    input [5:0] rob_head,
    input [5:0] rob_tail,

    input mult_done,
    input  [65:0]          mult_inst_pkg_in,             // pc_to_dec
    input  [65:0]          alu1_inst_pkg_in,           // inst_to_dec
    input  [65:0]          alu2_inst_pkg_in,        // recv_pc_to_dec
    input  [65:0]          addr_inst_pkg_in,    // pred_result_to_dec


    output mult_fun_rdy,
    output wire [65:0]     mult_inst_pkg_out_ok,             // pc_to_dec
    output wire [65:0]     alu1_inst_pkg_out_ok,           // inst_to_dec
    output wire [65:0]     alu2_inst_pkg_out_ok,        // recv_pc_to_dec
    output wire [65:0]     addr_inst_pkg_out_ok    // pred_result_to_dec
);
    
	wire flush_alu2; 
	wire flush_mult; 
	wire flush_addr; 

    wire [65:0] mult_inst_pkg_out;
    wire [65:0] alu1_inst_pkg_out;
    wire [65:0] alu2_inst_pkg_out;
    wire [65:0] addr_inst_pkg_out;

	assign flush_alu2 = (!mis_pred) ? 1'b0
					  : (((alu2_inst_pkg_out[64:59] >= rob_head) &&
						  (alu2_inst_pkg_out[64:59] <= 63      ) &&
					      (mis_pred_indx            >= rob_head) &&
						  (mis_pred_indx            <= 63      ))  ||
					     ((alu2_inst_pkg_out[64:59] >= 0       ) &&
						  (alu2_inst_pkg_out[64:59] <  rob_tail) &&
					      (mis_pred_indx            >= 0       ) &&
						  (mis_pred_indx            <  rob_tail)))
					  ? ((alu2_inst_pkg_out[64:59] < mis_pred_indx)
					    ? 1'b0 
						: 1'b1)
					  : ((alu2_inst_pkg_out[64:59] < mis_pred_indx)
					    ? 1'b1 
						: 1'b0);

	assign flush_mult = (!mis_pred) ? 1'b0
					  : (((mult_inst_pkg_out[64:59] >= rob_head) &&
						  (mult_inst_pkg_out[64:59] <= 63      ) &&
					      (mis_pred_indx            >= rob_head) &&
						  (mis_pred_indx            <= 63      ))  ||
					     ((mult_inst_pkg_out[64:59] >= 0       ) &&
						  (mult_inst_pkg_out[64:59] <  rob_tail) &&
					      (mis_pred_indx            >= 0       ) &&
						  (mis_pred_indx            <  rob_tail)))
					  ? ((mult_inst_pkg_out[64:59] < mis_pred_indx)
					    ? 1'b0 
						: 1'b1)
					  : ((mult_inst_pkg_out[64:59] < mis_pred_indx)
					    ? 1'b1 
						: 1'b0);

	assign flush_addr = (!mis_pred) ? 1'b0
					  : (((addr_inst_pkg_out[64:59] >= rob_head) &&
						  (addr_inst_pkg_out[64:59] <= 63      ) &&
					      (mis_pred_indx            >= rob_head) &&
						  (mis_pred_indx            <= 63      ))  ||
					     ((addr_inst_pkg_out[64:59] >= 0       ) &&
						  (addr_inst_pkg_out[64:59] <  rob_tail) &&
					      (mis_pred_indx            >= 0       ) &&
						  (mis_pred_indx            <  rob_tail)))
					  ? ((addr_inst_pkg_out[64:59] < mis_pred_indx)
					    ? 1'b0 
						: 1'b1)
					  : ((addr_inst_pkg_out[64:59] < mis_pred_indx)
					    ? 1'b1 
						: 1'b0);


	assign alu1_inst_pkg_out_ok = alu1_inst_pkg_out;
	assign alu2_inst_pkg_out_ok = (flush_alu2) ? 66'h0 : alu2_inst_pkg_out;
	assign mult_inst_pkg_out_ok = (flush_mult) ? 66'h0 : mult_inst_pkg_out;
	assign addr_inst_pkg_out_ok = (flush_addr) ? 66'h0 : addr_inst_pkg_out;

    wire enable;   // ~stall

    assign enable = ~stall;

    assign mult_fun_rdy = ( ~mult_inst_pkg_out[65] || mult_done);
                        
    //data
    rf_enable mult_inst_pkg           [65:0]    ( .q(mult_inst_pkg_out), .d(mult_inst_pkg_in), .wrt_en(~mult_inst_pkg_out[65] || mult_done), .clk(clk), .rst_n(rst_n));
    rf_enable alu1_inst_pkg         [65:0]    ( .q(alu1_inst_pkg_out), .d(alu1_inst_pkg_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_inst_pkg      [65:0]    ( .q(alu2_inst_pkg_out), .d(alu2_inst_pkg_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_inst_pkg  [65:0]    ( .q(addr_inst_pkg_out), .d(addr_inst_pkg_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));


endmodule
    
