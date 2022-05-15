import seakers.vassarheur.BaseParams;
import seakers.vassarheur.Result;
import seakers.vassarheur.architecture.AbstractArchitecture;
import seakers.vassarheur.evaluation.AbstractArchitectureEvaluator;
import seakers.vassarheur.evaluation.ArchitectureEvaluationManager;
import seakers.vassarheur.problems.PartitioningAndAssigning.ClimateCentricPartitioningParams;
import seakers.vassarheur.problems.PartitioningAndAssigning.Architecture;
import seakers.vassarheur.problems.PartitioningAndAssigning.ArchitectureEvaluator;

import java.util.*;


public class ClimateCentricPartitioningTest {

    public static void main(String[] args){

        //// PATH
        String path = "C:\\SEAK Lab\\SEAK Lab Github\\VASSAR\\VASSAR_resources-heur";

        //BaseParams params = new Decadal2017AerosolsParams(path,"CRISP-ATTRIBUTES","test","normal");
        BaseParams params = new ClimateCentricPartitioningParams(path, "CRISP-ATTRIBUTES","test", "normal");

        double dcThreshold = 0.5;
        double massThreshold = 3000.0; // [kg]
        double packEffThreshold = 0.4; // [kg]
        boolean considerFeasibility = false; // use false to test architectures with partitions not using restricted growth strings

        HashMap<String, String[]> interferenceMap = getInstrumentInterferenceNameMap(params);
        HashMap<String, String[]> synergyMap = getInstrumentSynergyNameMap(params);

        AbstractArchitectureEvaluator eval = new ArchitectureEvaluator(considerFeasibility, interferenceMap, synergyMap, dcThreshold, massThreshold, packEffThreshold);
        ArchitectureEvaluationManager evalManager = new ArchitectureEvaluationManager(params, eval);
        AbstractArchitecture testArch;

        //// List of instruments and orbits (Decadal Survey)
//      {"ACE_CPR","ACE_ORCA","ACE_POL","ACE_LID","CLAR_TIR","CLAR_VNIR"};
//      {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};

        //// List of instruments and orbits (Climate Centric Study)
        //String[] instrumentList = {"ACE_ORCA", "ACE_POL", "ACE_LID", "CLAR_ERB", "ACE_CPR", "DESD_SAR", "DESD_LID", "GACM_VIS", "GACM_SWIR", "HYSP_TIR", "POSTEPS_IRS", "CNES_KaRIN"};
        //String[] orbitList = {"LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-DD"};

        //// ARCHITECTURE CREATION METHOD 1
        //List<Set<String>> instrumentPartitioning = new ArrayList<>();
        //Map<Set<String>, String> orbitAssignment = new HashMap<>();

        //Set<String> set1 = new HashSet<>();
        //set1.add("ACE_ORCA");
        //set1.add("ACE_POL");
        //set1.add("ACE_LID");
        //set1.add("CLAR_ERB");
        //instrumentPartitioning.add(set1);
        //orbitAssignment.put(set1,"SSO-600-SSO-AM");

        //Set<String> set2 = new HashSet<>();
        //set2.add("ACE_CPR");
        //set2.add("DESD_SAR");
        //set2.add("DESD_LID");
        //instrumentPartitioning.add(set2);
        //orbitAssignment.put(set2,"SSO-800-SSO-PM");

        //Set<String> set3 = new HashSet<>();
        //set3.add("GACM_VIS");
        //set3.add("GACM_SWIR");
        //instrumentPartitioning.add(set3);
        //orbitAssignment.put(set3,"LEO-600-polar-NA");

        //Set<String> set4 = new HashSet<>();
        //set4.add("HYSP_TIR");
        //instrumentPartitioning.add(set4);
        //orbitAssignment.put(set4,"SSO-600-SSO-DD");

        //Set<String> set5 = new HashSet<>();
        //set5.add("POSTEPS_IRS");
        //set5.add("CNES_KaRIN");
        //instrumentPartitioning.add(set5);
        //orbitAssignment.put(set5,"SSO-600-SSO-AM");

        // ARCHITECTURE CREATION METHOD 2
        //int[] instrumentPartitioning = new int[]{2, 2, 2, 1, 4, 0, 3, 1, 4, 3, 0, 2};
        //int[] orbitAssignment = new int[]{1, 1, 0, 2, 4, -1, -1, -1, -1, -1, -1, -1};

        //testArch = new Architecture(instrumentPartitioning, orbitAssignment, 1, params);

        // ARCHITECTURE CREATION METHOD 3
        String archString = "0 0 0 0 0 0 1 1 2 2 2 2 | 1 3 4 -1 -1 -1 -1 -1 -1 -1 -1 -1";
        testArch = new Architecture(archString, 1, params);

        System.out.println(testArch.ppString());

        evalManager.reset();
        evalManager.init(1);
        Result resu = evalManager.evaluateArchitectureSync(testArch, "Slow", interferenceMap, synergyMap, dcThreshold, massThreshold, packEffThreshold);

        System.out.println("Science: " + resu.getScience());
        System.out.println("Cost: " + resu.getCost());

        ArrayList<Double> archHeuristics = resu.getHeuristics();
        System.out.println("Duty Cycle Violation: " + archHeuristics.get(0));
        System.out.println("Instrument Orbit Assignment Violation: " + archHeuristics.get(1));
        System.out.println("Interference Violation: " + archHeuristics.get(2));
        System.out.println("Packing Efficiency Violation: " + archHeuristics.get(3));
        System.out.println("Spacecraft Mass Violation: " + archHeuristics.get(4));
        System.out.println("Synergy Violation: " + archHeuristics.get(5));

        System.out.println("DONE");
        evalManager.clear();
    }

