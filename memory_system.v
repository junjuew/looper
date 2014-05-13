module memory_system(flush, // flush cache back to memory
		    	clk, 
			rst, 
			addr_ca, // address for cache operation
			data_ca_in, // input data for cache
			rd_wrt_ca, // read or write
			enable, // enable signal for memory system
			idle, // whether the system is idle
			done, // whether operation is completed
			data_ca_out, // data read out from the system
                     	mmu_mem_clk ,
                     	mmu_mem_rst ,
                     	mmu_mem_enb ,
                     	mmu_mem_web ,
                     	mmu_mem_addrb ,
                     	mmu_mem_dinb ,
                     	mmu_mem_doutb
                     );

   input rd_wrt_ca, enable, clk, rst, flush;
   input [15:0] addr_ca, data_ca_in;
   output       idle, done;
   output [15:0] data_ca_out;


   input wire    mmu_mem_clk ;
   input wire    mmu_mem_rst ;
   input wire    mmu_mem_enb ;
   input wire    mmu_mem_web ;
   input wire [13:0] mmu_mem_addrb ;
   input wire [63:0] mmu_mem_dinb ;
   output wire [63:0] mmu_mem_doutb ;
   
   
   wire              	miss_hit, // whether it's a cache hit/miss
			wrt_bck, // whether cache line writeback is needed
			done_mem, // whether main memory operation is completed
			rd_wrt_mem, // read or write to the first port of main memory
			mem_enable, // enable for the first port of main memory
			mem_rdy, // whether the data read out from main memory is ready for cache use
			line_dirty, // whether the cache line is dirty
			one_line_flushed, // when a cache line is flushed back to main memory
			flush_finish; // when the cache flushing should end
   wire [63:0]       data_to_mem, data_from_mem;  
   wire [13:0]       addr_mem;
   
   cache #(8) ca(.flush_finish(flush_finish), .flush(flush), .one_line_flushed(one_line_flushed), .rst(rst), .clk(clk), .addr_ca(addr_ca), .data_ca_in(data_ca_in), .rd_wrt_ca(rd_wrt_ca), .enable(enable),
                 .data_ca_out(data_ca_out), .addr_mem(addr_mem),.mem_rdy(mem_rdy), 
                 .data_to_mem(data_to_mem), .wrt_bck(wrt_bck), .miss_hit(miss_hit), .data_from_mem(data_from_mem),.done(done), .line_dirty(line_dirty));
   
   cache_controller cc(.flush(flush), .line_dirty(line_dirty), .rst(rst), .clk(clk), .enable_cache(enable),.done_mem(done_mem), .miss_hit(miss_hit), .wrt_bck(wrt_bck), .rd_wrt_mem(rd_wrt_mem),
                       .mem_enable(mem_enable), .idle(idle), .mem_rdy(mem_rdy), .one_line_flushed(one_line_flushed), .flush_finish(flush_finish));


   /* -----\/----- EXCLUDED -----\/-----
    memory_interface mem(.rst(rst), .clk(clk), .addr_mem(addr_mem), .rd_wrt_mem(rd_wrt_mem), .enable(mem_enable), .data_mem_in(data_to_mem), 
    .data_mem_out(data_from_mem),.done(done_mem));
    -----/\----- EXCLUDED -----/\----- */

   
   memory_interface mem(
                        // Outputs
                        .data_mem_out   (data_from_mem[63:0]),
                        .done           (done_mem),
                        // Inputs
                        .mmu_mem_clk    (mmu_mem_clk),
                        .mmu_mem_rst    (mmu_mem_rst),
                        .mmu_mem_enb    (mmu_mem_enb),
                        .mmu_mem_web    (mmu_mem_web),
                        .mmu_mem_addrb  (mmu_mem_addrb[13:0]),
                        .mmu_mem_dinb   (mmu_mem_dinb[63:0]),
                        .mmu_mem_doutb  (mmu_mem_doutb[63:0]),
                        .rst            (rst),
                        .clk            (clk),
                        .rd_wrt_mem     (rd_wrt_mem),
                        .enable         (mem_enable),
                        .addr_mem       (addr_mem[13:0]),
                        .data_mem_in    (data_to_mem[63:0]));
   
   
endmodule
