module Divider_tb();
	reg [15:0] 	inst1, inst2, inst3, inst4;
	wire [63:0] 	inst_in;

	wire [15:0] 	bits11_8_out, bits7_4_out, bits3_0_out, opco_out;
	wire [7:0]	jmp_off_out;
	reg		clk;
	
	initial
		begin
			inst1 	= $random % 64000;
			inst2 	= $random % 64000;
			inst3 	= $random % 64000;
			inst4 	= $random % 64000;
		end

	initial
		begin
			clk 	= 0;
			forever #10 clk = ~clk;
		end

	always@(posedge clk)
		begin
			inst1 <= inst1 + 4;
			inst2 <= inst2 + 4;
			inst3 <= inst3 + 4;
			inst4 <= inst4 + 4;
		end


	assign inst_in = {inst1, inst2, inst3, inst4};

	Divider DUT_divider (
		// input
		.inst_in(inst_in), 

		// output
		.bits11_8_out(bits11_8_out),

		.bits7_4_out(bits7_4_out),

		.bits3_0_out(bits3_0_out),

		.opco_out(opco_out),

		.jmp_off_out(jmp_off_out));

	
	
endmodule
