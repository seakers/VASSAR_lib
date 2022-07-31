import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.MOEAConProgressListener;
import seakers.vassar.moea.MOEAInsAltProgressListener;
import seakers.vassar.moea.RadarArchProblem;
import seakers.vassar.moea.RadarInsAltProblem;

import java.io.File;
import java.util.Properties;

public class DSHIELD_Con_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(8);
            Properties properties = new Properties();
            for(int i = 7; i <= 10; i++) {
                properties.setProperty("populationSize","48");
                properties.setProperty("maxEvaluations","1200");
                File f = new File("./src/test/output/varfixsep/run"+i+"/");
                f.mkdir();
                properties.setProperty("filepath","./src/test/output/varfixsep/run"+i+"/");
                MOEAConProgressListener progressListener = new MOEAConProgressListener();
                NondominatedPopulation result = new Executor().withProblemClass(RadarArchProblem.class).withAlgorithm("NSGA-II").withProperties(properties).distributeOn(8).withProgressListener(progressListener).run();
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
