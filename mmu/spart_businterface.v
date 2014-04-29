//////////////////////////////////////////////////////////////////////////////////
// Company: UW-Madison
// Engineer: J.J.(Junjue) Wang, Pari Lingampally, Zheng Ling
// 
// Create Date: Feb 03   
// Design Name: SPART
// Module Name: spart_businterface
// Project Name: SPART
// Target Devices: FPGA Virtex 2 Pro
// Tool versions: Xilinx 10.1
// Description: This block include a combinational logic used for inout databus. The block was controlled by iorw and ioaddr signals. We perform a tri-state circuits to drive the inout and pass different data
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module spart_businterface(/*autoarg*/
   // Outputs
   tx_enable, baud_write, baud_select, baud_high, baud_low, tx_data,clr_rda,
   // Inouts
   databus,
   // Inputs
   rx_data, IOCS, IORW, RDA, TBR, IOADDR
   );


   input wire [7:0] rx_data;
   input wire       IOCS,IORW,RDA,TBR;
   input wire [1:0] IOADDR;
   output reg tx_enable,baud_write,baud_select,clr_rda;
   output reg [7:0] baud_high,baud_low,tx_data;
   inout wire  [7:0]    databus;

   reg [7:0]            data_out;
   wire [7:0]           data_in;
   
   

   always@(*)
     begin
        //default value of control signals
        tx_enable = 1'b0;
        baud_write = 1'b0;
        clr_rda = 1'b0;
        baud_low=8'h00;
        baud_high=8'h00;
        baud_select=0;
        tx_data=8'h00;
        data_out = 8'h00;
        
        if(IOCS) //the spart works only when IOCS is 1
          begin
             case(IOADDR)
               2'b00: //write to tx register of read from rx register
                 begin
                    if(IORW == 1'b0) 
                      begin
                         tx_data = data_in;
                         tx_enable = 1'b1;
                      end
                    else
                      begin
                         data_out = rx_data;
                         clr_rda = 1'b1;
                      end
                    
                 end
               2'b01: //read status register
                 if(IORW == 1'b1)
                   data_out = {6'b0,RDA,TBR};
               2'b10: //write to baud genterator low part
                 begin
                    baud_low = data_in;
                    baud_write = 1'b1;
                    baud_select = 1'b0;//baud_select is 0 for low division buffer and 1 for high divsion buffer
                 end
               default: //write to baud generator high part
                 begin
                    baud_high = data_in;
                    baud_write = 1'b1;
                    baud_select = 1'b1;
                 end
             endcase                          
          end
        
     end // always@ (*)

   //assign the 3-state inout
   assign databus = (IOCS && IORW && (IOADDR == 2'b00 || IOADDR == 2'b01)) ? data_out : 8'bz;
   
   assign data_in = (IOCS && ((!IORW && IOADDR == 2'b00) || IOADDR == 2'b10 || IOADDR == 2'b11)) ? databus : 8'bz;
 
   
   
endmodule // spart_businterface
