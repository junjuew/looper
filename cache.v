module cache (flush_finish, one_line_flushed, rst, clk, flush, addr_ca, data_ca_in, rd_wrt_ca, enable,
    data_ca_out, mem_rdy, addr_mem,
    data_to_mem, wrt_bck, miss_hit, data_from_mem, done, line_dirty); 
    
    // input and output ports declarations
    input rst, clk, rd_wrt_ca, enable, mem_rdy, flush, one_line_flushed, flush_finish;
    input [15:0] addr_ca, data_ca_in;
    input [63:0] data_from_mem;
    output miss_hit, wrt_bck, line_dirty;
    output reg [15:0] data_ca_out;
     output reg [13:0] addr_mem;
    output reg [63:0] data_to_mem;
    output reg done;
    
    parameter ENTRY_NUMBER = 8;
   wire [7:0] match;
    reg victim; // indicate which way to evict if a miss occurs
    reg [153:0] mem[0:ENTRY_NUMBER-1]; // cache memory
    wire [10:0] tag; // tag bits for comparison
    wire [2:0]  index; // index which entry
    wire [1:0] offset; // indicate which part of the cache line is the wanted
    wire read, // whether this is a read operation
          write, // whether this is a write operation
          hit_first, // whether the first way is a cache hit
          hit_second, // whether the second way is a cache hit
          non_cache_able,
          write_hit_first,
          write_hit_second,
          miss_read_ready;
      reg flush_way, flush_reg;
      reg [2:0] flush_index;
