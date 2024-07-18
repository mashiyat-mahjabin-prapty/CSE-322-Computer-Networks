import java.io.*;
import java.net.Socket;
import java.util.Scanner;

public class ClientThread implements Runnable{
    private Socket socket;
    private DataOutputStream dataOutputStream;
    private String input;

    public ClientThread(Socket socket, String fileName) throws IOException
    {
        this.socket = socket;
        this.input = fileName;
        dataOutputStream = new DataOutputStream(socket.getOutputStream());
        Thread thread = new Thread(this);
        thread.start();
    }


    @Override
    public void run() {
        try{
            File file = new File(input);

            if(!file.exists())
            {
                dataOutputStream.writeBytes("Invalid\r\n");
                dataOutputStream.flush();
                System.out.println("Invalid file name given\r\n");

                dataOutputStream.close();
                socket.close();
            }
            else {
                dataOutputStream.writeBytes("UPLOAD " + input + "\r\n");
                dataOutputStream.flush();

                FileInputStream fis;
                BufferedInputStream bis;
                OutputStream os;
                BufferedOutputStream bos;

                fis = new FileInputStream(file);
                bis = new BufferedInputStream(fis);
                os = socket.getOutputStream();
                bos = new BufferedOutputStream(os);

                byte[] bytes = new byte[1024];
                int count;

                while (true)
                {
                    count = bis.read(bytes);

                    if (count != -1)
                    {
                        bos.write(bytes, 0, 1024);
                        //System.out.println(bytes);
                        bos.flush();
                    }
                    else {
                        bis.close();
                        bos.close();
                        break;
                    }
                }
            }
        } catch(IOException e)
        {
            e.printStackTrace();
        }



        try{
            dataOutputStream.close();
            socket.close();
        } catch(IOException e)
        {
            e.printStackTrace();
        }
    }
}
