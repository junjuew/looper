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
    
    reg victim; // indicate which way to evict if a miss occurs
    reg [153:0] mem[0:ENTRY_NUMBER-1]; // cache memory
    wire [10:0] tag; // tag bits for comparison
    wire [2:0]  index; // index which entry
    wire [1:0] offset; // indicate which part of the cache line is the wanted
    wire read, // whether this is a read operation
          write, // whether this is a write operation
          hit_first, // whether the first way is a cache hit
          hit_second, // whether the second way is a cache hit
          non_cache_able;
      reg flush_way, flush_reg;
      reg [2:0] flush_index;
      
    assign tag=addr_ca[15:5];
    assign index=addr_ca[4:2];
    assign offset=addr_ca[1:0];
    assign read=enable & rd_wrt_ca & rst;
    assign write=enable & (!rd_wrt_ca) & rst;
    assign hit_first=(mem[index][152] === 1) & (tag === mem[index][151:141]);
    assign hit_second=(mem[index][75] === 1) & (tag === mem[index][74:64]);
    assign miss_hit=(non_cache_able) ? 0 : (hit_first | hit_second);
    assign wrt_bck= (non_cache_able) ? 0 : 
                      (victim == 1'b1) ?  (!(miss_hit) & (mem[index][153] === 1)) :
                                          (!(miss_hit) & (mem[index][76] === 1)); // whether a writeback is needed telling from the corresponding dirty bit
    assign line_dirty= (flush_way == 0 && (&mem[flush_index][153:152] === 1'b1)) ? 1 : 
                      (flush_way == 1 && (&mem[flush_index][76:75] === 1'b1)) ? 1:
                                                                              0;
    assign non_cache_able= (&addr_ca) & enable;
    
      
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
          
          
          
    always@(posedge clk, negedge rst)
    if (!rst) begin
        data_to_mem <= 0;
        data_ca_out <= 0;
        addr_mem <= 0;
        victim <= 0;
        done <= 0;
    end
    else if (flush_reg) begin
      case(flush_way)
        1'b0: begin
           addr_mem <= (line_dirty ) ? {mem[flush_index][151:141], flush_index}: 0; // put memory address on the bus to write data back
           data_to_mem <= (line_dirty)? mem[flush_index][140:77]:0;
        end
        1'b1: begin
          addr_mem <= (line_dirty) ? {mem[flush_index][74:64], flush_index} : 0; // put memory address on the bus to write data back
          data_to_mem <= (line_dirty) ? mem[flush_index][63:0] : 0;  
      end
    endcase       
    end
  else if (non_cache_able) begin
    if (~mem_rdy) begin
        done <= 0;
        addr_mem <= 14'b11111111111111;
      end
    else begin
        data_ca_out <= data_from_mem[15:0];
        done <= 1;
    end      
  end
  else if (miss_hit & enable) begin  
          // read hit
          done <= 1;
          data_to_mem <= data_to_mem;
          addr_mem <= addr_mem;
          if (read) begin
             if (hit_first) 
                data_ca_out <=  (offset == 2'b11) ? mem[index][140:125] :
                                (offset == 2'b10) ? mem[index][124:109] :
                                (offset == 2'b01) ? mem[index][108:93] :
                                mem[index][92:77]; // read data out
             else
                data_ca_out <= (offset == 2'b11) ? mem[index][63:48] :
                                (offset == 2'b10) ? mem[index][47:32] :
                                (offset == 2'b01) ? mem[index][31:16] :
                                mem[index][15:0]; // read data out
           end
          // write hit                                
          else begin
             if (hit_first) 
                begin
                mem[index][153] <= 1'b1; // update dirty bit
                // write data
                case (offset)
                    2'b11: mem[index][140:125] <= data_ca_in;
                    2'b10: mem[index][124:109] <= data_ca_in;
                    2'b01: mem[index][108:93] <= data_ca_in;
                    2'b00: mem[index][92:77] <= data_ca_in;
                endcase
              end
              else
                begin
                mem[index][76] <= 1'b1; // update dirty bit
                // write data
                case (offset)
                    2'b11: mem[index][63:48] <= data_ca_in;
                    2'b10: mem[index][47:32] <= data_ca_in;
                    2'b01: mem[index][31:16] <= data_ca_in;
                    2'b00: mem[index][15:0] <= data_ca_in;
                endcase
                end
            end
end       
else if ((~miss_hit) & enable) begin
    done <= 0;
    if (~mem_rdy) 
            addr_mem <= {tag, index}; // fetch one cache line from memory
    else begin
       if (~wrt_bck) // no writeback is needed
        // replacement
            begin
                case (victim)
                1'b1:
                begin 
                    mem[index][140:77]<= data_from_mem; // cache line update
                    mem[index][151:141] <= tag; // tag update
                    mem[index][153:152] <= 2'b01; // state bits update            
                end
                1'b0:
                begin 
                    mem[index][63:0]<= data_from_mem; // cache line update
                    mem[index][74:64] <= tag; // tag update
                    mem[index][76:75] <= 2'b01; // state bits update               
                end
                endcase
            end
        else // writeback is needed
            // eviction and replacement
            begin
                case (victim)
                1'b1:
                begin
                    addr_mem <= {mem[index][151:141], index}; // put memory address on the bus to write data back
                    data_to_mem <= mem[index][140:77]; // put the dirty cache line on the bus to write back to memory
                    mem[index][140:77]<= data_from_mem; // cache line update
                    mem[index][151:141] <= tag; // tag update
                    mem[index][153:152] <= 2'b01; // state bits update
                    //victim <= ~victim; // flip the victim bit
                end
                1'b0:
                begin
                    addr_mem <= {mem[index][74:64], index}; // put memory address on the bus to write data back
                    data_to_mem <= mem[index][63:0]; // put the dirty cache line on the bus to write back to memory
                    mem[index][63:0]<= data_from_mem; // cache line update
                    mem[index][74:64] <= tag; // tag update
                    mem[index][76:75] <= 2'b01; // state bits update
                    //victim <= ~victim; // flip the victim bit
                end
                endcase
           end
           victim <= ~victim;
    end
end
else 
   done <= 0;

            
endmodule
    
    
    
    
