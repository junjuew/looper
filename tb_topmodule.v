`timescale 1ns / 1ps
module tb_topmodule();
   
   reg clk;
   reg rst_n;
   reg [15:0] extern_pc;
   reg        extern_pc_en;
   reg        flush_cache;
   
   integer    i;

   parameter testdone = 150000;
   parameter flush_mem = testdone - 2000;
   parameter dumptime = testdone - 5;
   


`include "is_dump_map.task"
`include "is_dump_inst.task"
`include "rf_dump_reg.task"
`include "mem_dump.task"
//`include "rf_dump_reg_all_time.task"


   
   /*autowire*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [63:0] mmu_mem_doutb;          // From DUT of top_module_looper.v
   // End of automatics
   /*autoreginput*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [13:0]  mmu_mem_addrb;          // To DUT of top_module_looper.v
   reg         mmu_mem_clk;            // To DUT of top_module_looper.v
   reg [63:0]  mmu_mem_dinb;           // To DUT of top_module_looper.v
   reg         mmu_mem_enb;            // To DUT of top_module_looper.v
   reg         mmu_mem_rst;            // To DUT of top_module_looper.v
   reg         mmu_mem_web;            // To DUT of top_module_looper.v
   // End of automatics
   
   top_module_looper DUT(/*autoinst*/
                         // Outputs
                         .mmu_mem_doutb         (mmu_mem_doutb[63:0]),
                         // Inputs
                         .mmu_mem_clk           (mmu_mem_clk),
                         .mmu_mem_rst           (mmu_mem_rst),
                         .mmu_mem_enb           (mmu_mem_enb),
                         .mmu_mem_web           (mmu_mem_web),
                         .mmu_mem_addrb         (mmu_mem_addrb[13:0]),
                         .mmu_mem_dinb          (mmu_mem_dinb[63:0]),
                         .clk                   (clk),
                         .rst_n                 (rst_n),
                         .flush_cache           (flush_cache),
                         .extern_pc             (extern_pc[15:0]),
                         .extern_pc_en          (extern_pc_en));


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

      mmu_mem_clk         =0;          
      mmu_mem_rst       =0;
      mmu_mem_enb     =0;
      mmu_mem_web   =0;
      mmu_mem_addrb[13:0] =0;
      mmu_mem_dinb[63:0] =0;
      
   end
   

   initial begin
      flush_cache = 1'b0;
      #flush_mem;
      flush_cache = 1'b1;
   end
  

    initial begin
    #300
        extern_pc_en=1'b1;
        extern_pc=16'h0004;
    #10
        extern_pc_en=1'b0;
        extern_pc=16'b0;
    end

   /* -----\/----- EXCLUDED -----\/-----
    always@(posedge clk)begin
    #2;
    
    
    /-* -----\/----- EXCLUDED -----\/-----
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
    /-* -----\/----- EXCLUDED -----\/-----
    
    
    
    $display("%t, LQ:the 0 entry is %x, the 1 entry is %x\n",$time,DUT.top_level_WB_DUT.lq.ld_entry[0][41:0],DUT.top_level_WB_DUT.lq.ld_entry[1][41:0]);
    -----/\----- EXCLUDED -----/\----- *-/
    
    
    $display("///////////////////////////////////////////////////////////////////////////////////\n");
    -----/\----- EXCLUDED -----/\----- *-/

   end // always@ (posedge clk)
    -----/\----- EXCLUDED -----/\----- */
   


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
   always@(posedge clk)
     begin
        if(DUT.al_DUT.br0.brnc_count != 2'b00)
          begin
             $display("///////////////////////////branch come in////////////////////////////\n");
             $display("time is %t\n",$time);
             $display("the current position is %x\n",DUT.al_DUT.br0.curr_pos);
             
             $display("the comming brcn signal is %b\n",{DUT.al_DUT.br0.brch3,DUT.al_DUT.br0.brch2,DUT.al_DUT.br0.brch1,DUT.al_DUT.br0.brch0});
             $display("the comming index is %d\n",DUT.al_DUT.br0.nxt_indx);
             $display("head is %b, tail is %b\n",DUT.al_DUT.br0.head,DUT.al_DUT.br0.tail);
             
             $display("the value input into reg0 is %x, the input into reg2 is %x \n" ,DUT.al_DUT.br0.fifo_update_val[0],DUT.al_DUT.br0.fifo_update_val[1]);
             $display("the enable signal 0 is %b, the enable signal 1 is %b",DUT.al_DUT.br0.fifo_enable[0],DUT.al_DUT.br0.fifo_enable[1]);
             #5;
             $display("%t,the content in reg0 is %x, the content in reg1 is %x\n",$time,DUT.al_DUT.br0.fifo[0],DUT.al_DUT.br0.fifo[1]);
             $display("%t, store_indx0 is %d, store_pos0 is %x, store_indx1 is %d, store_pos1 is %x\n",$time,DUT.al_DUT.br0.fifo[0][12:7],DUT.al_DUT.br0.fifo[0][6:0],DUT.al_DUT.br0.fifo[1][12:7],DUT.al_DUT.br0.fifo[1][6:0]);
             
          end
        
     end // always@ (DUT.al_DUT.br0.brch0,DUT.al_DUT.br0.brch1,DUT.al_DUT.br0.brch2,DUT.al_DUT.br0.brch3)

   always@(posedge DUT.al_DUT.br0.cmt_brch,posedge DUT.al_DUT.br0.mis_pred)
     begin
        $display("////////////////////////////mispred or cmt//////////////////////////////\n");
        $display("time is %t\n",$time);
        $display("the cmt signal is %b, the mis_pred signal is %b\n",DUT.al_DUT.br0.cmt_brch,DUT.al_DUT.br0.mis_pred);
        $display("the cmt index is %d, the mis index is %d\n",DUT.al_DUT.br0.cmt_brch_indx,DUT.al_DUT.br0.brch_mis_indx);
        $display("head is %b, tail is %b",DUT.al_DUT.br0.head,DUT.al_DUT.br0.tail);
        $display("the content in reg0 is %x, the content in reg1 is %x\n",DUT.al_DUT.br0.fifo[0],DUT.al_DUT.br0.fifo[1]);
        $display("store_indx0 is %d, store_pos0 is %x, store_indx1 is %d, store_pos1 is %x\n",DUT.al_DUT.br0.fifo[0][12:7],DUT.al_DUT.br0.fifo[0][6:0],DUT.al_DUT.br0.fifo[1][12:7],DUT.al_DUT.br0.fifo[1][6:0]);
        #5;
        $display("%t,head is %b, tail is %b",$time,DUT.al_DUT.br0.head,DUT.al_DUT.br0.tail);
        $display("%t,the content in reg0 is %x, the content in reg1 is %x\n",$time,DUT.al_DUT.br0.fifo[0],DUT.al_DUT.br0.fifo[1]);
        $display("%t, store_indx0 is %d, store_pos0 is %x, store_indx1 is %d, store_pos1 is %x\n",$time,DUT.al_DUT.br0.fifo[0][12:7],DUT.al_DUT.br0.fifo[0][6:0],DUT.al_DUT.br0.fifo[1][12:7],DUT.al_DUT.br0.fifo[1][6:0]);
     end // always@ (posedge DUT.al_DUT.br0.cmt_brch,posedge DUT.al_DUT.br0.mis_ped)




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
    #4995;
    $display("///////////////////////////////reg file//////////////////////////");
    
    for(i = 0; i < 64; i = i + 1)
    begin
    $display("reg %d, value is reg_file_body is %x\n",i,DUT.reg_file_DUT.reg_file_body[i]);
    
        end

    $display("///////////////////////////////reg file//////////////////////////");

   end // initial begin

    -----/\----- EXCLUDED -----/\----- */


   

   /*
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


    always@(posedge DUT.mis_pred_ROB_out)
    begin
    #10;
    $display("///////////////////////////////mispredict//////////////////////////");
    $display("alloc pointer position is %d \n",DUT.al_DUT.f0.alloc_ptr);
    $display("cmt pointer position is %d \n",DUT.al_DUT.f0.cmt_ptr);
    $display("in the fifo: fifo 0  is %x, fifo1 is %x \n",DUT.al_DUT.br0.fifo[0],DUT.al_DUT.br0.fifo[1]);
    $display("///////////////////////////////mispredict//////////////////////////");

     end
    */


   always@(posedge clk)
     begin
	#0;
	$display("%t, the coming store is %b",$time,{DUT.al_DUT.r0.inst_in0[25],DUT.al_DUT.r0.inst_in1[25],DUT.al_DUT.r0.inst_in2[25],DUT.al_DUT.r0.inst_in3[25]});
	
	$display("%t,first store valid is %b, first store index is %d\n", $time, DUT.al_DUT.r0.st_indx_to_lsq[7],DUT.al_DUT.r0.st_indx_to_lsq[5:0]);
	$display("%t,second store valid is %b, second store index is %d\n", $time, DUT.al_DUT.r0.st_indx_to_lsq[15],DUT.al_DUT.r0.st_indx_to_lsq[13:8]);
	$display("%t,third store valid is %b, third store index is %d\n", $time, DUT.al_DUT.r0.st_indx_to_lsq[23],DUT.al_DUT.r0.st_indx_to_lsq[21:16]);
	$display("%t,fourth store valid is %b, first fourth index is %d\n", $time, DUT.al_DUT.r0.st_indx_to_lsq[31],DUT.al_DUT.r0.st_indx_to_lsq[29:24]);
     end

   
   
   
   initial begin
      #testdone;
      /* -----\/----- EXCLUDED -----\/-----
       $monitor ("mult_enable_to_is:%b mult_done: %b mult_value:%x", DUT.mult_rdy_is_rf, DUT.mult_valid_ex_out, DUT.mult_data_ex_out);
       -----/\----- EXCLUDED -----/\----- */

      //flush all dump files
      $fflush(dump_1);
      $fflush(dump_2);
      //$fflush(reg_dump);      
      
      $fclose(dump_1);
      $fclose(dump_2);
      //$fclose(reg_dump);      
      
      
      $finish;
      
   end

   /* -----\/----- EXCLUDED -----\/-----

    //snapshot functions for issue stage output   
    task snapshot;
    begin
    $strobe("######## issue output ##############");
    $strobe("%g mul vld:%x, idx:%x, psrc1:%x, psrc2:%x, pdest:%x, ctrl:%x, free_preg:%x",$time, DUT.is_DUT.mul_ins_to_rf[65],DUT.is_DUT.mul_ins_to_rf[64:59], DUT.is_DUT.mul_ins_to_rf[58:52], DUT.is_DUT.mul_ins_to_rf[51:45], DUT.is_DUT.mul_ins_to_rf[44:39], DUT.is_DUT.mul_ins_to_rf[38:6], DUT.is_DUT.mul_ins_to_rf[5:0]);
    $strobe("%g alu1 vld:%x, idx:%x, psrc1:%x, psrc2:%x, pdest:%x, ctrl:%x, free_preg:%x",$time, DUT.is_DUT.alu1_ins_to_rf[65],DUT.is_DUT.alu1_ins_to_rf[64:59], DUT.is_DUT.alu1_ins_to_rf[58:52], DUT.is_DUT.alu1_ins_to_rf[51:45], DUT.is_DUT.alu1_ins_to_rf[44:39], DUT.is_DUT.alu1_ins_to_rf[38:6], DUT.is_DUT.alu1_ins_to_rf[5:0]);
    $strobe("%g alu2 vld:%x, idx:%x, psrc1:%x, psrc2:%x, pdest:%x, ctrl:%x, free_preg:%x",$time, DUT.is_DUT.alu2_ins_to_rf[65],DUT.is_DUT.alu2_ins_to_rf[64:59], DUT.is_DUT.alu2_ins_to_rf[58:52], DUT.is_DUT.alu2_ins_to_rf[51:45], DUT.is_DUT.alu2_ins_to_rf[44:39], DUT.is_DUT.alu2_ins_to_rf[38:6], DUT.is_DUT.alu2_ins_to_rf[5:0]);
    $strobe("%g addr vld:%x, idx:%x, psrc1:%x, psrc2:%x, pdest:%x, ctrl:%x, free_preg:%x",$time, DUT.is_DUT.adr_ins_to_rf[65],DUT.is_DUT.adr_ins_to_rf[64:59], DUT.is_DUT.adr_ins_to_rf[58:52], DUT.is_DUT.adr_ins_to_rf[51:45], DUT.is_DUT.adr_ins_to_rf[44:39], DUT.is_DUT.adr_ins_to_rf[38:6], DUT.is_DUT.adr_ins_to_rf[5:0]);
    $strobe("%g ful_to_al:%x", $time, DUT.is_DUT.ful_to_al);
    $strobe("######################");         
      end
   endtask

    

    always@(DUT.is_DUT.mul_ins_to_rf, DUT.is_DUT.alu1_ins_to_rf, DUT.is_DUT.alu2_ins_to_rf, DUT.is_DUT.adr_ins_to_rf)
    begin
    snapshot();
     end
    -----/\----- EXCLUDED -----/\----- */
   
   

   
   
endmodule // tb_topmodule
