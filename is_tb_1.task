        /********************* single instruction test****************/
        @(posedge clk);
        $display("");
        $display("");        
        $display("%g  ============= start valid inst test  ==========", $time);        
        $display("%g  ============= one add1 valid inst comes in   ==========", $time);
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
        clear();
        load(1);
        load(2);
        load(3);

        @(posedge clk);
        $display("%g  ============= check output. add1 should have inst  ==========", $time);

        $display("");
        $display("%g  ============= one add2  inst comes in   ==========", $time);
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
        pr_number=62;
        load(1);
        clear();
        load(0);
        load(2);
        load(3);

        @(posedge clk);
        $display("\n");        
        $display("%g  ============= check output. add2 should have inst  ==========", $time);
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
        clear();
        load(0);
        load(1);
        load(3);


        @(posedge clk);
        $display("\n");                
        $display("%g  ============= check output. mul should have inst  ==========", $time);
        clear();
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
        clear();
        load(0);
        load(1);
        load(2);


        @(posedge clk);
        $display("%g  ============= check output. addr should have inst  ==========", $time);

        @(posedge clk);
        rst_n=0;        
        
        @(posedge clk);
        rst_n=1;        
        $display("\n");                
        clear();
        //r0 =r1 + r2 but use address adder
        inst_valid=1;
        Rs_valid_bit=1;
        Rs=1;
        Rd_valid_bit=0;
        Rd=0;
        Rt_valid_bit=0;
        Rt=2;
        ALU_to_adder=0;
        RegWr=0;
        brn=1;
        pr_valid=0;
        load(0);
        clear();
        load(1);
        load(2);
        load(3);


        @(posedge clk);
        $display("%g  ============= check output. add1 should have inst  ==========", $time);
        

        @(posedge clk);
        rst_n=0;        
        
        @(posedge clk);
        rst_n=1;        
        $display("\n");                
        clear();
        //r0 =r1 + r2 but use address adder
        inst_valid=1;
        Rs_valid_bit=1;
        Rs=1;
        Rd_valid_bit=0;
        Rd=0;
        Rt_valid_bit=0;
        Rt=2;
        RegWr=0;
        jmp_valid_bit=1;
        pr_valid=0;
        load(0);
        clear();
        load(1);
        load(2);
        load(3);


        @(posedge clk);
        $display("%g  ============= check output. add1 should have inst  ==========", $time);
        rst_n=0;
