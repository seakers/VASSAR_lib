import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.MOEAInsConProgressListener;
import seakers.vassar.moea.MOEAScienceProgressListener;
import seakers.vassar.moea.RadarInsProblem;
import seakers.vassar.moea.RadarScienceProblem;

import java.io.File;
import java.util.Properties;

public class DSHIELD_Science_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(16);
            Properties properties = new Properties();
            for(int i = 1; i <= 10; i++) {
                properties.setProperty("populationSize","48");
                properties.setProperty("maxEvaluations","1200");
                File f = new File("./src/test/output/science/run"+i+"/");
                f.mkdir();
                properties.setProperty("filepath","./src/test/output/science/run"+i+"/");
                MOEAScienceProgressListener progressListener = new MOEAScienceProgressListener();
                NondominatedPopulation result = new Executor().withProblemClass(RadarScienceProblem.class).withAlgorithm("eMOEA").withProperties(properties).distributeOn(8).withProgressListener(progressListener).run();
            }
            OrekitConfig.end();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}
