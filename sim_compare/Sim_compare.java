import java.io.*;
import java.util.Hashtable;
import java.util.Scanner;
import java.util.*;

public class Sim_compare{

	public static Hashtable<Integer, Integer> log2phyMAP = new Hashtable<Integer, Integer>();
	public static Hashtable<Integer, Integer> phy2valMAP = new Hashtable<Integer, Integer>();
	public static Hashtable<Integer, Integer> sim2valMAP = new Hashtable<Integer, Integer>();
	public static Hashtable<Integer, String> mem2valMAP = new Hashtable<Integer, String>();
	public static Hashtable<Integer, String> simMem2valMAP = new Hashtable<Integer, String>();

	
	public static void main(String[] args) {
		// declare and initialize scanners for all dump files
		File mapFile = new File("../map.dump");
		File regFile = new File("../reg.dump");
		File simRegFile = new File("../sim_reg.dump");
		File memFile = new File("../mem.dump");
		File simMemFile = new File("../sim_mem.dump");
		Scanner mapScan = null;
		Scanner regScan = null;
		Scanner memScan = null;
		Scanner simRegScan = null;
		Scanner simMemScan = null;
		
		String fileName = args[0];
		FileWriter resultOut = null;
		BufferedWriter bufferWritter = null;
		
		try {
			mapScan = new Scanner(mapFile);
		} catch (FileNotFoundException e) {
			System.out.println("map.dump not found");
		}
		try {
			regScan = new Scanner(regFile);
		} catch (FileNotFoundException e) {
			System.out.println("reg.dump not found");
		}
		try {
			memScan = new Scanner(memFile);
		} catch (FileNotFoundException e) {
			System.out.println("reg.dump not found");
		}
		try {
			simRegScan = new Scanner(simRegFile);
		} catch (FileNotFoundException e) {
			System.out.println("sim_reg.dump not found");
		}
		try {
			simMemScan = new Scanner(simMemFile);
		} catch (FileNotFoundException e) {
			System.out.println("sim_reg.dump not found");
		}
		try {
			resultOut = new FileWriter("../run_all_result.dump", true);
    	        	bufferWritter = new BufferedWriter(resultOut);
		} catch (IOException e) {
			System.out.println("buffer writer error");
		}
		
		// process each dump file via scanner
		processMapDump(mapScan);
		processRegDump(regScan);
		processMemDump(memScan);
		processSimRegDump(simRegScan);
		processSimMemDump(simMemScan);
		
		boolean registerCorrect = validateRegisterResult();
		boolean memoryCorrect = validateMemoryResult();
		if (registerCorrect && memoryCorrect){
			try{
				bufferWritter.write(fileName + " SUCCESS\n");
			} catch (IOException e){
				System.out.println("buffer writer error");
			}
		}else{
			try{
				bufferWritter.write(fileName + " FAILED\n");
			} catch (IOException e){
				System.out.println("buffer writer error");
			}
		}
		try{
			bufferWritter.close();
		} catch (IOException e){
			System.out.println("buffer writer error");
		}
	}

	private static boolean validateMemoryResult(){
		boolean memoryCorrect = true;
		for (int i = 0; i < 16384; i ++){
			if ((simMem2valMAP.get(i) == null && !mem2valMAP.get(i).equals("0000000000000000")) || (simMem2valMAP.get(i) != null && !simMem2valMAP.get(i).equals(mem2valMAP.get(i)))){
				memoryCorrect = false;
				if (simMem2valMAP.get(i) == null){
					System.out.println("ERROR: memory 0x" + Integer.toHexString(i | 0x10000).substring(1) + " should be 0x0000 but is 0x" + mem2valMAP.get(i));
				}else{
					System.out.println("ERROR: memory 0x" + Integer.toHexString(i | 0x10000).substring(1) + " should be 0x" + simMem2valMAP.get(i) + " but is " + mem2valMAP.get(i));
				}
			}
		}
		if (memoryCorrect){
			System.out.println("Memory CORRECT");
		}else{
			System.out.println("Memory INCORRECT");
		}
		return memoryCorrect;
	}

