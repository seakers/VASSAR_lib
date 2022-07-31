package seakers.vassar.moea;

import org.moeaframework.Executor;
import org.moeaframework.core.Algorithm;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.util.TypedProperties;
import org.moeaframework.util.progress.ProgressEvent;
import org.moeaframework.util.progress.ProgressListener;

import java.io.*;
import java.lang.reflect.Field;

public class MOEAInsAltProgressListener implements ProgressListener {
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
        String filepath = "";
        Executor exec = event.getExecutor();
        Field f = null; //NoSuchFieldException
        try {
            f = exec.getClass().getDeclaredField("properties");
        } catch (NoSuchFieldException e) {
            throw new RuntimeException(e);
        }
        f.setAccessible(true);
        try {
            TypedProperties iWantThis = (TypedProperties) f.get(exec);
            filepath = (String) iWantThis.getProperties().get("filepath");
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
        System.out.println("Progress update: "+event.getPercentComplete()*100+"% complete!");
        System.out.println("Remaining time: "+event.getRemainingTime());
        System.out.println("Current function evals: "+event.getCurrentNFE());
        PrintStream fileOut = null;
        try {
            fileOut = new PrintStream(filepath+"0627_running_population"+event.getCurrentNFE()+".txt");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        System.setOut(fileOut);
        System.out.println("Variables for solution " + event.getCurrentSeed() + ":");
        Algorithm xd = event.getCurrentAlgorithm();
        if (xd != null) {
            NondominatedPopulation currentPop = xd.getResult();
            for (Solution sol : currentPop) {
                System.out.println(EncodingUtils.getInt(sol.getVariable(0))+","+EncodingUtils.getInt(sol.getVariable(7))+","+sol.getVariable(1)+","+sol.getVariable(2)+","+sol.getVariable(3)+","+sol.getVariable(4)+","+sol.getVariable(5)+","+sol.getVariable(6));
            }
            try {
                PopulationIO.writeObjectives(new File(filepath+"0627_objectives"+event.getCurrentNFE()+".txt"), currentPop);
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
