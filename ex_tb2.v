module ex_tb2(/*AUTOARG*/);

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          addr_out;               // From ex of execution.v
   wire [15:0]          alu1_out;               // From ex of execution.v
   wire [15:0]          alu2_out;               // From ex of execution.v
   wire [15:0]          mult_out;               // From ex of execution.v
   wire                 mult_valid_wb;          // From ex of execution.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg                  addr_en;                // To ex of execution.v
   reg [15:0]           addr_op1;               // To ex of execution.v
   reg [15:0]           addr_op2;               // To ex of execution.v
   reg                  alu1_en;                // To ex of execution.v
   reg [15:0]           alu1_imm;               // To ex of execution.v
   reg                  alu1_inv_Rt;            // To ex of execution.v
   reg                  alu1_ldi;               // To ex of execution.v
   reg [2:0]            alu1_mode;              // To ex of execution.v
   reg [15:0]           alu1_op1;               // To ex of execution.v
   reg [15:0]           alu1_op2;               // To ex of execution.v
   reg                  alu2_en;                // To ex of execution.v
   reg [15:0]           alu2_imm;               // To ex of execution.v
   reg                  alu2_inv_Rt;            // To ex of execution.v
   reg                  alu2_ldi;               // To ex of execution.v
   reg [2:0]            alu2_mode;              // To ex of execution.v
   reg [15:0]           alu2_op1;               // To ex of execution.v
   reg [15:0]           alu2_op2;               // To ex of execution.v
   reg                  clk;                    // To ex of execution.v
   reg                  mult_en;                // To ex of execution.v
   reg [15:0]           mult_op1;               // To ex of execution.v
   reg [15:0]           mult_op2;               // To ex of execution.v
   reg                  rst_n;                  // To ex of execution.v
   // End of automatics
   
   execution ex(/*autoinst*/
                // Outputs
                .mult_out               (mult_out[15:0]),
                .alu1_out               (alu1_out[15:0]),
                .alu2_out               (alu2_out[15:0]),
                .addr_out               (addr_out[15:0]),
                .mult_valid_wb          (mult_valid_wb),
                // Inputs
                .mult_op1               (mult_op1[15:0]),
                .mult_op2               (mult_op2[15:0]),
                .alu1_op1               (alu1_op1[15:0]),
                .alu1_op2               (alu1_op2[15:0]),
                .alu2_op1               (alu2_op1[15:0]),
                .alu2_op2               (alu2_op2[15:0]),
                .addr_op1               (addr_op1[15:0]),
                .addr_op2               (addr_op2[15:0]),
                .alu1_imm               (alu1_imm[15:0]),
                .alu2_imm               (alu2_imm[15:0]),
                .mult_en                (mult_en),
                .alu1_en                (alu1_en),
                .alu2_en                (alu2_en),
                .addr_en                (addr_en),
                .clk                    (clk),
                .rst_n                  (rst_n),
                .alu1_inv_Rt            (alu1_inv_Rt),
                .alu2_inv_Rt            (alu2_inv_Rt),
                .alu1_ldi               (alu1_ldi),
                .alu2_ldi               (alu2_ldi),
                .alu1_mode              (alu1_mode[2:0]),
                .alu2_mode              (alu2_mode[2:0]));



   task clear();
      begin
        addr_en=0;
        addr_op1=0;
        addr_op2=0;
        alu1_en=0;
        alu1_imm=0;
        alu1_inv_Rt=0;
        alu1_ldi=0;
        alu1_mode=0;
        alu1_op1=0;
        alu1_op2=0;
        alu2_en=0;
        alu2_imm=0;
        alu2_inv_Rt=0;
        alu2_ldi=0;
        alu2_mode=0;
        alu2_op1=0;        
        alu2_op2=0;
        mult_en=0;
        mult_op1=0;
        mult_op2=0;
      end
   endtask // clear
   
   
   
   initial 
     forever #5 clk=~clk;
   
   initial
     begin
        $wlfdumpvars(0, ex_tb2);
        
//        $monitor("%g  mult_out:%x, alu1_out:%x, alu2_out:%x, addr_out:%x, mult_valid_wb:%x, mult_free:%x state:%b",$time, mult_out,alu1_out, alu2_out, addr_out, mult_valid_wb, mult_free, ex.mult.state);
        $monitor("%g  mult_out:%x, alu1_out:%x, alu2_out:%x, addr_out:%x, mult_valid_wb:%x, state:%b",$time, mult_out,alu1_out, alu2_out, addr_out, mult_valid_wb,  ex.mult.state);
        
        clk = 0;
        clear();
        
        @(posedge clk);
        rst_n = 0;

        @(posedge clk);
        rst_n = 1;

        @(posedge clk);
        $display("%g start testing", $time);

        @(posedge clk);
        $display("%g alu1 add 0x34fd+0x8723 = 0xBC20", $time);
        alu1_en = 1;
        alu1_op1= 16'h34fd;
        alu1_op2= 16'h8723;
        alu1_inv_Rt = 0;
        alu1_mode = 0;
        alu1_ldi = 0;
        alu1_imm = 16'h02;

        @(posedge clk);
        $display("%g alu1 sub 0x34fd-0x1723 = 0x1DDA", $time);
        alu1_en = 1;
        alu1_op1= 16'h34fd;
        alu1_op2= 16'h1723;
        alu1_inv_Rt = 1;
        alu1_mode = 3'b010;
        alu1_ldi = 0;
        alu1_imm = 16'h02;

        @(posedge clk);
        $display("%g mult 0x0003 * 0x0040 = 0x00C0", $time);        
        clear();
        mult_en  = 1;
        mult_op1 = 16'h0003;
        mult_op2 = 16'h0040;

