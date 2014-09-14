import java.io.*;
import java.net.*;

public class MultiThreadChatClient implements Runnable {
	// The client socket
	  private static Socket clientSocket = null;
	  // The output stream
	  private static PrintStream os = null;
	  // The input stream
	  private static BufferedReader is = null;

	  private static BufferedReader inputLine = null;
	  private static boolean closed = false;
	  
	  public static void main(String[] args) {

		    // The default port.
		    int portNumber = 2222;
		    // The default host.
		    String host = "localhost";

		    if (args.length < 2) {
		      System.out
		          .println("Usage: java MultiThreadChatClient <host> <portNumber>\n"+ "Now using host=" + host + ", portNumber=" + portNumber);
		    } else {
		      host = args[0];
		      portNumber = Integer.valueOf(args[1]).intValue();
		    }

		    /*
		     * Open a socket on a given host and port. Open input and output streams.
		     */
		    try {
		      clientSocket = new Socket(host, portNumber);
		      inputLine = new BufferedReader(new InputStreamReader(System.in));
		      os = new PrintStream(clientSocket.getOutputStream());
		      is = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
		    } catch (UnknownHostException e) {
		      System.err.println("Don't know about host " + host);
		    } catch (IOException e) {
		      System.err.println("Couldn't get I/O for the connection to the host "+ host);
		    }
		    
		    //if everything is fine, we have to write data to the socket that is opened on a portNumber
		    if(clientSocket!=null && os!=null && is!=null){
		    	try {
		    		//create a thread to read from the server
		    		new Thread(new MultiThreadChatClient()).start();
		    		while(!closed){
		    			os.println(inputLine.readLine().trim());
		    		}
		    		//close all the streams and the socket
		    		os.close();
		    		is.close();
		    		clientSocket.close();
		    	}
		    	catch(Exception e){
		    		e.printStackTrace();
		    	}
		    }
	  }

	public void run() {
		/* Keep reading from the socket till we receive "Bye" from the server. */
		String responseLine="";
		try{
			while((responseLine = is.readLine())!=null){
				System.out.println(responseLine);
				if(responseLine.indexOf("*** Bye")!=-1)
					break;
			}
			closed = true;
		}
		catch(IOException e){
			e.printStackTrace();
		}
	}
}
