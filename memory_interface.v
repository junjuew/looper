`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:34:03 03/24/2014 
// Design Name: 
// Module Name:    memory_interface 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Used to wrap around data memory to emulate long-latency access
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module memory_interface(rst, clk, addr_mem, rd_wrt_mem, enable, data_mem_in, data_mem_out,done,  mmu_mem_clk ,
 mmu_mem_rst ,
 mmu_mem_enb ,
 mmu_mem_web ,
 mmu_mem_addrb ,
 mmu_mem_dinb ,
 mmu_mem_doutb
                        );



   input wire  mmu_mem_clk ;
   input wire mmu_mem_rst ;
   input wire  mmu_mem_enb ;
   input wire  mmu_mem_web ;
   input wire [13:0] mmu_mem_addrb ;
   input wire [63:0] mmu_mem_dinb ;
   output wire [63:0] mmu_mem_doutb ;
   

   
   input rst, clk, rd_wrt_mem, enable;
   input [13:0] addr_mem;
   input [63:0] data_mem_in;
   output [63:0] data_mem_out;
   output reg    done;

   localparam IDLE=2'b00;
   localparam WAIT=2'b01;
   localparam READ=2'b10;
   localparam DONE=2'b11;

   reg [1:0]     state, nxt_state;
   reg [5:0]     cntr; // counter used to control the latency
   reg           cntr_clr, cntr_enable, load;
   reg [63:0]    stored_data_out;
   wire [63:0]   data_out;
   assign data_mem_out= done ? stored_data_out:64'd0; // send the data out to cache only when the latency value is reached
   // state transition
   always@(posedge clk, negedge rst)
     if (!rst)
       state <= IDLE;
     else
       state <= nxt_state;
   
   
   always@(posedge clk, negedge rst)
     if (!rst)
       cntr <=6'd0;
     else if (cntr_clr)
       cntr <=6'd0;
     else if (cntr_enable)
       cntr <= cntr+6'd1;
     else
       cntr <= cntr;
   
   
   assign time_up= (cntr == 3);
   // store the data read from main memory
   always@(posedge clk, negedge rst)
     if (!rst)
       stored_data_out <= 64'd0;
     else if (load)
       stored_data_out <= data_out;
     else
       stored_data_out <= stored_data_out;

   // control signals generation
   always@(enable, state, time_up, rd_wrt_mem) begin
      done=0;
      cntr_enable=0;
      cntr_clr=0;
      load=0;
      case(state)
        IDLE:
          if (enable & rd_wrt_mem) begin
             nxt_state=READ;
          end
          else if (enable & (~rd_wrt_mem)) begin
             nxt_state=WAIT;
          end
          else
            nxt_state=IDLE;
        
        READ:
          begin
             load=1;
             nxt_state=WAIT;
          end

        WAIT:
          if (time_up)
            nxt_state=DONE;
          else begin
             nxt_state=WAIT;
             cntr_enable=1;
          end


        DONE:
          begin
             done=1;
             nxt_state=IDLE;
             cntr_clr=1;
          end

		default:
		  nxt_state=IDLE;
      endcase
   end


   // add data memory second port for MMU
   memory data_memory(
                      .clka(clk),
                      .rsta(~rst),
                      .ena(enable),
                      .wea(~rd_wrt_mem),
                      .addra(addr_mem),
                      .dina(data_mem_in),
                      .douta(data_out),

                      .clkb(mmu_mem_clk),
                      .rstb(mmu_mem_rst),
                      .enb(mmu_mem_enb),
                      .web(mmu_mem_web),
                      .addrb(mmu_mem_addrb),
                      .dinb(mmu_mem_dinb),
                      .doutb(mmu_mem_doutb)
      
                      );

endmodule
