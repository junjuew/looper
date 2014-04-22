`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:00:20 03/22/2014 
// Design Name: 
// Module Name:    branchPredictor 
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
module dynBranchPredictor(
    clk,
    rst_n,
    decr_count_brnch,
    mispredict,
    mispred_num,
    brnc_pred_log,
    brnch_pc_sel_from_bhndlr,
    update_bpred,
    loop_start,
    pc,
    pc_plus1,
    pc_plus2,
    pc_plus3,
    pred_to_pcsel
);

input clk,rst_n,decr_count_brnch,mispredict,mispred_num,brnc_pred_log;
input [3:0]brnch_pc_sel_from_bhndlr;
input update_bpred,loop_start;
input [15:0]pc, pc_plus1, pc_plus2, pc_plus3;
output [1:0] pred_to_pcsel;

/*
///////////////////////////////////////
//=======always TAKEN branch=========//
///////////////////////////////////////
wire [1:0] numbrnch;
assign numbrnch=brnch_pc_sel_from_bhndlr[0]+brnch_pc_sel_from_bhndlr[1]+brnch_pc_sel_from_bhndlr[2]+brnch_pc_sel_from_bhndlr[3];
assign pred_to_pcsel=(update_bpred)?((loop_start)?2'b11:((numbrnch==1)?2'b10:2'b11)):2'b00;
*/
//assign brnch_pc_sel_from_bhndlr=brnch_pc_sel_from_bhndlr;


localparam SN=2'b00;
localparam WN=2'b01;
localparam WT=2'b10;
localparam ST=2'b11;


///////////////////////////////////////
//======1level dynamic predictor=====//
///////////////////////////////////////
reg [1:0] predCounter;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        predCounter<=ST;
    else if(decr_count_brnch==1)//a branch is committed
    begin
        case(predCounter)
            SN:begin
            if(brnc_pred_log==1)
                predCounter<=WN;
            else
                predCounter<=SN;
            end
            WN:begin
                if(brnc_pred_log==1)
                predCounter<=WT;
            else
                predCounter<=SN;
            end
            WT:begin
                if(brnc_pred_log==1)
                predCounter<=ST;
            else
                predCounter<=WN;
            end
            ST:begin
                if(brnc_pred_log==1)
                predCounter<=ST;
            else
                predCounter<=WT;
            end
        endcase
    end
    else if(mispredict==1)
        if(mispred_num==1)begin
           if(brnc_pred_log==1)
               case(predCounter)
                   SN:predCounter<=SN;
                    WN:predCounter<=SN;
                    WT:predCounter<=SN;
                    ST:predCounter<=WN;
                endcase
           else
               case(predCounter)
                    SN:predCounter<=WT;
                    WN:predCounter<=ST;
                    WT:predCounter<=ST;
                    ST:predCounter<=ST;
                endcase
        end else begin
            if(brnc_pred_log==1)
               case(predCounter)
                   SN:predCounter<=SN;
                   WN:predCounter<=SN;
                   WT:predCounter<=WN;
                   ST:predCounter<=WT;
                endcase
           else
               case(predCounter)
                   SN:predCounter<=WN;
                   WN:predCounter<=WT;
                   WT:predCounter<=ST;
                   ST:predCounter<=ST;
                endcase
        end
    else
        predCounter<=predCounter;

end

reg [1:0] tmp;


wire [1:0] numbrnch;
assign numbrnch=brnch_pc_sel_from_bhndlr[0]+brnch_pc_sel_from_bhndlr[1]+brnch_pc_sel_from_bhndlr[2]+brnch_pc_sel_from_bhndlr[3];
assign pred_to_pcsel=(update_bpred)?((loop_start)?2'b11:((numbrnch==1)?{predCounter[1],1'b0}:{predCounter[1],predCounter[1]})):2'b00;




endmodule
