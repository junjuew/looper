//`default_nettype none

module isq_lin_tb(/*autoarg*/
   // Outputs
   isq_lin_out,
   // Inputs
   clk, rst_n, en, clr_wat, set_wat, clr_val, set_val, fls,
   isq_lin_in
   );


   parameter INST_WIDTH=14;
   parameter ISQ_LINE_WIDTH=INST_WIDTH+2;
   
   
   input reg clk, rst_n, en;
   input reg clr_wat, set_wat,clr_val, set_val, fls;
   input reg [ISQ_LINE_WIDTH-1:0] isq_lin_in;
   output wire [ISQ_LINE_WIDTH-1:0] isq_lin_out;


   isq_lin #(.INST_WIDTH(INST_WIDTH)) DUT(/*autoinst*/
               // Outputs
               .isq_lin_out             (isq_lin_out),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .en                      (en),
               .clr_wat                 (clr_wat),
               .set_wat                 (set_wat),
               .clr_val                 (clr_val),
               .set_val                 (set_val),
               .fls                     (fls),
               .isq_lin_in              (isq_lin_in));

   
   initial
     forever #5 clk=~clk;

   
   initial
     begin
        /////////////////////////////////////////////////
        //dump variables for debug
        ////////////////////////////////////////////////
        //dump all the signals
        $wlfdumpvars(0, isq_lin_tb);
        $monitor ("%g  isq_lin_out=%x",$time, isq_lin_out);
        
        clk=0;
        rst_n=1;
        en=0;
        clr_wat=0;
        set_wat=0;
        clr_val=0;
        set_val=0;
        fls=0;
        isq_lin_in = 0;
        repeat(2) @(posedge clk);
        $strobe("=============begin test. reset==========");
        @(posedge clk);
        rst_n=0;
        @(posedge clk);
        rst_n=1;
        $strobe("=============reset finished ==========");                
        @(posedge clk);
        en=1;
        isq_lin_in = 16'hfbab;
        $strobe("=============load in 0xfbab ==========");        
        @(posedge clk);
        en=0;
        clr_val=1;
        $strobe("=============clear valid bit ==========");                
        @(posedge clk);
        clr_val=0;        
        clr_wat=1;
        $strobe("=============clear wat bit ==========");                        
        @(posedge clk);
        clr_wat=0;        
        fls=1;
        $strobe("============= flush ==========");        
        @(posedge clk);
        fls=0;        
        set_val=1;
        $strobe("============= set valid bit ==========");        
        @(posedge clk);
        set_val=0;        
        set_wat=1;
        $strobe("============= set wat bit ==========");        
        repeat(40) @(posedge clk);
        $finish;
     end
   
endmodule   
