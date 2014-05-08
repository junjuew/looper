
module reorderUnit(/*autoarg*/
   // Outputs
   ld_indx_to_lsq, st_indx_to_lsq,
   // Inputs
   inst_in0, inst_in1, inst_in2, inst_in3, nxt_indx,stall
   );

   input wire [65:0] inst_in0,inst_in1,inst_in2,inst_in3;

   input wire [6:0] 	nxt_indx;

   input wire		stall;
   output wire [31:0] 	ld_indx_to_lsq;
   output wire [31:0] st_indx_to_lsq;
   
   
   wire [6:0]	      indx1,indx2,indx3;
   wire 	      valid;
   
   
   assign indx1 = nxt_indx + 7'h1;   
   assign indx2 = nxt_indx + 7'h2;   
   assign indx3 = nxt_indx + 7'h3;
   
   assign valid = ~stall;
   
   assign ld_indx_to_lsq[7:0] = inst_in0[26] ? {valid,nxt_indx} : (inst_in1[26] ? {valid,indx1} : (inst_in2[26] ? {valid,indx2} : (inst_in3[26] ? {valid,indx3} : 8'b0)));

   assign ld_indx_to_lsq[15:8] = (inst_in0[26] && inst_in1[26]) ? {valid,indx1}:
				 ((inst_in0[26] && inst_in2[26]) || (inst_in1[26] && inst_in2[26])) ? {valid,indx2}:
				 ((inst_in0[26] && inst_in3[26]) || (inst_in1[26] && inst_in3[26]) || (inst_in2[26] && inst_in3[26])) ? {valid,indx3}:
				 8'b0;
   

   assign ld_indx_to_lsq[23:16] = (inst_in0[26] && inst_in1[26] && inst_in2[26]) ? {valid,indx2}:
				  ((inst_in0[26] && inst_in1[26] && inst_in3[26]) || (inst_in0[26] && inst_in2[26] && inst_in3[26]) || (inst_in2[26] && inst_in1[26] && inst_in3[26])) ? {valid,indx3}:8'b0;
   

   assign ld_indx_to_lsq[31:24] = (inst_in0[26] && inst_in1[26] && inst_in2[26] && inst_in3[26]) ? {valid,indx3} : 8'b0;


   assign st_indx_to_lsq[7:0] = inst_in0[25] ? {valid,nxt_indx} : (inst_in1[25] ? {valid,indx1} : (inst_in2[25] ? {valid,indx2} : (inst_in3[25] ? {valid,indx3} : 8'b0)));

   assign st_indx_to_lsq[15:8] = (inst_in0[25] && inst_in1[25]) ? {valid,indx1}:
				 ((inst_in0[25] && inst_in2[25]) || (inst_in1[25] && inst_in2[25])) ? {valid,indx2}:
				 ((inst_in0[25] && inst_in3[25]) || (inst_in1[25] && inst_in3[25]) || (inst_in2[25] && inst_in3[25])) ? {valid,indx3}:
				 8'b0;

   
   assign st_indx_to_lsq[23:16] = (inst_in0[25] && inst_in1[25] && inst_in2[25]) ? {valid,indx2}:
				  ((inst_in0[25] && inst_in1[25] && inst_in3[25]) || (inst_in0[25] && inst_in2[25] && inst_in3[25]) || (inst_in2[25] && inst_in1[25] && inst_in3[25])) ? {valid,indx3}:8'b0;
   assign st_indx_to_lsq[31:24] = (inst_in0[25] && inst_in1[25] && inst_in2[25] && inst_in3[25]) ? {valid,indx3} : 8'b0;



   
   
 
   
endmodule // reorderUnit
