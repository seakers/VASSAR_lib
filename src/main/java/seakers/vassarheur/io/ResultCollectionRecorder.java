package seakers.vassarheur.io;

import seakers.vassarheur.Result;
import seakers.vassarheur.ResultCollection;
import seakers.vassarheur.BaseParams;
import seakers.vassarheur.problems.Assigning.AssigningParams;
import seakers.vassarheur.problems.PartitioningAndAssigning.PartitioningAndAssigningParams;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class ResultCollectionRecorder {

    private BaseParams params;
    private int numInputs;

    public ResultCollectionRecorder(BaseParams params){
        this.params = params;

        if(this.params instanceof AssigningParams){
            this.numInputs = this.params.getNumInstr() * this.params.getNumOrbits();

        }else if(this.params instanceof PartitioningAndAssigningParams){
            this.numInputs = this.params.getNumInstr() * 2;

        }else{
            throw new UnsupportedOperationException("ResultCollectionRecorder not implemented for this problem: " +
                    this.params.getClass().getName());
        }
    }

    public void write(ResultCollection results) {

        SimpleDateFormat dateFormat = new SimpleDateFormat( "yyyy-MM-dd_HH-mm-ss" );
        String stamp = dateFormat.format( new Date() );

        String name = params.getName();
        String filePath = params.pathSaveResults + File.separator + stamp + "_" + name + ".csv"; // comma-separated values

        int count = 0;
        try (BufferedWriter outputWriter = new BufferedWriter(new FileWriter(filePath))) {

            StringJoiner header = new StringJoiner(",");
            for(int i = 0; i < this.numInputs; i++){
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
