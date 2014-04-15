`default_nettype none

  /////////////////
  //test problem: when load in a new instruction, need to reset dst_rdy_reg
  // to 0, but if synchronous, only can be resetted next cycle
  // need to add async reset to dst_rdy register in tpu_lin
  //////////////////////////////////////////////
  module is_tb();

   /*********** param for stage inputs ***************/
   //vld + 6 bit idx
   parameter BRN_WIDTH=7;
   //vld + 6 bit indx
   parameter PRG_SIG_WIDTH=7;
   parameter INST_WIDTH=56;
   //TODO. need changes, reorganize insts   
   parameter IS_INST_WIDTH = 66;   
   
   //isq
   parameter ISQ_DEPTH = 64;
   // 6 is just an arbitrary value for widths of idx bit   
   parameter ISQ_IDX_BITS_NUM= 6;
   parameter INST_PORT=4;
   parameter ISQ_LINE_WIDTH= INST_WIDTH + ISQ_IDX_BITS_NUM + 1;
   
   //counter
   parameter BITS_IN_COUNT = 4;//=log2(ISQ_DEPTH/INST_PORT)

   //tpu
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   //psrc1 and psrc2 need two more bits than lsrc1, lsrc2, no ldest
   parameter TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5;
   parameter BIT_INST_VLD = INST_WIDTH  - 1 ;
   parameter BIT_INST_WAT= INST_WIDTH +1;
   parameter BIT_LSRC1_VLD = INST_WIDTH   -1 -1  ;   
   parameter BIT_LSRC2_VLD = INST_WIDTH  - 1 - 11;      
   parameter BIT_LDST_VLD = INST_WIDTH  - 1 - 6;

   //pdc
   // which bit is representing each function unit
   parameter FUN_MULT_BIT= 0;
   parameter FUN_ADD1_BIT= 1;
   parameter FUN_ADD2_BIT= 2;
   parameter FUN_ADDR_BIT= 3;
   parameter BIT_IDX= ISQ_LINE_WIDTH-1;
   
   parameter TPU_BIT_IDX= ISQ_LINE_WIDTH-1;
   parameter TPU_BIT_PDEST= 6;         
   parameter TPU_BIT_CTRL_START= ISQ_LINE_WIDTH -1 - ISQ_IDX_BITS_NUM - 2*7;
   parameter TPU_BIT_CTRL_END= TPU_BIT_PDEST + 1;   
   parameter TPU_BIT_INST_VLD= ISQ_LINE_WIDTH -1 -ISQ_IDX_BITS_NUM;
   parameter TPU_BIT_INST_WAT= ISQ_LINE_WIDTH -1 -ISQ_IDX_BITS_NUM -1;   
   parameter TPU_BIT_CTRL_MULT= 10;
   parameter TPU_BIT_CTRL_ADD= 11;
   parameter TPU_BIT_CTRL_ADDR= 9;
   parameter TPU_BIT_CTRL_BR= 21;
   parameter TPU_BIT_CTRL_JMP_VLD= 19;      
   
   
   reg clk,rst_n;

   /********** input **********/
   //input from allocation stage   
   reg [IS_INST_WIDTH-1:0]                      inst_al[3:0];
   wire [4 * INST_WIDTH-1:0] inst_frm_al;

   //input from ROB
   reg  [BRN_WIDTH-1:0]         fls_frm_rob;
   reg  [BRN_WIDTH-1:0]         cmt_frm_rob; //commit signal for branch
   
   //input from execution
   //function rdy
   reg  [3:0]                   fun_rdy_frm_exe;
   //physcial register rdy
   reg  [4 * PRG_SIG_WIDTH-1:0] prg_rdy_frm_exe;

   /********** output **********/
   //to al
    wire                        ful_to_al;
   //to rf
    wire [IS_INST_WIDTH-1:0]    mul_ins_to_rf;
    wire [IS_INST_WIDTH-1:0]    alu1_ins_to_rf;
    wire [IS_INST_WIDTH-1:0]    alu2_ins_to_rf;
    wire [IS_INST_WIDTH-1:0]    adr_ins_to_rf;   
   //to rob
    wire [4* PRG_SIG_WIDTH -1 :0] fre_prg_to_rob;




   reg                          inst_valid;
   reg                          Rs_valid_bit;
   reg [3:0]                    Rs;
   reg                          Rd_valid_bit;
   reg [3:0]                    Rd;
   reg                          Rt_valid_bit;
   reg [3:0]                    Rt;
   reg                          imm_valid_bit;
   reg [15:0]                   imme;
   reg                          LDI;
   reg [1:0]                    brn;
   reg                          jmp_valid_bit;
   reg [1:0]                    jump;
   reg                          MemRd;
   reg                          MemWr;
   reg [2:0]                    ALU_ctrl;
   reg                          ALU_to_adder;
   reg                          ALU_to_mult;
   reg                          ALU_to_addr;
   reg                          invtRt;
   reg                          RegWr;
   reg                          pr_valid;
   reg [5:0]                    pr_number;


   is #(/*AUTOINSTPARAM*/
        // Parameters
        .BRN_WIDTH                      (BRN_WIDTH),
        .PRG_SIG_WIDTH                  (PRG_SIG_WIDTH),
        .INST_WIDTH                     (INST_WIDTH),
        .IS_INST_WIDTH                  (IS_INST_WIDTH),
        .ISQ_DEPTH                      (ISQ_DEPTH),
        .ISQ_IDX_BITS_NUM               (ISQ_IDX_BITS_NUM),
        .INST_PORT                      (INST_PORT),
        .ISQ_LINE_WIDTH                 (ISQ_LINE_WIDTH),
        .BITS_IN_COUNT                  (BITS_IN_COUNT),
        .TPU_MAP_WIDTH                  (TPU_MAP_WIDTH),
        .TPU_INST_WIDTH                 (TPU_INST_WIDTH),
        .BIT_INST_VLD                   (BIT_INST_VLD),
        .BIT_INST_WAT                   (BIT_INST_WAT),
        .BIT_LSRC1_VLD                  (BIT_LSRC1_VLD),
        .BIT_LSRC2_VLD                  (BIT_LSRC2_VLD),
        .BIT_LDST_VLD                   (BIT_LDST_VLD),
        .FUN_MULT_BIT                   (FUN_MULT_BIT),
        .FUN_ADD1_BIT                   (FUN_ADD1_BIT),
        .FUN_ADD2_BIT                   (FUN_ADD2_BIT),
        .FUN_ADDR_BIT                   (FUN_ADDR_BIT),
        .BIT_IDX                        (BIT_IDX),
        .TPU_BIT_IDX                    (TPU_BIT_IDX),
        .TPU_BIT_PDEST                  (TPU_BIT_PDEST),
        .TPU_BIT_CTRL_START             (TPU_BIT_CTRL_START),
        .TPU_BIT_CTRL_END               (TPU_BIT_CTRL_END),
        .TPU_BIT_INST_VLD               (TPU_BIT_INST_VLD),
        .TPU_BIT_INST_WAT               (TPU_BIT_INST_WAT),
        .TPU_BIT_CTRL_MULT              (TPU_BIT_CTRL_MULT),
        .TPU_BIT_CTRL_ADD               (TPU_BIT_CTRL_ADD),
        .TPU_BIT_CTRL_ADDR              (TPU_BIT_CTRL_ADDR),
        .TPU_BIT_CTRL_BR                (TPU_BIT_CTRL_BR),
        .TPU_BIT_CTRL_JMP_VLD           (TPU_BIT_CTRL_JMP_VLD))
   DUT(/*autoinst*/
       // Outputs
       .ful_to_al                       (ful_to_al),
       .mul_ins_to_rf                   (mul_ins_to_rf[IS_INST_WIDTH-1:0]),
       .alu1_ins_to_rf                  (alu1_ins_to_rf[IS_INST_WIDTH-1:0]),
       .alu2_ins_to_rf                  (alu2_ins_to_rf[IS_INST_WIDTH-1:0]),
       .adr_ins_to_rf                   (adr_ins_to_rf[IS_INST_WIDTH-1:0]),
       .fre_prg_to_rob                  (fre_prg_to_rob[4*PRG_SIG_WIDTH-1:0]),
       // Inputs
       .clk                             (clk),
       .rst_n                           (rst_n),
       .inst_frm_al                     (inst_frm_al[4*INST_WIDTH-1:0]),
       .fls_frm_rob                     (fls_frm_rob[BRN_WIDTH-1:0]),
       .cmt_frm_rob                     (cmt_frm_rob[BRN_WIDTH-1:0]),
       .fun_rdy_frm_exe                 (fun_rdy_frm_exe[3:0]),
       .prg_rdy_frm_exe                 (prg_rdy_frm_exe[4*PRG_SIG_WIDTH-1:0]));

   /********* tasks to display the output of issue queue ****************/
   task tell;
      input [IS_INST_WIDTH:0] is_out;
      begin
         $display("==%g vld:%x, idx:%x, psrc1:%x, psrc2:%x, pdest:%x, ctrl:%x, free_preg:%x",$time, is_out[65],is_out[64:59], is_out[58:52], is_out[51:45], is_out[44:39], is_out[38:6], is_out[5:0]);
      end
   endtask
   


   /** function to combine individual signals into a correct instruction***/
   function[INST_WIDTH-1:0] inst;
      input inst_valid;
      input Rs_valid_bit;
      input[3:0] Rs;
      input Rd_valid_bit;
      input[3:0] Rd;
      input Rt_valid_bit;
      input[3:0] Rt;
      input imm_valid_bit;
      input[15:0] imme;
      input LDI;
      input[1:0] brn;
      input jmp_valid_bit;
      input[1:0] jump;
      input MemRd;
      input MemWr;
      input[2:0] ALU_ctrl;
      input ALU_to_adder;
      input ALU_to_mult;
      input ALU_to_addr;
      input invtRt;
      input RegWr;
      input pr_valid;
      input[5:0] pr_number;
      
      inst = {
       inst_valid,
        Rs_valid_bit,
        Rs,
        Rd_valid_bit,
        Rd,
        Rt_valid_bit,
        Rt,
        imm_valid_bit,
        imme,
        LDI,
        brn,
        jmp_valid_bit,
        jump,
        MemRd,
        MemWr,
        ALU_ctrl,
        ALU_to_adder,
        ALU_to_mult,
        ALU_to_addr,
        invtRt,
        RegWr,
        pr_valid,
        pr_number

              };
   endfunction
   
   

   /************** clear variables used for constructing instructions **********************/
   task clear;
      begin
        inst_valid =0;
        Rs_valid_bit=0;
        Rs=0;
        Rd_valid_bit=0;
        Rd=0;
        Rt_valid_bit=0;
        Rt=0;
        imm_valid_bit=0;
        imme=0;
        LDI=0;
        brn=0;
        jmp_valid_bit=0;
        jump=0;
        MemRd=0;
        MemWr=0;
        ALU_ctrl=0;
        ALU_to_adder=0;
        ALU_to_mult=0;
        ALU_to_addr=0;
        invtRt=0;
        RegWr=0;
        pr_valid=0;
        pr_number=0;
      end
   endtask

   /*********** load into certain instruction coming from al ****************/
   task load;
      input inst_idx;
      begin
        inst_al[inst_idx]=inst(inst_valid,Rs_valid_bit,Rs,Rd_valid_bit,Rd,Rt_valid_bit,Rt,imm_valid_bit,imme, LDI,  brn, jmp_valid_bit, jump, MemRd, MemWr, ALU_ctrl,ALU_to_adder, ALU_to_mult,ALU_to_addr,invtRt, RegWr, pr_valid, pr_number);
         $display("%g load_inst:%x  === :%x Rs_valid_bit:%x Rs:%x Rd_valid_bit:%x Rd:%x Rt_valid_bit:%x Rt:%x imm_valid_bit:%x imme:%x  LDI:%x   brn:%x  jmp_valid_bit:%x  jump:%x  MemRd:%x  MemWr:%x  ALU_ctrl:%x ALU_to_adder:%x  ALU_to_mult:%x ALU_to_addr:%x invtRt:%x  RegWr:%x  pr_valid:%x  pr_number:%x", $time, inst_idx, inst_valid,Rs_valid_bit,Rs,Rd_valid_bit,Rd,Rt_valid_bit,Rt,imm_valid_bit,imme, LDI,  brn, jmp_valid_bit, jump, MemRd, MemWr, ALU_ctrl,ALU_to_adder, ALU_to_mult,ALU_to_addr,invtRt, RegWr, pr_valid, pr_number);
      end           
   endtask
   
   
   //================== group instruction together =====
   generate
      genvar                                      al_inst_i;
      //16 logical registers to physical mappings
      for (al_inst_i=0; al_inst_i<4; al_inst_i=al_inst_i+1) 
        begin
           assign inst_frm_al[INST_WIDTH*(al_inst_i+1)-1:INST_WIDTH*al_inst_i]= inst_al[al_inst_i][INST_WIDTH-1:0];
        end
   endgenerate


   
   


   //monitor inst_out and inst_out_reo
/* -----\/----- EXCLUDED -----\/-----
   always @(inst_out[0],inst_out[1],inst_out[2],inst_out[3], inst_out_reo[0], inst_out_reo[1], inst_out_reo[2], inst_out_reo[3])
     begin
        $strobe("inst_out_reo[0]: %x\ninst_out_reo[1]: %x\ninst_out_reo[2]: %x\ninst_out_reo[3]: %x\n", inst_out_reo[0], inst_out_reo[1], inst_out_reo[2], inst_out_reo[3]);
     end
 -----/\----- EXCLUDED -----/\----- */
   
   initial
     forever #5 clk=~clk;

   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, is_tb);
//        $monitor("%g\n mul_ins_to_rf: %x, alu1_ins_to_rf: %x, alu2_ins_to_rf: %x, adr_add_ins_to_rf: %x\n clr_inst_wat: %x,", $time, mul_ins_to_rf, alu1_ins_to_rf, alu2_ins_to_rf, adr_add_ins_to_rf, clr_inst_wat);
//        $monitor ("%g\n (3)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n (2)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n (1)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n (0)tpu_inst_rdy: %b, tpu out: idx: %x, vld: %x, psrc1: %x, psrc2: %x, pdst: %x free_preg:%x \n top head map: %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x, mid head map: %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x, arch:%b ",$time, tpu_inst_rdy[3],  inst_idx[3], inst_vld[3], inst_psrc1[3], inst_psrc2[3], inst_pdst[3] , fre_preg[3] ,  tpu_inst_rdy[2],  inst_idx[2], inst_vld[2], inst_psrc1[2], inst_psrc2[2], inst_pdst[2] , fre_preg[2] , tpu_inst_rdy[1],  inst_idx[1], inst_vld[1], inst_psrc1[1], inst_psrc2[1], inst_pdst[1] , fre_preg[1] , tpu_inst_rdy[0],  inst_idx[0], inst_vld[0], inst_psrc1[0], inst_psrc2[0], inst_pdst[0] , fre_preg[0],top_hed[15],  top_hed[14],  top_hed[13],  top_hed[12], top_hed[11],  top_hed[10],  top_hed[9],  top_hed[8],  top_hed[7],  top_hed[6],  top_hed[5],  top_hed[4], top_hed[3],  top_hed[2],  top_hed[1],  top_hed[0],mid_hed[15],  mid_hed[14],  mid_hed[13],  mid_hed[12], mid_hed[11],  mid_hed[10],  mid_hed[9],  mid_hed[8],  mid_hed[7],  mid_hed[6],  mid_hed[5],  mid_hed[4], mid_hed[3],  mid_hed[2],  mid_hed[1],  mid_hed[0], DUT.arch);
        
        clear();

        clk=0;
        rst_n=1;

        load(0);
        load(1);
        load(2);
        load(3);        
        
        fls_frm_rob=0;
        cmt_frm_rob=0;
        fun_rdy_frm_exe=4'hf;
        prg_rdy_frm_exe=0;
        
        repeat(2) @(posedge clk);

        //=== use display since we are working on combinational logic
        $display("%g =============begin test. reset==========", $time);
        rst_n=0;
        
        @(posedge clk);
        $display("%g  =============reset finished ==========", $time);
        rst_n=1;
        
        @(posedge clk);
        $display("%g  =============load invalid instruction ==========", $time);

        @(posedge clk);
        $display("%g  ============= valid inst  ==========", $time);
        clear();
        


        
        @(posedge clk);
        $display("%g  ============= valid inst. no dependency  ==========", $time);
        $display("%g  ===inst: idx:01, vld:1, src1:1,0011, src2:1,0100, ldst:1,0101, pdst:010001", $time);
        $display ("%g ==== add ======", $time);        
        //idx, vld, wat, br, jmp, mult, add, addr,  src1, ldst (0010) valid, src2, physical 000001



        @(posedge clk);
        $display("%g  ============= valid inst. no dependency  ==========", $time);
        $display("%g  ===inst: idx:10, vld:1, src1:1,0011, src2:1,0100, ldst:1,0101, pdst:010010", $time);
        $display ("%g ==== add ======", $time);                
        //idx, vld, wat, br, jmp, mult, add, addr,  src1, ldst (0010) valid, src2, physical 000001          


        //test dependency        
        @(posedge clk);
        $display("%g  ============= valid inst. src1 has dependency  ==========", $time);
        $display("%g  ===inst: idx:11, vld:1, src1:1,0101, src2:1,0100, ldst:1,0110, pdst:010011", $time);
        $display ("%g ==== add addr======", $time);                        
        //idx, vld, wat, br, jmp, mult, add, addr,  src1, ldst (0010) valid, src2, physical 000001          



        @(posedge clk);
        $display("%g  ============= after sending, inst0 is no longer waiting  ==========", $time);
        $display("%g  ===inst: idx:00, vld:1, src1:1,0000, src2:1,0001, ldst:1,0010, pdst:010000", $time);
        //idx, vld, wat, br, jmp, mult, add, addr,  src1, ldst (0010) valid, src2, physical 000001        



        //test physical register becomes rdy
        @(posedge clk);
        $display("%g  ============= physical register of ldst 0101 becomes rdy ==========", $time);
        $display("%g  ===inst[3] should become ready", $time);


        @(posedge clk);

        
        //test arch switch
        @(posedge clk);
        $display("%g  ============= arch swch  ==========", $time);
        
        @(posedge clk);

        @(posedge clk);

        

        $display("%g  ============= test suit 2  ==========", $time);
        $display("%g  ===inst 2: idx:00, vld:1, src1:1,2, src2:1,3, ldst:1,0, pdst:20", $time);
        $display("%g  ===inst 2: branch ", $time);        
        
        $display("%g  ===inst 3: idx:01, vld:1, src1:1,0, src2:1,1, ldst:1,0, pdst:21", $time);
        $display("%g  ===inst 3: add, should go to 2 ", $time);                
        //idx, vld, wat, br, jmp, mult, add, addr,  src1, ldst (0010) valid, src2, physical 000001        

        
        $display("%g  ===inst 0: idx:10, vld:1, src1:1,0, src2:1,0, ldst:1,1, pdst:22", $time);
        $display ("%g ==== jmp ======", $time);                        
        //idx, vld, wat, br, jmp, mult, add, addr,  src1, ldst (0010) valid, src2, physical 000001        


        $display("%g  ===inst 1: idx:11, vld:1, src1:1,0, src2:1,1, ldst:1,3, pdst:23", $time);
        $display ("%g ==== add, should got to 1 ======", $time);                                
        //idx, vld, wat, br, jmp, mult, add, addr,  src1, ldst (0010) valid, src2, physical 000001        


        @(posedge clk);
        

        @(posedge clk);
        $display("%g  ============= 02 inst dest solved  ==========", $time);                


        @(posedge clk);
        $display("%g  ============= 03 inst dest solved  ==========", $time);                        


        @(posedge clk);
        $display("%g  ============= 00 inst dest solved  ==========", $time);                        
        

        @(posedge clk);



        @(posedge clk);


        @(posedge clk);
        
        @(posedge clk);
        

        @(posedge clk);

        @(posedge clk);
        
        
        repeat(20)@(posedge clk);        
        $finish;
     end
   

   
endmodule // tpu_tb





/* -----\/----- EXCLUDED -----\/-----
   //================== separate each  output ===============
   generate
      genvar                                      inst_out_i;
      //16 logical registers to physical mappings
      for (inst_out_i=0; inst_out_i<ISQ_DEPTH; inst_out_i=inst_out_i+1) 
        begin
           //possible mapping
           assign inst_out[inst_out_i][TPU_INST_WIDTH-1:0] = tpu_out_flat[TPU_INST_WIDTH*(inst_out_i+1)-1:TPU_INST_WIDTH*inst_out_i];
           assign inst_out_reo[inst_out_i][TPU_INST_WIDTH-1:0] = tpu_out_reo_flat[TPU_INST_WIDTH*(inst_out_i+1)-1:TPU_INST_WIDTH*inst_out_i];
           
           assign inst_idx[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-1:TPU_INST_WIDTH-2];
           assign inst_vld[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-3];
           assign inst_psrc1[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-4:TPU_INST_WIDTH-10];           
           assign inst_psrc2[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-11:TPU_INST_WIDTH-17];
           assign inst_pdst[inst_out_i] = inst_out[inst_out_i][TPU_INST_WIDTH-18:TPU_INST_WIDTH-23];                                 

        end
   endgenerate

   //================== separate each free physical registers output =====
   generate
      genvar                                      preg_i;
      //16 logical registers to physical mappings
      for (preg_i=0; preg_i<ISQ_DEPTH; preg_i=preg_i+1) 
        begin
           //possible mapping
           assign fre_preg[preg_i][6:0] = fre_preg_out_flat[7*(preg_i+1)-1:7*preg_i];
        end
   endgenerate


   //================== group instruction together =====
   generate
      genvar                                      inst_in_i;
      //16 logical registers to physical mappings
      for (inst_in_i=0; inst_in_i<ISQ_DEPTH; inst_in_i=inst_in_i+1) 
        begin
           assign isq_lin_flat[ISQ_LINE_WIDTH*(inst_in_i+1)-1:ISQ_LINE_WIDTH*inst_in_i]= isq_lin[inst_in_i][ISQ_LINE_WIDTH-1:0];
        end
   endgenerate
   

   //================== separate each field for easy debuggin
   //generate output mapping
   generate
      genvar                                      map_i;
      //16 logical registers to physical mappings
      for (map_i=0; map_i<16; map_i=map_i+1) 
        begin
           //possible mapping
           assign top_hed[map_i][7:0] = DUT.top_hed_map[7*(map_i+1)-1:7*map_i];
           assign mid_hed[map_i][7:0] = DUT.mid_hed_map[7*(map_i+1)-1:7*map_i];           
        end
   endgenerate
 -----/\----- EXCLUDED -----/\----- */
