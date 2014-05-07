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
			    input [3:0]       brnch_pc_sel_from_bhndlr,//choose which pc of the instruction to calculate
			    input [15:0]      inst0,
			    input [15:0]      inst1,
			    input [15:0]      inst2,
			    input [15:0]      inst3,
			    input [3:0]       tkn_brnch,
			    input [15:0]      pc,
			    output reg [15:0] brnch_addr_pc0,
			    output reg [15:0] brnch_addr_pc1,
			    output reg [15:0] recv_pc0,
			    output reg [15:0] recv_pc1
			    );

   //internal signal
   wire [15:0] 				      immd_brnch0,immd_brnch1,immd_brnch2,immd_brnch3;
   reg [15:0] 				      brnch_target_addr0,brnch_target_addr1,brnch_target_addr2,brnch_target_addr3;

   assign immd_brnch0={{8{inst0[7]}},inst0[7:0]};
   assign immd_brnch1={{8{inst1[7]}},inst1[7:0]};
   assign immd_brnch2={{8{inst2[7]}},inst2[7:0]};
   assign immd_brnch3={{8{inst3[7]}},inst3[7:0]};

   always@(*)
     if((|brnch_pc_sel_from_bhndlr)==0)//no branch inst
       begin
          brnch_target_addr0=16'b0;
          brnch_target_addr1=16'b0;
          brnch_target_addr2=16'b0;
          brnch_target_addr3=16'b0;
       end else begin
          brnch_target_addr0=pc+1+immd_brnch0;
          brnch_target_addr1=pc+2+immd_brnch1;

          brnch_target_addr2=pc+3+immd_brnch2;
          brnch_target_addr3=pc+4+immd_brnch3;

       end


   //use taken signal to select output
   always@(*)begin
      brnch_addr_pc0=16'b0;
      recv_pc0=16'b0;
      brnch_addr_pc1=16'b0;
      recv_pc1=16'b0;
      if((|brnch_pc_sel_from_bhndlr)&&(^brnch_pc_sel_from_bhndlr))begin//if one bran instruction 
	 brnch_addr_pc1=16'b0;
	 recv_pc1=16'b0;
	 if(brnch_pc_sel_from_bhndlr[3]==1)
	   if(tkn_brnch[3]==1)begin
	      brnch_addr_pc0=brnch_target_addr0;
	      recv_pc0=pc+1;
	   end
	   else begin
	      brnch_addr_pc0=pc+1;
	      recv_pc0=brnch_target_addr0;
	   end
	 else if(brnch_pc_sel_from_bhndlr[2]==1)begin
	    if(tkn_brnch[2]==1)begin
	       brnch_addr_pc0=brnch_target_addr1;
	       recv_pc0=pc+2;
	    end
	    else begin
	       brnch_addr_pc0=pc+2;
	       recv_pc0=brnch_target_addr1;
	    end

	 end else if(brnch_pc_sel_from_bhndlr[1]==1)begin
	    if(tkn_brnch[1]==1)begin
	       brnch_addr_pc0=brnch_target_addr2;
	       recv_pc0=pc+3;
	    end
	    else begin
	       brnch_addr_pc0=pc+3;
	       recv_pc0=brnch_target_addr2;
	    end
	 end else if(brnch_pc_sel_from_bhndlr[0]==1)begin
	    if(tkn_brnch[0]==1)begin
	       brnch_addr_pc0=brnch_target_addr3;
	       recv_pc0=pc+4;
	    end
	    else begin
	       brnch_addr_pc0=pc+4;
	       recv_pc0=brnch_target_addr3;
	    end
	 end 

      end else if((|brnch_pc_sel_from_bhndlr)&&(~^brnch_pc_sel_from_bhndlr))begin//two branches
	 if(brnch_pc_sel_from_bhndlr==4'b1100)begin
	    if(tkn_brnch[3]==1)//first one taken, no need send pc for second one
	      begin
		 brnch_addr_pc0=brnch_target_addr0;
		 recv_pc0=pc+1;
		 brnch_addr_pc1=16'b0;
		 recv_pc1=16'b0;
	      end
	    else if(tkn_brnch[2]==1)//first one not taken
	      begin
		 brnch_addr_pc0=pc+1;
		 recv_pc0=brnch_target_addr0;
		 brnch_addr_pc1=brnch_target_addr1;
		 recv_pc1=pc+2;
	      end
	    else begin
	       brnch_addr_pc0=pc+1;
	       recv_pc0=brnch_target_addr0;
	       brnch_addr_pc1=pc+2;
	       recv_pc1=brnch_target_addr1;
	    end
	 end
	 else if(brnch_pc_sel_from_bhndlr==4'b1010)begin
	    if(tkn_brnch[3]==1)//first one taken, no need send pc for second one
	      begin
		 brnch_addr_pc0=brnch_target_addr0;
		 recv_pc0=pc+1;
		 brnch_addr_pc1=16'b0;
		 recv_pc1=16'b0;
	      end
	    else if(tkn_brnch[1]==1)//first one not taken
	      begin
		 brnch_addr_pc0=pc+1;
		 recv_pc0=brnch_target_addr0;
		 brnch_addr_pc1=brnch_target_addr2;
		 recv_pc1=pc+3;
	      end
	    else begin
	       brnch_addr_pc0=pc+1;
	       recv_pc0=brnch_target_addr0;
	       brnch_addr_pc1=pc+3;
	       recv_pc1=brnch_target_addr2;
	    end
	 end
	 else if(brnch_pc_sel_from_bhndlr==4'b1001)begin
	    if(tkn_brnch[3]==1)//first one taken, no need send pc for second one
	      begin
		 brnch_addr_pc0=brnch_target_addr0;
		 recv_pc0=pc+1;
		 brnch_addr_pc1=16'b0;
		 recv_pc1=16'b0;
	      end
	    else if(tkn_brnch[0]==1)//first one not taken
	      begin
		 brnch_addr_pc0=pc+1;
		 recv_pc0=brnch_target_addr0;
		 brnch_addr_pc1=brnch_target_addr3;
		 recv_pc1=pc+4;
	      end
	    else begin
	       brnch_addr_pc0=pc+1;
	       recv_pc0=brnch_target_addr0;
	       brnch_addr_pc1=pc+4;
	       recv_pc1=brnch_target_addr3;
	    end

	 end
	 else if(brnch_pc_sel_from_bhndlr==4'b0110)begin
	    if(tkn_brnch[2]==1)//first one taken, no need send pc for second one
	      begin
		 brnch_addr_pc0=brnch_target_addr1;
		 recv_pc0=pc+2;
		 brnch_addr_pc1=16'b0;
		 recv_pc1=16'b0;
	      end
	    else if(tkn_brnch[1]==1)//first one not taken
	      begin
		 brnch_addr_pc0=pc+2;
		 recv_pc0=brnch_target_addr1;
		 brnch_addr_pc1=brnch_target_addr2;
		 recv_pc1=pc+3;
	      end
	    else begin
	       brnch_addr_pc0=pc+2;
	       recv_pc0=brnch_target_addr1;
	       brnch_addr_pc1=pc+3;
	       recv_pc1=brnch_target_addr2;
	    end
	 end
	 else if(brnch_pc_sel_from_bhndlr==4'b0101)begin

	    if(tkn_brnch[2]==1)//first one taken, no need send pc for second one
	      begin
		 brnch_addr_pc0=brnch_target_addr1;
		 recv_pc0=pc+2;
		 brnch_addr_pc1=16'b0;
		 recv_pc1=16'b0;
	      end
	    else if(tkn_brnch[0]==1)//first one not taken
	      begin
		 brnch_addr_pc0=pc+2;
		 recv_pc0=brnch_target_addr1;
		 brnch_addr_pc1=brnch_target_addr3;
		 recv_pc1=pc+4;
	      end
	    else begin
	       brnch_addr_pc0=pc+2;
	       recv_pc0=brnch_target_addr1;
	       brnch_addr_pc1=pc+4;
	       recv_pc1=brnch_target_addr3;
	    end
	 end
	 else if(brnch_pc_sel_from_bhndlr==4'b0011)begin

	    if(tkn_brnch[1]==1)//first one taken, no need send pc for second one
	      begin
		 brnch_addr_pc0=brnch_target_addr2;
		 recv_pc0=pc+3;
		 brnch_addr_pc1=16'b0;
		 recv_pc1=16'b0;
	      end
	    else if(tkn_brnch[0]==1)//first one not taken
	      begin
		 brnch_addr_pc0=pc+3;
		 recv_pc0=brnch_target_addr2;
		 brnch_addr_pc1=brnch_target_addr3;
		 recv_pc1=pc+4;
	      end
	    else begin
	       brnch_addr_pc0=pc+3;
	       recv_pc0=brnch_target_addr2;
	       brnch_addr_pc1=pc+4;
	       recv_pc1=brnch_target_addr3;
	    end

	 end
      end//two branch
      else
	begin
	   brnch_addr_pc0=16'b0;
	   recv_pc0=16'b0;
	   brnch_addr_pc1=16'b0;
	   recv_pc1=16'b0;
	end
   end//always



   //add recov pc

endmodule
