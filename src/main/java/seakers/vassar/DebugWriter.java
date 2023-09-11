package seakers.vassar;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

public class DebugWriter {

    public static boolean debug = false;

    public static void writeDebug(ArrayList<String> lines, String file_name) {
        if(!DebugWriter.debug){
            return;
        }

        File debugDirectory = new File("debug");
        if (!debugDirectory.exists()) {
            debugDirectory.mkdir();
        }

        try (PrintWriter writer = new PrintWriter(new File(debugDirectory, file_name))) {
            for (String line : lines) {
                line += '\n';
                writer.println(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void writeDebug(String text, String file_name) {
        if(!DebugWriter.debug){
            return;
        }

        File debugDirectory = new File("debug");
        if (!debugDirectory.exists()) {
            debugDirectory.mkdir();
        }

        try (PrintWriter writer = new PrintWriter(new File(debugDirectory, file_name))) {
            writer.println(text);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }





}
