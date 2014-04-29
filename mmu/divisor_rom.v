`default_nettype none
`timescale 1ns / 1ps   
module divisor_rom(/*autoarg*/
   // Outputs
   rdata,
   // Inputs
   clk, addr
   );

   /////////////////////////////////////
   //the divisor should be in the form:
   //odd line: high byte
   //even line: low byte
   //the divisor is for sampling (receive)
   ///////////////////////////////////
   parameter ROM_DATA_FILE = "divisor.mem";

   input wire clk;
   input wire [1:0] addr;
   output reg [15:0] rdata;

   ///////////////////////////////
   //support 4 possible baud rate
   ///////////////////////////////
   reg [7:0] MY_DIVISOR [0:7];
   initial $readmemh(ROM_DATA_FILE, MY_DIVISOR);
   always @(posedge clk)
     rdata <= {MY_DIVISOR[2*addr], MY_DIVISOR[2*addr+1]};

endmodule
