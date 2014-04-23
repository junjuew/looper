// 
// Create Date: 11/03/2014
// Design Name: multiplier
// Module Name: multiplier
// Project Name: Loopers
// Target Devices: XUP Virtex-5 Pro
// Tool versions: 
// Description: This module is a multiplier using technique of radix 4 Booth 
//                          recoding
//
//
// Revision 1.0 - funtion verified
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////
// multiplier will not clock in a new instruction 
// when mult_free is high or mult_valid_wb is high
// The earliest time multiplier can clock in a new
// instruction is the cycle after mult_valid_wb goes high
///////////////////////////////////////////////////

module multiplier( mult_op1, mult_op2, mult_out, mult_en, mult_valid_wb, /*mult_free,*/ clk, rst_n);

   input mult_en, clk, rst_n;
   input [15:0] mult_op1, mult_op2;
   output [15:0] mult_out;
   output        mult_valid_wb /*, mult_free*/;
   reg [32:0]    Product;
   reg [15:0]    Mand1,Mand2,sum;
   reg [3:0]     counter;
   reg           state, nstate;
   reg           cnt_en, rst_cnt;
   wire          done;



   //-----------------------------------------------------------------------------
   //  FSM controller
   //-----------------------------------------------------------------------------
   always @(state, done, mult_en)
     begin  
        rst_cnt = 0;
        cnt_en = 0;
        case (state)
          1'b0: begin
             if (!mult_en)
               nstate = 1'b0;
             else begin
                nstate = 1'b1;
                rst_cnt = 1;
             end
          end               
          1'b1: begin
             cnt_en = 1;
             rst_cnt = 0;
             if(!done)
               nstate = 1'b1;
             else  begin
                nstate = 1'b0;
                rst_cnt = 1;
             end
          end
        endcase 
     end 
   assign done = counter[3];

   
   //-----------------------------------------------------------------------------
   //  Implement state register
   //-----------------------------------------------------------------------------
   always @(posedge clk, negedge rst_n)
     if (~rst_n)
       state <= 1'b0;
     else
       state <= nstate;

   
   //-----------------------------------------------------------------------------
   //  Cycle counter
   //-----------------------------------------------------------------------------
   always @(posedge clk, negedge rst_n)
     if (~rst_n)
       counter <=4'h0;
     else if (rst_cnt)
       counter <= 4'h0;
     else if(cnt_en)
       counter <= counter + 1;
     else
       counter <=counter;

   //-----------------------------------------------------------------------------
   //  Booth Multiplier
   //-----------------------------------------------------------------------------
   // combinational logic. doing the add step in booth 
   always @(*)     
     begin //  Adder
        case ({state,Product[2:0]})
          4'b1000:
            sum = Product[32:17];
          4'b1001:
            sum = Product[32:17] + Mand1;
          4'b1010:
            sum = Product[32:17] + Mand1;
          4'b1011:
            sum = Product[32:17] + Mand2;
          4'b1100:
            sum = Product[32:17] - Mand2;
          4'b1101:
            sum = Product[32:17] - Mand1;
          4'b1110:
            sum = Product[32:17] - Mand1;
          4'b1111:
            sum = Product[32:17];
          
          default:
            sum=16'h0000;
        endcase 
     end 
   
   //-----------------------------------------------------------------------------
   //  This is the Product register and counter
   //-----------------------------------------------------------------------------

   always @(posedge clk, negedge rst_n)
     begin
        if (~rst_n)
          begin
             Product[32:0] <= 33'h000000000;
             Mand1 <= 16'h0000;
             Mand2 <= 16'h0000;
          end
        
        case (state)
          1'b0:
            begin
               Product[32:17] <= 16'b0;
               Product[16:1] <= mult_op1;
               Product[0] <= 1'b0;
               Mand1 <= mult_op2;
               Mand2 <= mult_op2 <<1;
            end        

          1'b1:
            begin
               Product <= {sum[15],sum[15],sum, Product[16:2]};
               Mand1<=Mand1;
               Mand2<=Mand2;
            end
        endcase 

     end
   
   assign mult_out = Product[16:1];
   assign mult_valid_wb = done;

//   assign mult_free = (~state) || ( (~counter[3]) & counter[2] & counter[1] & (counter[0])) || mult_valid_wb;

endmodule

