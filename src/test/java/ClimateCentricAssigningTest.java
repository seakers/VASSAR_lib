import seakers.vassarheur.Result;
import seakers.vassarheur.architecture.AbstractArchitecture;
import seakers.vassarheur.evaluation.AbstractArchitectureEvaluator;
import seakers.vassarheur.evaluation.ArchitectureEvaluationManager;
import seakers.vassarheur.problems.Assigning.Architecture;
import seakers.vassarheur.problems.Assigning.ArchitectureEvaluator;
import seakers.vassarheur.problems.Assigning.ClimateCentricAssigningParams;

import java.util.ArrayList;

public class ClimateCentricAssigningTest {

    public static void main(String[] args){

        String resourcesPath = "C:\\SEAK Lab\\SEAK Lab Github\\VASSAR\\VASSAR_resources-heur";

        ClimateCentricAssigningParams params = new ClimateCentricAssigningParams(resourcesPath, "CRISP-ATTRIBUTES",
                "test", "normal");

//        for(String key: params.revtimes.keySet()){
//            System.out.println(key + ": " + params.revtimes.get(key));
//        }

        AbstractArchitectureEvaluator evaluator = new ArchitectureEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);

        //ArchitectureGenerator archGenerator = new ArchitectureGenerator(params);
        //List<AbstractArchitecture> archs = archGenerator.generateRandomPopulation(1);

        String architectureString = "111111111100000000000011000000000000000000000000000000000000";
        AbstractArchitecture arch = new Architecture(architectureString, params.getNumSatellites()[0], params);

        double dcThreshold = 0.5;
        double massThreshold = 3000.0; // [kg]
        double packEffThreshold = 0.4; // [kg]

        //Result result = evaluationManager.evaluateArchitectureSync(archs.get(0), "Slow", dcThreshold, massThreshold, packEffThreshold);
        Result result = evaluationManager.evaluateArchitectureSync(arch, "Slow", dcThreshold, massThreshold, packEffThreshold);

        System.out.println("science: " + result.getScience() + ", cost:" + result.getCost());

        ArrayList<Double> archHeuristics = result.getHeuristics();
        System.out.println("Duty Cycle Violation: " + archHeuristics.get(0));
        System.out.println("Instrument Orbit Assignment Violation: " + archHeuristics.get(1));
        System.out.println("Interference Violation: " + archHeuristics.get(2));
        System.out.println("Packing Efficiency Violation: " + archHeuristics.get(3));
        System.out.println("Spacecraft Mass Violation: " + archHeuristics.get(4));
        System.out.println("Synergy Violation: " + archHeuristics.get(5));

        System.out.println("DONE");
        evaluationManager.clear();
    }
}
