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
    input [15:0] pc,
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
wire [63:0] instLine0,instLine1;

assign pc_plus1=pc+1;
assign pc_plus2=pc+2;
assign pc_plus3=pc+3;
//assign pc_plus4=pc+4;

imemory IM0(clk, pc[15:2], instLine0, clk, pc_plus3[15:2],instLine1);

//IM IM0(clk, pc[15:2], instLine0, clk, pc_plus3[15:2],instLine1);

//inst0 mux
always@(*)
	case(pc[1:0])
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