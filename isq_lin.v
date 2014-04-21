//`default_nettype none

//////////////////////////////////////////////////
// represent each line of valid bit
// clr_val,set_val in charge of valid bit
// clr_wat, set_wat in charge of wait bit
// fls in charge of inst bits, doesn't alter valid and wait bit
/////////////////////////////////////////////////// /
module isq_lin(/*autoarg*/
   // Outputs
   isq_lin_out,
   // Inputs
   clk, rst_n, en, clr_wat, set_wat, clr_val, /*set_val,*/ fls_inst,
   isq_lin_in
   );
   parameter INST_WIDTH=56;
   parameter ISQ_LINE_NO_IDX_WIDTH=INST_WIDTH +1;
   localparam ISQ_LINE_NO_IDX_BIT_WAT=INST_WIDTH;
   
   input wire clk, rst_n, en;
   input wire clr_wat, set_wat,clr_val, /*set_val,*/ fls_inst;
   input wire [ISQ_LINE_NO_IDX_WIDTH-1:0] isq_lin_in;
   output wire [ISQ_LINE_NO_IDX_WIDTH-1:0] isq_lin_out;

   reg                          val, wat;
   reg [INST_WIDTH-1:0]             inst;
         
             
   /////////////////////////////////////
   //valid bit
   /////////////////////////////////////
/* -----\/----- EXCLUDED -----\/-----
   always @(posedge clk, negedge rst_n)
     begin
        if (!rst_n)
          val<=1'b0;
        else if (clr_val)
          val<=1'b0;
        else if (set_val)
          val<=1'b1;
        else if (en)
          val<=isq_lin_in[ISQ_LINE_NO_IDX_WIDTH-1];
     end
 -----/\----- EXCLUDED -----/\----- */
   

   /////////////////////////////////////
   //wait bit
   /////////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          wat<=1'b0;
        else if (clr_wat)
          wat<=1'b0;
        else if (set_wat)
          wat<=1'b1;
        else if (en)
          wat<=isq_lin_in[ISQ_LINE_NO_IDX_BIT_WAT];
     end
     

   /////////////////////////////////////
   //instruction flops
   /////////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        if (!rst_n)
          inst[INST_WIDTH-1:0]<=0;
        else if (fls_inst)
          inst[INST_WIDTH-1:0]<=0;
        else if (en)
          inst[INST_WIDTH-1:0]<=isq_lin_in[INST_WIDTH-1:0];
     end

   
   ///////////////////////////
   //output
   ///////////////////////////
   assign isq_lin_out = {/*val,*/wat, inst};
   
endmodule // isq_lin
