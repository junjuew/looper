`timescale 1ns/1ps
module PC_MUX_tb();
reg clk,rst_n;
reg [15:0] pc_recovery,brnch_addr_pc0,brnch_addr_pc1,jump_addr_pc,pc_next,pc_bhndlr;
reg [2:0] PC_select;
    PC_MUX PC_MUX(clk, rst_n,pc_recovery,brnch_addr_pc0,brnch_addr_pc1,jump_addr_pc,
    pc_next,pc_bhndlr,PC_select,pc);

//wire [15:0] pc;    
    
 initial
begin
rst_n=1;
#2 rst_n=0;
pc_recovery=16'd0;
brnch_addr_pc0=16'd1;
brnch_addr_pc1=16'd2;
jump_addr_pc=16'd3;
pc_next=pc+4;
pc_bhndlr=16'd4;

PC_select=3'd5;

#1 rst_n=1;
pc_next=pc+4;
end

   
 initial begin
    clk=0;
    forever begin
        #1 clk= ~clk;
   end
end   
    
endmodule
