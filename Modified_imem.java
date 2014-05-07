import java.io.*;
import java.util.Hashtable;
import java.util.Scanner;
import java.util.*;

public class Modified_imem{

	
	public static void main(String[] args) {
		// declare and initialize scanners for all dump files
		File imemoryFile = new File("imemory.v");
		String asmFile = args[0];
		String content = "`timescale 1ns/1ps\n" + 
					"module imemory(\n"+
						"input clka,\n"+
						"input[13:0] addra,\n"+
						"output reg [63:0] douta,\n"+
						"input clkb,\n"+
						"input[13:0] addrb,\n"+
						"output reg [63:0] doutb);\n"+
						"reg [63:0] mem[0:16383];\n"+
					       "always@(posedge clka) begin\n"+
						     "douta<=mem[addra];\n"+
						     "doutb<=mem[addrb];\n"+
						  "end\n"+
					   "initial begin\n"+
					      "$readmemb(\"./ECE554_assembler/Test/" + asmFile + "_mif.mif\", mem);\n"+
					   "end\n"+
						"endmodule\n";
        	PrintWriter imemoryWriter = null;
		try {
	        	imemoryWriter = new PrintWriter(imemoryFile);
		} catch (IOException ioeOpenOut) {
		    System.err.println("could not open "+imemoryFile+" for output");
		    System.exit(-1);
		}
		imemoryWriter.println(content);
		imemoryWriter.close();
	}
}
