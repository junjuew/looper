        /******************* test inst not finished + architecture switch ****************/
        @(posedge clk);
        $display("");        
        $display("%g complex test No.2. test what will happen if arch swt happen but the inst dest is not ready", $time);
        
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
        
        for (i=0; i<10; i=i+1)
          begin
             @(posedge clk);
             $display("%g iteration: %x", $time, i);
             $display("%g counter value: %x", $time, DUT.counter);
             
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
             pr_number=pr_number-1;
             load(1);
             pr_number=pr_number-1;             
             load(2);
             pr_number=pr_number-1;                          
             load(3);
             
             k=pr_number;
          end
   
        @(alu2_ins_to_rf[64:59] == 6'h1f);
        $display("attention. send idx 31");
        $display("%g cur_map from isq_lin 31: ", $time);
        print_cur_map(DUT.is_tpu.cur_map[31][TPU_MAP_WIDTH-1:0]);
        $display("%g cur_map from top header: ", $time);
        print_cur_map(DUT.is_tpu.top_hed_map);
        $display("%g cur_map from mid header: ", $time);
        print_cur_map(DUT.is_tpu.mid_hed_map);
        
        $display("%g resolve 31 inst. check if mapping's valid bit will change", $time);
        prg_rdy_frm_exe={1'b1, 6'd31, {3{7'h0}} };

        @(posedge DUT.is_tpu.arch_swt);
        $display("arch swt!!!!!");
        $display("%g cur_map from isq_lin 31: ", $time);
        print_cur_map(DUT.is_tpu.cur_map[31][TPU_MAP_WIDTH-1:0]);
        $display("%g cur_map from top header: ", $time);
        print_cur_map(DUT.is_tpu.top_hed_map);
        $display("%g cur_map from mid header: ", $time);
        print_cur_map(DUT.is_tpu.mid_hed_map);
        
        @(posedge clk);
        $display("%g cur_map from isq_lin 31: ", $time);
        print_cur_map(DUT.is_tpu.cur_map[31][TPU_MAP_WIDTH-1:0]);
        $display("%g cur_map from top header: ", $time);
        print_cur_map(DUT.is_tpu.top_hed_map);
        $display("%g cur_map from mid header: ", $time);
        print_cur_map(DUT.is_tpu.mid_hed_map);

        @(posedge clk);
        $display("arch swt value should show");        
        $display("%g cur_map from isq_lin 31: ", $time);
        print_cur_map(DUT.is_tpu.cur_map[31][TPU_MAP_WIDTH-1:0]);
        $display("%g cur_map from top header: ", $time);
        print_cur_map(DUT.is_tpu.top_hed_map);
        $display("%g cur_map from mid header: ", $time);
        print_cur_map(DUT.is_tpu.mid_hed_map);

