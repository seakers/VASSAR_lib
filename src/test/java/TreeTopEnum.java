import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;

import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class TreeTopEnum {
    public static void main(String[] args){
        String path = "D:/Documents/VASSAR/VASSAR_resources"; // CHANGE THIS FOR YOUR IMPLEMENTATION
        ArrayList<SimpleArchitecture> architectures = new ArrayList<>();
        ArrayList<String> orbitList = new ArrayList<>();
        String[] orbitHeights = new String[] {"400","500","600","700"};
        String[] instruments = new String[] {"VIIRS","CMIS","SMAP_RAD","SMAP_MWR","BIOMASS"};
        List<String[]> instrumentSets = new ArrayList<>();
        int n = instruments.length;
        for(int i = 0; i < (1<<n); i++) {
            ArrayList<String> instrumentSet = new ArrayList<>();
            for (int j = 0; j < n; j++) {
                if ((i & (1 << j)) > 0) {
                    instrumentSet.add(instruments[j]);
                }
            }
            instrumentSets.add(instrumentSet.toArray(new String[0]));
        }
        for (String orbitHeight : orbitHeights) {
            orbitList.add("LEO-" + orbitHeight + "-polar-NA");
            orbitList.add("LEO-" + orbitHeight + "-30-NA");
            orbitList.add("LEO-" + orbitHeight + "-0-NA");
            orbitList.add("SSO-" + orbitHeight + "-SSO-DD");
            orbitList.add("SSO-" + orbitHeight + "-SSO-PM");
            orbitList.add("SSO-" + orbitHeight + "-SSO-AM");
        }
        for (String s : orbitList) {
            for (String[] instrumentList : instrumentSets) {
                ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
                OrbitInstrumentObject satellite = new OrbitInstrumentObject(instrumentList, s);
                satellites.add(satellite);
                SimpleArchitecture architecture = new SimpleArchitecture(satellites);
                architecture.setName(s + " " + Arrays.toString(instrumentList));
                architectures.add(architecture);
            }
        }

        String[] orbList = new String[orbitList.size()];
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        SimpleParams params = new SimpleParams(orbList, "SMAP", path, "CRISP-ATTRIBUTES","test", "normal");
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);


        JSONObject results = new JSONObject();
        JSONArray arches = new JSONArray();
        for(SimpleArchitecture architecture : architectures) {
            evaluationManager.init(1);
            long start = System.nanoTime();
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            long end = System.nanoTime();
            System.out.printf("Took %.4f sec", (end - start) / Math.pow(10, 9));
            evaluationManager.clear();
            architecture.setCost(result.getCost());
            architecture.setScience(result.getScience());
            System.out.println(architecture.toString("")+"Cost: "+result.getCost()+", Science: "+result.getScience());
            JSONObject arch = new JSONObject();
            arch.put("name",architecture.getName());
            arch.put("cost",architecture.getCost());
            arch.put("science",architecture.getScience());
            arches.add(arch);
            results.put("architectures",arches);
            try{
                FileWriter writer = new FileWriter("output_2_18.json"); // may want to change this!
                writer.write(results.toJSONString());
                writer.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        System.out.println("DONE");
    }
}