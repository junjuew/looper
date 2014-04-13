//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:	15/03/2014
// Design Name: ALU
// Module Name: ALU
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: This module is a general purpose ALU with add, and, or, xor, shift
//              , not and subtract operation
//
// Revision 1.0 - initial version
// Additional Comments: 
//        1. For SRA, the execution time of this type of shift is double of
//        : assign out={[N'b0,in[7:N]}. !but here Right hand should be constant?!
//        2. For alu_free, is it needed?
//
//////////////////////////////////////////////////////////////////////////////////

module ALU( alu_op1, alu_op2, alu_mode, alu_en, alu_inv_Rt, alu_out);
  input  [15:0] alu_op1, alu_op2;
  input  [2:0]  alu_mode;
  input         alu_en, alu_inv_Rt;

  output reg [15:0] alu_out;
 // output [5:0]  alu_index_out;
  
  wire [15:0] alu_op2_new;
////////////////////////////////////
//   Input Inverter 
///////////////////////////////////
	assign alu_op2_new = (alu_op2 ^ {16{alu_inv_Rt}});
  
  
  //////// Change this to combinational logic and for multiplier hold all the controll signal
  always @(*) begin
  if(alu_en == 1'b1) begin
  	casex(alu_mode)
		3'b00x:	begin alu_out <= alu_op1 + alu_op2_new; end	  // Nop 0+0?
		3'b010:	begin alu_out <= alu_op1 + alu_op2_new + 1;	end	  // SUB
		3'b011:	begin alu_out <= alu_op1 & alu_op2_new; end   // AND
		3'b100:	begin alu_out <= alu_op1 | alu_op2_new; end   // OR
		3'b101:	begin alu_out <= alu_op1 ^ alu_op2_new; end   // XOR
		3'b110:	begin alu_out <= ~alu_op1;              end   // NOT
		3'b111:	begin alu_out <= alu_op1 >> alu_op2;    end   // SRA

		//default:	begin			err <= 1; end	// default
	 endcase
	end
	end
	

	
	
	endmodule
  