import java.io.*;
import java.util.Hashtable;

/**
 * Note to posterity:  This assembler really could use some basic
 * cleaning up of its structure.  It does not allow expressions
 * as literals/constants, and can't because it does not evaluate
 * symbols in the same pass it is parsing the source.  It could
 * be turned into an ordinary two-pass assembler without all that
 * much work.
 *
 **************************************************************
 * 
 * This code reads a line of assembly at a time and passes it to
 * AssemblyLine, which will parse the instruction and return the
 * various fields of the machine code.  This class keeps track of
 * the label table, and does the final combining and printing of
 * the machine word.
 *
 * Edited Mar 22, 2007 by pratap Ramamurthy. Changed to include
 * new instructions for spring 07 CS/ECE 552
 *
 * Edited 5/2/06 by Andy Phelps -- added "data" opcode to
 * insert 16-bit literals into the output.
 *           Syntax:  data n
 * where n is a decimal number, or 0x<hex>, or a label.
 *
 * Edited 4/28/06 by Andy Phelps -- added "zerofill" opcode to
 * allow inserting blocks of zeros into the object code.
 *           Syntax:  zerofill n
 * where n is a decimal number, or 0x<hex>, to specify how many
 * words of zero to insert.
 *
 * Edited 4/26/06 by Andy Phelps -- added output for 4-way interleaved
 * memory.  (Though this should probably be made an option.)
 *
 * Edited 1/15/06 by Andy Phelps -- fixed relative addressing for
 * jumps and conditional branches.
 */


class Assemble {

    public static final int MAX_SOURCE_LENGTH = 1024;
    private static int sourceLineID;

    public static void main(String [] args) {
        BufferedReader file = null;
        PrintWriter listOut = null;
            // Output for four banks of interleaved memory:
        PrintWriter mem0out = null;
        PrintWriter mem1out = null;
        PrintWriter mem2out = null;
        PrintWriter mem3out = null;
        String option = "";
        AssemblyLine [] progLine = new AssemblyLine[MAX_SOURCE_LENGTH];

        Hashtable<String, Integer> labelTable =
                   new Hashtable<String, Integer>();

        if (args.length != 4) {
            System.err.println("Usage: java Assemble <file> <outfile> -m <coe or lst>");
            System.exit(-1);
        }
        
        if (!args[2].equals("-m") || (!args[3].equals("lst") && !args[3].equals("coe"))){
            System.err.println("Usage: java Assemble <file> <outfile> -m <coe or lst>");
            System.exit(-1);
        }

        try {
            file = new BufferedReader(new FileReader(args[0]));
        } catch (IOException ioeOpen) {
            System.err.println("error opening " + args[0]);
            System.exit(-1);
        }

        String listFileName = "";
        if (args[3].equals("lst")){
        	listFileName = args[1] + "_lst.lst";
        }else{
        	listFileName = args[1] + "_coe.coe";
        }
        try {
                listOut = new PrintWriter(listFileName);
        } catch (IOException ioeOpenOut) {
            System.err.println("could not open "+listFileName+" for output");
            System.exit(-1);
        }

        String memFileName = args[1] + "_";
        /*try {
                mem0out = new PrintWriter(memFileName+"0"+".img");
                mem1out = new PrintWriter(memFileName+"1"+".img");
                mem2out = new PrintWriter(memFileName+"2"+".img");
                mem3out = new PrintWriter(memFileName+"3"+".img");
        } catch (IOException ioeOpenOut) {
            System.err.println("could not open "+memFileName+"[0123] for output");
            System.exit(-1);
        }*/

        AssemblyLine oneLine;
        int objLineID = 0;

        try {
            for (sourceLineID = 0; sourceLineID < MAX_SOURCE_LENGTH; sourceLineID++) {
            // create an AssemblyLine object to hold the source line's information.

            String tempParseLine = file.readLine();
            if (tempParseLine == null) break;

            //System.out.println("Reading line: "+tempParseLine);

            // instantiate an assemble line
            oneLine = new AssemblyLine(tempParseLine, objLineID);
            progLine[sourceLineID] = oneLine;

            if ( !( (oneLine.lineNum == objLineID) || 
                (oneLine.type == AssemblyLine.NULL_FORM) )) {
                System.err.println("Error in Assemble.java");
                System.err.println(oneLine.type + ", " + oneLine.lineNum + 
                           ", " + objLineID);
                System.exit(-1);
            }

            switch (oneLine.type) {
            case AssemblyLine.NULL_FORM:
                // do nothing
                break;
            case AssemblyLine.LABEL_FORM:
                labelTable.put(oneLine.label, new Integer(oneLine.lineNum));
                break;
            case AssemblyLine.CONSTANT_FORM:
                labelTable.put(oneLine.label, new Integer(oneLine.immediateVal));
                break;
            case AssemblyLine.ZERO_FORM:
                objLineID += oneLine.immediateVal;
                break;
            default:
                //objLineID++; //word addressing
                objLineID = objLineID + 1; //byte addressing
                break;
            }
            }

            file.close();

        } catch (IOException ioeRead) {
            System.err.println("error reading " + args[0]);
            System.exit(-1);
        }
    	option = args[3];
        // patch labels and give output
        replaceLabels(progLine, labelTable);
        printCode(progLine, listOut, mem0out, mem1out, mem2out, mem3out, option);
        listOut.close();
        /*mem0out.close();
        mem1out.close();
        mem2out.close();
        mem3out.close();*/

        //System.err.println("IF THERE ARE ANY ERRORS, YOUR OUTPUT "+ 
        //		   "PROGRAM IS NOT GUARANTEED TO BE CORRECT!");
        return;
    }

