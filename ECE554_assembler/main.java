import java.io.File;
import java.io.FileNotFoundException;
import java.util.Hashtable;
import java.util.Scanner;


public class main {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Hashtable<Integer, Integer> mapping = new Hashtable<Integer, Integer>();
		File file = new File("map.dump");
		Scanner sc;
		String line = null;
		try {
			sc = new Scanner(file);

			while (sc.hasNextLine()){
				line = sc.nextLine();
			}
			String delims = "[ ]+";
			String[] parts = line.split(delims);
			String[] newMapping = new String[parts.length-2];
			for (int i = 0; i < newMapping.length; i++){
				newMapping[i] = parts[i+2];
			}
			int[] phy = new int[newMapping.length];
			int[] log = new int[newMapping.length];
			for (int i = 0;  i < newMapping.length; i++){
				phy[i] = hexToDec(newMapping[i].substring(1, 3));
				log[i] = hexToDec(newMapping[i].substring(4, 5));
			}
			for (int i = 0; i< phy.length; i++){
				mapping.put(log[i], phy[i]);
			}
			System.out.println(mapping.toString());
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	private static int hexToDec(String hex){
		int d1 = Integer.parseInt(hex, 16);
		return d1;
	}
}



