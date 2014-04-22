`timescale 1ns / 1ps
module tb_topmodule();
   
   reg clk;
   reg rst_n;
   reg [15:0] extern_pc;
   reg 	      extern_pc_en;
   integer    i;

   

   
   top_module_looper DUT(/*autoinst*/
			 // Inputs
			 .clk			(clk),
			 .rst_n			(rst_n),
			 .extern_pc		(extern_pc[15:0]),
			 .extern_pc_en		(extern_pc_en));


   initial begin
      $wlfdumpvars(0,tb_topmodule);
      clk = 0;
      forever #5 clk = ~clk;
   end

   initial begin
      rst_n = 1'b0;
      #7 rst_n = 1'b1;
   end
   
   initial begin
      extern_pc = 16'b0;
      extern_pc_en = 1'b0;
   end
   
   
   always@(posedge clk)begin
      #2;
      
      
      $display("%t, IF: instruction0 is %x,instruction1 is %x,instruction2 is %x,instruction3 is %x\n",$time,DUT.inst_to_dec[63:48],DUT.inst_to_dec[47:32],DUT.inst_to_dec[31:16],DUT.inst_to_dec[15:0]);
      $display("%t, ID: decode inst0 out is %b %b %b %b %b\n",$time,DUT.dcd_inst1_out_to_AL[65:64],DUT.dcd_inst1_out_to_AL[63:48],DUT.dcd_inst1_out_to_AL[47:32],DUT.dcd_inst1_out_to_AL[31:16],DUT.dcd_inst1_out_to_AL[15:0]);
      
      $display("%t, ID_AL: pack0 receive is %x,pack1 receive is %x,pack2 receive is %x,pack3 receive is %x\n",$time,DUT.inst0_id_al_out,DUT.inst1_id_al_out,DUT.inst2_id_al_out,DUT.inst3_id_al_out);

      $display("%t, AL:recver pc to cmt is %x\n",$time,DUT.rcvr_pc_to_CMT);
      $display("%t, AL:reg write to CMT is %b\n",$time,DUT.reg_wrt_to_CMT);
      $display("%t, AL:st_en_to_CMT is %b\n",$time,DUT.st_en_to_CMT);
      $display("%t, AL:ld_en_to_CMT is %b\n",$time,DUT.ld_en_to_CMT);
      $display("%t, AL:spec_to_CMT is %b\n",$time,DUT.spec_to_CMT);
      $display("%t, AL:brch_mode_to_CMT is %b\n",$time,DUT.brch_mode_to_CMT);
      $display("%t, AL:brch_pred_result is %b\n",$time,DUT.brch_pred_res_to_CMT);
      $display("%t, AL:pr_need_inst is %b\n",$time,DUT.al_DUT.pr_need_inst);      
      $display("%t, AL:preg0 is %d, preg1 is %d, preg2 is %d, preg3 is %d\n",$time,DUT.inst_out_to_SCH0[5:0],DUT.inst_out_to_SCH1[5:0],DUT.inst_out_to_SCH2[5:0],DUT.inst_out_to_SCH3[5:0]);

      
      //$display("%t, SQ:insert signal is %b",$time, DUT.top_level_WB_DUT.sq.insert);
      //$display("%t, SQ:first is %b",$time, DUT.top_level_WB_DUT.sq.update);
/* -----\/----- EXCLUDED -----\/-----
      
      
      
      $display("%t, LQ:the 0 entry is %x, the 1 entry is %x\n",$time,DUT.top_level_WB_DUT.lq.ld_entry[0][41:0],DUT.top_level_WB_DUT.lq.ld_entry[1][41:0]);
 -----/\----- EXCLUDED -----/\----- */
      
      
      $display("///////////////////////////////////////////////////////////////////////////////////\n");

   end // always@ (posedge clk)
   


/* -----\/----- EXCLUDED -----\/-----

   always@(posedge clk)
     begin
	//#2;
	$display("///////////////////////////////////////////////////////////////////////////////////\n");
	$display("%t, rf:read_alu1_op1_pnum is %d, read_alu1_op2_pnum is %d,read_alu2_op1_pnum is %d,read_alu2_op2_pnum is %d\n",$time,DUT.reg_file_DUT.read_alu1_op1_pnum,DUT.reg_file_DUT.read_alu1_op2_pnum,DUT.reg_file_DUT.read_alu2_op1_pnum,DUT.reg_file_DUT.read_alu2_op2_pnum);
	$display("%t, rf:wrt_alu1_dst_pnum is %d, wrt_alu2_vld is %d, wrt_alu2_dst_pnum is %d, wrt_alu2_vld is %d\n",$time,DUT.reg_file_DUT.wrt_alu1_dst_pnum,DUT.reg_file_DUT.wrt_alu1_vld,DUT.reg_file_DUT.wrt_alu2_dst_pnum,DUT.reg_file_DUT.wrt_alu2_vld);
	$display("%t, rf:read_alu1_op1_data is %x, read_alu1_op2_data is %x, read_alu2_op1_data is %x, read_alu2_op2_data is %x\n",$time,DUT.reg_file_DUT.read_alu1_op1_data,DUT.reg_file_DUT.read_alu1_op2_data,DUT.reg_file_DUT.read_alu2_op1_data,DUT.reg_file_DUT.read_alu2_op2_data);
	$display("%t, rf:wrt_alu1_data is %x, wrt_alu2_data is %x\n",$time,DUT.reg_file_DUT.wrt_alu1_data,DUT.reg_file_DUT.wrt_alu2_data);
	$display("///////////////////////////////////////////////////////////////////////////////////\n");
     end

 -----/\----- EXCLUDED -----/\----- */
   
	   
/* -----\/----- EXCLUDED -----\/-----
   end // always@ (posedge clk)
   
   always@(posedge clk) begin
      $display("/////////////////////////////////ROB PART//////////////////////////////////////////////////\n");
      $display("%t, ROB:vld is %b\n",$time,DUT.rob_DUT.rob_vld[3:0]);
      $display("%t, ROB:done is %b\n",$time,DUT.rob_DUT.rob_done[3:0]);
     // $display("%t, ROB:brnc is %b\n",$time,DUT.rob_DUT.brnc[3:0]);
      $display("%t, ROB:st is %b\n",$time,DUT.rob_DUT.rob_st[3:0]);
      $display("%t, ROB:st_ptr is %b\n",$time,DUT.rob_DUT.rob_st_ptr[2]);
      $display("%t, ROB:ld_ptr is %b\n",$time,DUT.rob_DUT.rob_ld_ptr[3]);
      $display("%t, ROB:reg wrt is %b\n",$time,DUT.rob_DUT.rob_reg_wrt[3:0]);
      //$display("%t, ROB:reg wrt is %b\n",$time,DUT.rob_DUT.rob_reg_wrt[3:0]);
      $display("%t, ROB:tail is %b\n",$time,DUT.rob_DUT.rob_tail);
      $display("//////////////////////////////////////////////////////////////////////////////////////////\n");
   end // always@ (posedge clk)
 -----/\----- EXCLUDED -----/\----- */
   
/* -----\/----- EXCLUDED -----\/-----

   always@(posedge clk)
     begin
	if(DUT.top_level_WB_DUT.sq.insert)
	  begin
	     for(i = 0; i < 24; i = i + 1)
	       begin
		  $display("SQ:first i is %b", DUT.top_level_WB_DUT.sq.first[i]);		  
		  $display("SQ:first idx is %b", DUT.top_level_WB_DUT.sq.first_indx);
		  
		  $display("SQ:the %d entry is %x\n",i,DUT.top_level_WB_DUT.sq.str_entry[i][40:0]);
		  
	       end
	  end
     end // always@ (posedge )
   
 -----/\----- EXCLUDED -----/\----- */

/* -----\/----- EXCLUDED -----\/-----

   initial begin
      #195;
      $display("///////////////////////////////reg file//////////////////////////");
      
      for(i = 0; i < 64; i = i + 1)
	begin
	   $display("reg %d, value is reg_file_body is %x\n",i,DUT.reg_file_DUT.reg_file_body[i]);
	   
	end

      $display("///////////////////////////////reg file//////////////////////////");

   end // initial begin
 -----/\----- EXCLUDED -----/\----- */
   


   initial begin
      #150;

      $display("///////////////////////////////freelist//////////////////////////");
      $display("alloc pointer position is %d \n",DUT.al_DUT.f0.alloc_ptr);
      $display("cmt pointer position is %d \n",DUT.al_DUT.f0.cmt_ptr);
      for(i = 0; i < 64; i = i + 1)
	begin
	   $display("free lis %d, value is %d \n",i, DUT.al_DUT.f0.list[i]);
	end
      $display("///////////////////////////////freelist//////////////////////////");
   end
   
   initial begin
      #400;
      $finish;
      
   end
   
   
endmodule // tb_topmodule