	private static boolean validateRegisterResult(){
		boolean allPass = true;
		boolean[] track = new boolean[16];
		for (int i = 0; i <= 15; i ++){
			track[i] = true;
		}
		for (int i = 0; i <= 15; i ++){
			int simValue = sim2valMAP.get(i);
			int realValue = phy2valMAP.get(log2phyMAP.get(i));
			if (simValue != realValue){
				System.out.println("******************** ERROR ********************");
				track[i] = false;
				allPass = false;
			}
			System.out.println("Simulate: Logical reg 0x" + Integer.toHexString(i | 0x10).substring(1) + ": " + Integer.toHexString(simValue | 0x10000).substring(1));
			System.out.println("Real    : Logical reg 0x" + Integer.toHexString(i | 0x10).substring(1) + " => " + "Physical reg 0x" + Integer.toHexString(log2phyMAP.get(i) | 0x100).substring(1) + ": " + Integer.toHexString(realValue | 0x10000).substring(1));
			System.out.println();
		}
		if (!allPass){
			System.out.println("Registers INCORRECT");
			int i = 0;
			while (i <= 15){
				if (!track[i]){
					System.out.println("ERROR in register 0x" + Integer.toHexString(i | 0x10).substring(1));
				}
				i ++;
			}
		}else{
			System.out.println("Registers CORRECT");
		}
		return allPass;
	}


	public static void processSimMemDump(Scanner simMemScan){
		while (simMemScan.hasNextLine()){
			String line = simMemScan.nextLine();
			String[] tokens = line.split(" ");
			int memLocation = hexToDec(tokens[1]);
			String memValue = tokens[3];
			simMem2valMAP.put(memLocation, memValue);
		}
		// System.out.println(simMem2valMAP.toString());
	}
	
	public static void processMemDump(Scanner memScan){
		while (memScan.hasNextLine()){
			String line = memScan.nextLine();
			String[] tokens = line.split(" ");
			int memLocation = hexToDec(tokens[1].substring(0, tokens[1].length() - 1));
			String memValue = tokens[3];
			mem2valMAP.put(memLocation, memValue);
		}
		// System.out.println(mem2valMAP.toString());
	}

	private static void processSimRegDump(Scanner simRegScan){
		String line = "";
		while (simRegScan.hasNextLine()){
			line = simRegScan.nextLine();
			String[] tokens = line.split(" ");
			int register = Integer.parseInt(tokens[0].substring(0, tokens[0].length() - 1));
			int value = hexToDec(tokens[1]);
			sim2valMAP.put(register, value);
		}
		// System.out.println(sim2valMAP.toString());
	}
	
	private static void processRegDump(Scanner regScan){
		// abort first line
		String line = "";
		regScan.nextLine();
		while (regScan.hasNextLine()){
			line = regScan.nextLine();
			String[] tokens = line.split(" ");
			int register = hexToDec(tokens[1].substring(0, tokens[1].length() - 1));
			int value	= hexToDec(tokens[6]);
			phy2valMAP.put(register, value);
		}
		// System.out.println(phy2valMAP.toString());
	}
	
	private static void processMapDump(Scanner mapScan){
		String line = "";

		ArrayList<String> threeF = new ArrayList<String>();
		ArrayList<String> oneF = new ArrayList<String>();

		while (mapScan.hasNextLine()){
			line = mapScan.nextLine();
			String tokens[] = line.split(" ");
			if (tokens[1].equals("3f")){
				threeF.add(line);
			}
			if (tokens[1].equals("1f")){
				oneF.add(line);
			}
		}
		if (line.charAt(line.length()-1) == '0'){
			line = threeF.get(threeF.size()-1);
		}else{
			line = oneF.get(oneF.size() - 1);
		}
		String delims = "[ ]+";
		String[] tokens = line.split(delims);
		for (int i = 2; i< tokens.length-1; i++){
			log2phyMAP.put(hexToDec(tokens[i].substring(4, 5)), hexToDec(tokens[i].substring(1, 3)));
		}
		// System.out.println(log2phyMAP.toString());
	}
	
	private static int hexToDec(String hex){
		int d1 = Integer.parseInt(hex, 16);
		return d1;
	}

}