wire [63:0] flush_data_to_mem;
wire [13:0] flush_addr_mem, evicted_data_addr;
wire [15:0] candidate_data;
wire [63:0] evicted_data;
      
    assign tag=addr_ca[15:5];
    assign index=addr_ca[4:2];
    assign offset=addr_ca[1:0];
    assign read=enable & rd_wrt_ca;
    assign write=enable & (!rd_wrt_ca);
    assign hit_first=(mem[index][152] == 1) & (tag == mem[index][151:141]);
    assign hit_second=(mem[index][75] == 1) & (tag == mem[index][74:64]);
    assign miss_hit=(non_cache_able) ? 0 : (hit_first | hit_second);
    assign wrt_bck= (non_cache_able) ? 0 :
                      (victim == 1'b1) ?  (!(miss_hit) & (mem[index][153] == 1)) :
                                          (!(miss_hit) & (mem[index][76] == 1)); // whether a writeback is needed telling from the corresponding dirty bit
    assign line_dirty= (flush_way == 0 && (&mem[flush_index][153:152] == 1'b1)) ? 1 : 
                      (flush_way == 1 && (&mem[flush_index][76:75] == 1'b1)) ? 1:
                                                                              0;
    assign non_cache_able= (&addr_ca) & enable;
    assign write_hit_first = write & hit_first;
    assign write_hit_second = write & hit_second;
    assign miss_read_ready= (~miss_hit) & enable & mem_rdy;
	assign match[0] = (index == 0);
	assign match[1] = (index == 1);
	assign match[2] = (index == 2);
	assign match[3] = (index == 3);
	assign match[4] = (index == 4);
	assign match[5] = (index == 5);
	assign match[6] = (index == 6);
	assign match[7] = (index == 7);
    generate
    genvar i;
    for (i=0;i < ENTRY_NUMBER ; i=i+1)
    begin: cache_assignment
    always@(posedge clk, negedge rst) begin
    if (!rst)
       mem[i][153:0]<=154'b0;
    else if ( match[i] ) begin
         if (write_hit_first)
            mem[i][153:0] <= (offset == 2'b11) ? {1'b1, 1'b1,mem[i][151:141], data_ca_in, mem[i][124:0]}:
                              (offset == 2'b10) ? {1'b1, 1'b1, mem[i][151:125], data_ca_in, mem[i][108:0]}:
                               (offset == 2'b01) ? {1'b1, 1'b1, mem[i][151:109], data_ca_in, mem[i][92:0]}:
                                                   {1'b1, 1'b1, mem[i][151:93], data_ca_in, mem[i][76:0]};
         else if (write_hit_second)
            mem[i][153:0] <= (offset == 2'b11) ? {mem[i][153:77], 1'b1, 1'b1, mem[i][74:64], data_ca_in, mem[i][47:0]}:
                              (offset == 2'b10) ? {mem[i][153:77], 1'b1, 1'b1, mem[i][74:48], data_ca_in, mem[i][31:0]}:
                               (offset == 2'b01) ?{mem[i][153:77], 1'b1, 1'b1, mem[i][74:32], data_ca_in, mem[i][15:0]}:
                                                  {mem[i][153:77], 1'b1, 1'b1, mem[i][74:16], data_ca_in};
         else if (miss_read_ready)
              mem[i][153:0] <= (victim == 1'b1) ? {2'b01,tag,data_from_mem, mem[i][76:0]} :
                                                  {mem[i][153:77],2'b01,tag, data_from_mem};
         else
             mem[i][153:0] <= mem[i][153:0];
    end
    else
        mem[i][153:0] <= mem[i][153:0];
end
end
endgenerate




      
      always@(posedge clk, negedge rst)
      if (!rst)
        flush_reg <= 0;
      else if (flush_finish)
        flush_reg <= 0;
      else if (flush)
        flush_reg <= 1;     
      else
        flush_reg <= flush_reg;
   


      always@(posedge clk, negedge rst)
      if (!rst)
        flush_way <= 0;
      else if (flush_reg & one_line_flushed)
        flush_way <= ~flush_way;
      else
        flush_way <= flush_way;





        always@(posedge clk, negedge rst)
        if (!rst)
          flush_index <= 3'b000;
        else if (flush_reg & one_line_flushed & flush_way)
          flush_index <= flush_index +1'b1;
        else
          flush_index <= flush_index;



    assign flush_addr_mem = (flush_way & line_dirty) ? {mem[flush_index][74:64], flush_index}:
			     ((!flush_way) & line_dirty) ? {mem[flush_index][151:141], flush_index}: 0;
 
    assign flush_data_to_mem = (flush_way & line_dirty) ? mem[flush_index][63:0]:
			     ((!flush_way) & line_dirty) ? mem[flush_index][140:77]: 0;

assign candidate_data = (hit_first & offset == 2'b11)? mem[index][140:125]:
			(hit_first & offset == 2'b10)? mem[index][124:109] :
			(hit_first & offset == 2'b01)? mem[index][108:93] :
			(hit_first & offset == 2'b00)? mem[index][92:77]:
			(hit_second & offset == 2'b11)? mem[index][63:48]:
			(hit_second & offset == 2'b10)? mem[index][47:32] :
			(hit_second & offset == 2'b01)? mem[index][31:16] :
			(hit_second & offset == 2'b00)? mem[index][15:0]: 0;

assign evicted_data = (victim == 1) ?  mem[index][140:77] : mem[index][63:0];
assign evicted_data_addr= (victim == 1)? {mem[index][151:141], index} : {mem[index][74:64], index};
 
    always@(posedge clk, negedge rst)
    if (!rst) begin
        data_to_mem <= 0;
        data_ca_out <= 0;
        addr_mem <= 0;
        victim <= 0;
        done <= 0;
    end
    else if (flush_reg) begin
		done <= 0;
		victim <= victim;
		data_ca_out <= 16'h0000;
        	addr_mem <= flush_addr_mem;
		data_to_mem <= flush_data_to_mem;
	
    end
    else if (non_cache_able & (~mem_rdy)) begin
	  victim <= victim;
          done <= 0;
          addr_mem <= 14'b11111111111111;
          data_to_mem <= data_to_mem;
	 data_ca_out <= 16'h0000;
    end
    else if (non_cache_able & mem_rdy) begin
	addr_mem <= 14'h0000;
	victim <= victim;
	data_to_mem <= data_to_mem;
        data_ca_out <= data_from_mem[15:0];
        done <= 1;
    end      
    else if (miss_hit & read) begin
          // read hit
          done <= 1;
          data_to_mem <= 16'h0000;
          addr_mem <= 14'h0000;
          data_ca_out <= candidate_data;
          victim <= victim;
    end
else if (miss_hit & write) begin
	  done <= 1;
	  data_to_mem <= data_to_mem;
	 addr_mem <= addr_mem;
         data_ca_out <= data_ca_out;
         victim <= victim;
end
else if ((~miss_hit) & enable & (~mem_rdy)) begin
    done <= 0;
    addr_mem <= {tag, index};
    data_to_mem <= 64'b0;
    victim <= victim;
    data_ca_out <= 16'h0000;
end
else if ((~miss_hit) & enable & mem_rdy & wrt_bck) begin
	    // writeback is needed
            // eviction and replacement
           addr_mem <= evicted_data_addr;
	  data_to_mem <= evicted_data;
           victim <= ~victim;
	   done <= 0;
	  data_ca_out <= 16'h0000;
end
else begin
   done <= 0;
   victim <= victim;
   data_ca_out <= data_ca_out;
   data_to_mem <= data_to_mem;
   addr_mem <= addr_mem;
end


endmodule
    
    
    
    
