`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:33:09 03/21/2014 
// Design Name: 
// Module Name:    top_level_wb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top_level_wb( clk,
                     rst,
                     flsh,
                     flsh_cache,                
                     mis_pred_ld_ptr ,  
                     indx_ld_al, 
                     mem_rd, 
                     phy_addr_ld_in, 
                     mis_pred_str_ptr, 
                     cmmt_str, 
                     indx_str_al, 
                     mem_wrt, 
                     data_str, 
                     indx_ls,
                     addr_ls,
                     fnsh_unrll,
                     loop_strt,
                     stll,
                     indx_ld,
                     vld_ld,
                     data_ld,
                     phy_addr_ld,
                     reg_wrt_ld,
                     str_iss,
                     cmmt_ld_ptr,

                     mmu_mem_clk  ,
                     mmu_mem_rst  ,
                     mmu_mem_enb  ,
                     mmu_mem_web  ,
                     mmu_mem_addrb,
                     mmu_mem_dinb ,
                     mmu_mem_doutb,
                     ca_idle
                     );


   //for mmu
   input wire    mmu_mem_clk ;
   input wire    mmu_mem_rst ;
   input wire    mmu_mem_enb ;
   input wire    mmu_mem_web ;
   input wire [13:0] mmu_mem_addrb ;
   input wire [63:0] mmu_mem_dinb ;
   output wire [63:0] mmu_mem_doutb ;
   output             ca_idle;
   
   
   // input and output ports declarations
   input             clk, rst, flsh, mem_rd,cmmt_str,mem_wrt, fnsh_unrll, loop_strt, flsh_cache;
   input [31:0]      indx_ld_al, indx_str_al;
   input [4:0]       mis_pred_ld_ptr, cmmt_ld_ptr;  
   input [3:0]       mis_pred_str_ptr;
   input [5:0]       phy_addr_ld_in,indx_ls;
   input [15:0]      data_str, addr_ls;
   output            stll,vld_ld,reg_wrt_ld,str_iss;
   output [5:0]      indx_ld,phy_addr_ld;
   output [15:0]     data_ld;

   wire              ld_grnt, done, fwd,fwd_rdy, ld_req, stll_ld, stll_str, str_req, str_grnt, addr_sel, ld_head, rd_wrt_ca, ca_idle, ca_enable;
   wire [15:0]       data_ca_out , data_ca_in , addr_ca , data_fwd , addr_ld, addr_str;
   wire [6:0]        indx_fwd;

   load_queue lq(.fnsh_unrll(fnsh_unrll), .rst(rst), .clk(clk), .loop_strt(loop_strt),.flsh(flsh), .indx_ld_al(indx_ld_al),  .mem_rd(mem_rd),
                 .phy_addr_ld_in(phy_addr_ld_in), .indx_ls(indx_ls), .addr_ls(addr_ls),
                 .ld_grnt(ld_grnt), .done(done), .data_sq(data_fwd), .data_ca(data_ca_out),
                 .fwd(fwd), .fwd_rdy(fwd_rdy), .ld_req(ld_req), .addr(addr_ld), .reg_wrt_ld(reg_wrt_ld),
                 .phy_addr_ld(phy_addr_ld), .data_ld(data_ld), .vld_ld(vld_ld), .indx_ld(indx_ld), .stll(stll_ld),
                 .mis_pred_ld_ptr(mis_pred_ld_ptr),  .indx_fwd(indx_fwd), .cmmt_ld_ptr(cmmt_ld_ptr), .ld_head(ld_head));
   
   store_queue sq(.ld_head(ld_head),.fnsh_unrll(fnsh_unrll), .loop_strt(loop_strt), .rst(rst), .clk(clk),.addr_fwd(addr_ld),.indx_fwd(indx_fwd), .flsh(flsh), .indx_str_al(indx_str_al), .ld_grnt(ld_grnt),
                  .mem_wrt(mem_wrt), .data_str(data_str), .indx_ls(indx_ls), 
                  .addr_ls(addr_ls), .str_grnt(str_grnt), .done(done), .str_req(str_req), 
                  .str_iss(str_iss), .stll(stll_str), .fwd(fwd), .fwd_rdy(fwd_rdy), .addr(addr_str),
                  .data_ca(data_ca_in), .data_fwd(data_fwd), .mis_pred_str_ptr(mis_pred_str_ptr),
                  .cmmt_str(cmmt_str));
   
   load_store_arbi lsa(.rst(rst), .clk(clk),.ld_req(ld_req), .str_req(str_req), .idle(ca_idle), .done(done),
                       .ld_grnt(ld_grnt), .str_grnt(str_grnt), .addr_sel(addr_sel),
                       .rd_wrt_ca(rd_wrt_ca), .enable(ca_enable));


/* -----\/----- EXCLUDED -----\/-----
   memory_system mem_sys(.rst(rst), .clk(clk),.addr_ca(addr_ca), .data_ca_out(data_ca_out),.rd_wrt_ca(rd_wrt_ca), 
                         .data_ca_in(data_ca_in),.enable(ca_enable), .idle(ca_idle), .done(done), .flush(flsh_cache));
 -----/\----- EXCLUDED -----/\----- */


   memory_system mem_sys(
                         // Outputs
                         .idle                  (ca_idle),
                         .done                  (done),
                         .data_ca_out           (data_ca_out[15:0]),
                         // Inputs
                         .rd_wrt_ca             (rd_wrt_ca),
                         .enable                (ca_enable),
                         .clk                   (clk),
                         .rst                   (rst),
                         .flush                 (flsh_cache),
                         .addr_ca               (addr_ca[15:0]),
                         .data_ca_in            (data_ca_in[15:0]),
                         .mmu_mem_clk           (mmu_mem_clk),
                         .mmu_mem_rst           (mmu_mem_rst),
                         .mmu_mem_enb           (mmu_mem_enb),
                         .mmu_mem_web           (mmu_mem_web),
                         .mmu_mem_addrb         (mmu_mem_addrb[13:0]),
                         .mmu_mem_dinb          (mmu_mem_dinb[63:0]),
                         .mmu_mem_doutb         (mmu_mem_doutb[63:0]));
   


   
   assign addr_ca= (addr_sel == 1) ? addr_str : addr_ld;
   assign stll= stll_ld | stll_str;

endmodule
