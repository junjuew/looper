`timescale 1ns/1ps
module imemory(
        input clka,
        input[13:0] addra,
        output reg [63:0] douta,
        input clkb,
        input[13:0] addrb,
        output reg [63:0] doutb);
        
        reg [63:0] mem[0:16383];
       /* reg [13:0] addr_buf1, addr_buf2;
        
        always@(posedge clka)
                        begin
                                addr_buf1 <= addra;
                        end
                always@(posedge clkb)
                        begin
                                addr_buf2 <= addrb;
                        end
        */
       always@(posedge clka) begin
             douta<=mem[addra];
             doutb<=mem[addrb];
          end

   initial begin

      $readmemb("./ECE554_assembler/Test/bubble_sort20_mif.mif", mem); // IM.mif is memory file
   end
   
        
        endmodule
