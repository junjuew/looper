//`default_nettype none
//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    14:36:21 02/11/2008
// Design Name:
// Module Name:    vga_logic
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module display_plane(/*autoarg*/
   // Outputs
   addr, fifo_in, wrt_en,
   // Inputs
   clk, rst, rom_out, fifo_full
   );

   input wire clk;
   input wire rst;

   //interface with rom
   input wire [23:0] rom_out;
   output wire [12:0] addr;

   //interface with fifo
   input  wire       fifo_full;
   output wire[23:0] fifo_in;
   output  reg     wrt_en;

//   reg [23:0]    pixel_color;

   reg [3:0]     cnt_h,cnt_v;
   reg [6:0]     cnt_r;


   reg [12:0]    addr_cnt;

   reg [2:0]     state,nxt_state;

   ///////////state machine///////////
   reg           cnt_h_clr,cnt_h_en,cnt_v_clr,cnt_v_en,cnt_r_clr,cnt_r_en,addr_cnt_clr,addr_cnt_en, addr_cnt_repeat;

   localparam IDLE = 3'b000;
   localparam H_INC = 3'b001;
   localparam R_INC = 3'b010;
   localparam V_INC = 3'b011;
   localparam IDLE_2 = 3'b100;

/* -----\/----- EXCLUDED -----\/-----
   always@(posedge clk, posedge rst)
     if (rst)
       pixel_color <= 24'h000000;
     else if (dp_ld)
       pixel_color <= next_pixel_color;
 -----/\----- EXCLUDED -----/\----- */

   ////////////////////////////////////
   ///counter for repetation horizontal
   ////////////////////////////////////
   always @(posedge clk, posedge rst)
     begin
        if (rst)
             cnt_h <= 4'h0;
                  else if (cnt_h_clr)
             cnt_h <= 4'h0;
        else if (cnt_h_en)
          cnt_h <= cnt_h +1;
     end

   ////////////////////////////////////
   ///counter for repetation vertical
   ////////////////////////////////////
   always @(posedge clk, posedge rst)
     begin
        if (rst)
             cnt_v <= 4'h0;
                  else if (cnt_v_clr)
             cnt_v <= 4'h0;
        else if (cnt_v_en)
          cnt_v <= cnt_v + 1;
     end

   ////////////////////////////////////
   ///counter for display until edge
   ////////////////////////////////////
   always @(posedge clk, posedge rst)
     begin
        if(rst)
          cnt_r <= 7'b0;
                        else if (cnt_r_clr)
          cnt_r <= 7'b0;
        else if(cnt_r_en)
          cnt_r <= cnt_r + 1;
     end

   always @(posedge clk, posedge rst)
     begin
        if(rst)
          state <= IDLE;
        else
          state <= nxt_state;
     end

   ////////////////////////////////////
   ///counter for incrementing rom_addr
   ////////////////////////////////////
   assign addr=addr_cnt;
   always@(posedge clk, posedge rst)
     begin
        if(rst)
          addr_cnt <= 13'b0;
        else if (addr_cnt_clr)
          addr_cnt <= 13'b0;
        else if(addr_cnt_en)
          if(addr_cnt == 13'd4799)
            addr_cnt <= 13'd0;
          else
            addr_cnt <= addr_cnt + 13'b1;
        else if(addr_cnt_repeat)
          addr_cnt <= addr_cnt - 13'd79;

     end


   always@(*)
     begin
        cnt_h_en = 1'b0;
        cnt_r_en = 1'b0;
        cnt_v_en = 1'b0;
        addr_cnt_en = 1'b0;
        cnt_h_clr = 1'b0;
        cnt_r_clr = 1'b0;
        cnt_v_clr = 1'b0;
        addr_cnt_clr = 1'b0;
        addr_cnt_repeat = 1'b0;
        wrt_en = 1'b0;

        nxt_state = state;

        case(state)
          IDLE: // entry point
            begin
               nxt_state = IDLE_2;
               cnt_h_clr = 1'b1;
               cnt_r_clr = 1'b1;
               cnt_v_clr = 1'b1;
               addr_cnt_clr = 1'b1;
            end

          IDLE_2: //wait for the rom data to be ready
            begin
               nxt_state = H_INC;
               cnt_h_en=1'b1;
               cnt_r_clr = 1'b1;
               cnt_v_clr = 1'b1;
               addr_cnt_clr = 1'b1;
            end

          H_INC: // repeat pixel 8 times horizontal
            begin
               if(!fifo_full && cnt_h != 4'd8)
                 begin
                    cnt_h_en = 1'b1;
                    wrt_en = 1'b1;
                    nxt_state = H_INC;
                 end
               else if(!fifo_full && cnt_h == 4'd8)
                 begin
                    nxt_state = R_INC;
                    cnt_h_clr = 1'b1;
                 end
               else
                 nxt_state = H_INC;
            end // case: H_INC

          R_INC: // display 80 pixels in one line
            begin
               if(!fifo_full)
                 begin
                    if(cnt_r == 8'd79)
                      begin
                         nxt_state = V_INC;
                         cnt_r_clr = 1'b1;
                         cnt_h_clr=1'b1;
//                         addr_cnt_en = 1'b1;
                      end
                    else
                      begin
                         nxt_state = H_INC;
                         cnt_r_en = 1'b1;
                         cnt_h_clr=1'b1;
                         addr_cnt_en = 1'b1;
                      end // else: !if(cnt_r == 6'b80)
                 end // if (!fifo_full)
               else
                 nxt_state = R_INC;
            end // case: R_INC

          V_INC: // repeat line 8 times
            begin
               if(!fifo_full)
                 begin
                    cnt_v_en = 1'b1;
                    nxt_state = H_INC;
                    cnt_r_clr = 1'b1;
                    cnt_h_clr=1'b1;
                    if(cnt_v ==  4'd7)
                      begin
                         cnt_v_clr = 1'b1;
                         addr_cnt_en=1'b1;
                      end
                    else
                      begin
                         addr_cnt_repeat = 1'b1;
                      end
                 end // if (!fifo_full)
               else
                 nxt_state = V_INC;
            end // case: V_INC

          default:
            nxt_state = IDLE;
        endcase // case (state)


     end

   assign fifo_in = rom_out;

endmodule // display_plane













