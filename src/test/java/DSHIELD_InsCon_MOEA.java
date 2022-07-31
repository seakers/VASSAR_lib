import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.MOEAInsAltProgressListener;
import seakers.vassar.moea.MOEAInsConProgressListener;
import seakers.vassar.moea.RadarInsAltProblem;
import seakers.vassar.moea.RadarInsProblem;

import java.io.File;
import java.util.*;

public class DSHIELD_InsCon_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(16);
            Properties properties = new Properties();
            for(int i = 3; i <= 10; i++) {
                properties.setProperty("populationSize","48");
                properties.setProperty("maxEvaluations","1200");
                File f = new File("./src/test/output/varfixcomb/run"+i+"/");
                f.mkdir();
                properties.setProperty("filepath","./src/test/output/varfixcomb/run"+i+"/");
                MOEAInsConProgressListener progressListener = new MOEAInsConProgressListener();
                NondominatedPopulation result = new Executor().withProblemClass(RadarInsProblem.class).withAlgorithm("NSGA-II").withProperties(properties).distributeOn(8).withProgressListener(progressListener).run();
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
