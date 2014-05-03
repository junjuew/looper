`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UW-Madison
// Engineer: J.J.(Junjue) Wang, Pari Lingampally, Zheng Ling
// 
// Create Date: Feb 03   
// Design Name: SPART
// Module Name: spart_rx
// Project Name: SPART
// Target Devices: FPGA Virtex 2 Pro
// Tool versions: Xilinx 10.1
// Description: 
// This block is responsible for receiving data over the data bus line (asynchronously). The FSM within this block first waits to see a 0 (the start bit), then proceeds to sample the incoming data 16 times per clock. Based on what the majority of the sample results, this value is recorded into “rx_data_next”. When 8bits were received, the databus is cleared (next cycle) and rda_next is asserted. 
//
// Dependencies:
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module spart_rx(
                // inputs
                clk, rst_n, clr_rda, baud_en, RX,
                // outputs
                rda, rx_data
                );

   // Port Declarations
   input  wire clk, rst_n, clr_rda, baud_en, RX;
   output reg  rda;
   output reg [7:0] rx_data;

   // Local Vars
   reg              bit_cnt_en, rda_next, rx_data_en, rx_data_clr;
   reg              mjr_cnt_en, mjr_cnt_clr, smpl_cnt_en, smpl_cnt_full;  
   reg              RX1, RX2;
   reg [2:0]        bit_cnt;
   reg [4:0]        mjr_cnt, smpl_cnt;
   reg [2:0]        state, state_next;
   reg [7:0]        rx_data_next; 

   // Local Consts
   parameter IDLE = 3'b001, START = 3'b010, SAMPLE = 3'b011, RECORD = 3'b100, FIN = 3'b101, START_TEST=3'b110;


   //////////////////////////
   //3 Bit Counter         //
   ////////////////////////// 
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        bit_cnt <= 3'b000;// declare
      else if (bit_cnt_en)
        bit_cnt <= bit_cnt+1;// increment
      else
        bit_cnt <= bit_cnt;// no change
   end

   //////////////////////////////
   //4 bit Majority Counter   //
   ////////////////////////////// 
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        mjr_cnt <= 5'h0;// declare
      else if (mjr_cnt_clr)
        mjr_cnt <= 5'h0;// clear 
      else if (mjr_cnt_en) 
        mjr_cnt <= mjr_cnt+1;// increment
      else
        mjr_cnt <= mjr_cnt;// no change
   end

   //////////////////////////////
   //4 bit Sample Counter   //
   ////////////////////////////// 
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        smpl_cnt <= 5'h0;// declare 
      else if (smpl_cnt_full) 
        smpl_cnt <= 5'h0;// clear
      else if (smpl_cnt_en) 
        smpl_cnt <= smpl_cnt+1;// increment
      else
        smpl_cnt <= smpl_cnt;// no change
   end

   ///////////////////////////
   //8 Bit Register to hold //
   //incoming data          //
   /////////////////////////// 
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        rx_data <= 8'h00;// declare
      else if (rx_data_clr)
        rx_data <= 8'h00;// clear
      else if (rx_data_en)
        rx_data <= rx_data_next;// receiving
      else
        rx_data <= rx_data;// no change
   end

   /////////////////////////////////////
   //Flop the rda  bit                //
   /////////////////////////////////////
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        rda <= 1'b0;
      else
        rda <= rda_next;
   end

   /////////////////////////////////////
   //Double Flop the incoming RX      //
   /////////////////////////////////////
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         RX1 <= 1'b0;  
         RX2 <= 1'b0;
      end
      else begin
         RX1 <= RX;
         RX2 <= RX1; 
      end
   end

   /////////////////////////////////
   //Implement the fsm             /
   /////////////////////////////////
   always @(posedge clk or negedge rst_n) 
     begin : FSM_SEQ
        if (!rst_n)
          state <= IDLE;
        else
          state <= state_next;
     end

   /////////////////////////////////
   //Output Logic                  /
   /////////////////////////////////
   always @ (*)
     begin : FSM_COMBO
        rda_next = 0;
        bit_cnt_en = 0;
        mjr_cnt_en = 0;
        mjr_cnt_clr = 0;
        smpl_cnt_en = 0;
        smpl_cnt_full = 0;
        rx_data_en = 0;
        rx_data_next = rx_data;
        state_next = state;
        rx_data_clr = 0;
        
        case(state)
          IDLE:
            if(!RX2) begin
               state_next = START;
            end

          START: //sample start bit
            begin
               bit_cnt_en = 0;                                     
               rx_data_clr = 0;
               state_next = START;               
               if (baud_en && RX2) begin
                  smpl_cnt_en = 1; 
                  mjr_cnt_en = 0;
               end
               if (baud_en && !RX2) begin
                  smpl_cnt_en = 1;
                  mjr_cnt_en = 1;                  
               end
               if (/*baud_en &&*/ (smpl_cnt == 5'd16)) begin
                  //sampled 16 times
                  rx_data_next = 8'h00;                                    
                  state_next = START_TEST;
                  rx_data_clr=1;
                  smpl_cnt_en = 0;                                                                        
                  smpl_cnt_full = 1;                  
               end
               
            end


          START_TEST: //determine if it's a start bit or just a glitch
            begin
               smpl_cnt_full = 1;
               mjr_cnt_clr = 1;
               if (mjr_cnt >= 5'd8) begin
                  state_next = SAMPLE;
               end
               else if (mjr_cnt < 5'd8) begin 
                  state_next = IDLE;
               end
               if (bit_cnt == 3'b111)
                 state_next = FIN;
               
            end // case: START_TEST
          
          
          SAMPLE: //sample the RX line
            begin
               rx_data_clr = 0;
               state_next = SAMPLE;               
               if (baud_en && RX2) begin
                  smpl_cnt_en = 1;                                    
                  mjr_cnt_en = 1;
               end
               if (baud_en && !RX2) begin
                  smpl_cnt_en = 1;                                    
                  mjr_cnt_en = 0;
               end
               if (/*baud_en &&*/ (smpl_cnt == 5'd16)) begin
                  //sampled 16 times
                  state_next = RECORD;
                  smpl_cnt_en = 0; 
               end
            end

          RECORD: //get the majority vote of sampled data and record it as one bit
            begin
               smpl_cnt_full = 1;
               bit_cnt_en = 1;
               mjr_cnt_clr = 1;
               rx_data_en = 1;
               state_next = SAMPLE;
               if (mjr_cnt >= 5'd8) begin
                  rx_data_next = (8'h01<<bit_cnt) | rx_data;
               end
               else if (mjr_cnt < 5'd8) begin 
                  rx_data_next = (8'h00<<bit_cnt) | rx_data;
               end
               if (bit_cnt == 3'b111)
                 state_next = FIN;
            end // case: REC

          FIN:
            begin
               rda_next = 1;
               if (clr_rda && RX2) begin
                  rda_next = 0;//when clr_rda is asserted,deassert rda
                  state_next = IDLE;
               end
               //if the clr_rda is asserted and transmission starts at the same time
               else if (clr_rda && !RX2) begin
                  rda_next = 0; //clear ready
                  state_next = START;
               end
            end // case: FIN

          default:
            begin
               state_next = IDLE;
            end
        endcase

     end

endmodule
