`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:30:06 03/24/2014 
// Design Name: 
// Module Name:    dataout_pack 
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
//1. if instruction got replaced is the pc output set to all 0??
//2. the recovery pc output for jump instructionis what?? what if reg based?
//////////////////////////////////////////////////////////////////////////////////
module dataout_pack(
    input [15:0] pc,
    input [15:0] pc_plus1,
    input [15:0] pc_plus2,
    input [15:0] pc_plus3,
    input [15:0] instruction0,
    input [15:0] instruction1,
    input [15:0] instruction2,
    input [15:0] instruction3,
    input [15:0] jump_addr_pc,
    input [15:0] brnch_addr_pc0,
    input [15:0] brnch_addr_pc1,
    input [1:0] pred_to_pcsel,
    input [3:0] brnch_pc_sel_from_bhndlr,
    input [3:0] isImJmp,//from branch handler, nop immdiate jump at output

    output [63:0] pc_to_dec,
    output [63:0] inst_to_dec,
    output reg[63:0] recv_pc_to_dec,
    output reg[3:0] pred_result_to_dec
);

//internal signal
reg [3:0]taken;

always@(*)begin
	taken=brnch_pc_sel_from_bhndlr;
	recv_pc_to_dec=64'b0;
	pred_result_to_dec=4'b0;
	if((|brnch_pc_sel_from_bhndlr)==0)//no branch inst
		taken=4'b0000;
	else if ((^brnch_pc_sel_from_bhndlr)==0)//two branch inst
	begin
		if(brnch_pc_sel_from_bhndlr==4'b1100)
		begin
			pred_result_to_dec[3:2]=pred_to_pcsel;
			recv_pc_to_dec[63:32]={(!pred_to_pcsel[1])?brnch_addr_pc0:pc_plus1,(!pred_to_pcsel[0])?brnch_addr_pc1:pc_plus2};
		end
		else if(brnch_pc_sel_from_bhndlr==4'b1010)
		begin
			pred_result_to_dec[3]=pred_to_pcsel[1];
			pred_result_to_dec[1]=pred_to_pcsel[0];
			recv_pc_to_dec[63:48]=(!pred_to_pcsel[1])?brnch_addr_pc0:pc_plus1;
			recv_pc_to_dec[31:16]=(!pred_to_pcsel[0])?brnch_addr_pc1:pc_plus3;
		end
		else if(brnch_pc_sel_from_bhndlr==4'b1001)
		begin
			pred_result_to_dec[3]=pred_to_pcsel[1];
			pred_result_to_dec[0]=pred_to_pcsel[0];
			recv_pc_to_dec[63:48]=(!pred_to_pcsel[1])?brnch_addr_pc0:pc_plus1;
			recv_pc_to_dec[15:0]=(!pred_to_pcsel[0])?brnch_addr_pc1:(pc_plus3+1);
		end
		else if(brnch_pc_sel_from_bhndlr==4'b0110)
		begin
			pred_result_to_dec[2]=pred_to_pcsel[1];
			pred_result_to_dec[1]=pred_to_pcsel[0];
			recv_pc_to_dec[47:16]={(!pred_to_pcsel[1])?brnch_addr_pc0:pc_plus2,
				(!pred_to_pcsel[0])?brnch_addr_pc1:pc_plus3};
		end
		else if(brnch_pc_sel_from_bhndlr==4'b0101)
		begin
			pred_result_to_dec[2]=pred_to_pcsel[1];
			pred_result_to_dec[0]=pred_to_pcsel[0];
			recv_pc_to_dec[47:32]=(!pred_to_pcsel[1])?brnch_addr_pc0:pc_plus2;
			recv_pc_to_dec[15:0]=(!pred_to_pcsel[0])?brnch_addr_pc1:(pc_plus3+1);
		end
		else if(brnch_pc_sel_from_bhndlr==4'b0011)
		begin
			pred_result_to_dec[1]=pred_to_pcsel[1];
			pred_result_to_dec[0]=pred_to_pcsel[0];
			recv_pc_to_dec[31:0]={(!pred_to_pcsel[1])?brnch_addr_pc0:pc_plus3,(!pred_to_pcsel[0])?brnch_addr_pc1:(pc_plus3+1)};
		end
	end else //one branch
	begin
		if((pred_to_pcsel[1])==1)begin
			if(brnch_pc_sel_from_bhndlr[3]==1)
				recv_pc_to_dec[63:48]=pc_plus1;
			else if(brnch_pc_sel_from_bhndlr[2]==1)
				recv_pc_to_dec[47:32]=pc_plus2;	
			else if(brnch_pc_sel_from_bhndlr[1]==1)
				recv_pc_to_dec[31:16]=pc_plus3;
			else if(brnch_pc_sel_from_bhndlr[0]==1)
				recv_pc_to_dec[15:0]=pc_plus3+1;
		end
		else
		begin
			if(brnch_pc_sel_from_bhndlr[3]==1)
				recv_pc_to_dec[63:48]=brnch_addr_pc0;
			else if(brnch_pc_sel_from_bhndlr[2]==1)
				recv_pc_to_dec[47:32]=brnch_addr_pc0;	
			else if(brnch_pc_sel_from_bhndlr[1]==1)
				recv_pc_to_dec[31:16]=brnch_addr_pc0;
			else if(brnch_pc_sel_from_bhndlr[0]==1)
				recv_pc_to_dec[15:0]=brnch_addr_pc0;
		end
	end
end

//if the instruction is jump, the recovery address is the jump address for that instruction
/*always@(*)
	if(instruction0[15:12]==4'b1111)
		recv_pc_to_dec[63:48]=jump_addr_pc;
	else if (instruction1[15:12]==4'b1111)
		recv_pc_to_dec[47:32]=jump_addr_pc;
	else if (instruction2[15:12]==4'b1111)
		recv_pc_to_dec[31:16]=jump_addr_pc;
	else if(instruction3[15:12]==4'b1111)
		recv_pc_to_dec[15:0]=jump_addr_pc;
*/
assign pc_to_dec={pc,pc_plus1,pc_plus2,pc_plus3};
assign inst_to_dec={isImJmp[3]?16'b0:instruction0,isImJmp[2]?16'b0:instruction1,
	isImJmp[1]?16'b0:instruction2,isImJmp[0]?16'b0:instruction3};


endmodule
