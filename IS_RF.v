module IS_RF (
    input clk, 
    input rst_n,
    
    input mult_done,
    input  [65:0]          mult_inst_pkg_in,             // pc_to_dec
    input  [65:0]          alu1_inst_pkg_in,           // inst_to_dec
    input  [65:0]          alu2_inst_pkg_in,        // recv_pc_to_dec
    input  [65:0]          addr_inst_pkg_in,    // pred_result_to_dec
    input                  stall,


    output mult_fun_rdy,
    output [65:0]          mult_inst_pkg_out,             // pc_to_dec
    output [65:0]          alu1_inst_pkg_out,           // inst_to_dec
    output [65:0]          alu2_inst_pkg_out,        // recv_pc_to_dec
    output [65:0]           addr_inst_pkg_out    // pred_result_to_dec
);
    
    wire enable;   // ~stall

   assign enable = ~stall;

   assign mult_fun_rdy = ( ~mult_inst_pkg_out[65] || mult_done);
                        
    //data
    rf_enable mult_inst_pkg           [65:0]    ( .q(mult_inst_pkg_out), .d(mult_inst_pkg_in), .wrt_en(~mult_inst_pkg_out[65] || mult_done), .clk(clk), .rst_n(rst_n));
    rf_enable alu1_inst_pkg         [65:0]    ( .q(alu1_inst_pkg_out), .d(alu1_inst_pkg_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable alu2_inst_pkg      [65:0]    ( .q(alu2_inst_pkg_out), .d(alu2_inst_pkg_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));
    rf_enable addr_inst_pkg  [65:0]    ( .q(addr_inst_pkg_out), .d(addr_inst_pkg_in), .wrt_en(enable), .clk(clk), .rst_n(rst_n));


endmodule
    
