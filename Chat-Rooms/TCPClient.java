import java.io.*;
import java.net.*;

class TCPClient {
	public static void main(String args[]) throws Exception {
		String sentence;
		String serverSentence="";
		Socket clientSocket = null;
		
		while (!serverSentence.equalsIgnoreCase("bye")) {
			
			clientSocket = new Socket(InetAddress.getLocalHost(), 6789);
			System.out.println("Client is connected to the port numbered "+ clientSocket.getPort());
			System.out.print("\n\n\t\t TO SERVER : ");
			
			BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));
			DataOutputStream outToServer = new DataOutputStream(clientSocket.getOutputStream());
			BufferedReader inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

			sentence = inFromUser.readLine();

			outToServer.writeBytes(sentence + '\n');

			serverSentence = inFromServer.readLine();

			System.out.print("\n\n\t\t FROM SERVER : " + serverSentence);
		}
		clientSocket.close();
	}

}