import java.io.*;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Date;

public class ServerThread implements Runnable{

    private static final int PACKET_SIZE = 1024;
    private final Socket socket;
    private BufferedReader input;
    private DataOutputStream output;
    private FileWriter log;
    private static final String ABSOLUTE_PATH_TO_ROOT = "F:\\3-2\\CSE 322 Network Sessional\\Offline 1\\1805117\\root";
    private static final String ABSOLUTE_PATH_TO_UPLOADED = "F:\\3-2\\CSE 322 Network Sessional\\Offline 1\\1805117\\uploaded";

    ServerThread(Socket socket)
    {
        this.socket = socket;
        try{
            log = new FileWriter("log.txt", true);
            input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            output = new DataOutputStream(socket.getOutputStream());
        } catch(IOException e)
        {
            e.printStackTrace();
        }
        Thread thread = new Thread(this);
        thread.start();
    }

    @Override
    public void run() {
        try{
            StringBuilder content = FileManager.openFile("index.html");
            String in = null;
            try{
                in = input.readLine();
                System.out.println("In:"+in);
            } catch(IOException e)
            {
                e.printStackTrace();
            }

            if(in == null) {
                try {
                    input.close();
                    socket.close();
                    log.close();
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    return;
                }

            }

            if(in.length() > 0) {
                if(in.startsWith("GET"))
                {
                    String[] inputs = in.split("\\s");
                    this.GetReq(inputs, content);
                }

                else if(in.startsWith("UPLOAD"))
                {
                    DataInputStream dataInputStream = new DataInputStream(new BufferedInputStream(socket.getInputStream()));
                    FileOutputStream fileOutputStream = new FileOutputStream(new File(ABSOLUTE_PATH_TO_UPLOADED+"\\"+in));

                    int count;
                    byte[] bytes = new byte[PACKET_SIZE];

                    while ((count=dataInputStream.read(bytes)) > 0)
                    {
                        fileOutputStream.write(bytes, 0, count);
                        System.out.println("...");
                    }
                    fileOutputStream.close();
                }
                else
                {
                    System.out.println("File not found");
                }
            }
            socket.close();
            input.close();
            log.close();
        } catch (IOException e)
        {
            e.printStackTrace();
        }
        System.out.println("Request Served\n");

        //socket.close();
    }

    private void GetReq(String[] inputs, StringBuilder content) {
        String path = ABSOLUTE_PATH_TO_ROOT+"\\"+inputs[1];
        File requestedFile = new File(path);
        System.out.println(inputs[1]);
        try{
            if(requestedFile.exists())
            {
                if (!requestedFile.isDirectory())
                {
                    this.downloadFile(requestedFile);
                }
                else
                {
                    this.showDirectory(inputs, content);
                }
            }
            else
            {
                this.showErrorMessage();
            }
        } catch(Exception e)
        {
            e.printStackTrace();
        }
    }

    private void showErrorMessage() {
        try{
            System.out.println("404 Error");
            StringBuilder content = FileManager.openFile("error.html");

            StringBuilder header = new StringBuilder();
            header.append("HTTP/1.1 404 NOT FOUND\r\n").
                    append("Server: Java HTTP Server: 1.0\r\n").
                    append("Date: ").append(new Date()).append("\r\n").
                    append("Content-Type: text/html\r\n");
            assert content != null;
            header.append("Content-Length: ").append(content.length()).append("\r\n").
                    append("Connection: close\r\n").append("\r\n");
            log.write(header.toString());

            output.writeBytes(header.toString());
            output.writeBytes(content.toString());
            output.flush();
        } catch(IOException e)
        {
            e.printStackTrace();
        }
    }

    private void showDirectory(String[] inputs, StringBuilder content) {
        try{
            String path = ABSOLUTE_PATH_TO_ROOT+"\\"+inputs[1];
            FileManager.viewDirectory(content, inputs[1], path);
            StringBuilder header = new StringBuilder();
            header.append("HTTP/1.1 200 OK\r\n").
                    append("Server: Java HTTP Server: 1.0\r\n").
                    append("Date: ").append(new Date()).append("\r\n").
                    append("Content-Type: text/html\r\n").
                    append("Content-Length: ").append(content.length()).append("\r\n").
                    append("Connection: close\r\n").append("\r\n");

            log.write(header.toString());

            output.writeBytes(header.toString());
            output.writeBytes(content.toString());
            output.flush();
        } catch(IOException e)
        {
            e.printStackTrace();
        }
    }

    private void downloadFile(File requestedFile) {
        try{
            System.out.println("In download");
            StringBuilder header = new StringBuilder();
            header.append("HTTP/1.1 200 OK\r\n").
                    append("Server: Java HTTP Server: 1.0\r\n").
                    append("Date: ").append(new Date()).append("\r\n").
                    append("Content-Type: ").append(Files.probeContentType(Path.of(requestedFile.toString()))).append("\r\n").
                    append("Content-Length: ").append(requestedFile.length()).append("\r\n").
                    append("Content-Disposition: attachment; filename=\"").
                    append(requestedFile.getName()).append("\"\r\n").
                    append("Connection: close\r\n").append("\r\n");

            log.write(header.toString());

            output.writeBytes(header.toString());
            output.flush();

            BufferedInputStream bufferedInputStream = new BufferedInputStream(new FileInputStream(requestedFile));
            int count = 0;
            byte[] bytes = new byte[PACKET_SIZE];
            while(true)
            {
                count = bufferedInputStream.read(bytes);
                if(count > 0)
                {
                    output.write(bytes);
                }
                else
                {
                    output.flush();
                    output.close();
                    break;
                }
            }
            output.close();
        } catch(IOException e)
        {
            e.printStackTrace();
        }
    }
}



