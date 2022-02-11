package seakers.vassar;

import org.moeaframework.core.Algorithm;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.util.progress.ProgressEvent;
import org.moeaframework.util.progress.ProgressListener;

import java.io.*;

public class MOEAProgressListener implements ProgressListener {
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
            fileOut = new PrintStream("./src/test/output/running_population"+event.getCurrentNFE()+".txt");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        System.setOut(fileOut);
        System.out.println("Variables for solution " + event.getCurrentSeed() + ":");
        Algorithm xd = event.getCurrentAlgorithm();
        if (xd != null) {
            NondominatedPopulation currentPop = xd.getResult();
            for (Solution sol : currentPop) {
                System.out.println("Number of radar satellites: " + EncodingUtils.getInt(sol.getVariable(0)));
                System.out.println("Altitude of radar satellites: " + sol.getVariable(1));
                System.out.println("Inclination of radar satellites: " + sol.getVariable(2));
                System.out.println("Radar dAz: " + sol.getVariable(3));
                System.out.println("Radar dEl: " + sol.getVariable(4));
                System.out.println("Radar chirp bw: " + sol.getVariable(5));
                System.out.println("Radar pulse width: " + sol.getVariable(6));
            }
            try {
                PopulationIO.writeObjectives(new File("./src/test/output/objectives"+event.getCurrentNFE()+".txt"), currentPop);
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
