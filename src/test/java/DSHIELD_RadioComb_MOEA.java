import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.MOEAInsAltProgressListener;
import seakers.vassar.moea.MOEARadioCombProgressListener;
import seakers.vassar.moea.RadarInsAltProblem;
import seakers.vassar.moea.RadioCombProblem;

import java.io.File;
import java.util.Properties;

public class DSHIELD_RadioComb_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(16);
            Properties properties = new Properties();
            properties.setProperty("populationSize","48");
            properties.setProperty("maxEvaluations","4800");
            MOEARadioCombProgressListener progressListener = new MOEARadioCombProgressListener();
            NondominatedPopulation result = new Executor().withProblemClass(RadioCombProblem.class).withAlgorithm("NSGA-II").withProperties(properties).distributeOnAllCores().withProgressListener(progressListener).run();

            //NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).distributeOnAllCores().run();
            int count = 1;
            for (Solution sol : result) {
                System.out.println("Variables for solution " + count + ":");
                System.out.println("Altitude of radiometer satellites: " + sol.getVariable(0));
                System.out.println("Inclination of radiometer satellites: " + sol.getVariable(1));
                System.out.println("Number of planes: " + EncodingUtils.getInt(sol.getVariable(2)));
                System.out.println("Satellites per plane: " + EncodingUtils.getInt(sol.getVariable(3)));
                System.out.println("Radiometer dAz: " + sol.getVariable(4));
                System.out.println("Radiometer dEl: " + sol.getVariable(5));
                System.out.println("Radiometer bw: " + sol.getVariable(6));
                count++;
            }
            PopulationIO.writeObjectives(new File("./src/test/output/radiocomb/objectives.txt"), result);
            OrekitConfig.end();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}
