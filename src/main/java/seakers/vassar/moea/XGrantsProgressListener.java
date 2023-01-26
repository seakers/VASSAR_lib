package seakers.vassar.moea;

import org.moeaframework.core.Algorithm;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.util.progress.ProgressEvent;
import org.moeaframework.util.progress.ProgressListener;

import java.io.*;
import java.util.Arrays;

public class XGrantsProgressListener implements ProgressListener {
    private int seedCount = 0;

    private int callCount = 0;

    private ProgressEvent lastEvent = null;

    @Override
    public void progressUpdate(ProgressEvent event) {
        if (event.isSeedFinished()) {
            seedCount++;
        }
        callCount++;
        lastEvent = event;

        System.out.println("Progress update: "+event.getPercentComplete()*100+"% complete!");
        System.out.println("Remaining time: "+event.getRemainingTime());
        System.out.println("Current function evals: "+event.getCurrentNFE());
        PrintStream fileOut = null;
        try {
            fileOut = new PrintStream("./src/test/output/xgrants/012323_running_population"+event.getCurrentNFE()+".txt");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        System.setOut(fileOut);
        System.out.println("Variables for solution " + event.getCurrentSeed() + ":");
        Algorithm xd = event.getCurrentAlgorithm();
        if (xd != null) {
            NondominatedPopulation currentPop = xd.getResult();
            try {
                FileOutputStream f = new FileOutputStream("current_population.txt");
                ObjectOutputStream o = new ObjectOutputStream(f);
                for (Solution sol : currentPop) {
                    o.writeObject(sol);
                    System.out.println(EncodingUtils.getInt(sol.getVariable(0))+","+EncodingUtils.getInt(sol.getVariable(1))+","+sol.getVariable(2)+","+sol.getVariable(3)+","+EncodingUtils.getInt(sol.getVariable(4))+","+EncodingUtils.getInt(sol.getVariable(5))+","+EncodingUtils.getInt(sol.getVariable(6))+","+EncodingUtils.getInt(sol.getVariable(7))+","+EncodingUtils.getReal(sol.getVariable(8))+","+EncodingUtils.getReal(sol.getVariable(9))+","+EncodingUtils.getReal(sol.getVariable(10))+ Arrays.toString(sol.getObjectives()));
                }
                o.close();
                f.close();
            } catch (FileNotFoundException e) {
                System.out.println("File not found");
            } catch (IOException e) {
                System.out.println("Error initializing stream");
            }
            try {
                PopulationIO.writeObjectives(new File("./src/test/output/xgrants/012323_objectives"+event.getCurrentNFE()+".txt"), currentPop);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        PrintStream consoleStream = new PrintStream(
                new FileOutputStream(FileDescriptor.out));
        System.setOut(consoleStream);
    }

    public int getSeedCount() {
        return seedCount;
    }

    public int getCallCount() {
        return callCount;
    }

    public ProgressEvent getLastEvent() {
        return lastEvent;
    }
}
