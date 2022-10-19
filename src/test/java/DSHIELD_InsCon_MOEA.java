import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.MOEAInsConProgressListener;
import seakers.vassar.moea.RadarInsProblem;

import java.io.File;
import java.util.*;

public class DSHIELD_InsCon_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(16);
            Properties properties = new Properties();
            properties.setProperty("populationSize","48");
            properties.setProperty("maxEvaluations","4800");
            MOEAInsConProgressListener progressListener = new MOEAInsConProgressListener();
            NondominatedPopulation result = new Executor().withProblemClass(RadarInsProblem.class).withAlgorithm("NSGA-II").withProperties(properties).distributeOnAllCores().withProgressListener(progressListener).run();

            //NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).distributeOnAllCores().run();
            int count = 1;
            for (Solution sol : result) {
                System.out.println("Variables for solution " + count + ":");
                System.out.println("Number of radar satellites: " + EncodingUtils.getInt(sol.getVariable(0)));
                System.out.println("Altitude of radar satellites: " + sol.getVariable(1));
                System.out.println("Inclination of radar satellites: " + sol.getVariable(2));
                System.out.println("Radar dAz: " + sol.getVariable(3));
                System.out.println("Radar dEl: " + sol.getVariable(4));
                System.out.println("Radar chirp bw: " + sol.getVariable(5));
                System.out.println("Radar pulse width: " + sol.getVariable(6));
                count++;
            }
            PopulationIO.writeObjectives(new File("./src/test/output/inscon/objectives.txt"), result);
            OrekitConfig.end();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}