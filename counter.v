`default_nettype none


module counter(/*autoarg*/
   // Outputs
   isq_lin_en,
   // Inputs
   clk, rst_n, set, val, inst_vld, en
   );


   parameter ISQ_DEPTH=64;
   parameter ISQ_ADDR=6;   //=log2(ISQ_DEPTH)   
   parameter INST_PORT =4;
   parameter BITS_IN_COUNT = 4;//=log2(ISQ_DEPTH/INST_PORT)
   
   
   input wire clk, rst_n, set;
   input wire[ISQ_ADDR -1 :0] val; //the value such counter should set to when set is high
   input wire [INST_PORT-1:0] inst_vld;
   input wire                 en;
   output wire [ISQ_DEPTH-1:0] isq_lin_en;

   reg [BITS_IN_COUNT-1:0]          counter;

   wire                        all_nop = ~(|inst_vld);
   //whether there are indeed some lines in the issue queue rdy for input
   wire                        cnt_en= (~all_nop) & (en);
   wire [ISQ_DEPTH / INST_PORT : 0] cnt_dec;
                       
   
   /////////////////////////////////////
   //counter, increment by 4 by default
   //stop increment when all inst are nop
   //if set signal is high, override counter
   //TODO: what is the inst is full
   ///////////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        if (!rst_n)
          counter <= 0;
        else if (!cnt_en)
          counter <= counter;
        else if (set)
          //only take the highest BITS_IN_COUNT number of bits
          counter <= val[ISQ_ADDR -1 : ISQ_ADDR - BITS_IN_COUNT ] +1 ; 
        else
          counter <=counter +1;
     end

   ///////////////////////////////////////
   //get the decoded result for each inst group ( instructions showing up at the input ports
   //at a certain time instance
   ////////////////////////////////////
   assign cnt_dec= (cnt_en)? (1'b1 << counter): {(ISQ_DEPTH/INST_PORT){1'b0}};
   
   
   ///////////////////////////////////////////////////////////
   //expand each decoded value to the the total depth of isq
   ///////////////////////////////////////////////////////////
   generate
      genvar                                      dec_i;
      for (dec_i=0; dec_i<ISQ_DEPTH / INST_PORT; dec_i=dec_i+1) 
        begin
           assign isq_lin_en[(dec_i+1)* INST_PORT -1 : dec_i * INST_PORT] = {(INST_PORT){cnt_dec[dec_i]}};
        end
   endgenerate

   
endmodule // counter
