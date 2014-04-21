//`default_nettype none


  ////////////////////////////////////
  //  issue queue
  // instruction in the lowest bits goes to top
  ///////////////////////////////////
  module isq(/*autoarg*/
   // Outputs
   isq_out_flat,
   // Inputs
   inst_in_flat, isq_en, rst_n, clk, isq_lin_en, clr_inst_wat,
   fls_inst
   );

   parameter ISQ_DEPTH=64;
   parameter ISQ_IDX_BITS_NUM=6;   
   parameter INST_PORT=4;
   parameter INST_WIDTH=56;
   parameter ISQ_LINE_WIDTH=INST_WIDTH +1 + ISQ_IDX_BITS_NUM;
   parameter BIT_INST_VLD = INST_WIDTH  - 1 ;

   localparam ISQ_LINE_NO_IDX_WIDTH = ISQ_LINE_WIDTH - ISQ_IDX_BITS_NUM;

   input wire[INST_WIDTH * INST_PORT-1:0] inst_in_flat;
   wire [INST_WIDTH-1:0]                  inst_in[INST_PORT-1:0];

   input wire                             isq_en, rst_n, clk;
   input wire [ISQ_DEPTH -1 :0]           isq_lin_en;
   input wire [ISQ_DEPTH -1 :0]           clr_inst_wat;
   input wire [ISQ_DEPTH -1 :0]           fls_inst;      

   
   output wire [ISQ_LINE_WIDTH * ISQ_DEPTH -1 :0 ] isq_out_flat;

   //////////////////////////////
   //wires that clears out some contents in the isssue queue
   /////////////////////                                                   
   wire                                           clr_val[0:ISQ_DEPTH-1];
//   wire                                           set_val[0:ISQ_DEPTH-1];   
   wire                                           clr_wat[0:ISQ_DEPTH-1];
   wire                                           set_wat[0:ISQ_DEPTH-1];

   wire [ISQ_LINE_NO_IDX_WIDTH-1:0]                      isq_lin_out[0:ISQ_DEPTH-1];   
   wire [ISQ_LINE_NO_IDX_WIDTH-1:0]                      isq_lin_in[0:ISQ_DEPTH-1];


   /////////////////////////
   //indices
   /////////////////////////////
   reg [ISQ_IDX_BITS_NUM -1:0]                            indices[ISQ_DEPTH -1 :0];

   
   /////////////////////////////////
    //unflat isq input
   /////////////////////////////////
   generate
      genvar                                      input_i;
      for (input_i=0; input_i<INST_PORT; input_i=input_i+1) 
        begin
           assign inst_in[input_i][INST_WIDTH-1:0] = inst_in_flat[INST_WIDTH*(input_i+1)-1 : INST_WIDTH*input_i];
        end
   endgenerate


   ////////////////////////////////////
   //prefix valid. wait bit
   //right now everything is always 1
   //TODO: need to check if it's nop later
   //////////////////////////////////
   generate
      genvar                                      prefix_i;
      for (prefix_i=0; prefix_i<ISQ_DEPTH; prefix_i=prefix_i+1) 
        begin
           assign isq_lin_in[prefix_i] = {inst_in[prefix_i%INST_PORT][BIT_INST_VLD], inst_in[prefix_i%INST_PORT]};
        end
   endgenerate
   

   //////////////////////////////
   //wires that clears out some contents in the isssue queue
   /////////////////////                                                   
   generate
      genvar                                      clr_i;
      for (clr_i=0; clr_i<ISQ_DEPTH; clr_i=clr_i+1) 
        begin
           assign clr_val[clr_i] = 1'b0;
//           assign set_val[clr_i] = 1'b0;
           assign set_wat[clr_i] = 1'b0;
//           assign fls[clr_i] = 1'b0;           
        end
   endgenerate


   
   ///////////////////////////////////////
   //instantiate the issue queue matrix
   ///////////////////////////////////////
   generate
      genvar                                      i;
      for (i=0; i<ISQ_DEPTH; i=i+1) 
        begin
           isq_lin #(/*autoinstparam*/
                     // Parameters
                     .INST_WIDTH        (INST_WIDTH),
                     .ISQ_LINE_NO_IDX_WIDTH(ISQ_LINE_NO_IDX_WIDTH))
           
                           isq_mat(
                           // Outputs
                           .isq_lin_out     (isq_lin_out[i]),
                           // Inputs
                           .clk             (clk),
                           .rst_n           (rst_n),
                           .en              (isq_lin_en[i] && isq_en),
                           .clr_wat         (clr_inst_wat[i]),
                           .set_wat         (set_wat[i]),
                           .clr_val         (clr_val[i]),
//                           .set_val         (set_val[i]),
                           .fls_inst             (fls_inst[i]),
                           .isq_lin_in      (isq_lin_in[i]));
        end
   endgenerate


   /////////////////////////////////////////////////////
   //assign idx to each line in the issue queue
   ////////////////////////////////////////////////////
   generate
      genvar                                      idx_i;
      for (idx_i=0; idx_i<ISQ_DEPTH; idx_i=idx_i+1) 
        begin
           always @(posedge clk, negedge rst_n)
             begin
                if (!rst_n)
                  indices[idx_i] <= idx_i;
                else
                  indices[idx_i] <= indices[idx_i];
             end
        end
   endgenerate


   
   ///////////////////////////////
   //flat output data
   //////////////////////////////
   generate
      genvar                                      out_i;
      for (out_i=0; out_i<ISQ_DEPTH; out_i=out_i+1) 
        begin
           //append indices at the beginning of inst line!!
           //tpu rely on this property to parse the bus
           assign isq_out_flat[ISQ_LINE_WIDTH*(out_i+1)-1 : ISQ_LINE_WIDTH*out_i] =  { indices[out_i], isq_lin_out[out_i]};
        end
   endgenerate

   
   
endmodule // isq
