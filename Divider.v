module Divider(
	// input
	inst_in,
	
	// output
	bits11_8_out,
	bits7_4_out,
	bits3_0_out,
	opco_out,
	jmp_off_out);

	input [63:0]	inst_in;
	
	output [15:0]	bits11_8_out, bits7_4_out, bits3_0_out, opco_out;
	output [7:0]	jmp_off_out;
	
	assign bits11_8_out	= {inst_in[59:56], inst_in[43:40], inst_in[27:24], inst_in[11:8]};
	assign bits7_4_out	= {inst_in[55:52], inst_in[39:36], inst_in[23:20], inst_in[7:4]};
	assign bits3_0_out	= {inst_in[51:48], inst_in[35:32], inst_in[19:16], inst_in[3:0]};
	assign opco_out 	= {inst_in[63:60], inst_in[47:44], inst_in[31:28], inst_in[15:12]};
	assign jmp_off_out	= {inst_in[49:48], inst_in[33:32], inst_in[17:16], inst_in[1:0]};
	
endmodule
