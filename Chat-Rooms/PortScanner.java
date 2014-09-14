import java.net.*;

public class PortScanner {
	public static void main(String args[]){
		int startPortRange = 0;
		int endPortRange = 0;
		
		startPortRange = Integer.parseInt(args[0]);
		endPortRange = Integer.parseInt(args[1]);
		
		for(int i=startPortRange;i<=endPortRange;i++){
			try {
				Socket serverSocket = new Socket("localhost", i);
				System.out.println("Port in use: "+i);
				serverSocket.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
			
		}
	}
}
