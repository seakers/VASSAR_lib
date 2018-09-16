package rbsa.eoss.local.test;

import rbsa.eoss.ResultCollection;
import rbsa.eoss.ResultManager;
import rbsa.eoss.io.ResultCollectionRecorder;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.evaluation.AbstractArchitectureEvaluator;
import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
import rbsa.eoss.architecture.AbstractArchitectureGenerator;
import rbsa.eoss.local.BaseParams;
import rbsa.eoss.problems.Assigning.ArchitectureGenerator;
import rbsa.eoss.problems.Assigning.ClimateCentricParams;
import rbsa.eoss.problems.Assigning.SMAPParams;
import rbsa.eoss.problems.PartitioningAndAssigning.Decadal2017AerosolsParams;

import java.io.File;
import java.util.ArrayList;

public class RandomPopulation {
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {

        int POP_SIZE = 200;

        ClimateCentricParams params;
        AbstractArchitectureEvaluator evaluator;


        String path = "." + File.separator + "problems" + File.separator + "ClimateCentric";
        params = new ClimateCentricParams(path,
                "CRISP-ATTRIBUTES","test","normal","search_heuristic_rules_smap_127");
        params.aggregationXls = params.path + "/xls/Aggregation Rules-Climate.xls";
        AbstractArchitectureEvaluator eval = new rbsa.eoss.problems.Assigning.ArchitectureEvaluator(params);
        ArchitectureEvaluationManager AE = new ArchitectureEvaluationManager(params, eval);
        AbstractArchitectureGenerator archGenerator = new ArchitectureGenerator(params);



        ArrayList<AbstractArchitecture> initialPopulation = archGenerator.generateBiasedRandomPopulation(POP_SIZE, 0.25);
        AE.init(6);
        AE.setPopulation(initialPopulation);
        AE.evaluatePopulation();
        ResultCollection c = new ResultCollection(params, AE.getResults());

        //RM.saveResultCollection(c);
        ResultCollectionRecorder writer = new ResultCollectionRecorder(params);
        writer.write(c);

        AE.clear();
        System.out.println("DONE");
    }
}
