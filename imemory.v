`timescale 1ns/1ps
module imemory(
	input clka,
	input[13:0] addra,
	output [63:0] douta,
	input clkb,
	input[13:0] addrb,
	output  [63:0] doutb);
	
	reg [63:0] mem[0:16383];
	
	//always@(posedge clk)begin
	
	 assign douta=mem[addra];
	
	
	 assign doutb=mem[addrb];
	

   initial begin

      $readmemb("./ECE554_assembler/src/mult1_mif.mif", mem); // IM.mif is memory file
   end
   
	
	endmodule
