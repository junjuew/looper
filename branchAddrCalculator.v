`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:07:56 03/22/2014 
// Design Name: 
// Module Name:    branchAddrCalculator 
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
module branchAddrCalculator(
    input [3:0] brnch_pc_sel_from_bhndlr,//choose which pc of the instruction to calculate
    input [15:0] brnch_inst0,
    input [15:0] brnch_inst1,
    input [15:0] pc,
    output reg [15:0] brnch_addr_pc0,
    output reg [15:0] brnch_addr_pc1
);

//internal signal
wire [15:0] immd_brnch0,immd_brnch1;

assign immd_brnch0={{8{brnch_inst0[7]}},brnch_inst0[7:0]};
assign immd_brnch1={{8{brnch_inst1[7]}},brnch_inst1[7:0]};

always@(*)
    if((|brnch_pc_sel_from_bhndlr)==0)//no branch inst
    begin
        brnch_addr_pc0=16'b0;
        brnch_addr_pc1=16'b0;
    end else if ((^brnch_pc_sel_from_bhndlr)==0)//two branch inst
    begin
        if(brnch_pc_sel_from_bhndlr==4'b1100)
        begin
            brnch_addr_pc0=pc+1+immd_brnch0;
            brnch_addr_pc1=pc+2+immd_brnch1;
        end
        else if(brnch_pc_sel_from_bhndlr==4'b1010)
        begin
            brnch_addr_pc0=pc+1+immd_brnch0;
            brnch_addr_pc1=pc+3+immd_brnch1;
        end
        else if(brnch_pc_sel_from_bhndlr==4'b1001)
        begin
            brnch_addr_pc0=pc+1+immd_brnch0;
            brnch_addr_pc1=pc+4+immd_brnch1;
        end
        else if(brnch_pc_sel_from_bhndlr==4'b0110)
        begin
            brnch_addr_pc0=pc+2+immd_brnch0;
            brnch_addr_pc1=pc+3+immd_brnch1;
        end
        else if(brnch_pc_sel_from_bhndlr==4'b0101)
        begin
            brnch_addr_pc0=pc+2+immd_brnch0;
            brnch_addr_pc1=pc+4+immd_brnch1;
        end
        else if(brnch_pc_sel_from_bhndlr==4'b0011)
        begin
            brnch_addr_pc0=pc+3+immd_brnch0;
            brnch_addr_pc1=pc+4+immd_brnch1;
        end
        else begin
            brnch_addr_pc0=16'b0;
            brnch_addr_pc1=16'b0;
        end
    end else begin//one branch
        brnch_addr_pc0=(brnch_pc_sel_from_bhndlr[3])?(pc+1+immd_brnch0):
            (brnch_pc_sel_from_bhndlr[2]?(pc+2+immd_brnch0):
            (brnch_pc_sel_from_bhndlr[1]?(pc+3+immd_brnch0):
            (brnch_pc_sel_from_bhndlr[0]?(pc+4+immd_brnch0):16'b0)));
        brnch_addr_pc1=16'b0;
    end

endmodule
