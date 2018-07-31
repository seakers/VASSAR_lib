package rbsa.eoss.local.test;

import rbsa.eoss.ResultCollection;
import rbsa.eoss.ResultManager;
import rbsa.eoss.io.ResultCollectionRecorder;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.evaluation.AbstractArchitectureEvaluator;
import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
import rbsa.eoss.architecture.AbstractArchitectureGenerator;
import rbsa.eoss.local.BaseParams;
import rbsa.eoss.problems.Assigning.SMAPParams;
import rbsa.eoss.problems.PartitioningAndAssigning.Decadal2017AerosolsParams;

import java.util.ArrayList;

public class RandomPopulation {
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {

        int POP_SIZE = 1000;
        String problem = "Decadal2017Aerosols";
        String path = "./problems/";

        BaseParams params;
        AbstractArchitectureEvaluator evaluator;
        ArchitectureEvaluationManager AEM;
        AbstractArchitectureGenerator archGenerator;

        switch (problem){
            case "SMAP":
                path = path + "SMAP";
                params = new SMAPParams(path,
                        "CRISP-ATTRIBUTES","test","normal","");
                evaluator = new rbsa.eoss.problems.Assigning.ArchitectureEvaluator(params);
                archGenerator = new rbsa.eoss.problems.Assigning.ArchitectureGenerator((SMAPParams)params);
                break;

            case "Decadal2017Aerosols":
                path = path + "SMAP";
                params = new Decadal2017AerosolsParams(path,
                        "CRISP-ATTRIBUTES","test","normal","");
                evaluator = new rbsa.eoss.problems.PartitioningAndAssigning.ArchitectureEvaluator(params);
                archGenerator = new rbsa.eoss.problems.PartitioningAndAssigning.ArchitectureGenerator((Decadal2017AerosolsParams)params);
                break;
            default:
                throw new IllegalArgumentException();
        }

        AEM = new ArchitectureEvaluationManager(params, evaluator);

        ResultManager RM = ResultManager.getInstance();
        ResultCollection c = null;

        ArrayList<AbstractArchitecture> initialPopulation = archGenerator.generateRandomPopulation(POP_SIZE);
        AEM.init(6);
        AEM.setPopulation(initialPopulation);
        AEM.evaluatePopulation();
        c = new ResultCollection(params, AEM.getResults());

        //RM.saveResultCollection(c);
        ResultCollectionRecorder writer = new ResultCollectionRecorder(params);
        writer.write(c);

        AEM.clear();
        System.out.println("DONE");
    }
}
