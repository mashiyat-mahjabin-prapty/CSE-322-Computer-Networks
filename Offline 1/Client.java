import java.io.IOException;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) throws IOException {

        Scanner scanner = new Scanner(System.in);

        while(true)
        {
            String fileName = scanner.nextLine();
            Socket socket = new Socket("localhost", 5117);
            System.out.println("Connection established");

            new ClientThread(socket, fileName);
        }
    }
}
