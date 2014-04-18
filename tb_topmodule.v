`timescale 1ns / 1ps
module tb_topmodule();
   
   reg clk;
   reg rst_n;
   reg [15:0] extern_pc;
   reg 	      extern_pc_en;


   

   
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
      
      
      $display("%t, instruction0 is %x,instruction1 is %x,instruction2 is %x,instruction3 is %x\n",$time,DUT.inst_to_dec[63:48],DUT.inst_to_dec[47:32],DUT.inst_to_dec[31:16],DUT.inst_to_dec[15:0]);
      $display("%t, decode inst0 out is %b %b %b %b %b\n",$time,DUT.dcd_inst1_out_to_AL[65:64],DUT.dcd_inst1_out_to_AL[63:48],DUT.dcd_inst1_out_to_AL[47:32],DUT.dcd_inst1_out_to_AL[31:16],DUT.dcd_inst1_out_to_AL[15:0]);
      
      $display("%t, pack0 receive is %x,pack1 receive is %x,pack2 receive is %x,pack3 receive is %x\n",$time,DUT.inst0_id_al_out,DUT.inst1_id_al_out,DUT.inst2_id_al_out,DUT.inst3_id_al_out);

      $display("%t, recver pc to cmt is %x\n",$time,DUT.rcvr_pc_to_CMT);
      $display("%t, reg write to CMT is %b\n",$time,DUT.reg_wrt_to_CMT);
      $display("%t, st_en_to_CMT is %b\n",$time,DUT.st_en_to_CMT);
      $display("%t, ld_en_to_CMT is %b\n",$time,DUT.ld_en_to_CMT);
      $display("%t, spec_to_CMT is %b\n",$time,DUT.spec_to_CMT);
      $display("%t, brch_mode_to_CMT is %b\n",$time,DUT.brch_mode_to_CMT);
      $display("%t, brch_pred_result is %b\n",$time,DUT.brch_pred_res_to_CMT);
      $display("///////////////////////////////////////////////////////////////////////////////////\n");
      
   end // always@ (posedge clk)
   
      



   initial begin
      #100;
      $finish;
      
   end
   
   
endmodule // tb_topmodule
