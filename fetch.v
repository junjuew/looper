`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:02:12 03/21/2014 
// Design Name: 
// Module Name:    fetch 
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
module fetch(clk,rst_n,stall_fetch,loop_start,decr_count_brnch,has_mispredict,
	jump_base_rdy_from_rf, pc_recovery,jump_base_from_rf,
	exter_pc,exter_pc_en,mispred_num,brnc_pred_log,
	pc_to_dec,inst_to_dec, recv_pc_to_dec,pred_result_to_dec);

////////////////////
//local parameters//
////////////////////
localparam PC_WIDTH=16;


////////////////////
//input parameters//
///////////////////
input clk,rst_n,
	stall_fetch,//from DECODE, set when issue queue is full
	loop_start,//from DECODE, set when entering loop mode, branch always taken
	decr_count_brnch,//from ROB, set when taken branch is commited from ROB
	has_mispredict,//from ROB, set when mispredition is detected
	jump_base_rdy_from_rf;//from RF, set when base register value is fetched in RF stage

input [PC_WIDTH-1:0] pc_recovery,//from ROB, recovery pc address on misprediction
	jump_base_from_rf;//from RF, jump base is register value

input [15:0]exter_pc;//input pc from external device, for testing
input exter_pc_en;
input mispred_num;//From ROB, if misprediction occurs tell predictor and counter which to flush
input brnc_pred_log;//prediction value from ROB, when committed 

/////////////////////
//output parameters//
/////////////////////
output [63:0]pc_to_dec,inst_to_dec, recv_pc_to_dec;
output [3:0]pred_result_to_dec;


//////////////////////////////
//internal wires and signals//
/////////////////////////////
wire [15:0] brnch_addr_pc0, brnch_addr_pc1, jump_addr_pc,pc_plus4, pc_bhndlr,
		pc,pc_plus1,pc_plus2,pc_plus3,inst0,inst1, inst2, inst3,
		instruction0, instruction1, instruction2,instruction3,
		brnch_inst0,brnch_inst1;
wire [3:0] brnch_pc_sel_from_bhndlr,isImJmp;
wire [2:0] PC_select;
wire [1:0] pred_to_pcsel;
wire [15:0] pc_from_mux;

///////////////////////////////////
//internal registers and signals///
///////////////////////////////////
//reg [PC_WIDTH-1:0] pc,pc_reg,pc_next,
//reg [2:0] PC_select;
//reg [PC_WIDTH-1:0]brnch_addr_pc0,brnch_addr_pc1;

///////////////////////////////////////////////////////////////////
/////================code starts here=========================/////
///////////////////////////////////////////////////////////////////

//PC_MUX and PC_reg
PC_MUX PC_MUX0(clk, rst_n,pc_recovery, brnch_addr_pc0, brnch_addr_pc1, jump_addr_pc,
    pc_plus4, pc_bhndlr, PC_select, pc_from_mux);

assign pc=exter_pc_en?exter_pc:pc_from_mux;

//from external control signals
assign pc_plus4=pc+4;

//instruction memory
instrMemModule IMM(clk, pc,inst0,inst1, inst2, inst3, pc_plus1, pc_plus2, pc_plus3);


//branch prediction
branchHandler branchjumpHandler(clk,rst_n,pc,inst0,inst1,inst2,inst3, stall_for_jump,//from jump
	pred_to_pcsel, (decr_count_brnch||has_mispredict),stall_fetch,mispred_num,brnc_pred_log,
   update_bpred, brnch_pc_sel_from_bhndlr, pcsel_from_bhndlr, pc_bhndlr,
	instruction0, instruction1, instruction2,instruction3,//to output
   brnch_inst0,brnch_inst1,isImJmp);//to calculator


/*
branchPredictor bpred( brnch_pc_sel_from_bhndlr,update_bpred,loop_start,
pc,	pc_plus1, pc_plus2, pc_plus3, pred_to_pcsel);
*/
dynBranchPredictor bpred0(clk,rst_n,decr_count_brnch,
   has_mispredict,mispred_num,brnc_pred_log,
   brnch_pc_sel_from_bhndlr,update_bpred,
   loop_start,pc,pc_plus1,pc_plus2,pc_plus3,pred_to_pcsel);
/*GshareBranchPredictor bpred1(clk,rst_n,decr_count_brnch,
   mispredict,mispred_num,brnch_pc_sel_from_bhndlr,update_bpred,
   loop_start,pc,pc_plus1,pc_plus2,pc_plus3,pred_to_pcsel);
*/

branchAddrCalculator branchAddrCalculator(brnch_pc_sel_from_bhndlr, brnch_inst0, brnch_inst1, pc,
	brnch_addr_pc0, brnch_addr_pc1);


//jump
jumpHandler jumpHandler(clk,rst_n,pc,instruction0,instruction1,instruction2,instruction3,
    jump_base_from_rf,jump_base_rdy_from_rf,jump_addr_pc,jump_for_pcsel,stall_for_jump);


//next PC selector
nextPCSel next_PC_selector(clk,rst_n,stall_fetch, has_mispredict, 
	pred_to_pcsel,jump_for_pcsel, pcsel_from_bhndlr,stall_for_jump, PC_select);

//output to DECODE stage
dataout_pack dataout(pc,pc_plus1,pc_plus2,pc_plus3,
	instruction0,instruction1,instruction2,instruction3,
	 brnch_addr_pc0,brnch_addr_pc1,jump_addr_pc,
	 brnch_addr_pc0,brnch_addr_pc1,
	 pred_to_pcsel,brnch_pc_sel_from_bhndlr,isImJmp,
	 pc_to_dec,inst_to_dec,recv_pc_to_dec,pred_result_to_dec);

endmodule
