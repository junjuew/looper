`default_nettype none

  //////////////////////////////////////////////////
  // tpu_inst_rdy goes high when the instruction is not valid,
  // or all possible physical registers are ready
  //
  // prv_map input format:
  // logical mapping for reg 15, 14, 13, ...., 1,0
  //
  // input signal operations:
  // when loading a new instruction, dst_rdy_reg_en=1, dst_reg_rdy=0, so that inst below
  // will be blocked
  //
  // when an instruction finished executed, dst_rdy_reg_en=1, dst_reg_rdy=1, so that inst
  // below will start evaluate
  //
  /////////////////////////////////////////////////// /
  module tpu_lin(/*autoarg*/
   // Outputs
   cur_map, tpu_out, tpu_inst_rdy, fre_preg,
   // Inputs
   rst_n, clk, dst_reg_rdy, dst_rdy_reg_en, isq_lin, prv_map
   );

   parameter INST_WIDTH= 56;
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   // 6 is just an arbitrary value for widths of idx bit   
   parameter ISQ_IDX_BITS_NUM= 6;
   parameter ISQ_LINE_WIDTH=INST_WIDTH + ISQ_IDX_BITS_NUM + 1;
   //for each logical source register, physical register index has 2 more bits
   parameter TPU_INST_WIDTH= ISQ_LINE_WIDTH + 2 + 2 -5; 
   
   //bitmap for instructions
   //everything is relative to the inst_width, not isq_lin_width!!
   parameter BIT_INST_VLD = INST_WIDTH  - 1 ;
   parameter BIT_LSRC1_VLD = INST_WIDTH   -1 -1  ;   
   parameter BIT_LSRC2_VLD = INST_WIDTH  - 1 - 11;      
   parameter BIT_LDST_VLD = INST_WIDTH  - 1 - 6;
   
   
   ///////////////////////////////////////
   //need to define all the bit masks
   //////////////////////////////////////

   //used for the preg rdy register
   // dst_reg_rdy: ready signal for destination register (physical)
   // dst_rdy_reg_en: enable signal to read in dst_reg_rdy

   input wire rst_n, clk, dst_reg_rdy, dst_rdy_reg_en;
   //correspond to each line in isq
   input wire [ISQ_LINE_WIDTH-1:0] isq_lin;
   input wire [TPU_MAP_WIDTH-1:0]  prv_map;
   
   output reg [TPU_MAP_WIDTH-1:0]  cur_map;
   //free previously occupied physical register, if needed
   output wire [6:0]  fre_preg; 
   output wire [TPU_INST_WIDTH-1:0] tpu_out;
   output wire                      tpu_inst_rdy;
   
   reg                             dst_rdy;
   // rdy bit + since we have 64 registers (6 bits)
   wire [6:0]                      psrc1;
   wire [6:0]                      psrc2;   

   reg [6:0]                       psrc1_map;
   reg [6:0]                       psrc2_map;   

   wire [TPU_MAP_WIDTH-1:0]        pos_map[15:0];
   wire [5:0]                      pdst; //allocated physical register
   wire [3:0]                      ldst;

   //valid bit | logical reg number 
   wire [4:0]                      lsrc1, lsrc2;

   //mapping wires separated from prv_map
   wire [6:0]                      idi_map[15:0];

   //async reset signal for destination ready register
   //bad idea????: right now global rst_n is and with a module signal
   //that signfies a new instruction is loaded
   wire                            dst_rdy_rst;
   
   
   ///////////////////////////////
   //grab ldst from inst
   ////////////////////////////
   assign ldst = isq_lin[BIT_LDST_VLD -1 :BIT_LDST_VLD -4];
   //by default the physical register addr is at the LSB of inst coming in
   assign pdst = isq_lin [5:0];
   assign lsrc1 = isq_lin[BIT_LSRC1_VLD : BIT_LSRC1_VLD - 4];
   assign lsrc2 = isq_lin[BIT_LSRC2_VLD : BIT_LSRC2_VLD - 4];   
   
   
   ///////////////////////////////////////
   //source register renaming
   //////////////////////////////////////
   //find the physical mapping for all instructions
   //combinational logic
   always @(/*autosense*/isq_lin or prv_map)
     begin
        //16 logical registers (4 bits)
        case (lsrc1[3:0])
          4'd0: psrc1_map = prv_map[6:0];
          4'd1: psrc1_map = prv_map[13:7];
          4'd2: psrc1_map = prv_map[20:14];           
          4'd3: psrc1_map = prv_map[27:21];
          4'd4: psrc1_map = prv_map[34:28];
          4'd5: psrc1_map = prv_map[41:35];           
          4'd6: psrc1_map = prv_map[48:42];
          4'd7: psrc1_map = prv_map[55:49];
          4'd8: psrc1_map = prv_map[62:56];           
          4'd9: psrc1_map = prv_map[69:63];
          4'd10: psrc1_map = prv_map[76:70];
          4'd11: psrc1_map = prv_map[83:77];           
          4'd12: psrc1_map = prv_map[90:84];
          4'd13: psrc1_map = prv_map[97:91];           
          4'd14: psrc1_map = prv_map[104:98];
          4'd15: psrc1_map = prv_map[111:105];           
        endcase // case ()

        case (lsrc2[3:0])
          4'd0: psrc2_map = prv_map[6:0];
          4'd1: psrc2_map = prv_map[13:7];
          4'd2: psrc2_map = prv_map[20:14];           
          4'd3: psrc2_map = prv_map[27:21];
          4'd4: psrc2_map = prv_map[34:28];
          4'd5: psrc2_map = prv_map[41:35];           
          4'd6: psrc2_map = prv_map[48:42];
          4'd7: psrc2_map = prv_map[55:49];
          4'd8: psrc2_map = prv_map[62:56];           
          4'd9: psrc2_map = prv_map[69:63];
          4'd10: psrc2_map = prv_map[76:70];
          4'd11: psrc2_map = prv_map[83:77];           
          4'd12: psrc2_map = prv_map[90:84];
          4'd13: psrc2_map = prv_map[97:91];           
          4'd14: psrc2_map = prv_map[104:98];
          4'd15: psrc2_map = prv_map[111:105];           
        endcase // case ()
     end

   //for operations that doesn't write to register file
   //the ready bit should goes high instantly so that no furthur insts will
   //be blocked
   // if the instruction is not valid, then psrc1 and psrc2 are
   // rdy immediately
   assign psrc1 = ( (!isq_lin[BIT_LSRC1_VLD]) || (!isq_lin[BIT_INST_VLD]) )? 7'h40:{psrc1_map};
   assign psrc2 = ( (!isq_lin[BIT_LSRC2_VLD]) || (!isq_lin[BIT_INST_VLD]) )? 7'h40:{psrc2_map};
   

   ////////////////////////////////////
   // destination reg rdy bit
   // such flop should only be enabled
   // in following 2 scenerios:
   // 1. instruction load into issue queue: dst_reg_rdy =0;
   // 2. physical register value rdy: dst_reg_rdy=1;
   ///////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          dst_rdy<=1'b0;
        else if (dst_rdy_reg_en)
          begin
             //when loading, the value should be dst should be invalid
             if (isq_lin[BIT_INST_VLD] && isq_lin[BIT_LDST_VLD])
               dst_rdy <= dst_reg_rdy;
             //if such instruciton is not valid, or doesn't write to register file
             else
               dst_rdy<=1;
          end
        else
          dst_rdy <= dst_rdy;
     end
   
   
   //////////////////////////
   //output
   ///////////////////////////
   assign tpu_inst_rdy = psrc1[6] && psrc2[6];
   assign tpu_out = {isq_lin[ISQ_LINE_WIDTH-1:BIT_LSRC1_VLD+1], psrc1, psrc2, isq_lin[BIT_LSRC2_VLD-1 - 4:0]};

   //output current mappping
   //cur_map is the actual mapping output
   //pos_map is the potential mapping output
   always @(ldst, pos_map[0],pos_map[1],pos_map[2],pos_map[3],pos_map[4],pos_map[5],pos_map[6],pos_map[7],pos_map[8],pos_map[9],pos_map[10],pos_map[11],pos_map[12],pos_map[13],pos_map[14],pos_map[15])
     begin
        case (ldst)
          0: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[0];
          1: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[1];
          2: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[2];
          3: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[3];
          4: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[4];
          5: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[5];
          6: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[6];
          7: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[7];
          8: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[8];
          9: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[9];
          10: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[10];
          11: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[11];
          12: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[12];
          13: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[13];
          14: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[14];
          15: cur_map[TPU_MAP_WIDTH-1:0] = pos_map[15];
          default:
            cur_map[TPU_MAP_WIDTH-1:0] = {TPU_MAP_WIDTH{1'b0}};
        endcase // case (ldst)
     end


   ////////////////////////////////////////
   // separate previous mapping bus into different wires
   // /////////
   generate
      genvar prv_map_i;
      for (prv_map_i =0 ; prv_map_i<16; prv_map_i=prv_map_i+1)
        assign idi_map[prv_map_i][6:0]=prv_map[7 * (prv_map_i+1)-1: 7*prv_map_i];
   endgenerate
   
   /////////////////////////////////////
   //figure out what register to free
   // if this instruction allocate a new
   // physical register for current ldst
   ////////////////////////////////////
   assign fre_preg[6:0] = {isq_lin[BIT_LDST_VLD], idi_map[ldst][5:0]};

   
   //generate output mapping
   generate
      genvar                                      map_i;
      //16 logical registers to physical mappings
      for (map_i=0; map_i<16; map_i=map_i+1) 
        begin
           //possible mapping
           if (map_i ==0)
             assign pos_map[map_i]= {prv_map[TPU_MAP_WIDTH-1:(map_i+1)*7], dst_rdy, pdst};
           else if (map_i == 15)
             assign pos_map[map_i]= {dst_rdy, pdst, prv_map[map_i *7 -1: 0]};
           else
             assign pos_map[map_i]= {prv_map[TPU_MAP_WIDTH-1:(map_i+1)*7], dst_rdy, pdst, prv_map[map_i *7 -1: 0]};             
        end
   endgenerate

   
endmodule // isq_lin
