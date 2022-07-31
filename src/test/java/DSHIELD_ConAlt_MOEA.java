import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.*;

import java.io.File;
import java.util.Properties;

public class DSHIELD_ConAlt_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(16);
            Properties properties = new Properties();
            for(int i = 6; i <= 10; i++) {
                properties.setProperty("populationSize","16");
                properties.setProperty("maxEvaluations","1200");
                File f = new File("./src/test/output/varvarsep/run"+i+"/");
                f.mkdir();
                properties.setProperty("filepath","./src/test/output/varvarsep/run"+i+"/");
                MOEAConAltProgressListener progressListener = new MOEAConAltProgressListener();
                NondominatedPopulation result = new Executor().withProblemClass(RadarArchAltProblem.class).withAlgorithm("NSGA-II").withProperties(properties).distributeOn(16).withProgressListener(progressListener).run();
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
