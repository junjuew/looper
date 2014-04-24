//`default_nettype none


module counter(/*autoarg*/
   // Outputs
   isq_lin_en, counter,
   // Inputs
   clk, rst_n, set, val, inst_vld, isq_ful
   );


   parameter ISQ_DEPTH=64;
   parameter ISQ_IDX_BITS_NUM=6;   //=log2(ISQ_DEPTH)   
   parameter INST_PORT =4;
   parameter BITS_IN_COUNT = 4;//=log2(ISQ_DEPTH/INST_PORT)
   
   
   input wire clk, rst_n, set;
   input wire[ISQ_IDX_BITS_NUM -1 :0] val; //the value such counter should set to when set is high
   input wire [INST_PORT-1:0] inst_vld;
   input wire                 isq_ful;
   output wire [ISQ_DEPTH-1:0] isq_lin_en;

   output reg [BITS_IN_COUNT-1:0]          counter;

   wire                        all_nop = ~(|inst_vld);
   //whether there are indeed some lines in the issue queue rdy for input
   wire                        cnt_en= (~all_nop) & (~isq_ful);
   wire [ISQ_DEPTH / INST_PORT : 0] cnt_dec;
                       
   
   /////////////////////////////////////
   //counter, increment by 4 by default
   //stop increment when all inst are nop
   //if set signal is high, override counter
   //TODO: what is the inst is full
   ///////////////////////////////////////
   wire[ISQ_IDX_BITS_NUM -1 -2:0] fls_val_div_4; // flsh idx divided by 4
   assign fls_val_div_4 = (val[1:0] == 2'b00)? val[ISQ_IDX_BITS_NUM-1:ISQ_IDX_BITS_NUM-BITS_IN_COUNT]
                          :  val[ISQ_IDX_BITS_NUM-1:ISQ_IDX_BITS_NUM-BITS_IN_COUNT] +1;
   
   always @(posedge clk, negedge rst_n)
     begin
        if (!rst_n)
          counter <= 0;
        else if (set)
          //only take the highest BITS_IN_COUNT number of bits
          // up round to the neareast multiple of 4
          counter <= fls_val_div_4; //*val[ISQ_IDX_BITS_NUM -1 : ISQ_IDX_BITS_NUM - BITS_IN_COUNT ] +1 ; 
        else if (!cnt_en)
          counter <= counter;
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
        begin : dec_gen
           assign isq_lin_en[(dec_i+1)* INST_PORT -1 : dec_i * INST_PORT] = {(INST_PORT){cnt_dec[dec_i]}};
        end
   endgenerate

   
endmodule // counter
