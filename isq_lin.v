`default_nettype none

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
   clk, rst_n, en, clr_wat, set_wat, clr_val, set_val, fls,
   isq_lin_in
   );
   parameter INST_WIDTH=56;
   parameter ISQ_LINE_NO_IDX_WIDTH=INST_WIDTH +2;
   
   input wire clk, rst_n, en;
   input wire clr_wat, set_wat,clr_val, set_val, fls;
   input wire [ISQ_LINE_NO_IDX_WIDTH-1:0] isq_lin_in;
   output wire [ISQ_LINE_NO_IDX_WIDTH-1:0] isq_lin_out;

   reg                          val, wat;
   reg [INST_WIDTH-1:0]             inst;
         
             
   /////////////////////////////////////
   //valid bit
   /////////////////////////////////////
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
   

   /////////////////////////////////////
   //wait bit
   /////////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        if (!rst_n)
          wat<=1'b0;
        else if (clr_wat)
          wat<=1'b0;
        else if (set_wat)
          wat<=1'b1;
        else if (en)
          wat<=isq_lin_in[ISQ_LINE_NO_IDX_WIDTH-2];
     end
     

   /////////////////////////////////////
   //instruction flops
   /////////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        if (!rst_n)
          inst[INST_WIDTH-1:0]<=0;
        else if (fls)
          inst[INST_WIDTH-1:0]<=0;
        else if (en)
          inst[INST_WIDTH-1:0]<=isq_lin_in[ISQ_LINE_NO_IDX_WIDTH-3:0];
     end

   
   ///////////////////////////
   //output
   ///////////////////////////
   assign isq_lin_out = {val,wat, inst};
   
endmodule // isq_lin
