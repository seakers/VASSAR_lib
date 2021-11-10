import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import seakers.vassar.HeteroArchProblem;

import java.io.File;

public class DSHIELD_MOEA {
    public static void main(String[] args){
        try{
            NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).distributeOnAllCores().run();
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
