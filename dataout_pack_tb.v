`timescale 1ns/1ps
module dataout_pack_tb();
reg clk,rst;
reg [15:0] pc,pc_plus1,pc_plus2,pc_plus3,instruction0,instruction1,
   instruction2,instruction3,brnch_addr_0,brnch_addr_1,jump_addr_pc,brnch_addr_pc0,
   brnch_addr_pc1;
 reg [1:0] pred_to_pcsel;
 reg [3:0] brnch_pc_sel_from_bhndlr;

dataout_pack DUT(pc,pc_plus1,pc_plus2,pc_plus3,instruction0,instruction1,
   instruction2,instruction3,brnch_addr_0,brnch_addr_1,jump_addr_pc,brnch_addr_pc0,
   brnch_addr_pc1,pred_to_pcsel,brnch_pc_sel_from_bhndlr,pc_to_dec,inst_to_dec,
   recv_pc_to_dec,pred_result_to_dec
    );
    
initial begin
clk=0;    
    
    
    
    
    
end

always@(clk)
   #1 clk=~clk;


endmodule
