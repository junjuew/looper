//`default_nettype none
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
              iocs, iorw, ioaddr, enb, web, addrb, dinb, flsh, rom_out,
              dis_dvi_out, state,
              // Inouts
              databus,
              // Inputs
              clk, rst_n, br_cfg, rda, tbr, doutb, cpu_pc, mem_sys_fin, 
              display_plane_addr
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
   output reg        enb, web;
   output reg [13:0] addrb;
   output reg [63:0] dinb;
   input wire [63:0] doutb;   
   
   //interface with CPU IF stage
   input wire [15:0] cpu_pc;

   //interface with memory system
   output reg        flsh;//state machine output
   input wire        mem_sys_fin; //one cycle signal

   //interface with DVI
   input wire [12:0] display_plane_addr;
   output reg [23:0] rom_out;
   //disable dvi unit
   output reg        dis_dvi_out;
   
   output reg [3:0]  state;
   reg [3:0]         nxt_state;

   //define states
   localparam IDLE = 4'h0;
   localparam CLR_MEM = 4'h1;   
   localparam ECHO = 4'h2;
   localparam BAUD_LOW = 4'h3;
   localparam BAUD_HIGH = 4'h4;
   localparam PRG_EXE = 4'h5;
   localparam TRANS_RESULT = 4'h6;
   localparam TRANS_LOAD=4'h7;
   localparam TRANS_SEND=4'h8;   
   
   reg [1:0]         ioaddr_reg;
   reg               iorw_reg;
   

   
   assign iocs = 1'b1; //since our drive is only used for this spart, so we assume iocs is always 1
   assign ioaddr = ioaddr_reg;
   assign iorw = iorw_reg;
   

   
   reg [1:0]         prev_br_cfg; //used to check the change of baud rate
   reg               prev_br_cfg_en;
   

   wire [7:0]        data_in;
   reg [7:0]         data_out;
   wire [15:0]       baud_rate;

   //registers to store the value of data read from spart   
   reg [7:0]         stored_spart_data[7:0]; 

   //cnt is considered 9 clock cycles as one full operation cycle
   //when cnt is 0--7: recording data
   //cnt is 8: recording cmd
   reg [3:0]         cnt;
   //state machien output 
   reg               cnt_en;
   
   // we override the memory space when the thrid incoming byte
   // is character "s" 0x73
   reg [7:0]         cmd;

   reg [13:0]        start_mem_addr;
   //1 if program is done and memory system is done
   // 0 if program is done and memory system is busing flushing
   // no guarantee what the value would be (0 or 1) when program is running
   reg               mem_done_aft_prg;

   
   reg               ld_data, clr_cmd, start_mem_addr_en, stop_mem_addr_en, ld_addr_cnt, addr_cnt_en, clr_trans_cnt, ld_mem_out_buf, trans_cnt_en;
   wire [7:0]        echo_back_data;
   
   assign data_in = (iorw && (ioaddr == 2'b00 || ioaddr == 2'b01)) ? databus : 8'bz;

   assign databus = ((!iorw && ioaddr == 2'b00) || ioaddr == 2'b10 || ioaddr == 2'b11) ? data_out : 8'bz;
   
   //baudrate mux, used to select different baudrate
   // this is referring to the receive side, transmission's baud value
   // is 16 times larger than receiver
   // 0x516 * 16 = (10^9) / 4800 /10
   assign baud_rate = (br_cfg == 2'b00) ? 16'h82://16'h516://16'd64://16'h516://16'd16:
                      (br_cfg == 2'b01) ? 16'h28B:
                      (br_cfg == 2'b10) ? 16'h146: 16'ha3;
   
   wire [7:0]        stored_spart_data_en;

   // buffer value: as integer instead of ASCII
   // array idx 0 -- highest byte
   generate
      genvar         spart_i;
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


   always @(posedge clk, negedge rst_n)
     begin
        if(~rst_n)
          mem_done_aft_prg <= 1'b0;
        else if (flsh)
          mem_done_aft_prg <=1'b0;
        else if (mem_sys_fin)
          mem_done_aft_prg <=1'b1;
        else
          mem_done_aft_prg <= mem_done_aft_prg;
     end
   
          
   
   
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


   //cnt has already incremented by one when in ECHO state
   wire[3:0] echo_back_idx;
   assign echo_back_idx[3:0] = (cnt == 0)? 4'h8 : cnt-1;
   assign echo_back_data[7:0]  =  (echo_back_idx == 4'h8) ? cmd: (stored_spart_data[echo_back_idx][7:0] + 8'h30);


   /******* address counter used for tranmitting out the result**/
   reg [13:0] addr_cnt;
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          addr_cnt <= 14'h0;
        else if (ld_addr_cnt)
          addr_cnt <= start_mem_addr;
        else if (addr_cnt_en)
          addr_cnt <= addr_cnt +1;
        else
          addr_cnt <= addr_cnt;
     end

   /******* address counter used for tranmitting out the result**/
   reg [3:0] trans_cnt;
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          trans_cnt <= 4'h0;
        else if (clr_trans_cnt)
          trans_cnt <= 4'h0;
        else if (trans_cnt_en)
          trans_cnt <= trans_cnt +1;
        else
          trans_cnt <= trans_cnt;
     end

   
   /******* buffer to hold data from memory temporarily *******/
   reg [63:0] mem_out_buf;
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          mem_out_buf <= 14'h0;
        else if (ld_mem_out_buf)
          mem_out_buf <= doutb;
        else
          mem_out_buf <= mem_out_buf;
     end

   //element with highest idx represents MSB bytes
   wire[7:0] mem_out[7:0];
   generate
      genvar mem_out_i;
      for (mem_out_i=0; mem_out_i < 8; mem_out_i=mem_out_i+1)
        begin: mem_out_gen
           assign mem_out[mem_out_i][7:0] = mem_out_buf[(8 - mem_out_i)*8-1: (8 - mem_out_i -1)*8];
        end
   endgenerate
   

   /**** record the start and end address for final tranmission ****/

   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          start_mem_addr <= 14'h0;
        else if (start_mem_addr_en)
          start_mem_addr <= wrt_mem_data[13:0];
        else
          start_mem_addr <= start_mem_addr;
     end


   reg [13:0] stop_mem_addr;
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          stop_mem_addr <= 14'h0;
        else if (stop_mem_addr_en)
          stop_mem_addr <= wrt_mem_data[13:0];
        else
          stop_mem_addr <= stop_mem_addr;
     end
   
   wire               ld_cmd;
   assign ld_cmd = ld_data && (cnt == 4'h8);


   
   /******* cmd buffer ***********/
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          cmd <= 8'h0;
        //Magic send number: ASCII s !!
        // when load in one s, only keep it for one cycle
        else if (clr_cmd)
          cmd[7:0] <= 8'h0;
        else if (ld_cmd)
          cmd[7:0] <= data_in;
        else
          cmd <= cmd;
     end


   always@( mem_out[0] or mem_out[1] or mem_out[2] or mem_out[3] or mem_out[4] or mem_out[5] 
            or mem_out[6] or mem_out[7] 
            or addr_cnt or baud_rate or br_cfg or cmd or cpu_pc
            or echo_back_data or mem_done_aft_prg or prev_br_cfg or rda
            or state or stop_mem_addr or tbr or trans_cnt
            or wrt_mem_data or doutb or start_mem_addr or display_plane_addr)
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
        enb=1'b0;
        web=1'b0;
        addrb=LAST_SLOT_MEM_ADDR;
        dinb=wrt_mem_data;
        clr_cmd=1'b0;
        flsh=1'b0;
        start_mem_addr_en=1'b0;
        stop_mem_addr_en=1'b0;
        ld_addr_cnt=1'b0;
        addr_cnt_en=1'b0;
        clr_trans_cnt=1'b0;
        trans_cnt_en=1'b0;
        ld_mem_out_buf=1'b0;
        dis_dvi_out=1'b1;
        rom_out = 24'h0;
        
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
                    nxt_state = ECHO;                    
                 end
               else if (cmd == 8'h73) //s
                 begin
                    /********* cmd: send to data memory *************/
                    enb = 1'b1;
                    web = 1'b1;
                    addrb = LAST_SLOT_MEM_ADDR;
                    dinb = wrt_mem_data;
                    clr_cmd=1'b1;
                    
                    // overwrite memory value
                    //next state clr such value
                    nxt_state = CLR_MEM;
                 end // if (cmd == 8'h73)
               else if (cmd == 8'h61) //a
                 begin
                    /********* cmd: update start addr *************/
                    start_mem_addr_en=1'b1;
                    clr_cmd=1'b1;
                    nxt_state = IDLE;
                 end
               else if (cmd == 8'h65) //e
                 begin
                    /********* cmd: update stop addr *************/
                    stop_mem_addr_en=1'b1;                    
                    clr_cmd=1'b1;
                    nxt_state = IDLE;
                 end
               else if (cmd == 8'h64) //d
                 begin
                    /********* display img through dvi *************/
                    dis_dvi_out=1'b0;
                    rom_out = doutb[23:0];
                    enb=1'b1;
                    addrb= start_mem_addr + display_plane_addr;
                    //don't clr cmd in this case, keep continuously display
                    //wait for another cmd from spart to stop display
                    nxt_state=IDLE;
                 end
               else 
                 nxt_state = IDLE;
            end // case: IDLE

          // after cpu starts to execute such program
          // clr the last slot in mem to 0
          // so that we only execute each benchmark once
          CLR_MEM:
            begin
               //wait for pc to jump into the benchmark
               if (cpu_pc > 16'h3)
                 begin
                    enb = 1'b1;
                    web = 1'b1;
                    addrb = LAST_SLOT_MEM_ADDR;
                    dinb = 64'b0;
                    nxt_state=PRG_EXE;
                 end
               else
                                                //transmit back memory last slot for debug
                                                begin
                                                        nxt_state = CLR_MEM;
                                                        enb=1'b1;
                                                        addrb = LAST_SLOT_MEM_ADDR;
                                                        if (tbr)
                                                          begin
                                                                  ioaddr_reg = 2'b00;
                                                                  iorw_reg = 1'b0;        
                                                                  data_out = doutb[55:48];
                                                          end
                                                        
                                                end
            end

          //detect the end of program execution
          PRG_EXE:
            begin
               //when pc finished and jump back to
               // the loop at top
               // flush memory system
               // load the starting addr to addr_cnt
               if (cpu_pc <= 16'h3)
                 begin
                    flsh =1'b1;
                    ld_addr_cnt=1'b1;
                    nxt_state=TRANS_RESULT;
                 end
               else
                 nxt_state = PRG_EXE;
            end

          //bench mark finish execution mem system finish flush
          //start transmitting memory out to PC
          // in this state, ask the data from memory
          // memory need a posedge clk to output the read data
          // make sure tranmission buffer is rdy as well
          TRANS_RESULT:
            begin
               if (tbr && mem_done_aft_prg)
                 begin
                    // loop through interested memory region
                    if (addr_cnt <= stop_mem_addr)
                      begin
                         enb=1'b1;
                         addrb=addr_cnt;
                         addr_cnt_en =1'b1;
                         nxt_state = TRANS_LOAD;
                      end
                    else
                      begin
                         nxt_state = IDLE;
                      end
                 end
               else
                 nxt_state = TRANS_RESULT;
            end

          //load buffer from memory
          // addrb at this point changed, assume
          // the memory will hold address read out for one
          // clk cycle
          // possible problem..., if memory model assumption is wrong
          TRANS_LOAD:
            begin
               enb=1'b1;
               ld_mem_out_buf=1'b1;
               addrb=addr_cnt - 14'h1;
               clr_trans_cnt=1'b1;              
               nxt_state = TRANS_SEND;
            end
          
          // start transmitting each byte
          TRANS_SEND:
            begin
               if (trans_cnt <= 4'h7)
                 begin
                    if (tbr)
                      begin
                         ioaddr_reg = 2'b00;
                         iorw_reg = 1'b0;        
                         data_out = mem_out[trans_cnt][7:0];
                         trans_cnt_en=1'b1;
                         nxt_state = TRANS_SEND;                         
                      end
                    else
                      nxt_state= TRANS_SEND;
                 end // if (trans_cnt <= 4'h7)
               else
                 // finish sending 8 bytes
                 begin
                    nxt_state = TRANS_RESULT;
                 end // else: !if(trans_cnt <= 4'h7)
            end
          

          ECHO://try to echo back
            begin
               if (tbr)
                 begin
                    ioaddr_reg = 2'b00;
                    iorw_reg = 1'b0;        
                    nxt_state = IDLE;
                    data_out = echo_back_data;
                 end
               else
                 nxt_state = ECHO;
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
