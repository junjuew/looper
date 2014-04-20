`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:40 03/22/2014 
// Design Name: 
// Module Name:    branchHandler 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Branch Handler is in charge of NOPing instructions 
//						when branch is predicted taken or jump instructions occur;
//						when jump address is not ready it stalls fetching by nop 4 
//						instructions
//               1:if misprediction occurs, look if need to decrease counter value
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module branchHandler(input clk,
	input rst_n,
	input [15:0] pc,
    input [15:0] inst0,
    input [15:0] inst1,
    input [15:0] inst2,
    input [15:0] inst3,
    input stall_for_jump,
    input [1:0] pred_to_pcsel,
    input decr_count_from_rob,
	 input stall_fetch,
	 input mispred_num,
    output update_bpred,
    output [3:0] brnch_pc_sel_from_bhndlr,
    output pcsel_from_bhndlr,
    output [15:0] pc_bhndlr,
    output [15:0] instruction0,
    output [15:0] instruction1,
    output [15:0] instruction2,
    output [15:0] instruction3,
    output [15:0] brnch_inst0,
    output [15:0] brnch_inst1,
    output [3:0] isImJmp
    );
	 
//internal signals
wire [3:0] all_nop;
wire [3:0] isJump,tkn_brnch;
reg [1:0] brnch_cnt;

//wire [15:0] inst0_b,inst1_b,inst2_b,inst3_b;
	 
//////////////////////////////////////////////////////////
///////============code starts here=============//////////
//////////////////////////////////////////////////////////




//////////////////////////////////////
//4 nop conditions:
//   1).jump
//   2).branch number<2
//   3).branch taken
//   4).stall(loop/register-based jump)
///////////////////////////////////////


//<1>
//check if there is jump instruction, if there is flush the next instruction.
assign isJump[3]=&inst0[15:12];
assign isJump[2]=&inst1[15:12];
assign isJump[1]=&inst2[15:12];
assign isJump[0]=&inst3[15:12];

assign isImJmp[3]=isJump[3]&&(!(|inst0[1:0]));
assign isImJmp[2]=isJump[2]&&(!(|inst1[1:0]));
assign isImJmp[1]=isJump[1]&&(!(|inst2[1:0]));
assign isImJmp[0]=isJump[0]&&(!(|inst3[1:0]));

//<2>
//check if there are more than two instructions in the processor
//check for branch instructions
assign brnch_pc_sel_from_bhndlr[3]=(inst0[15:14]==2'b10) && (!(inst0[13:12]==2'b00));
assign brnch_pc_sel_from_bhndlr[2]=(inst1[15:14]==2'b10) && (!(inst1[13:12]==2'b00));
assign brnch_pc_sel_from_bhndlr[1]=(inst2[15:14]==2'b10) && (!(inst2[13:12]==2'b00));
assign brnch_pc_sel_from_bhndlr[0]=(inst3[15:14]==2'b10) && (!(inst3[13:12]==2'b00));

/*//if there is branch enable branch predictor
assign update_bpred=hold_for_brnch?0:(isJump[3]?0:
   (brnch_pc_sel_from_bhndlr[3]?1:(isJump[2]?0:
   (brnch_pc_sel_from_bhndlr[2]?1:(isJump[1]?0:
   ((|brnch_pc_sel_from_bhndlr[1:0])?1:0))))));
  */ 

//|brnch_pc_sel_from_bhndlr


//if branch instruction is taken and not flushed, increase counter
//calculate number of instructions before current branch instruction
reg [1:0] incr_cnt;
wire [1:0] brnch_before_inst0,brnch_before_inst1,brnch_before_inst2,brnch_before_inst3;
assign brnch_before_inst0=brnch_cnt;
assign brnch_before_inst1=brnch_before_inst0+brnch_pc_sel_from_bhndlr[3];
assign brnch_before_inst2=brnch_before_inst1+brnch_pc_sel_from_bhndlr[2];
assign brnch_before_inst3=brnch_before_inst2+brnch_pc_sel_from_bhndlr[1];
wire [3:0] exd_cnt;
assign exd_cnt={(brnch_before_inst0>=2'b10),(brnch_before_inst1>=2'b10),
                  (brnch_before_inst2>=2'b10),(brnch_before_inst3>=2'b10)};
wire [3:0] third_brnch;
assign third_brnch[3]=exd_cnt[3]&&brnch_pc_sel_from_bhndlr[3];
assign third_brnch[2]=(exd_cnt[2]&&brnch_pc_sel_from_bhndlr[2])||third_brnch[3];
assign third_brnch[1]=(exd_cnt[1]&&brnch_pc_sel_from_bhndlr[1])||third_brnch[2];
assign third_brnch[0]=(exd_cnt[0]&&brnch_pc_sel_from_bhndlr[0])||third_brnch[1] ;

reg hold_for_brnch;
always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
    hold_for_brnch<=0;
  else if(|third_brnch==1'b1)
    hold_for_brnch<=1;
  else if(&exd_cnt==0)
    hold_for_brnch<=0;
  else
    hold_for_brnch<=hold_for_brnch;
end
/*///limit number of brnches
assign inst0_b=exd_cnt[3]?16'b0:inst0;
assign inst1_b=exd_cnt[3]?16'b0:inst1;
assign inst2_b=exd_cnt[3]?16'b0:inst2;
assign inst3_b=exd_cnt[3]?16'b0:inst3;
*/

//if there is branch enable branch predictor
assign update_bpred=hold_for_brnch?0:((isJump[3]||third_brnch[3])?0:
   (brnch_pc_sel_from_bhndlr[3]?1:((isJump[2]||third_brnch[2])?0:
   (brnch_pc_sel_from_bhndlr[2]?1:((isJump[1]||third_brnch[1])?0:
   ((brnch_pc_sel_from_bhndlr[1])?1:((isJump[0]||third_brnch[0])?0:
   ((brnch_pc_sel_from_bhndlr[0])?1:0))))))));




//update counter
/*
assign incr_cnt=all_nop[3]?2'b00:(all_nop[2]?
   (brnch_pc_sel_from_bhndlr[3]?2'b01:2'b00):
(      all_nop[1]?(   (&brnch_pc_sel_from_bhndlr[3:2])?2'b10:
(   (|brnch_pc_sel_from_bhndlr[3:2])?2'b01:2'b00)):
(   all_nop[0]?(   (|brnch_pc_sel_from_bhndlr[3:1]==0)?2'b00:
(   (^brnch_pc_sel_from_bhndlr[3:1]==1)?2'b01:2'b10)):
(   ((brnch_before_inst3-brnch_cnt)==2'b10)?2'b10:
(   ((brnch_before_inst3-brnch_cnt)==2'b01)?2'b01:
//nothing flushed, check last instruction
((brnch_before_inst3-brnch_cnt+brnch_pc_sel_from_bhndlr[0])==2'b10)?2'b10:
(((brnch_before_inst3-brnch_cnt+brnch_pc_sel_from_bhndlr[0])==2'b01)?2'b01:2'b00))))   ));//nothing flushed
*/

always@(*)begin
    if(all_nop[3]==1)
        incr_cnt=2'b00;
    else if(all_nop[2]==1)begin
        if(brnch_pc_sel_from_bhndlr[3]==1)
            incr_cnt=2'b01;
        else
            incr_cnt=2'b00;
    end else if(all_nop[1]==1)begin
        if(&brnch_pc_sel_from_bhndlr[3:2]==1)
            incr_cnt=2'b10;
        else if(|brnch_pc_sel_from_bhndlr[3:2]==1)
            incr_cnt=2'b01;
        else
            incr_cnt=2'b00;
  end else if(all_nop[0]==1)begin
        if(|brnch_pc_sel_from_bhndlr[3:1]==0)
            incr_cnt=2'b00;
        else if(^brnch_pc_sel_from_bhndlr[3:1]==1)
            incr_cnt=2'b01;
        else
            incr_cnt=2'b10;
  end else//no flush
        incr_cnt=brnch_pc_sel_from_bhndlr[3]+brnch_pc_sel_from_bhndlr[2]
            +brnch_pc_sel_from_bhndlr[1]+brnch_pc_sel_from_bhndlr[0];
  
end



//(brnch_before_inst3>=2'b10)?2'b10:(
 //  ((brnch_before_inst3-brnch_cnt)==2'b01)?2'b01:2'b00);
//(brnch_before_inst0>=2'b10)+(brnch_before_inst1>=2'b10)+
 //  (brnch_before_inst2>=2'b10)+(brnch_before_inst3>=2'b10);

//counter to keep track of number of branches
//counter need to be decreased if misperdiction takes place
always@(posedge clk or negedge rst_n)begin
	if(rst_n==0)
		brnch_cnt<=2'b00;
	else if(decr_count_from_rob==1 && brnch_cnt>2'b00)begin
	//expected if normal brnch commit,decrease one
	   if(mispred_num==1)
		   brnch_cnt<=brnch_cnt-2'b10;
	//if mispredict rob output decr_count also, if mispred_num==1, we decrease two
	   else
	      brnch_cnt<=brnch_cnt-1;
	end
	else if((|incr_cnt)&& (brnch_cnt<2'b10))
	   brnch_cnt<=brnch_cnt+incr_cnt;
	else if(brnch_cnt>=2'b10)
		brnch_cnt<=2'b10;
	else
	   brnch_cnt<=brnch_cnt;
end

//<3>
//check if taken or not
//taken branch 1-taken 0-not taken
//if already flushed no need decide
assign tkn_brnch[3]=(exd_cnt[3])?0:(brnch_pc_sel_from_bhndlr[3]?(pred_to_pcsel[1]?1:0):0);
assign tkn_brnch[2]=(exd_cnt[2])?0:(  brnch_pc_sel_from_bhndlr[2]?
( brnch_pc_sel_from_bhndlr[3]?(pred_to_pcsel[0]?1:0):(pred_to_pcsel[1]?1:0) ):0  );

assign tkn_brnch[1]=(exd_cnt[1])?0:(   (|brnch_pc_sel_from_bhndlr[3:2]==0)?//if there is not branch before3rd inst
(pred_to_pcsel[0]?1:0):(pred_to_pcsel[1]?1:0)   );
assign tkn_brnch[0]=(exd_cnt[3])?0:((|brnch_pc_sel_from_bhndlr[3:1])?
(pred_to_pcsel[0]?1:0):(pred_to_pcsel[1]?1:0));


//<4>
//stall signal, plus tkn, exceed count,jump, if immdediate jump flush at dataout module
//if previous instruction got flushed, latter ones all get flushed
//all_nop=1-->flush
assign all_nop[3]=(stall_for_jump|| stall_fetch||hold_for_brnch)?1:(third_brnch[3]?1:0);
assign all_nop[2]=(stall_for_jump|| stall_fetch||hold_for_brnch)?1:(all_nop[3]?1:(isJump[3]?1:(third_brnch[2]?1:(tkn_brnch[3]?1:0))));
assign all_nop[1]=(stall_for_jump|| stall_fetch||hold_for_brnch)?1:(all_nop[2]?1:(isJump[2]?1:(third_brnch[1]?1:(tkn_brnch[2]?1:0))));
assign all_nop[0]=(stall_for_jump|| stall_fetch||hold_for_brnch)?1:(all_nop[1]?1:(isJump[1]?1:(third_brnch[0]?1:(tkn_brnch[1]?1:0))));


///////////////////////
//Output signals    //
////////////////////
   //for next PC
   assign pcsel_from_bhndlr=(stall_for_jump||stall_fetch||isJump[3])||(|third_brnch)||hold_for_brnch;
   //reg [15:0] pc_bhndlr;//if more than two branches, third got flushed
   
   assign pc_bhndlr=(stall_for_jump||stall_fetch||third_brnch[3]||isJump[3]||hold_for_brnch)?pc:
        (third_brnch[2]?(pc+1):(third_brnch[1]?(pc+2):(third_brnch[0]?(pc+3):pc+4)));

   
   //instructions
   assign instruction0=(all_nop[3])?16'b0:inst0;
   assign instruction1=(all_nop[2])?16'b0:inst1;
   assign instruction2=(all_nop[1])?16'b0:inst2;
   assign instruction3=(all_nop[0])?16'b0:inst3;	
   
   //output branch target address
	assign brnch_inst0=tkn_brnch[3]?inst0:(tkn_brnch[2]?inst1:(tkn_brnch[1]?inst2:(tkn_brnch[0]?inst3:16'b0)));
	assign brnch_inst1=(&tkn_brnch[3:2])?inst1:(((tkn_brnch[3]&tkn_brnch[1])||(&tkn_brnch[2:1]))?inst2:
	(((tkn_brnch[3]&tkn_brnch[0])||(tkn_brnch[2]&tkn_brnch[0])||(&tkn_brnch[1:0]))?inst3:16'b0));

endmodule
