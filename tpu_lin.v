`default_nettype none

  //////////////////////////////////////////////////
// represent each line of valid bit
  // clr_val,set_val in charge of valid bit
  // clr_wat, set_wat in charge of wait bit
  // fls in charge of inst bits, doesn't alter valid and wait bit
  /////////////////////////////////////////////////// /
  module tpu_lin(/*autoarg*/
   // Outputs
   cur_map, tpu_out, tpu_inst_rdy,
   // Inputs
   rst_n, clk, dst_reg_rdy, dst_rdy_reg_en, isq_lin, prv_map
   );

   parameter INST_WIDTH=67;
   parameter TPU_MAP_WIDTH= 7 * 16; //7 bit for each logical register
   parameter TPU_INST_WIDTH= 7 * 16; //7 bit for each logical register   
   localparam ISQ_LINE_WIDTH=INST_WIDTH +2;
   //bitmap for instructions
   //everything is relative to the inst_width
   localparam BIT_INST_VLD = INST_WIDTH -1 ;
   localparam BIT_LSRC1_VLD = INST_WIDTH -1 -1  ;   
   localparam BIT_LSRC2_VLD = INST_WIDTH -1 - 11;      
   localparam BIT_LDST_VLD = INST_WIDTH -1 - 6;
   
   
   
   ///////////////////////////////////////
   //need to define all the bit masks
   //////////////////////////////////////

   //used for the preg rdy register
   input wire rst_n, clk, dst_reg_rdy, dst_rdy_reg_en;
   //correspond to each line in isq
   input wire [ISQ_LINE_WIDTH-1:0] isq_lin;
   input wire [TPU_MAP_WIDTH-1:0]  prv_map;
   
   output wire [TPU_MAP_WIDTH-1:0]  cur_map;
   output wire [TPU_INST_WIDTH-1:0] tpu_out;
   output wire                      tpu_inst_rdy;
   
   reg                             dst_rdy;
   // valid bit + rdy bit + since we have 64 registers (6 bits)
   wire [7:0]                      psrc1;
   wire [7:0]                      psrc2;   

   reg [6:0]                       psrc1_map;
   reg [6:0]                       psrc2_map;   

   wire [TPU_MAP_WIDTH-1:0]        pos_map[15:0];
   wire [5:0]                      pdst; //allocated physical register
   wire [3:0]                      ldst;
   
   
   ///////////////////////////////
   //grab ldst from inst
   ////////////////////////////
   assign ldst = isq_lin[BIT_LDST_VLD -1 :BIT_LDST_VLD -4];
   assign pdst = isq_lin [5:0];
   
   ///////////////////////////////////////
   //source register renaming
   //////////////////////////////////////
   //find the physical mapping for all instructions
   //combinational logic
   always @(/*autosense*/isq_lin
            or prv_map)
     begin
        //16 logical registers (4 bits)
        case (isq_lin[BIT_LSRC1_VLD -1: BIT_LSRC1_VLD -4])
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

        case (isq_lin[BIT_LSRC2_VLD -1: BIT_LSRC2_VLD -4])
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
   assign psrc1 = (!isq_lin[BIT_LSRC1_VLD])? 7'h40:{1'b1, psrc1_map};
   assign psrc1 = (!isq_lin[BIT_LSRC2_VLD])? 7'h40:{1'b1, psrc2_map};
   

   ////////////////////////////////////
   // destination reg rdy bit
   // such flop should only be enabled
   // in following 2 scenerios:
   // 1. instruction load into issue queue: dst_reg_rdy =0;
   // 2. physical register value rdy: dst_reg_rdy=1;
   ///////////////////////////////////
   always @(posedge clk, negedge rst_n)
     begin
        if (!rst_n)
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
   //TODO: not sure if this works
   //can convert it into an always block
   assign cur_map = pos_map[ldst];
   assign tpu_out = {isq_lin[ISQ_LINE_WIDTH-1:BIT_LSRC1_VLD+1], psrc1, psrc2, isq_lin[BIT_LSRC2_VLD-1:0]};
   
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
