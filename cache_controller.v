module cache_controller(rst, 
			clk, 
			flush, // whether a cache flushing is initiated 
			enable_cache, // whether a cache operation is enabled
			line_dirty, // whether the line is dirty, needing flushing back to main memory
			done_mem, // whether memory operation is done
			miss_hit, // whether a cache miss/hit occurs
			wrt_bck, // whether writeback is needed
			rd_wrt_mem,// read or write, control the first port of main memory
			mem_enable, // enable for the first port of main memory
			idle, // whether the memory system is idle
			mem_rdy, // whether the data read from main memory is ready for cache use
			one_line_flushed, // whether one line is done flushing
			flush_finish); // when the cache flushing should end
   
   // input and output ports declarations
   input rst, clk, miss_hit, wrt_bck, enable_cache, done_mem,flush, line_dirty;
   output reg rd_wrt_mem, mem_enable, idle, mem_rdy, one_line_flushed, flush_finish;
   wire       flush_end;
   localparam IDLE=3'b000; // idle state
   localparam CACHE=3'b001; // handle cache operation (busy)
   localparam MISS =3'b010; // handle cache miss (busy)
   localparam WRITEBACK=3'b011; // handle memory writeback (busy)
   localparam FLUSH_START=3'b100; 
   localparam FLUSH_IN_PROCESS=3'b101;
   
   
   reg [2:0]  state, nxt_state; // state registers
   
   reg [3:0]  flush_cntr; // counter used to count how many lines have been flushed
   
   reg 	      flush_clr, flush_enable; // control signals for the flush counter
   
   
   // count how many lines have been flushed
   always@(posedge clk, negedge rst)
     if (!rst)
       flush_cntr <= 0;
     else if (flush_clr)
       flush_cntr <= 0;
     else if (flush_enable)
       flush_cntr <= flush_cntr+1;
     else
       flush_cntr <= flush_cntr;
   
   
   
   assign flush_end=(flush_cntr == 4'b1111); // 16 lines to flush
   
   // state transition
   always@(posedge clk, negedge rst)
     if (!rst)
       state <= IDLE;
     else
       state <= nxt_state;
   
   // output generation logic   
   always@(miss_hit,line_dirty, flush_end, flush, wrt_bck, enable_cache, done_mem, state) 
     begin
	rd_wrt_mem=0;
	mem_enable=0;
	idle=1;
	mem_rdy=0;
	one_line_flushed=0;
	flush_clr=0;
	flush_enable=0;
	flush_finish=0;
	case (state)
          IDLE:
            if (flush) begin
               nxt_state= FLUSH_START;
               flush_clr=1;
               idle=0;
            end
          
            else if (enable_cache && !(miss_hit)) begin
               nxt_state=MISS;
               // Enable memory read
               mem_enable=1;
               rd_wrt_mem=1;
               // Memory system is busy now
               idle=0;
            end
            else if (enable_cache && miss_hit) begin
               nxt_state=CACHE;
               idle=0;
            end
            else
              nxt_state=IDLE;
          
          CACHE: 
            nxt_state=IDLE;
          
          
          MISS: begin
             idle=0;
             if (done_mem && !(wrt_bck)) begin
                mem_rdy=1;
                nxt_state=IDLE;
             end
             else if (done_mem && wrt_bck) begin
                mem_rdy=1;
                nxt_state=WRITEBACK;
                rd_wrt_mem=0;
                mem_enable=1;
             end
             else
               nxt_state=MISS;
          end
          
          WRITEBACK:
            if (done_mem) begin
               idle = 0;
               nxt_state = IDLE;
            end
            else begin
               nxt_state=WRITEBACK;
               mem_enable=1;
               idle=0;
            end
          
          
          
          FLUSH_START: begin
             idle=0;
	     if (flush_end) begin
		nxt_state=IDLE;
		flush_finish=1;
		flush_clr=1;
	     end
	     else if (line_dirty) begin
		mem_enable=1;
		nxt_state=FLUSH_IN_PROCESS;
             end
             else begin
		flush_enable=1;
		one_line_flushed=1;
		nxt_state=FLUSH_START;
             end
          end
          
          
          FLUSH_IN_PROCESS: begin
             idle=0;
             mem_enable=1;
             if (done_mem && (!flush_end)) begin
		flush_enable=1;
		one_line_flushed=1;
		nxt_state=FLUSH_START;
             end
             else if (done_mem && flush_end) begin
		flush_finish=1;
		flush_clr=1;
		idle=1;
		nxt_state=IDLE;
             end
             else
               nxt_state=FLUSH_IN_PROCESS;
          end
          

	  default:
	    nxt_state = IDLE;
	            
        endcase
        
        
     end               
   
   
   
endmodule
