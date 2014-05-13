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
    pred_to_pcsel
);

input clk,rst_n,decr_count_brnch,mispredict,mispred_num,brnc_pred_log;
input [3:0]brnch_pc_sel_from_bhndlr;
input update_bpred,loop_start;
output [1:0] pred_to_pcsel;



localparam SN=2'b00;
localparam WN=2'b01;
localparam WT=2'b10;
localparam ST=2'b11;


///////////////////////////////////////
//======1level dynamic predictor=====//
///////////////////////////////////////
reg [1:0] predCounter;
reg [1:0] predCounter_next;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        predCounter<=WT;
	else
		predCounter<=predCounter_next;
end

always@(decr_count_brnch, predCounter, brnc_pred_log, mispredict)begin

	predCounter_next = predCounter;

    if(decr_count_brnch==1)//a branch is committed
    begin
        case(predCounter)
            SN:begin
            if(brnc_pred_log==1)
                predCounter_next = WN;
            else
                predCounter_next = SN;
            end
            WN:begin
                if(brnc_pred_log==1)
                predCounter_next = WT;
            else
                predCounter_next = SN;
            end
            WT:begin
                if(brnc_pred_log==1)
                predCounter_next = ST;
            else
                predCounter_next = WN;
            end
            ST:begin
                if(brnc_pred_log==1)
                predCounter_next = ST;
            else
                predCounter_next = WT;
            end
        endcase
    end
    else if(mispredict==1)//update predictor when misprediction takes place
		begin
		if(brnc_pred_log==1)//==1 indicates mistakenly predicted taken
               case(predCounter)
                   SN:predCounter_next = SN;
                   WN:predCounter_next = SN;
                   WT:predCounter_next = WN;
                   ST:predCounter_next = WT;
                endcase
           else
               case(predCounter)
                   SN:predCounter_next = WN;
                   WN:predCounter_next = WT;
                   WT:predCounter_next = ST;
                   ST:predCounter_next = ST;
                endcase
        end
end



wire [1:0] numbrnch;
assign numbrnch=brnch_pc_sel_from_bhndlr[0]+brnch_pc_sel_from_bhndlr[1]+brnch_pc_sel_from_bhndlr[2]+brnch_pc_sel_from_bhndlr[3];
assign pred_to_pcsel=(update_bpred)?((loop_start)?2'b11:((numbrnch==1)?{predCounter[1],1'b0}:{predCounter[1],predCounter[1]})):2'b00;




endmodule
