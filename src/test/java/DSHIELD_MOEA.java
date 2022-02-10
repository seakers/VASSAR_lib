import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.vassar.HeteroArchProblem;
import seakers.vassar.RadarArchProblem;
import java.io.File;
import java.util.*;

public class DSHIELD_MOEA {
    public static void main(String[] args){
        try{
            Properties properties = new Properties();
            properties.setProperty("populationSize","10");
            properties.setProperty("maxEvaluations","100");
            NondominatedPopulation result = new Executor().withProblemClass(RadarArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).withProperties(properties).run();

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
            PopulationIO.writeObjectives(new File("./src/main/test/output/objectives.txt"), result);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}