    /**
     * Creates instrument synergy map used to compute the instrument synergy violation heuristic (only formulated for the
     * Climate Centric problem for now) (added by roshansuresh)
     * @param params
     * @return Instrument synergy hashmap
     */

    private static HashMap<String, String[]> getInstrumentSynergyNameMap(BaseParams params) {
        HashMap<String, String[]> synergyNameMap = new HashMap<>();
        if (params.getProblemName().equalsIgnoreCase("ClimateCentric")) {
            synergyNameMap.put("ACE_ORCA", new String[]{"DESD_LID", "GACM_VIS", "ACE_POL", "HYSP_TIR", "ACE_LID"});
            synergyNameMap.put("DESD_LID", new String[]{"ACE_ORCA", "ACE_LID", "ACE_POL"});
            synergyNameMap.put("GACM_VIS", new String[]{"ACE_ORCA", "ACE_LID"});
            synergyNameMap.put("HYSP_TIR", new String[]{"ACE_ORCA", "POSTEPS_IRS"});
            synergyNameMap.put("ACE_POL", new String[]{"ACE_ORCA", "DESD_LID"});
            synergyNameMap.put("ACE_LID", new String[]{"ACE_ORCA", "CNES_KaRIN", "DESD_LID", "GACM_VIS"});
            synergyNameMap.put("POSTEPS_IRS", new String[]{"HYSP_TIR"});
            synergyNameMap.put("CNES_KaRIN", new String[]{"ACE_LID"});
        }
        else {
            System.out.println("Synergy Map for current problem not formulated");
        }
        return synergyNameMap;
    }

    /**
     * Creates instrument interference map used to compute the instrument interference violation heuristic (only formulated for the
     * Climate Centric problem for now) (added by roshansuresh)
     * @param params
     * @return Instrument interference hashmap
     */

    private static HashMap<String, String[]> getInstrumentInterferenceNameMap(BaseParams params) {
        HashMap<String, String[]> interferenceNameMap = new HashMap<>();
        if (params.getProblemName().equalsIgnoreCase("ClimateCentric")) {
            interferenceNameMap.put("ACE_LID", new String[]{"ACE_CPR", "DESD_SAR", "CLAR_ERB", "GACM_SWIR"});
            interferenceNameMap.put("ACE_CPR", new String[]{"ACE_LID", "DESD_SAR", "CNES_KaRIN", "CLAR_ERB", "ACE_POL", "ACE_ORCA", "GACM_SWIR"});
            interferenceNameMap.put("DESD_SAR", new String[]{"ACE_LID", "ACE_CPR"});
            interferenceNameMap.put("CLAR_ERB", new String[]{"ACE_LID", "ACE_CPR"});
            interferenceNameMap.put("CNES_KaRIN", new String[]{"ACE_CPR"});
            interferenceNameMap.put("ACE_POL", new String[]{"ACE_CPR"});
            interferenceNameMap.put("ACE_ORCA", new String[]{"ACE_CPR"});
            interferenceNameMap.put("GACM_SWIR", new String[]{"ACE_LID", "ACE_CPR"});
        }
        else {
            System.out.println("Interference Map fpr current problem not formulated");
        }
        return interferenceNameMap;
    }
}
