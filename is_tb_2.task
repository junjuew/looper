        /****************** test if clr wait when succesful send***************/
        @(posedge clk);
        $display("");
        $display("");
        rst_n=1;
        $display("%g  ============= test if clr wait is successful after send  ==========", $time);        
        clear();
        //r0 =r1 + r2
        inst_valid=1;
        Rs_valid_bit=1;
        Rs=1;
        Rd_valid_bit=1;
        Rd=0;
        Rt_valid_bit=1;
        Rt=2;
        ALU_to_adder=1;
        RegWr=1;
        pr_valid=1;
        pr_number=63;
        load(0);
        pr_number=62;
        load(1);
        
        clear();
        //r0 =r1 * r2
        inst_valid=1;
        Rs_valid_bit=1;
        Rs=1;
        Rd_valid_bit=1;
        Rd=0;
        Rt_valid_bit=1;
        Rt=2;
        ALU_to_mult=1;
        RegWr=1;
        pr_valid=1;
        pr_number=61;
        load(2);
        
        //r0 =r1 + r2 but use address adder
        inst_valid=1;
        Rs_valid_bit=1;
        Rs=1;
        Rd_valid_bit=1;
        Rd=0;
        Rt_valid_bit=1;
        Rt=2;
        ALU_to_addr=1;
        RegWr=1;
        pr_valid=1;
        pr_number=60;
        load(3);

        @(posedge clk);
        $display("%g  ============= should have outputs  ==========", $time);
        clear();
        load(0);
        load(1);
        load(2);
        load(3);        
        
        
        @(posedge clk);
        $display("%g  ============= all outputs should die  ==========", $time);

        @(posedge clk);
        rst_n=0;
        
        /************** load instructions with dependency ***********/
        @(posedge clk);
        rst_n=1;
        $display("%g  ============= load instructions with dependency  ==========", $time);
        
        clear();
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
        pr_number=63;
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
        pr_number=62;
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
        pr_number=61;
        load(2);

        //r8 =r6 + r7
        inst_valid=1;
        Rs_valid_bit=1;
        Rs=6;
        Rd_valid_bit=1;
        Rd=8;
        Rt_valid_bit=1;
        Rt=7;
        ALU_to_adder=1;
        RegWr=1;
        pr_valid=1;
        pr_number=60;
        load(3);


        @(posedge clk);
        $display("%g  ============ output. only inst 0 should be available  ==========", $time);
        clear();
        load(0);
        load(1);
        load(2);        
        load(3);                

        @(posedge clk);
        //now start to resolve the instructions
        prg_rdy_frm_exe={ 1'b1, 6'h00, {3{7'h00}} };
        $display("%g  ============ inst 0 resolved  ==========", $time);        
        
        @(posedge clk);
        prg_rdy_frm_exe={ 1'b1, 6'h01, 1'b1, 6'h02, {2{7'h00}} };
        $display("%g  ============ output.  inst 1 should be available  ==========", $time);      
        $display("%g  ============ inst 1,2 resolved  ==========", $time);

        @(posedge clk);
        $display("%g  ============ output.  inst 2 should be available  ==========", $time);  