    private static final int INSTR_LEN = 16;

    public static final int OPCODE_LEN = 4;
    public static final int OPCODE_MASK = (1 << OPCODE_LEN) - 1;
    public static final int REG_LEN = 4;
    public static final int JUMP_DISP_LEN = 10;
    public static final int JUMP_IMMEDIATE_LEN = 6;
    public static final int LOAD_IMMEDIATE_LEN = 8;
    public static final int IMMEDIATE_LEN = 4;
    public static final int DATA_IMMEDIATE_LEN = 16;

    private static final int OP_SHIFT = (INSTR_LEN - OPCODE_LEN);         // 12
    private static final int RD_SHIFT = (OP_SHIFT - REG_LEN);             // 8
    private static final int RT_SHIFT = (RD_SHIFT - REG_LEN - REG_LEN);   // 0
    private static final int RS_RI_SHIFT = RD_SHIFT;                      // 8
    private static final int RS_RRI_SHIFT = (RD_SHIFT - REG_LEN);         // 4
    private static final int RS_RRR_SHIFT = (RD_SHIFT - REG_LEN);         // 4

    public static void replaceLabels(AssemblyLine[] prog, Hashtable table) {

	for (int i = 0; i < sourceLineID; i++) {
	    AssemblyLine l = prog[i];
	    String iR = l.immediateRef;
	    if (iR == null) continue;
	    if (iR.startsWith("L") || iR.startsWith("U")) {
		  iR = iR.substring(1);
	    }
	    Integer val = (Integer) table.get(iR);
	    if (val == null) {
		  l.PrintErr("could not find label in symbol table\n");
		  continue;
	    }

	    l.immediateVal = val.intValue();
	    if (l.immediateRef.startsWith("L")) {
		  l.immediateVal &= 0xff;
	    } else if (l.immediateRef.startsWith("U")) {
		  l.immediateVal = (l.immediateVal >> 8) & 0xff;
        }

	    if (l.relative) {         // PC-RELATIVE INDEXING!
	    	l.immediateVal -= l.lineNum + 1; //Fall06
		//l.immediateVal -= l.lineNum + 1;// Spring 06
		//l.immediateVal -= l.lineNum;  // Fall 05
	    }
	}
    }

