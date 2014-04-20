`timescale 1ns/1ps
module fetch_tb();
reg clk,rst_n,stall_fetch,loop_start,decr_count_brnch,has_mispredict,jump_base_rdy_from_rf;
reg [15:0] pc_recovery,jump_base_from_rf,exter_pc;
reg exter_pc_en,mispred_num;
wire [63:0] pc_to_dec,inst_to_dec, recv_pc_to_dec;
wire [3:0] pred_result_to_dec;

fetch DUT(clk,rst_n,stall_fetch,loop_start,decr_count_brnch,has_mispredict,
	jump_base_rdy_from_rf, pc_recovery,jump_base_from_rf,
	exter_pc,exter_pc_en,mispred_num,
	pc_to_dec,inst_to_dec, recv_pc_to_dec,pred_result_to_dec);
    
wire [15:0] pc=DUT.PC_MUX0.pc;
wire [2:0] pc_select=DUT.PC_MUX0.PC_select;
wire [15:0] inst0=DUT.inst0;
wire [15:0] inst1=DUT.inst1;
wire [15:0] inst2=DUT.inst2;
wire [15:0] inst3=DUT.inst3;
wire [15:0] jump_addr_pc=DUT.jumpHandler.jump_addr_pc;
wire jump_for_pcsel=DUT.jumpHandler.jump_for_pcsel;
wire wtJumpAddr=DUT.jumpHandler.wtJumpAddr;
wire [15:0]jump_pc=DUT.jumpHandler.jump_pc;
wire stall_for_jump=DUT.jumpHandler.stall_for_jump;
wire [1:0] pred_to_pcsel=DUT.bpred.pred_to_pcsel;



//for number of branches
wire tkn_brnch=DUT.branchjumpHandler.tkn_brnch[1];
wire [3:0]countbrnch=DUT.branchjumpHandler.exd_cnt;
wire [1:0] counter=DUT.branchjumpHandler.brnch_cnt;
wire [3:0] brnchcheck=DUT.branchjumpHandler.brnch_pc_sel_from_bhndlr;
wire [1:0] brnch_before_inst0=DUT.branchjumpHandler.brnch_before_inst0;
wire [1:0] brnch_before_inst1=DUT.branchjumpHandler.brnch_before_inst1;
wire [1:0] brnch_before_inst2=DUT.branchjumpHandler.brnch_before_inst2;
wire [1:0] brnch_before_inst3=DUT.branchjumpHandler.brnch_before_inst3;
wire decr_cnt_in_bh=DUT.branchjumpHandler.decr_count_from_rob;

initial begin
        $wlfdumpvars(0, fetch_tb);
    end

initial begin
   
rst_n=1;
stall_fetch=0;
loop_start=0;
decr_count_brnch=0;
has_mispredict=0;
jump_base_rdy_from_rf=0;
pc_recovery=16'b0;
jump_base_from_rf=16'b0;
exter_pc=16'b0;
exter_pc_en=0;
mispred_num=0;
 
#2 rst_n=0;
#2 rst_n=1;
#25
jump_base_rdy_from_rf=0;
jump_base_from_rf=16'b0;

#2
jump_base_rdy_from_rf=0;
//decr_count_brnch=1;
//mispred_num=1;
#2
decr_count_brnch=0;
mispred_num=0;
#40 $finish;
end

initial begin
    clk=0;
    forever begin
        #1 clk= ~clk;
   end
end


endmodule
