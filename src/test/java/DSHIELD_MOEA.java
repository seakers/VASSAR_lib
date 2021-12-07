import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import seakers.vassar.HeteroArchProblem;

import java.io.File;
import java.util.Properties;

public class DSHIELD_MOEA {
    public static void main(String[] args){
        try{
            Properties properties = new Properties();
            properties.setProperty("populationSize","10");
            properties.setProperty("maxEvaluations","10");
            NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).withProperties(properties).distributeOnAllCores().run();
            PopulationIO.write(new File("population.txt"), result);
            PopulationIO.writeObjectives(new File("objectives.txt"), result);
            System.out.println(result.toString());
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}
