import seakers.vassar.Result;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.problems.Assigning.Architecture;
import seakers.vassar.problems.Assigning.ArchitectureEvaluator;
import seakers.vassar.problems.Assigning.ArchitectureGenerator;
import seakers.vassar.problems.Assigning.ClimateCentricParams;

import java.util.List;
import java.util.Stack;

public class ClimateCentricEvaluationTest {

    public static void main(String[] args){

        String resourcesPath = "../VASSAR_resources";

        ClimateCentricParams params = new ClimateCentricParams(resourcesPath, "CRISP-ATTRIBUTES",
                "test", "normal");


//        for(String key: params.revtimes.keySet()){
//            System.out.println(key + ": " + params.revtimes.get(key));
//        }

        AbstractArchitectureEvaluator evaluator = new ArchitectureEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);

        ArchitectureGenerator archGenerator = new ArchitectureGenerator(params);

        List<AbstractArchitecture> archs = archGenerator.generateRandomPopulation(1);

        Result result = evaluationManager.evaluateArchitectureSync(archs.get(0), "Slow");

        System.out.println("science: " + result.getScience() + ", cost:" + result.getCost());
    }
}
