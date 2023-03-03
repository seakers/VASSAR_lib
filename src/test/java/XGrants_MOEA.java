import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.MOEAInsAltProgressListener;
import seakers.vassar.moea.RadarInsAltProblem;
import seakers.vassar.moea.XGrantsProblemFixedAgility;
import seakers.vassar.moea.XGrantsProgressListener;

import java.io.File;
import java.util.Properties;

public class XGrants_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(12);
            Properties properties = new Properties();
            properties.setProperty("populationSize","100");
            properties.setProperty("maxEvaluations","10000");
            XGrantsProgressListener progressListener = new XGrantsProgressListener();
            NondominatedPopulation result = new Executor().withProblemClass(XGrantsProblemFixedAgility.class).withAlgorithm("eMOEA").distributeOn(12).withProperties(properties).withProgressListener(progressListener).run();

            //NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).distributeOnAllCores().run();
            int count = 1;
            for (Solution sol : result) {
                System.out.println("Variables for solution " + count + ":");
                System.out.println("Sats per plane: " + EncodingUtils.getInt(sol.getVariable(0)));
                System.out.println("Num planes: " + EncodingUtils.getInt(sol.getVariable(1)));
                System.out.println("Altitude: " + sol.getVariable(2));
                System.out.println("Inclination: " + sol.getVariable(3));
                System.out.println("Num spectral pixels: " + sol.getVariable(4));
                System.out.println("Lower spectral bound (nm): " + sol.getVariable(5));
                System.out.println("Upper spectral bound (nm): " + sol.getVariable(6));
                System.out.println("Focal length: " + sol.getVariable(7));
                System.out.println("FOV: " + sol.getVariable(8));
                count++;
            }
            PopulationIO.writeObjectives(new File("./src/test/output/xgrants/objectives.txt"), result);
            OrekitConfig.end();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}
