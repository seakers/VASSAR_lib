package rbsa.eoss.local.test;

import rbsa.eoss.Result;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.evaluation.AbstractArchitectureEvaluator;
import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
import rbsa.eoss.local.BaseParams;

import java.util.*;


public class DecadalSurveyEvaluationTest {

    public static void main(String[] args){

        //PATH
        String path = "./problems/SMAP";

        BaseParams params = new rbsa.eoss.problems.PartitioningAndAssigning.Decadal2017AerosolsParams(path,"CRISP-ATTRIBUTES","test","normal","");
        AbstractArchitectureEvaluator eval = new rbsa.eoss.problems.PartitioningAndAssigning.ArchitectureEvaluator(params);
        ArchitectureEvaluationManager evalManager = new ArchitectureEvaluationManager(params, eval);
        AbstractArchitecture testArch;

        // List of instruments and orbits
//      {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
//      {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};

        List<Set<String>> instrumentPartitioning = new ArrayList<>();
        Map<Set<String>, String> orbitAssignment = new HashMap<>();

        Set<String> set1 = new HashSet<>();
        set1.add("BIOMASS");
        set1.add("SMAP_RAD");
        instrumentPartitioning.add(set1);
        orbitAssignment.put(set1,"LEO-600-polar-NA");

        Set<String> set2 = new HashSet<>();
        set2.add("SMAP_MWR");
        set2.add("CMIS");
        instrumentPartitioning.add(set2);
        orbitAssignment.put(set2,"SSO-600-SSO-DD");

        Set<String> set3 = new HashSet<>();
        set3.add("VIIRS");
        instrumentPartitioning.add(set3);
        orbitAssignment.put(set3,"SSO-800-SSO-AM");
        testArch = new rbsa.eoss.problems.PartitioningAndAssigning.Architecture(instrumentPartitioning, orbitAssignment, 1, params);

        evalManager.reset();
        evalManager.init(1);
        Result resu = evalManager.evaluateArchitecture(testArch, "Slow");

        System.out.println(resu.getScience());
        System.out.println(resu.getCost());
        System.out.println("DONE");
    }
}
