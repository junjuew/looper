module Control_Unit(
		    // input signals
		    opco_in,
		    jmp_off_in,
		    // output signals
		    LDI_out,
		    brn_out,
		    jmp_out,
		    MemRd_out,
		    MemWr_out,
		    ALU_ctrl_out,
		    invRt_out,
		    Rs_v_out,
		    Rd_v_out,
		    Rt_v_out,
		    im_v_out,
		    RegWr_out,
		    jmp_v_out,
		    ALU_to_add_out,
		    ALU_to_mult_out,
		    ALU_to_addr_out,
		    inst_vld_out
		    );

   input	[3:0]	opco_in;
   input [1:0] 		jmp_off_in;

   output reg		ALU_to_add_out, ALU_to_mult_out, ALU_to_addr_out;
   output reg		LDI_out, MemRd_out, MemWr_out, invRt_out, Rs_v_out, Rd_v_out, Rt_v_out, im_v_out, RegWr_out, jmp_v_out;
   output reg [1:0] 	brn_out;
   output reg [1:0] 	jmp_out;
   output reg [2:0] 	ALU_ctrl_out;
   output reg 		inst_vld_out;
   
   always @(opco_in, jmp_off_in)
     begin
	case({opco_in})
	  // No OP
	  6'b0000: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b0; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b0; RegWr_out = 1'b0; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b0; end
	  // ADD
	  6'b0001: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b001; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b1; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // SUB
	  6'b0010: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b010; invRt_out = 1'b1; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b1; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // AND
	  6'b0011: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b011; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b1; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // OR
	  6'b0100: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b100; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b1; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // XOR
	  6'b0101: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b101; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b1; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // NOT
	  6'b0110: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b110; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b0; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // SRA
	  6'b0111: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b111; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b1; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // MUL
	  6'b1000: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b1; im_v_out = 1'b0; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b1; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // BEQZ
	  6'b1001: begin LDI_out = 1'b0; brn_out = 2'b11; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b0; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // BLTZ
	  6'b1010: begin LDI_out = 1'b0; brn_out = 2'b01; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b0; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // BGTZ
	  6'b1011: begin LDI_out = 1'b0; brn_out = 2'b10; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b0; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // LDI
	  6'b1100: begin LDI_out = 1'b1; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b0; Rd_v_out = 1'b1; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // STR
	  6'b1101: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b1; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b0; Rt_v_out = 1'b1; im_v_out = 1'b1; RegWr_out = 1'b0; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b1; inst_vld_out = 1'b1; end
	  // LDR
	  6'b1110: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b1; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b1; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b1; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b1; inst_vld_out = 1'b1; end
	  // J
	  6'b1111:
begin
if(jmp_off_in == 2'b00)
begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b0; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b0; jmp_v_out = 1'b1; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // JR
else if(jmp_off_in == 2'b01)
begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b01; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b0; jmp_v_out = 1'b1; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
	  // JAL changed to LDI
else
begin LDI_out = 1'b1; brn_out = 2'b00; jmp_out = 2'b10; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b0; Rd_v_out = 1'b1; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b1; jmp_v_out = 1'b1; ALU_to_add_out = 1'b1; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b1; end
end
	  // JALR
	  default: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b00; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b0; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b0; RegWr_out = 1'b0; jmp_v_out = 1'b0; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; inst_vld_out = 1'b0; end
	  

	  //6'b1111_11: begin LDI_out = 1'b0; brn_out = 2'b00; jmp_out = 2'b11; MemRd_out = 1'b0; MemWr_out = 1'b0; ALU_ctrl_out = 3'b000; invRt_out = 1'b0; Rs_v_out = 1'b1; Rd_v_out = 1'b0; Rt_v_out = 1'b0; im_v_out = 1'b1; RegWr_out = 1'b0; jmp_v_out = 1'b1; ALU_to_add_out = 1'b0; ALU_to_mult_out = 1'b0; ALU_to_addr_out = 1'b0; end
	endcase

     end
   

endmodule


