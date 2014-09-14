import java.io.*;
import java.net.*;

class TCPServer {
	public static void main(String argv[]) throws Exception {
		String sentence;
		String clientSentence = "";
		ServerSocket welcomeSocket = new ServerSocket(6789);

		while (!clientSentence.equalsIgnoreCase("bye")) {
			Socket connectionSocket = welcomeSocket.accept();
			if(connectionSocket!=null){
				System.out.println("Connected to the client at the port numbered "+connectionSocket.getPort());
				BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));

				BufferedReader inFromClient = new BufferedReader(new InputStreamReader(connectionSocket.getInputStream()));

				DataOutputStream outToClient = new DataOutputStream(connectionSocket.getOutputStream());

				clientSentence = inFromClient.readLine();

				System.out.print("\n\n\t\t FROM CLIENT : " + clientSentence);

				System.out.print("\n\n\t\t TO CLIENT : ");

				sentence = inFromUser.readLine();

				outToClient.writeBytes(sentence + '\n');
			}
			else{
				System.out.println("Couldn't connect to the client");
				throw new Exception();
			}

		}
		welcomeSocket.close();

	}

}