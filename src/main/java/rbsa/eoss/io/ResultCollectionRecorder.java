package rbsa.eoss.io;

import rbsa.eoss.Result;
import rbsa.eoss.ResultCollection;
import rbsa.eoss.local.BaseParams;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class ResultCollectionRecorder {

    private BaseParams params;

    public ResultCollectionRecorder(BaseParams params){
        this.params = params;
    }

    public void write(ResultCollection results) {

        SimpleDateFormat dateFormat = new SimpleDateFormat( "yyyy-MM-dd_HH-mm-ss" );
        String stamp = dateFormat.format( new Date() );

        String name = params.getName();
        String filePath = params.pathSaveResults + File.separator + stamp + "_" + name + ".csv"; // comma-separated values

        int count = 0;
        try (BufferedWriter outputWriter = new BufferedWriter(new FileWriter(filePath))) {

            StringJoiner header = new StringJoiner(",");
            for(int i = 0; i < 2 * this.params.getNumInstr(); i++){
                header.add("input" + i);
            }
            header.add("Science");
            header.add("Cost");
            outputWriter.write(header.toString() + "\n");

            for (Result result: results.getResults()) {
                if (result.getScience() == 0.0) {
                    count++;

                }else {
                    StringJoiner sj = new StringJoiner(",");
                    String inputs = result.getArch().toString(",");
                    sj.add(inputs);
                    sj.add(Double.toString(result.getScience()));
                    sj.add(Double.toString(result.getCost()));
                    outputWriter.write(sj.toString() + "\n");
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println(count);
    }
}
