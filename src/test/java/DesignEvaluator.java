import seakers.orekit.util.OrekitConfig;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;

import java.util.ArrayList;

public class DesignEvaluator {
    public static void main(String[] args) {
        String path = "../VASSAR_resources";
        OrekitConfig.init(16);
        ArrayList<String> orbitList = new ArrayList<>();
        String orbitName = "LEO-500-polar-NA";
        ArrayList<OrbitInstrumentObject> constellation = new ArrayList<>();
        orbitList.add(orbitName);
        OrbitInstrumentObject testSatellite = new OrbitInstrumentObject(new String[]{"L-band_SAR"},orbitName);
        constellation.add(testSatellite);
        SimpleArchitecture architecture = new SimpleArchitecture(constellation);
        String[] orbList = new String[orbitList.size()];
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        SimpleParams params = new SimpleParams(orbList, "Designer", path, "CRISP-ATTRIBUTES","test", "normal");
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);
        long start = System.nanoTime();
        Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
        long end = System.nanoTime();
        System.out.printf("Full constellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
        evaluationManager.clear();
        architecture.setCost(result.getCost());
        architecture.setCoverage(result.getCoverage());
        System.out.println(architecture.toString("")+"Cost: "+result.getCost()+", Revisit Time: "+result.getCoverage());
        System.exit(0);
    }
}
