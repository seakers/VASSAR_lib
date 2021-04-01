import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;

import java.util.ArrayList;

public class ReflectometerTest {
    public static void main(String[] args){
        String path = "D:/Documents/VASSAR/VASSAR_resources"; // CHANGE THIS FOR YOUR IMPLEMENTATION
        ArrayList<SimpleArchitecture> architectures = new ArrayList<SimpleArchitecture>();
        ArrayList<String> orbitList = new ArrayList<>();
        String orbit = "SSO-700-SSO-DD";
        orbitList.add(orbit);
        ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
        OrbitInstrumentObject satellite = new OrbitInstrumentObject(new String[]{"Reflectometer"},orbit);
        satellites.add(satellite);
        SimpleArchitecture arc = new SimpleArchitecture(satellites);
        architectures.add(arc);
        String[] orbList = new String[orbitList.size()];
        for (int i = 0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        SimpleParams params = new SimpleParams(orbList, "DSHIELD", path, "CRISP-ATTRIBUTES","test", "normal");
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);


        for(SimpleArchitecture architecture : architectures) {
            evaluationManager.init(1);
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            evaluationManager.clear();
            architecture.setCost(result.getCost());
            architecture.setCoverage(result.getCoverage());
            System.out.println(architecture.toString("")+"Cost: "+result.getCost()+", Revisit Time: "+result.getCoverage());
        }

        System.out.println("DONE");
    }
}
