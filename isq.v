`default_nettype none


////////////////////////////////////
//  issue queue
///////////////////////////////////
module isq(/*autoarg*/);

   parameter ISQ_DEPTH=64;

   isq_lin isq_mat[ISQ_DEPTH-1:0] (/*autoinst*/);


   


   
endmodule // isq
