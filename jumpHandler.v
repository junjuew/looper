`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:06:24 03/22/2014 
// Design Name: 
// Module Name:    jumpHandler 
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
module jumpHandler(input clk,
	input rst_n,
	input [15:0] pc,
    input [15:0] instruction0,
    input [15:0] instruction1,
    input [15:0] instruction2,
    input [15:0] instruction3,
	 input [15:0]jump_base_from_rf_0,
	 input jump_base_rdy_from_rf_0,
	 //input [15:0] jump_base_for_fetch,
	// input jump_base_rdy_for_fetch,
    output reg[15:0] jump_addr_pc,
    output reg jump_for_pcsel,
    output reg stall_for_jump
    );

//internal signal
reg [15:0] jump_pc;//register to hold pc of register-based jump
reg wtJumpAddr,preJmp;

reg [15:0]jump_base_from_rf;
reg jump_base_rdy_from_rf,jump_base_rdy_from_rf_buf; 
reg disable_ins;
//assign disable_ins=0;
   
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
       jump_base_from_rf<=16'b0;
	    jump_base_rdy_from_rf_buf<=0;
	     
	 end else begin
	    jump_base_from_rf<=jump_base_from_rf_0;
	    jump_base_rdy_from_rf_buf<=jump_base_rdy_from_rf_0;
	    
	  end  
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    jump_base_rdy_from_rf<=0;
    
   end else
   jump_base_rdy_from_rf<=jump_base_rdy_from_rf_buf;
end


always@(posedge clk or negedge rst_n)
   if(!rst_n)
    disable_ins<=0;
   else if(jump_base_rdy_from_rf_0)
    disable_ins<=1;
   else if(jump_for_pcsel==1)
      disable_ins<=1;






//reg [15:0]in_pc;
wire ImJmp0=(instruction0[15:12]==4'b1111)&&(instruction0[0]==0);
wire ImJmp1=(instruction1[15:12]==4'b1111)&&(instruction1[0]==0);
wire ImJmp2=(instruction2[15:12]==4'b1111)&&(instruction2[0]==0);
wire ImJmp3=(instruction3[15:12]==4'b1111)&&(instruction3[0]==0);
wire existImdJmp=ImJmp0||ImJmp1||ImJmp2||ImJmp3;
wire BsJmp0=disable_ins?0:(instruction0[15:12]==4'b1111)&&(instruction0[0]==1);
wire BsJmp1=disable_ins?0:(instruction1[15:12]==4'b1111)&&(instruction1[0]==1);
wire BsJmp2=disable_ins?0:(instruction2[15:12]==4'b1111)&&(instruction2[0]==1);
wire BsJmp3=disable_ins?0:(instruction3[15:12]==4'b1111)&&(instruction3[0]==1);




//assign jump_for_pcsel=(!rst_n)?0:
 //  (wtJumpAddr?0:(jump_base_rdy_from_rf?1:(preJmp?0:(existImdJmp?1:0))));
 //change to reg
 always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
       jump_for_pcsel<=0;
    //else if(wtJumpAddr)
     //  jump_for_pcsel<=0;
     
    end
    else if(jump_base_rdy_from_rf)begin
        jump_for_pcsel<=1;
        
   end
    else if(preJmp)begin
       jump_for_pcsel<=0;
       
   end
    else if(existImdJmp)begin
       jump_for_pcsel<=1;
       
   end
    else
    jump_for_pcsel<=0;
     
 
 end
 


/*assign jump_addr_pc=(!rst_n)?16'b0:(wtJumpAddr?16'b0://not sure if we want wtJmpAddr
   (jump_base_rdy_from_rf?(jump_pc+jump_base_from_rf):(preJmp?16'b0:
   (ImJmp0?(pc+1+{{6{instruction0[11]}},instruction0[11:2]}):
   (ImJmp1?(pc+1+{{6{instruction1[11]}},instruction1[11:2]}):
   (ImJmp2?(pc+1+{{6{instruction2[11]}},instruction2[11:2]}):
   (ImJmp3?(pc+1+{{6{instruction3[11]}},instruction3[11:2]}):16'b0)))))));*/
wire [15:0] ImJmp_addr;
assign ImJmp_addr=(ImJmp0?(pc+1+{{6{instruction0[11]}},instruction0[11:2]}):
   (ImJmp1?(pc+2+{{6{instruction1[11]}},instruction1[11:2]}):
   (ImJmp2?(pc+3+{{6{instruction2[11]}},instruction2[11:2]}):
   (ImJmp3?(pc+4+{{6{instruction3[11]}},instruction3[11:2]}):16'b0))));
always@(posedge clk or negedge rst_n)begin
   if(!rst_n)
      jump_addr_pc<=16'b0;
    else if(jump_base_rdy_from_rf_buf)
       jump_addr_pc<=jump_pc+jump_base_from_rf;
    else if(preJmp)
       jump_addr_pc<=16'b0;
    else if(existImdJmp)
       jump_addr_pc<=ImJmp_addr;
    else
       jump_addr_pc<=jump_addr_pc;
end


   
always@(posedge clk or negedge rst_n) begin
    
   if(!rst_n)begin
        stall_for_jump<=0;
        jump_pc<=16'b0;
        wtJumpAddr<=0;
        preJmp<=0;
   end else begin
	
	//if already waiting for a jump instruction
	   if(wtJumpAddr==1)begin
		   stall_for_jump<=1;
		   jump_pc<=jump_pc;
		   //disable_ins<=1;
	      //while waiting addr, keep checking rdy signal
	      if(jump_base_rdy_from_rf)begin//once rdy, clear stall,wt
		   stall_for_jump<=0;
		   wtJumpAddr<=0;
		   //jump_pc<=16'b0;//clear internal reg
		   end
	   end else	if(ImJmp0)begin
				stall_for_jump<=0;
				jump_pc<=0;
				wtJumpAddr<=0;
				preJmp<=1;
		end else if(BsJmp0)begin
				wtJumpAddr<=1;
				jump_pc<={{10{instruction0[7]}},instruction0[7:2]};
				stall_for_jump<=1;
      end else if(ImJmp1)begin
			   stall_for_jump<=0;
				jump_pc<=0;
				wtJumpAddr<=0;
				preJmp<=1;
		end else if(BsJmp1)begin
				wtJumpAddr<=1;
				jump_pc<={{10{instruction1[7]}},instruction1[7:2]};
				stall_for_jump<=1;
		end else if(ImJmp2) begin
				stall_for_jump<=0;
				jump_pc<=0;
				wtJumpAddr<=0;
				preJmp<=1;
		end else if(BsJmp2) begin
				wtJumpAddr<=1;
				jump_pc<={{10{instruction2[7]}},instruction2[7:2]};
				stall_for_jump<=1;
		end else if(ImJmp3)begin
				stall_for_jump<=0;
				jump_pc<=0;
				wtJumpAddr<=0;
				preJmp<=1;
		end else if (BsJmp3)begin
				wtJumpAddr<=1;
				jump_pc<={{10{instruction3[7]}},instruction3[7:2]};
				stall_for_jump<=1;
		end else begin
		    wtJumpAddr<=0;
		    jump_pc<=jump_pc;
		    stall_for_jump<=0;
		    preJmp<=0;
		end
	
	end//rst_n

end//always

endmodule
