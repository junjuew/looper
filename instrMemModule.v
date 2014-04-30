`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:06:38 03/22/2014 
// Design Name: 
// Module Name:    instrMemModule 
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
module instrMemModule(
    input clk,
	input rst_n,
    input [15:0] pc,
    input flush_mem,
    output reg[15:0] inst0,
    output reg[15:0] inst1,
    output reg[15:0] inst2,
    output reg[15:0] inst3,
    output [15:0] pc_plus1,
    output [15:0] pc_plus2,
    output [15:0] pc_plus3
    //output [15:0] pc_plus4
);

//internal signals
//wire [15:0] pc_plus4;
wire [63:0] instLine0,instLine1,
    memLine0,memLine1;//add on april 29
wire [15:0] pc_nextline;
assign pc_nextline=pc+3;
//assign pc_plus4=pc+4;

imemory IM0(clk, pc[15:2], memLine0, clk, pc_nextline[15:2],memLine1);

//IM IM0(clk, pc[15:2], instLine0, clk, pc_plus3[15:2],instLine1);

assign instLine0=(flush_mem)?64'b0:memLine0;
assign instLine1=(flush_mem)?64'b0:memLine1;

reg [15:0] pc_lag;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        pc_lag<=16'b0;
    else
        pc_lag<=pc;

assign pc_plus1=pc_lag+1;
assign pc_plus2=pc_lag+2;
assign pc_plus3=pc_lag+3;

//inst0 mux
always@(*)
    case(pc_lag[1:0])
    2'b00:inst0=instLine0[63:48];
    2'b01:inst0=instLine0[47:32];
    2'b10:inst0=instLine0[31:16];
    2'b11:inst0=instLine0[15:0];
    endcase

//inst1 mux
always@(*)
    case(pc_plus1[1:0])
    2'b00:inst1=instLine1[63:48];
    2'b01:inst1=instLine0[47:32];
    2'b10:inst1=instLine0[31:16];
    2'b11:inst1=instLine0[15:0];
    endcase

//inst2 mux
always@(*)
    case(pc_plus2[1:0])
    2'b00:inst2=instLine1[63:48];
    2'b01:inst2=instLine1[47:32];
    2'b10:inst2=instLine0[31:16];
    2'b11:inst2=instLine0[15:0];
    endcase
    
//inst3 mux
always@(*)
    case(pc_plus3[1:0])
    2'b00:inst3=instLine1[63:48];
    2'b01:inst3=instLine1[47:32];
    2'b10:inst3=instLine1[31:16];
    2'b11:inst3=instLine0[15:0];
    endcase


endmodule
