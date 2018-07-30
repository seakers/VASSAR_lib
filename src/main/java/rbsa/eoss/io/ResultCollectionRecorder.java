package rbsa.eoss.io;

import rbsa.eoss.Result;
import rbsa.eoss.ResultCollection;
import rbsa.eoss.local.BaseParams;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class ResultCollectionRecorder {

    private boolean writeBinary;
    private BaseParams params;

    public ResultCollectionRecorder(BaseParams params){
        this.params = params;
    }

    public void write(ResultCollection results) {

        //String filename = "/home/antoni/Programacio/daphne/VASSAR_clean/results/2018-05-18_22-52-16_test.rs";

        SimpleDateFormat dateFormat = new SimpleDateFormat( "yyyy-MM-dd_HH-mm-ss" );
        String stamp = dateFormat.format( new Date() );

        String name = params.getName();
        String filePath = params.pathSaveResults + File.separator + stamp + "_" + name + ".tsv"; //tab-separated values

        int count = 0;
        try (BufferedWriter outputWriter = new BufferedWriter(new FileWriter(filePath))) {
            outputWriter.write("Inputs, Science, Cost\n");

            for (Result result: results.getResults()) {
                if (result.getScience() == 0.0) {
                    count++;

                }else {
                    StringJoiner sj = new StringJoiner("\t");
                    String inputs = result.getArch().toString(",");
                    sj.add(inputs);
                    sj.add(Double.toString(result.getScience()));
                    sj.add(Double.toString(result.getCost()));
                    sj.add("\n");
                    outputWriter.write(sj.toString());
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println(count);
    }
}
