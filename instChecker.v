`default_nettype none

module instChecker(/*autoarg*/
   // Outputs
   pr_need_inst_out, rcvr_pc_to_rob, str_en_to_rob, spec_brch_to_rob,
   brch_mode_to_rob, brch_pred_res_to_rob, no_exe_to_rob,
   inst_val_to_rob, jr_to_rob,
   // Inputs
   inst0_in, inst1_in, inst2_in, inst3_in
   );

   input wire [65:0] inst0_in,inst1_in,inst2_in,inst3_in65;
   output wire [3:0] pr_need_inst_out;
   output wire [63:0] rcvr_pc_to_rob;
   output wire [3:0]  str_en_to_rob;
   output wire [3:0]  spec_brch_to_rob;
   output wire [3:0]  brch_mode_to_rob;
   output wire [3:0]  brch_pred_res_to_rob;
   output wire [3:0]  no_exe_to_rob;
   output wire [3:0]  inst_val_to_rob;
   output wire [3:0]  jr_to_rob;
   
   wire 	 pr_need[3:0];
   wire 	 brch_spec[3:0];
   wire 	 jr[3:0];
   wire   no_exe[3:0];
   
   assign pr_need[3] = inst3_in[16] ? 1:0;
   assign pr_need[2] = inst2_in[16] ? 1:0;
   assign pr_need[1] = inst1_in[16] ? 1:0;
   assign pr_need[0] = inst0_in[16] ? 1:0;

   assign pr_need_inst_out = {pr_need[3],pr_need[2],pr_need[1],pr_need[0]};
  
   assign rcvr_pc_to_rob = {inst3_in[15:0],inst2_in[15:0],inst1_in[15:0],inst0_in[15:0]};

   assign str_en_to_rob = {inst3_in[25],inst2_in[25],inst1_in[25],inst0_in[25]};

   assign brch_spec[3] = (inst3_in[31:30] == 2'b00) ? 0:1;
   assign brch_spec[2] = (inst2_in[31:30] == 2'b00) ? 0:1;
   assign brch_spec[1] = (inst1_in[31:30] == 2'b00) ? 0:1;
   assign brch_spec[0] = (inst0_in[31:30] == 2'b00) ? 0:1;

   assign spec_brch_to_rob = {brch_spec[3],brch_spec[2],brch_spec[1],brch_spec[0]};

   assign brch_mode_to_rob = {inst3_in[31:30],inst2_in[31:30],inst1_in[31:30],inst0_in[31:30]};

   assign brch_pred_res_to_rob = {inst3_in[16],inst2_in[16],inst1_in[16],inst0_in[16]};

   assign inst_val_to_rob = {inst3_in[65],inst2_in[65],inst1_in[65],inst0_in[65]};

   assign no_exe[3] = ~(inst3_in[21] | inst3_in[20] | inst3_in[19]);
   assign no_exe[2] = ~(inst2_in[21] | inst2_in[20] | inst2_in[19]);
   assign no_exe[1] = ~(inst1_in[21] | inst1_in[20] | inst1_in[19]);
   assign no_exe[0] = ~(inst0_in[21] | inst0_in[20] | inst0_in[19]);
   assign no_exe_to_rob = {no_exe[3],no_exe[2],no_exe[1],no_exe[0]};
   
   
endmodule // instChecker
