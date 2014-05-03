`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// company: 
// engineer: 
// 
// create date:    16:27:38 02/10/2014 
// design name: 
// module name:    dvi_ifc 
// project name: 
// target devices: 
// tool versions: 
// description: 
//
// dependencies: 
//
// revision: 
// revision 0.01 - file created
// additional comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module dvi_ifc(
  clk,                          // clock input
  reset_n,                      // reset input
  sda,                          // i2c data
  scl,                          // i2c clock
  done,                         // i2c configuration done
  iic_xfer_done,                // iic configuration done
  init_iic_xfer                 // iic configuration request
  );

///////////////////////////////////////////////////////////////////////////////
// parameter declarations
///////////////////////////////////////////////////////////////////////////////
                 
parameter c_i2c_slave_addr = 7'b1110110;

parameter clk_rate_mhz = 25,  
          sck_period_us = 30, 
          transition_cycle = (clk_rate_mhz * sck_period_us) / 2,
          transition_cycle_msb = 11;  



input          clk;
input          reset_n;
inout          sda;
inout          scl;
output         done;
output         iic_xfer_done;
input          init_iic_xfer;

  
          
localparam    idle           = 3'd0,
              init           = 3'd1,
              start          = 3'd2,
              clk_fall       = 3'd3,
              setup          = 3'd4,
              clk_rise       = 3'd5,
              wait_iic       = 3'd6,
              xfer_done      = 3'd7,
              start_bit      = 1'b1,
              ack            = 1'b1,
              write          = 1'b0,
              reg_addr0      = 8'h49,
              reg_addr1      = 8'h21,
              reg_addr2      = 8'h33,
              reg_addr3      = 8'h34,
              reg_addr4      = 8'h36,
              data0          = 8'hc0,
              data1          = 8'h09,
              data2a         = 8'h06,
              data3a         = 8'h26,
              data4a         = 8'ha0,
              data2b         = 8'h08,
              data3b         = 8'h16,
              data4b         = 8'h60,
              stop_bit       = 1'b0,            
              sda_buffer_msb = 27; 
          
wire [6:0]    slave_addr = c_i2c_slave_addr ;
          

reg                          sda_out; 
reg                          scl_out;  
reg [transition_cycle_msb:0] cycle_count;
reg [2:0]                    c_state;
reg [2:0]                    n_state;
reg                          done;   
reg [2:0]                    write_count;
reg [31:0]                   bit_count;
reg [sda_buffer_msb:0]       sda_buffer;
wire                         transition; 
reg                          iic_xfer_done;


// generate i2c clock and data 
always @ (posedge clk or negedge reset_n) 
begin : i2c_clk_data
    if (~reset_n)
      begin
        sda_out <= 1'b1;
        scl_out <= 1'b1;
      end
         else if (c_state == idle)
                begin
        sda_out <= 1'b1;
        scl_out <= 1'b1;
      end
    else if (c_state == init && transition) 
      begin 
        sda_out <= 1'b0;
      end
    else if (c_state == setup) 
      begin
        sda_out <= sda_buffer[sda_buffer_msb];
      end
    else if (c_state == clk_rise && cycle_count == transition_cycle/2 
                                 && bit_count == sda_buffer_msb) 
      begin
        sda_out <= 1'b1;
      end
    else if (c_state == clk_fall) 
      begin
        scl_out <= 1'b0;
      end
    
    else if (c_state == clk_rise) 
      begin
        scl_out <= 1'b1;
      end
end

assign sda = sda_out;
assign scl = scl_out;
                        

// fill the sda buffer 
always @ (posedge clk or negedge reset_n) 
begin : sda_buf
    //reset or end condition
    if(~reset_n) 
      begin
        sda_buffer  <= {slave_addr,write,ack,reg_addr0,ack,data0,ack,stop_bit};
        cycle_count <= 0;
      end
    //setup sda for sck rise
    else if ( c_state==setup && cycle_count==transition_cycle)
      begin
        sda_buffer <= {sda_buffer[sda_buffer_msb-1:0],1'b0};
        cycle_count <= 0; 
      end
    //reset count at end of state
    else if ( cycle_count==transition_cycle)
       cycle_count <= 0; 
    //reset sda_buffer   
    else if (c_state==init && init_iic_xfer==1'b1) 
      begin
       sda_buffer <= {slave_addr,write,ack,8'h0/*tft_iic_reg_addr*/,
                                       ack,8'h0/*tft_iic_reg_data*/, ack,stop_bit};
       cycle_count <= cycle_count+1;
      end   
    else if (c_state==wait_iic )
      begin
        case(write_count)
          0:sda_buffer <= {slave_addr,write,ack,reg_addr1,ack,data1, 
                                                          ack,stop_bit};
          1:sda_buffer <= {slave_addr,write,ack,reg_addr2,ack,data2b,
                                                          ack,stop_bit};
          2:sda_buffer <= {slave_addr,write,ack,reg_addr3,ack,data3b,
                                                          ack,stop_bit};
          3:sda_buffer <= {slave_addr,write,ack,reg_addr4,ack,data4b,
                                                          ack,stop_bit};
        default: sda_buffer <=28'dx;
        endcase 
        cycle_count <= cycle_count+1;
      end
    else
      cycle_count <= cycle_count+1;
end


// generate write_count signal
always @ (posedge clk or negedge reset_n)
begin : gen_write_cnt
 if(~reset_n)
   write_count<=3'd0;
 else if (c_state == wait_iic && cycle_count == transition_cycle && iic_xfer_done==1'b0 )
   write_count <= write_count+1;
end    

// transaction done signal                        
always @ (posedge clk or negedge reset_n) 
begin : trans_done
    if(~reset_n)
      done <= 1'b0;
    else if (c_state == idle)
      done <= 1'b1;
end
 
       
// generate bit_count signal
always @ (posedge clk or negedge reset_n) 
begin : bit_cnt
    if(~reset_n) 
       bit_count <= 0;
         else if (c_state == wait_iic)
                 bit_count <= 0;
    else if ( c_state == clk_rise && cycle_count == transition_cycle)
       bit_count <= bit_count+1;
end    

// next state block
always @ (posedge clk or negedge reset_n) 
begin : next_state
    if(~reset_n)
       c_state <= init;
    else 
       c_state <= n_state;
end    

// generate transition for i2c
assign transition = (cycle_count == transition_cycle); 
              
//next state              
//always @ (*) 
always @ (reset_n, init_iic_xfer, transition, bit_count, write_count,
          c_state) 
begin : i2c_sm_cmb
   case(c_state) 
       //////////////////////////////////////////////////////////////
       //  idle state
       //////////////////////////////////////////////////////////////
       idle: begin
           if(~reset_n | init_iic_xfer) 
             n_state = init;
           else 
             n_state = idle;
           iic_xfer_done = 1'b0;

       end
       //////////////////////////////////////////////////////////////
       //  init state
       //////////////////////////////////////////////////////////////
       init: begin
          if (transition) 
            n_state = start;
          else 
            n_state = init;
          iic_xfer_done = 1'b0;
       end
       //////////////////////////////////////////////////////////////
       //  start state
       //////////////////////////////////////////////////////////////
       start: begin
          if( transition) 
            n_state = clk_fall;
          else 
            n_state = start;
          iic_xfer_done = 1'b0;
       end
       //////////////////////////////////////////////////////////////
       //  clk_fall state
       //////////////////////////////////////////////////////////////
       clk_fall: begin
          if( transition) 
            n_state = setup;
          else 
            n_state = clk_fall;
          iic_xfer_done = 1'b0;
       end
       //////////////////////////////////////////////////////////////
       //  setup state
       //////////////////////////////////////////////////////////////
       setup: begin
          if( transition) 
            n_state = clk_rise;
          else 
            n_state = setup;
          iic_xfer_done = 1'b0;
       end
       //////////////////////////////////////////////////////////////
       //  clk_rise state
       //////////////////////////////////////////////////////////////
       clk_rise: begin
          if( transition && bit_count == sda_buffer_msb) 
            n_state = wait_iic;
          else if (transition )
            n_state = clk_fall;  
          else 
            n_state = clk_rise;
          iic_xfer_done = 1'b0;
       end  
       //////////////////////////////////////////////////////////////
       //  wait_iic state
       //////////////////////////////////////////////////////////////
       wait_iic: begin
          iic_xfer_done = 1'b0;          
          if((transition && write_count <= 3'd3))
            begin
              n_state = init;
            end
          else if (transition ) 
            begin
              n_state = xfer_done;
            end  
          else 
            begin 
              n_state = wait_iic;
            end  
         end 

       //////////////////////////////////////////////////////////////
       //  xfer_done state
       //////////////////////////////////////////////////////////////
       xfer_done: begin
          
          iic_xfer_done = 1'b1;
          
          if(transition)
              n_state = idle;
          else 
              n_state = xfer_done;
         end 

       default: n_state = idle;


     
   endcase
end


endmodule