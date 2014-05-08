`timescale 1ns/1ps
module imemory(
input clka,
input[13:0] addra,
output reg [63:0] douta,
input clkb,
input[13:0] addrb,
output reg [63:0] doutb);
reg [63:0] mem[0:16383];
always@(posedge clka) begin
douta<=mem[addra];
doutb<=mem[addrb];
end
initial begin
$readmemb("./ECE554_assembler/Test/ldr_str_tutu_mif.mif", mem);
end
endmodule