//        @(posedge mult_valid_wb);
//        $display("%g multiplier output result", $time);


        @(posedge clk);        
        clear();

        @(posedge mult_valid_wb);
        @(posedge clk);
        @(posedge clk);        
        
        $display("%g mult 0x0004 * 0x0006 = 0x0018", $time);
        $display("%g alu1  0x3456 &  0x1234 = 0x1014", $time);        
        $display("%g alu2 0x3456 | 0x1234 = 0x3676", $time);        
        $display("%g adr 0x3456 + 0x0321 = 0x3777", $time);                
        mult_en  = 1;
        mult_op1 = 16'h0004;
        mult_op2 = 16'h0006;
        
        alu1_en = 1;
        alu1_op1= 16'h3456;
        alu1_op2= 16'h1234;
        alu1_inv_Rt = 0;
        alu1_mode = 3'b011;
        alu1_ldi = 0;
        alu1_imm = 16'h02;

        alu2_en = 1;
        alu2_op1= 16'h3456;
        alu2_op2= 16'h1234;
        alu2_inv_Rt = 0;
        alu2_mode = 3'b100;
        alu2_ldi = 0;
        alu2_imm = 16'h02;
        
        addr_en=1;                // To ex of execution.v
        addr_op1=16'h3456;               // To ex of execution.v
        addr_op2=16'h0321;               // To ex of execution.v

        @(posedge clk);
        clear();
        
        @(posedge mult_valid_wb);
        @(posedge clk);
        $display("%g mult 0x3456 * 0x0123 = 0x3B7DC2", $time);        
        mult_en  = 1;
        mult_op1 = 16'h3456;
        mult_op2 = 16'h0123;
        
        @(posedge clk);
        clear();
        
        @(posedge mult_valid_wb);
        @(posedge clk);
        $display("%g mult 0x3456 * 0x0023 = 0x727C2", $time);        
        mult_en  = 1;
        mult_op1 = 16'h3456;
        mult_op2 = 16'h0023;

        @(posedge mult_valid_wb);
        @(posedge clk);
        $display("%g mult 0x3456 * 0x0004 = 0xD158", $time);        
        mult_en  = 1;
        mult_op1 = 16'h3456;
        mult_op2 = 16'h0004;

        @(posedge mult_valid_wb);
        @(posedge clk);
        $display("%g mult 0x3456 * 0x0005 = 0x105AE", $time);        
        mult_en  = 1;
        mult_op1 = 16'h3456;
        mult_op2 = 16'h0005;


        @(posedge clk);
        clear();

        $display("%g alu1  0x3456 ^  0x1234 = 0x2662", $time);        
        $display("%g alu2 ~0x3456 = 0xcba9", $time);        
        $display("%g adr 0xb456 + 0xc301 = 0x17757", $time);                
        
        alu1_en = 1;
        alu1_op1= 16'h3456;
        alu1_op2= 16'h1234;
        alu1_inv_Rt = 0;
        alu1_mode = 3'b101;
        alu1_ldi = 0;
        alu1_imm = 16'h02;

        alu2_en = 1;
        alu2_op1= 16'h3456;
        alu2_op2= 16'h1234;
        alu2_inv_Rt = 0;
        alu2_mode = 3'b110;
        alu2_ldi = 0;
        alu2_imm = 16'h02;
        
        addr_en=1;                // To ex of execution.v
        addr_op1=16'hb456;               // To ex of execution.v
        addr_op2=16'hc301;               // To ex of execution.v

        @(posedge clk);
        clear();

        $display("%g alu1  0x3456 >> 4 = 0x0345", $time);        
        $display("%g alu2 ldi 0xcba9", $time);        
        $display("%g adr 0xb456 + 0xc301 = 0x17757", $time);                
        
        alu1_en = 1;
        alu1_op1= 16'h3456;
        alu1_op2= 16'h0004;
        alu1_inv_Rt = 0;
        alu1_mode = 3'b111;
        alu1_ldi = 0;
        alu1_imm = 16'h02;

        alu2_en = 1;
        alu2_op1= 16'h3456;
        alu2_op2= 16'h1234;
        alu2_inv_Rt = 0;
        alu2_mode = 3'b110;
        alu2_ldi = 1;
        alu2_imm = 16'hcba9;
        
        addr_en=1;                // To ex of execution.v
        addr_op1=16'hb456;               // To ex of execution.v
        addr_op2=16'hc301;               // To ex of execution.v

        @(posedge clk);
        clear();

        $display("%g alu1  0xf456 >> 4 = 0xff45", $time);        
        $display("%g alu2 ldi 0xcba9", $time);        
        $display("%g adr 0xb456 + 0xc301 = 0x17757", $time);                
        
        alu1_en = 1;
        alu1_op1= 16'hf456;
        alu1_op2= 16'h0004;
        alu1_inv_Rt = 0;
        alu1_mode = 3'b111;
        alu1_ldi = 0;
        alu1_imm = 16'h02;

        alu2_en = 1;
        alu2_op1= 16'h3456;
        alu2_op2= 16'h1234;
        alu2_inv_Rt = 0;
        alu2_mode = 3'b110;
        alu2_ldi = 1;
        alu2_imm = 16'hcba9;
        
        addr_en=1;                // To ex of execution.v
        addr_op1=16'hb456;               // To ex of execution.v
        addr_op2=16'hc301;               // To ex of execution.v
        
        
        repeat(30)@(posedge clk);

        $finish;
     end
endmodule