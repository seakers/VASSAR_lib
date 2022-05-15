import seakers.vassarheur.BaseParams;
import seakers.vassarheur.Result;
import seakers.vassarheur.architecture.AbstractArchitecture;
import seakers.vassarheur.evaluation.AbstractArchitectureEvaluator;
import seakers.vassarheur.evaluation.ArchitectureEvaluationManager;
import seakers.vassarheur.problems.Assigning.Architecture;
import seakers.vassarheur.problems.Assigning.ArchitectureEvaluator;
import seakers.vassarheur.problems.Assigning.ClimateCentricAssigningParams;

import java.util.ArrayList;
import java.util.HashMap;

public class ClimateCentricAssigningTest {

    public static void main(String[] args){

        String resourcesPath = "C:\\SEAK Lab\\SEAK Lab Github\\VASSAR\\VASSAR_resources-heur";

        ClimateCentricAssigningParams params = new ClimateCentricAssigningParams(resourcesPath, "CRISP-ATTRIBUTES",
                "test", "normal");

//        for(String key: params.revtimes.keySet()){
//            System.out.println(key + ": " + params.revtimes.get(key));
//        }

        HashMap<String, String[]> interferenceMap = getInstrumentInterferenceNameMap(params);
        HashMap<String, String[]> synergyMap = getInstrumentSynergyNameMap(params);

        AbstractArchitectureEvaluator evaluator = new ArchitectureEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);

        //ArchitectureGenerator archGenerator = new ArchitectureGenerator(params);
        //List<AbstractArchitecture> archs = archGenerator.generateRandomPopulation(1);

        String architectureString = "000000000000000000100010000000000000000000010010000000010001";
        AbstractArchitecture arch = new Architecture(architectureString, params.getNumSatellites()[0], params);

        double dcThreshold = 0.5;
        double massThreshold = 3000.0; // [kg]
        double packEffThreshold = 0.4; // [kg]

        //Result result = evaluationManager.evaluateArchitectureSync(archs.get(0), "Slow", dcThreshold, massThreshold, packEffThreshold);
        Result result = evaluationManager.evaluateArchitectureSync(arch, "Slow", interferenceMap, synergyMap, dcThreshold, massThreshold, packEffThreshold);

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
