`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UW-Madison
// Engineer: J.J.(Junjue) Wang, Pari Lingampally, Zheng Ling
// 
// Create Date: Feb 03   
// Design Name: SPART
// Module Name:    driver 
// Project Name: SPART
// Target Devices: FPGA Virtex 2 Pro
// Tool versions: Xilinx 10.1
// Description: This block is used to drive the whole spart and let it can work on  the FPGA board. 
// The functionality of this block is to receive the data from spart when there is data received by spart and then transmit it back to spart and let it do the transmission. // There is a FSM designed in the driver, it has five state, including one idle state, one receive state, 
// one transmit state and the other two state used to write the baud rate divisor. '
// It can also write different baud rate to spart based on the two selections br_cfg.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(/*autoarg*/
              // Outputs
              iocs, iorw, ioaddr, enb, web, addrb, dinb,
              // Inouts
              databus,
              // Inputs
              clk, rst_n, br_cfg, rda, tbr, doutb
              );


   parameter LAST_SLOT_MEM_ADDR=14'h3fff;
   
   input wire clk;
   input wire rst_n;

   // interface with spart
   input wire [1:0] br_cfg;
   output wire      iocs;
   output wire      iorw;
   input wire       rda;
   input wire       tbr;
   output wire [1:0] ioaddr;
   inout wire [7:0]  databus;
   
   //interface with memory
   output wire       enb, web;
   output wire [13:0] addrb;
   output wire [63:0] dinb;
   input wire [63:0]  doutb;   
   


   reg [2:0]          state,nxt_state;

   //define states
   localparam IDLE = 3'h0;
   localparam TRANS = 3'h2;
   localparam BAUD_LOW = 3'h3;
   localparam BAUD_HIGH = 3'h4;
   
   reg [1:0]          ioaddr_reg;
   reg                iorw_reg;
   

   
   assign iocs = 1'b1; //since our drive is only used for this spart, so we assume iocs is always 1
   assign ioaddr = ioaddr_reg;
   assign iorw = iorw_reg;
   

   reg [1:0]          prev_br_cfg; //used to check the change of baud rate
   reg                prev_br_cfg_en;
   

   wire [7:0]         data_in;
   reg [7:0]          data_out;
   
   wire [15:0]        baud_rate;

   //registers to store the value of data read from spart   
   reg [7:0]          stored_spart_data[7:0]; 

   
   // indicate which byte the spart is going to override
   // 0 ---- high byte
   // 1 ---- low byte
   // 2 --- cmd
   // by default (at rst), it's high byte
   reg [3:0]          cnt;
   //state machien output 
   reg                cnt_en;
   
   // we override the memory space when the thrid incoming byte
   // is character "s" 0x73
   reg [7:0]          cmd;

   //   wire              ld_spart_data_high, ld_spart_data_low, ld_cmd;
   wire               ld_cmd;
   reg                ld_data;
   wire [7:0]         echo_back_data;
   
   assign data_in = (iorw && (ioaddr == 2'b00 || ioaddr == 2'b01)) ? databus : 8'bz;

   assign databus = ((!iorw && ioaddr == 2'b00) || ioaddr == 2'b10 || ioaddr == 2'b11) ? data_out : 8'bz;
   
   //baudrate mux, used to select different baudrate
   // this is referring to the receive side, transmission's baud value
   // is 16 times larger than receiver
   // 0x516 * 16 = (10^9) / 4800
   assign baud_rate = (br_cfg == 2'b00) ? 16'd64://16'h516:
                      (br_cfg == 2'b01) ? 16'h28B:
                      (br_cfg == 2'b10) ? 16'h146: 16'ha3;
   
   wire [7:0]         stored_spart_data_en;

   // buffer value: as integer instead of ASCII
   // array idx 0 -- highest byte
   generate
      genvar          spart_i;
      for (spart_i=0; spart_i < 8; spart_i= spart_i+1)
        begin: spart_i_gen
           always @(posedge clk, negedge rst_n)
             begin
                if (~rst_n)
                  stored_spart_data[spart_i][7:0] <= 8'h0;
                else if (stored_spart_data_en[spart_i])
                  stored_spart_data[spart_i][7:0] <= data_in - 8'h30;
                else
                  stored_spart_data[spart_i] <= stored_spart_data[spart_i];
             end
        end
   endgenerate


   // generate the enable singals for stored data array
   generate
      genvar en_i;
      for (en_i=0; en_i < 8; en_i= en_i+1)
        begin: en_i_gen
           assign stored_spart_data_en[en_i] =  (ld_data) && (cnt == en_i);   
        end
   endgenerate
   
   
   always@(posedge clk, negedge rst_n)
     begin
        if(~rst_n)
          state <= BAUD_LOW;//when the spart was reset, set the state into write baud rate state
        else
          state <= nxt_state;
     end


   //when baud rate changed, set previous baud rate as current baud rate   
   always@(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          prev_br_cfg <= 2'b00;
        else if (prev_br_cfg_en)
          prev_br_cfg <=br_cfg;
        else
          prev_br_cfg<=prev_br_cfg;
     end


   /*   
    // buffer value: as integer instead of ASCII
    always @(posedge clk, negedge rst_n)
    begin
    if (~rst_n)
    stored_spart_data <= 16'h0;
    else if (ld_spart_data_high)
    stored_spart_data[15:8] <= data_in - 8'h30;
    else if (ld_spart_data_low)
    stored_spart_data[7:0] <= data_in - 8'h30;
    else
    stored_spart_data <= stored_spart_data; 
     end
    */
   
   wire wrt_mem;
   // buffer value: as integer instead of ASCII
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          cmd <= 8'h0;
        //Magic send number: ASCII s !!
        // when laod in one s, only keep it for one cycle
        else if (wrt_mem)
          cmd[7:0] <= 8'h0;
        else if (ld_cmd)
          cmd[7:0] <= data_in;
        else
          cmd <= cmd;
     end


   //combine stored_spart_data into one value
   // array idx 0 -- highest byte: 7
   // array idx 7 -- lowest byte: 0
   wire [63:0] wrt_mem_data;
   generate
      genvar   wrt_mem_data_i;
      for (wrt_mem_data_i=0; wrt_mem_data_i < 8; wrt_mem_data_i= wrt_mem_data_i+1)
        begin: wrt_mem_data_i_gen
           assign wrt_mem_data[(wrt_mem_data_i+1)*8-1: wrt_mem_data_i*8]  =  stored_spart_data[7-wrt_mem_data_i][7:0];
        end
   endgenerate
   
   
   /********* cmd send to data memory *************/
   //when cmd is 8'h73, start writing to data memory
   assign wrt_mem = (cmd == 8'h73);
   assign enb = wrt_mem;
   assign web = wrt_mem;
   //last slot in memory. hard coded!!!!
   assign addrb = LAST_SLOT_MEM_ADDR;
   assign dinb = wrt_mem_data;
   
   

   // indicate which byte we are overwriting
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          cnt <= 4'h0;
        else if (cnt == 4'h9)
          cnt <= 4'h0;
        else if (cnt_en)
          cnt <=cnt +1;
        else 
          cnt<=cnt;
     end


   //cnt has already incremented by one when in TRANS state
   wire[3:0] echo_back_idx;
   assign echo_back_idx[3:0] = (cnt == 0)? 4'h8 : cnt-1;
   
   assign echo_back_data[7:0]  =  (echo_back_idx == 4'h8) ? cmd: stored_spart_data[echo_back_idx][7:0];
/*   
   assign echo_back_data[7:0] = (cnt == 2'b00)? stored_spart_data[15:8]:
                                (cnt == 2'b01)? stored_spart_data[7:0]:
                                (cnt == 2'b10)? cmd[7:0]: 8'h0;
*/
 
   //   assign ld_spart_data_high = ld_data && (cnt == 2'b00);   
   //   assign ld_spart_data_low = ld_data && (cnt == 2'b01);
   assign ld_cmd = ld_data && (cnt == 4'h8);      
   
   always@(/*autosense*/baud_rate or br_cfg or echo_back_data
           or prev_br_cfg or rda or state or tbr)
     begin
        /*default*/
        // by default we are just reading the status register
        // ioaddr_reg to 2'b01 to have the data_out buts as ouput
        iorw_reg = 1'b1;
        ioaddr_reg = 2'b01;
        data_out = 8'h00;
        prev_br_cfg_en=0;
        ld_data=0;
        nxt_state=IDLE;
        cnt_en=1'b0;
        
        case(state)
          IDLE://idle state
            begin
               if(br_cfg != prev_br_cfg)
                 nxt_state = BAUD_LOW;
               else if(rda)
                 begin
                    ioaddr_reg = 2'b00;
                    //store data read from spart                    
                    ld_data=1'b1;
                    cnt_en=1'b1;
                    nxt_state = TRANS;                    
                 end
               else
                 nxt_state = IDLE;
            end

          /*          
           RECEV:// try to echo back
           begin
           if(tbr)
           begin
           ioaddr_reg = 2'b00;                                 
           data_out = data_in;
           nxt_state = TRANS;
                 end
           else
           nxt_state = RECEV;            
            end // case: RECEV
           */

          TRANS://try to echo back
            begin
               if (tbr)
                 begin
                    ioaddr_reg = 2'b00;
                    iorw_reg = 1'b0;        
                    nxt_state = IDLE;
                    data_out = echo_back_data;
                 end
               else
                 nxt_state = TRANS;
            end

          
          BAUD_LOW://write the baud rate
            begin
               ioaddr_reg = 2'b10;
               data_out = baud_rate[7:0];
               nxt_state = BAUD_HIGH;
            end
          BAUD_HIGH:
            begin
               ioaddr_reg = 2'b11;
               data_out = baud_rate[15:8];
               prev_br_cfg_en=1;
               nxt_state = IDLE;
            end
        endcase // case (state)
     end
   
endmodule
