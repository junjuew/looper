module reg_file (
    input clk, 
    input rst_n,
    
    // read section
    input [5:0] read_mult_op1_pnum,
    input [5:0] read_mult_op2_pnum,
    input [5:0] read_alu1_op1_pnum,
    input [5:0] read_alu1_op2_pnum, 
    input [5:0] read_alu2_op1_pnum, 
    input [5:0] read_alu2_op2_pnum, 
    input [5:0] read_addr_bas_pnum, 
    input [5:0] read_addr_reg_pnum, 
    input [1:0] brn, // detecting !(2'b00) => branch instruction
    output [15:0] read_mult_op1_data,
    output [15:0] read_mult_op2_data,
    output [15:0] read_alu1_op1_data,
    output [15:0] read_alu1_op2_data, 
    output [15:0] read_alu2_op1_data, 
    output [15:0] read_alu2_op2_data, 
    output [15:0] read_addr_bas_data, 
    output [15:0] read_addr_reg_data, 
    output [1:0] brn_cmp_rslt, // tell ROB the real brn result

    // write section
    input        wrt_mult_vld,
    input [5:0]  wrt_mult_dst_pnum,
    input [15:0] wrt_mult_data,
    input        wrt_alu1_vld,
    input [5:0]  wrt_alu1_dst_pnum,
    input [15:0] wrt_alu1_data,
    input        wrt_alu2_vld, 
    input [5:0]  wrt_alu2_dst_pnum,
    input [15:0] wrt_alu2_data,
    input        wrt_addr_vld,
    input [5:0]  wrt_addr_dst_pnum,
    input [15:0] wrt_addr_data
);

    // read section
    reg [15:0] reg_file_body [0:63];
    assign read_mult_op1_data = reg_file_body[read_mult_op1_pnum];
    assign read_mult_op2_data = reg_file_body[read_mult_op2_pnum];
    assign read_alu1_op1_data = reg_file_body[read_alu1_op1_pnum];
    assign read_alu1_op2_data = reg_file_body[read_alu1_op2_pnum];
    assign read_alu2_op1_data = reg_file_body[read_alu2_op1_pnum];
    assign read_alu2_op2_data = reg_file_body[read_alu2_op2_pnum];
    assign read_addr_bas_data = reg_file_body[read_addr_bas_pnum];
    assign read_addr_reg_data = reg_file_body[read_addr_reg_pnum];
    
    reg [1:0] reg_file_brn_log [0:63];
    assign brn_cmp_rslt = (brn != 2'b00) ? reg_file_brn_log[read_alu1_op1_pnum]
                                         : 2'b00;
    
    // write section
    generate
    genvar reg_idx;
        for(reg_idx = 0; reg_idx < 64; reg_idx = reg_idx + 1)
        begin
            always@(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    reg_file_body[reg_idx] <= 1;
                    reg_file_brn_log[reg_idx] <= 0;
                end
                else begin
                    if((reg_idx == wrt_mult_dst_pnum) && wrt_mult_vld) begin
                        reg_file_body[reg_idx] <= wrt_mult_data;
                        reg_file_brn_log[reg_idx] <= (wrt_mult_data == 0) ? 2'b11
                                                   : (wrt_mult_data[15] == 1) ? 2'b01
                                                   : (wrt_mult_data > 0) ? 2'b10
                                                   : 2'b00;
                    end
                    else if((reg_idx == wrt_alu1_dst_pnum) && wrt_alu1_vld) begin
                        reg_file_body[reg_idx] <= wrt_alu1_data;
                        reg_file_brn_log[reg_idx] <= (wrt_alu1_data == 0) ? 2'b11
                                                   : (wrt_alu1_data[15] == 1) ? 2'b01
                                                   : (wrt_alu1_data > 0) ? 2'b10
                                                   : 2'b00;
                    end
                    else if((reg_idx == wrt_alu2_dst_pnum) && wrt_alu2_vld) begin
                        reg_file_body[reg_idx] <= wrt_alu2_data;
                        reg_file_brn_log[reg_idx] <= (wrt_alu2_data == 0) ? 2'b11
                                                   : (wrt_alu2_data[15] == 1) ? 2'b01
                                                   : (wrt_alu2_data > 0) ? 2'b10
                                                   : 2'b00;
                    end
                    else if((reg_idx == wrt_addr_dst_pnum) && wrt_addr_vld) begin
                        reg_file_body[reg_idx] <= wrt_addr_data;
                        reg_file_brn_log[reg_idx] <= (wrt_addr_data == 0) ? 2'b11
                                                   : (wrt_addr_data[15] == 1) ? 2'b01
                                                   : (wrt_addr_data > 0) ? 2'b10
                                                   : 2'b00;
                    end
                    else begin
                        reg_file_body[reg_idx] <= reg_file_body[reg_idx];
                        reg_file_brn_log[reg_idx] <= reg_file_brn_log[reg_idx];
                    end
                end
            end
        end
    endgenerate
endmodule

