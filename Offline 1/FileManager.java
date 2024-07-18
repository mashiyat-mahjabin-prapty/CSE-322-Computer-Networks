import java.io.*;
import java.nio.charset.StandardCharsets;

public class FileManager {
    static StringBuilder openFile(String filename)
    {
        try{
            File file = new File(filename);
            FileInputStream fis = new FileInputStream(file);
            BufferedReader br = new BufferedReader(new InputStreamReader(fis, StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            String line;
            while(( line = br.readLine()) != null ) {
                sb.append( line );
                sb.append( '\n' );
            }
            return sb;

        } catch(IOException e)
        {
            e.printStackTrace();
        }
        return null;
    }
    static void viewDirectory(StringBuilder stringBuilder, String dirName, String path)
    {
        File[] files = new File(path).listFiles();

        if (dirName.equals("/"))
        {
            dirName = "";
        }

        assert files != null;
        for(File file:files)
        {
            if(file.isDirectory())
            {
                stringBuilder.append("<b><i><a href=\"").append(dirName).append("/").append(file.getName()).append("\">").append(file.getName()).append("</a></i></b><br>");
            }
            else
            {
                stringBuilder.append("<a href=\"").append(dirName).append("/").append(file.getName()).append("\">").append(file.getName()).append("</a><br>");
            }
        }
    }
}
