//`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: UW-Madison
// Engineer: J.J.(Junjue) Wang, Pari Lingampally, Zheng Ling
// 
// Create Date: Feb 03   
// Design Name: SPART
// Module Name: spart_tx
// Project Name: SPART
// Target Devices: FPGA Virtex 2 Pro
// Tool versions: Xilinx 10.1
// Description: This block is responsible for transmitting data over TxD. When “trmt” signal becomes high, the block reads in data from data bus and start transmission by putting start bit on the TxD line. The block implements a shifter and hold each bit until the enable signal from the baud generator changes. 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart_tx(/*autoarg*/
   // Outputs
   tx_out, tx_done,
   // Inputs
   in_data, clk, rst_n, trmt, clr_tbr, baud_full
   );

   //////////////////////////////
   // spart transmitter.
   // able to choose different baud rate
   //////////////////////////////
   input wire [7:0] in_data;
   input wire clk, rst_n, trmt, clr_tbr, baud_full;
   output wire tx_out;
   output reg   tx_done;

   ////////////////////////
   //states
   //////////////////////
   localparam IDLE = 1'b0;
   localparam TXS = 1'b1;   
   
   reg          state,nxt_state;

   //////////////////////
   //shifter
   /////////////////////
   reg [8:0]        shift_reg;
   
   ///////////////////////
   //Bit Counter
   //////////////////////
   reg [3:0]       bit_cntr;
   wire           trans_end;

   /////////////////////////////////
   // state machine output
   ///////////////////////////////
   reg           in_transmit;
   
   ////////////////////////////
   //bit counter
   //record how many bits have
   //been transmitted in one transmission task
   // (including the start and end bit
   //////////////////////////
   assign trans_end = (bit_cntr == 4'ha)? 1'b1: 1'b0;
   always @(posedge clk, negedge rst_n)
      if (!rst_n)
        bit_cntr<=4'h0;
      else if (trmt)
        bit_cntr<=4'h0;
      else if (in_transmit & baud_full)
        bit_cntr<=bit_cntr+1;
   
   //////////////////////
   //shifter
   /////////////////////
   always @(posedge clk, negedge rst_n)
     if (!rst_n)
       shift_reg <= 9'h1ff;
     else if (trmt)
       shift_reg <= {in_data,1'b0};
     else if (in_transmit & baud_full)
       shift_reg<={1'b1,shift_reg[8:1]};

   assign tx_out = shift_reg[0];

   ///////////////////
   //state machine
   //////////////////
   always @(posedge clk, negedge rst_n)
      if (!rst_n)
        state<=IDLE;
      else
        state<=nxt_state;
   
   always @(/*autosense*/ state or trans_end or trmt)
     begin
        ///////////////
        //defaults
        //////////////
        in_transmit=0;
        nxt_state=state;
        case (state)
          IDLE:
            if (trmt)
              nxt_state=TXS;
          TXS:
             begin
                in_transmit=1;
                if (trans_end)
                  nxt_state=IDLE;
             end
        endcase
     end

   /////////////////
   // signal tranmission finished
   ////////////////
   always @(posedge clk, negedge rst_n)
      if (!rst_n)
        tx_done <= 1'b1;
      else if (clr_tbr || trmt)
        tx_done<=1'b0;
      else if (trans_end)
        tx_done <=1'b1;
   
endmodule
