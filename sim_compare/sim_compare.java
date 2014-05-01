
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Hashtable;
import java.util.Scanner;

public class Sim_compare{

	public static Hashtable<Integer, Integer> log2phyMAP = new Hashtable<Integer, Integer>();
	public static Hashtable<Integer, Integer> phy2valMAP = new Hashtable<Integer, Integer>();
	public static Hashtable<Integer, Integer> sim2valMAP = new Hashtable<Integer, Integer>();
	
	public static void main(String[] args) {
		// declare and initialize scanners for all dump files
		File mapFile = new File("../map.dump");
		File regFile = new File("../reg.dump");
		File simFile = new File("../sim_reg.dump");
		
		Scanner mapScan = null;
		Scanner regScan = null;
		Scanner simScan = null;
		
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
			simScan = new Scanner(simFile);
		} catch (FileNotFoundException e) {
			System.out.println("sim_reg.dump not found");
		}
		
		// process each dump file via scanner
		processMapDump(mapScan);
		processRegDump(regScan);
		processSimDump(simScan);
		
		validateResult();
	}

	private static void validateResult(){
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
			System.out.println("INCORRECT");
			int i = 0;
			while (i <= 15){
				if (!track[i]){
					System.out.println("ERROR in register 0x" + Integer.toHexString(i | 0x10).substring(1));
				}
				i ++;
			}
		}else{
			System.out.println("CORRECT");
		}
	}
	
	private static void processSimDump(Scanner simScan){
		String line = "";
		while (simScan.hasNextLine()){
			line = simScan.nextLine();
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
		while (mapScan.hasNextLine()){
			line = mapScan.nextLine();
		}
		String delims = "[ ]+";
		String[] tokens = line.split(delims);
		for (int i = 2; i< tokens.length; i++){
			log2phyMAP.put(hexToDec(tokens[i].substring(4, 5)), hexToDec(tokens[i].substring(1, 3)));
		}
		// System.out.println(log2phyMAP.toString());
	}
	
	private static int hexToDec(String hex){
		int d1 = Integer.parseInt(hex, 16);
		return d1;
	}

}
