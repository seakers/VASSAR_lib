import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import seakers.vassar.HeteroArchProblem;

import java.io.File;

public class DSHIELD_MOEA {
    public static void main(String[] args){
        try{
            NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).distributeOnAllCores().run();
            int count = 1;
            for (Solution sol : result) {
                System.out.println("Variables for solution " + count + ":");
                System.out.println("Number of radar satellites: " + sol.getVariable(0));
                System.out.println("Altitude of radar satellites: " + sol.getVariable(1));
                System.out.println("Inclination of radar satellites: " + sol.getVariable(2));
                System.out.println("Number of cubesat planes: " + sol.getVariable(3));
                System.out.println("Cubesats per plane: " + sol.getVariable(4));
                System.out.println("Altitude of cubesats: " + sol.getVariable(5));
                System.out.println("Inclination of cubesats: " + sol.getVariable(6));
                count++;
            }
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
