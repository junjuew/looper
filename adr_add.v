//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:	15/03/2014
// Design Name: address adder
// Module Name: adr_add
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: The address adder will only handle the load and store instruction.
//           It is functionally same with an adder
//
//
// Revision 1.0 - initial version
// Additional Comments: timing issue this is a combinational unit but ALU takes 1
//                      clock cycle
//
//////////////////////////////////////////////////////////////////////////////////

module adr_add( addr_op1, addr_op2, addr_en, addr_free, addr_out);
  input  [15:0] addr_op1, addr_op2;
  input         addr_en;
  output        addr_free;
  output [15:0] addr_out;

  
  assign addr_out = addr_op1 + addr_op2;
  assign addr_free = ~addr_en;   // don't need this free signal
	
	
	endmodule
  