module timing_gen(fifo,clk,rst,empty,vsync,hsync,blank,rd_en,D);
//inputs
input [23:0]fifo;
input clk,empty,rst;

//outputs
//output reg [7:0] pixel_r,pixel_g,pixel_b;
output vsync,hsync,blank;
output [11:0]D;
output rd_en;

//internal signals
reg [9:0] vcount,hcount;
//reg state,nxt_state;

wire [9:0]nxt_vcount,nxt_hcount;



//counter for hsync, vsync
assign nxt_vcount=(hcount ==10'd799)?((vcount==10'd524)?0:vcount+1):vcount; // Yuewen's design here is 524
assign nxt_hcount=(hcount == 10'd799)?0:hcount+1;

always@(posedge clk,posedge rst)
if(rst)begin
    vcount<=10'h0;
    hcount<=10'h0;
end /*else if(empty)begin
    vcount<=10'h0;
    hcount<=10'h0;
end*/ else if(!empty) begin
    vcount<=nxt_vcount;
    hcount<=nxt_hcount;
end else begin
    vcount<=vcount;
    hcount<=hcount;
end
/*
 // from tutorial
		assign hsync = (hcount < 10'd656) || (hcount> 10'd751); // 96 cycle pulse
		assign vsync = (vcount < 10'd490) || (vcount > 10'd491); // 2 cycle pulse
		assign blank = ~((hcount > 10'd639) | (vcount > 10'd479));
*/
 // Yuewen's design
assign hsync=(hcount<10'd16)||(hcount>10'd111);
assign vsync=(vcount<10'd11)||(vcount>10'd12);
assign blank=(hcount>10'd159)&&(hcount<10'd800)&&(vcount>10'd44)&&(vcount<10'd525);

// test
assign D = (clk)? fifo[11:0] : fifo[23:12]; //pixel_gbrg[23:12] : pixel_gbrg[11:0];

assign rd_en = blank;

/*
//output colors
always@(clk)begin
    rd_en=0;
	 //D[11:0]=12'h000;
    if(!rst)begin
      if(hcount>10'd159 && vcount>10'd44//blank)begin
          rd_en=1;
          if(clk==1)begin
            //D[11:0]=fifo[11:0];//pixel_r=fifo[23:16];
            //D[7:0]=fifo[7:0];//pixel_g=fifo[15:8];
            //pixel_b=fifo[7:0];
				//D[11:0] = 12'hfff;
           end else begin
               //D[11:0]=fifo[23:12];
               //D[3:0]=fifo[15:12];
				//D[11:0] = 12'hfff;
           end
			  
       end
   end     
end
*/

endmodule
