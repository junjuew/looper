        /******************* test architecture switch ****************/
        @(posedge clk);
        $display("");        
        $display("%g complex test No.1", $time);
        
        rst_n=0;
        prg_rdy_frm_exe=0;
        
        /************** load instructions with dependency ***********/
        @(posedge clk);
        rst_n=1;
        $display("%g  ============= start loading in next cycle  ==========", $time);
        clear();
        load(0);
        load(1);
        load(2);
        load(3);        
        pr_number=64;
        k=pr_number;
        
        for (i=0; i<20; i=i+1)
          begin
             $display("%g iteration: %d", $time, i);
             @(posedge clk);
             if (i!=0)
               begin

                  j=(i-1);
/*                  
                  k=4*(i-1)+1;
                  l=4*(i-1)+2;
                  m=4*(i-1)+3;                  
*/                  
                  //resolve last instructions first
                  prg_rdy_frm_exe={ 1'b1, j[5:0], {3{1'b0, 6'h0}} };
                  $display("%g prg_rdy_frm_exe: %b", $time, prg_rdy_frm_exe);
//                  $display("%g test: %b", $time, { (4*i)[5:0], 4*i[5:0] });
               end

             clear();
             pr_number=k;
             //r2 =r0 + r1
             inst_valid=1;
             Rs_valid_bit=1;
             Rs=0;
             Rd_valid_bit=1;
             Rd=2;
             Rt_valid_bit=1;
             Rt=1;
             ALU_to_adder=1;
             RegWr=1;
             pr_valid=1;
             pr_number=pr_number-1;
             load(0);

             //r4 =r2 + r3
             inst_valid=1;
             Rs_valid_bit=1;
             Rs=2;
             Rd_valid_bit=1;
             Rd=4;
             Rt_valid_bit=1;
             Rt=3;
             ALU_to_adder=1;
             RegWr=1;
             pr_valid=1;
             pr_number=pr_number-1;
             load(1);

             //r6 =r4 + r5
             inst_valid=1;
             Rs_valid_bit=1;
             Rs=4;
             Rd_valid_bit=1;
             Rd=6;
             Rt_valid_bit=1;
             Rt=5;
             ALU_to_adder=1;
             RegWr=1;
             pr_valid=1;
             pr_number=pr_number-1;             
             load(2);

             //r0 =r6 + r7
             inst_valid=1;
             Rs_valid_bit=1;
             Rs=6;
             Rd_valid_bit=1;
             Rd=0;
             Rt_valid_bit=1;
             Rt=7;
             ALU_to_adder=1;
             RegWr=1;
             pr_valid=1;
             pr_number=pr_number-1;                          
             load(3);

             k=pr_number;
          end
   


        for (i=20; i<=64; i=i+1)
          begin
             $display("%g iteration: %d", $time, i);
             @(posedge clk);

             j=(i-1);
             //resolve last instructions first
             prg_rdy_frm_exe={ 1'b1, j[5:0], {3{1'b0, 6'h0}} };
             $display("%g prg_rdy_frm_exe: %b", $time, prg_rdy_frm_exe);
          end


        repeat(10) @(posedge clk);        

        for (i=0; i<=32; i=i+1)
          begin
             $display("%g iteration: %d", $time, i);
             @(posedge clk);

             j=(i-1);
             //resolve last instructions first
             prg_rdy_frm_exe={ 1'b1, j[5:0], {3{1'b0, 6'h0}} };
             $display("%g prg_rdy_frm_exe: %b", $time, prg_rdy_frm_exe);
          end
