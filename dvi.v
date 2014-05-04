`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// company: 
// engineer: 
// 
// create date:    21:15:00 02/10/2014 
// design name: 
// module name:    top_module 
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
module dvi(
           clk_100mhz,
           clk_25mhz,
           rst,
           d,
           blank,
           hsync,
           vsync,
           dvi_clk,
           dvi_clk_n,
           dvi_rst,
           scl,
           sda,
           //for memory interface
           rom_out,
           display_plane_addr,
           locked_dcm
           );
   
   input clk_100mhz;
   input clk_25mhz;
   input rst;
   output [11:0] d;
   output        blank;
   output        hsync;
   output        vsync;
   output        dvi_clk;
   output        dvi_clk_n;
   output        dvi_rst;

   
/* -----\/----- EXCLUDED -----\/-----
   // for test
   output reg    gpio_led_0;
   output reg    gpio_led_1;
   
   output reg    gpio_led_2;
   output reg    gpio_led_4;
   output reg    gpio_led_7;
 -----/\----- EXCLUDED -----/\----- */

   //interface with rom
   input wire [23:0] rom_out;
   output wire [12:0] display_plane_addr;
   
   
   wire               clkin_ibufg_out;
   wire               clk_25mhz;
   wire               clk_100mhz;
   input wire               locked_dcm;
   
   assign dvi_clk = clk_25mhz;
   assign dvi_clk_n = ~clk_25mhz;
   
   output wire               sda;
   output wire               scl;
   wire               iic_tx_done;
   wire               done;
   
//   wire [12:0]        addr;
   
   wire [23:0]        fifo, /*data_in,*/ data_out;
   wire               full;
   wire               empty,write,rd_en;
   
   ////////////////////////////////////////////////
   // led for test ////////////////////////////////
   
   reg [23:0]         cnt;
   reg [23:0]         cnt_25;
   
   // assign gpio_led_0 = 1'b1;
/*   
   always@(posedge clk_25mhz, posedge rst) begin
      if(rst) begin
         gpio_led_0 <= 1'b0;
         cnt_25 <= 24'h0;
      end
      else begin
         cnt_25 <= cnt_25+1;
         if(cnt_25[23] == 1) begin
            gpio_led_0 <= 1'b1;
         end
         else begin
            gpio_led_0 <= 1'b0;
         end
      end
   end
   
   always@(posedge clk_100mhz, posedge rst) begin
      if(rst) begin
         gpio_led_1 <= 1'b0;
         cnt <= 24'h0;
      end
      else begin
         if(empty) 
           cnt <= cnt+1;
         else 
           cnt <= cnt;
         
         if(cnt[10] == 1) begin
            gpio_led_1 <= 1'b1;
         end
         else begin
            gpio_led_1 <= 1'b0;
         end
      end
   end
   
   always@(posedge dvi_clk, posedge rst)
     if(rst)
       gpio_led_2 <= 0;
     else if(iic_tx_done)
       gpio_led_2 <= 1;
     else
       gpio_led_2 <= gpio_led_2;
 
   always@(posedge dvi_clk)
     if(rst)
       gpio_led_4 <= 0;
     else if(empty)
       gpio_led_4 <= 1;
     else
       gpio_led_4 <= 0; 
   
   always@(posedge dvi_clk, posedge rst)
     if(rst)
       gpio_led_7 <= 0;
     else if(full)
       gpio_led_7 <= 1;
     else
       gpio_led_7 <= 0;//gpio_led_7;
 */
   // led for test ////////////////////////////////
   ////////////////////////////////////////////////

   
   
   assign dvi_rst = ~(rst|~locked_dcm);
   // assign d = (clk)? fifo[23:12] : fifo[11:0];
 
   dvi_ifc dvi1(.clk(clk_25mhz), 
                .reset_n(dvi_rst), 
                .sda(sda), 
                .scl(scl), 
                .done(done),                        // i2c configuration done
                .iic_xfer_done(iic_tx_done),        // iic configuration done
                .init_iic_xfer(1'b0)                // iic configuration request
                );
 
   
   //   rom rom1(clk_100mhz_buf, addr, data_in);
   
   display_plane display_plane1(.rst(rst|~locked_dcm), .clk(clk_100mhz), .rom_out(rom_out), .fifo_full(full), .addr(display_plane_addr), .wrt_en(write), .fifo_in(data_out));
   
   xclk_fifo xclk_fifo1(.rst(rst|~locked_dcm), .wr_clk(clk_100mhz), .rd_clk(clk_25mhz), .din(data_out), .wr_en(write), .rd_en(rd_en), .dout(fifo), .full(full), .empty(empty));
   
   timing_gen timinggen1(fifo, clk_25mhz, (rst|~locked_dcm), empty, vsync, hsync, blank, rd_en, d);
endmodule