    public static void printCode(AssemblyLine [] prog, PrintWriter listOut,
                                  PrintWriter mem0out, PrintWriter mem1out,
                                  PrintWriter mem2out, PrintWriter mem3out, String option) {
	int i;
        int memAddress = 0;
	AssemblyLine l;
	String instrString;
	String instrStringHex;
	
	// printout!
        System.out.println("@0"); // tell Verilog loader to start at 0
        /*mem0out.println("@0"); // tell memory 0 to start at 0
        mem1out.println("@0"); // tell memory 1 to start at 0
        mem2out.println("@0"); // tell memory 2 to start at 0
        mem3out.println("@0"); // tell memory 3 to start at 0*/

    String instr4String = "";
    int count = 0;
    if (option.equals("coe")){
        listOut.println("memory_initialization_radix=16;");
        listOut.println("memory_initialization_vector=");
    }
	for (i = 0; i < sourceLineID; i++) {
	    l = prog[i];
	    l.checkImmediateRange();

	    // put the PC in hex form, 4 digits.
	    String PCstring = Integer.toHexString(l.lineNum);
	    while (PCstring.length() < 4) {
		  PCstring = "0" + PCstring;
	    }

	    if (l.type == AssemblyLine.NULL_FORM) {
	    	if (option.equals("lst")){
		        listOut.print("     ");
		        listOut.print("     ");
		        listOut.println(l.srcLine);
	    	}
	        continue;
	    }

	    if (l.type == AssemblyLine.CONSTANT_FORM) {
	    	if (option.equals("lst")){
		        listOut.print("     ");
		        listOut.print("     ");
		        listOut.println(l.srcLine);
	    	}
	        continue;
	    }

	    if (l.type == AssemblyLine.LABEL_FORM) {
	    	if (option.equals("lst")){
		        listOut.print(PCstring + " ");
		        listOut.print("     ");
		        listOut.println(l.srcLine);
	    	}
	        continue;
	    }

	    /*if (l.type == AssemblyLine.ZERO_FORM) {
	        listOut.print(PCstring + " ");
	        listOut.print("     ");
	        listOut.println(l.srcLine);
                instrString = "0000";
                for (int z=0; z<l.immediateVal/2; z++) {
	            System.out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
                    int ramNum = memAddress % 4;
                    if (ramNum == 0) mem0out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
                    if (ramNum == 1) mem1out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
                    if (ramNum == 2) mem2out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
                    if (ramNum == 3) mem3out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
                    memAddress++;
                }
		continue;
	    }*/

		// There are two extra opcode bits in some RRR
		// instructions.  These appear above the 5 main
		// opcode bits; we will move them into bits 0 & 1.
	    int instr = (l.opcode & OPCODE_MASK) << OP_SHIFT;
	    int immPart = l.immediateVal;
	    int rdPart=0;
	    if (l.dst != -1) {
		  rdPart = l.dst << RD_SHIFT; 
	    }
	    int rtPart=0;
	    if (l.src2 != -1) {	
		  rtPart = l.src2 << RT_SHIFT; 
	    }
	    int rsPart=0;
	    if (l.src1 != -1) {
            if (l.type == AssemblyLine.RI_FORM) {
                rsPart = l.src1 << RS_RI_SHIFT;
            }else if (l.type == AssemblyLine.RRI_FORM) {
                rsPart = l.src1 << RS_RRI_SHIFT;
            } else {
                rsPart = l.src1 << RS_RRR_SHIFT;
            }
	    }

	    // at this point, all non-immediate parts of the 
	    // instruction are ready.
	    switch (l.type) {
	    case AssemblyLine.RRI_FORM:
		  instr += rdPart + rsPart + immPart;
		break;

	    case AssemblyLine.RRR_FORM:
            instr += rdPart + rsPart + rtPart;
            instr += l.opcode >> OPCODE_LEN;
		break;
		
		case AssemblyLine.NOT_FORM:
			instr += rdPart + rsPart;
		break;
		
	    case AssemblyLine.RI_FORM:
	    	if (l.jmp_offset == 0x3 || l.jmp_offset == 0x1){
	    		immPart = immPart << 2;
	    		immPart += l.jmp_offset;
	    	}
	    	instr += rdPart + rsPart + immPart;
		break;
		
	    case AssemblyLine.JUMP_FORM:
	    	immPart = immPart << 2;
	    	immPart += l.jmp_offset;
	    	instr += immPart;
		break;
		
	    case AssemblyLine.DATA_FORM:
		  instr = immPart;
		break;
		
	    //case AssemblyLine.PRD_FORM:
		//instr += rdPart + rsPart;
		//break;
	    
	    case AssemblyLine.NOP_FORM:
		  break;
	    }
	    
	    if (instr < 0) {
		  // must be positive for hexString to work
		  instr += 0x10000;
	    }
	    instrString = Integer.toBinaryString(instr);
	    instrStringHex = Integer.toHexString(instr);
	    if (instrString.length() == 13){
	    	instrString = "000" + instrString;
	    }else if (instrString.length() == 14){
	    	instrString = "00" + instrString;
	    }else if (instrString.length() == 15){
	    	instrString = "0" + instrString;
	    }
	    while (instrStringHex.length() < 4) {
		  instrStringHex = "0" + instrString;
	    }
            // Print the hex version to the loadfile(s)
	    // System.out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
            /*int ramNum = memAddress % 4;
            if (ramNum == 0) mem0out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
            if (ramNum == 1) mem1out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
            if (ramNum == 2) mem2out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));
            if (ramNum == 3) mem3out.println(instrString.substring(0, 2)+'\n'+instrString.substring(2, 4));

            memAddress++;*/
	    if (option.equals("lst")){
		    listOut.print("PC: " + PCstring + " ");
		    listOut.print("Binary: " + instrString + " " + "Hex: " + instrStringHex + " ");
		    listOut.println(l.srcLine);
	    }else{
	    	instr4String += instrStringHex;
	    	if (count % 4 == 3){
	    		if (i != sourceLineID - 1){
	    			instr4String += ',';
	    		}else{
	    			instr4String += ';';
	    		}
	    		listOut.println(instr4String);
	    		instr4String = "";
	    	}else if ((i == sourceLineID - 1) && instr4String != ""){
	    		if (instr4String.length() == 4){
	    			instr4String += "000000000000;";
	    		}else if (instr4String.length() == 8){
	    			instr4String += "00000000;";
	    		}else if (instr4String.length() == 12){
	    			instr4String += "0000;";
	    		}else{
	    			instr4String += ';';
	    		}
	    		listOut.println(instr4String);
	    		instr4String = "";
	    	}
	    	count ++;
	    }
	}
}
}

