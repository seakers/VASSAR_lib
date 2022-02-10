import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import static java.lang.Double.parseDouble;
import static java.lang.Integer.parseInt;

public class RadioReflTest {
    public static void main(String[] args){
        String path = "./VASSAR_resources"; 
        ArrayList<SimpleArchitecture> architectures = new ArrayList<SimpleArchitecture>();
        ArrayList<String> orbitIncCombos = new ArrayList<>();
        ArrayList<String> orbitList = new ArrayList<>();
        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("VASSAR_lib/src/test/java/reduced_subset.csv"))) { 
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }
        int startingIndex = 0;
        HashMap<String,Integer> alt_repeat = new HashMap<>();
        for(int i = 0; i < 14; i++) {
            int repeat_cycle = parseInt(records.get(i+startingIndex).get(0));
            double alt = parseDouble(records.get(i+startingIndex).get(1));
            int inc = parseInt(records.get(i+startingIndex).get(4));
            alt = (double)Math.round(alt * 100d) / 100d;
            orbitIncCombos.add("LEO-"+alt+"-"+inc);
            alt_repeat.put("LEO-"+alt+"-"+inc,repeat_cycle);
        }
        for(int i=0; i < 14; i++) {                   // Original value of 20
            for(int j = 1; j <= 4; j++) {           // Number of planes.     Original value of 4
                for(int k = 1; k <= 8; k=k+2) {       // Satellites per plane. Original value of 4
                    for(int l = 1; l <= 1; l++) {    // Original value of 3
                        if (l == 0) {
                            ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
                            for(int m = 0; m < j; m++) {
                                for(int n = 0; n < k; n++) {
                                    int pu = 360 / (j*k);
                                    int delAnom = pu * j; //in plane spacing between satellites
                                    int delRAAN = pu * k; //node spacing
                                    int RAAN = delRAAN * m;
                                    int f = 1;
                                    int phasing = pu * f;
                                    int anom = (n * delAnom + phasing * m);
                                    String orbitName = orbitIncCombos.get(i)+"-"+RAAN+"-"+anom;
                                    if(!orbitList.contains(orbitName)) {
                                        orbitList.add(orbitName);
                                    }
                                    OrbitInstrumentObject satellite = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer","Aquarius"},orbitName);
                                    satellites.add(satellite);
                                }
                            }
                            SimpleArchitecture architecture = new SimpleArchitecture(satellites);
                            int rc = alt_repeat.get(orbitIncCombos.get(i));
                            architecture.setRepeatCycle(rc);
                            architecture.setName(orbitIncCombos.get(i)+", repeat cycle of "+rc+" days, "+j+" planes, "+k+" satellites per plane, Aquarius");
                            architectures.add(architecture);
                        } else if (l == 1) {
                            ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
                            for(int m = 0; m < j; m++) {
                                for(int n = 0; n < k; n++) {
                                    int pu = 360 / (j*k);
                                    int delAnom = pu * j; //in plane spacing between satellites
                                    int delRAAN = pu * k; //node spacing
                                    int RAAN = delRAAN * m;
                                    int f = 1;
                                    int phasing = pu * f;
                                    int anom = (n * delAnom + phasing * m);
                                    String orbitName = orbitIncCombos.get(i)+"-"+RAAN+"-"+anom;
                                    if(!orbitList.contains(orbitName)) {
                                        orbitList.add(orbitName);
                                    }
                                    OrbitInstrumentObject satellite = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer","FMPL-2"},orbitName);
                                    satellites.add(satellite);
                                }
                            }
                            SimpleArchitecture architecture = new SimpleArchitecture(satellites);
                            int rc = alt_repeat.get(orbitIncCombos.get(i));
                            architecture.setRepeatCycle(rc);
                            architecture.setName(orbitIncCombos.get(i)+", repeat cycle of "+rc+" days, "+j+" planes, "+k+" satellites per plane, FMPL-2");
                            architectures.add(architecture);
                        }
                    }
                }
            }
        }


        String[] orbList = new String[orbitList.size()];
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        SimpleParams params = new SimpleParams(orbList, "DSHIELD", path, "CRISP-ATTRIBUTES","test", "normal");
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);


        JSONObject results = new JSONObject();
        JSONArray arches = new JSONArray();
        for(SimpleArchitecture architecture : architectures) {
            evaluationManager.init(1);
            long start = System.nanoTime();
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            long end = System.nanoTime();
            System.out.printf("Full constellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
            evaluationManager.clear();
            architecture.setCost(result.getCost());
            architecture.setCoverage(result.getCoverage());
            System.out.println(architecture.toString("")+"Cost: "+result.getCost()+", Revisit Time: "+result.getCoverage());
            JSONObject arch = new JSONObject();
            arch.put("name",architecture.getName());
            arch.put("cost",architecture.getCost());
            arch.put("avgRevisit",architecture.getAvgRevisit());
            arch.put("maxRevisit",architecture.getMaxRevisit());
            arch.put("avgRevisitP",architecture.getAvgRevisitP());
            arch.put("maxRevisitP",architecture.getMaxRevisitP());
            arch.put("avgRevisitL",architecture.getAvgRevisitL());
            arch.put("maxRevisitL",architecture.getMaxRevisitL());
            arch.put("combReflRevisit",architecture.getCombReflMaxRevisit());
            arch.put("combReflCoverage",architecture.getCombReflCoverage());
            arch.put("reflRevisitP",architecture.getReflMaxRevisitP());
            arch.put("reflCoverageP",architecture.getReflCoverageP());
            arch.put("reflRevisitL",architecture.getReflMaxRevisitL());
            arch.put("reflCoverageL",architecture.getReflCoverageL());
            arch.put("radioRevisit",architecture.getRadioMaxRevisit());
            arch.put("radioCoverage",architecture.getRadioCoverage());
            arch.put("percentCoverage",architecture.getPercentCoverage());
            arch.put("repeatCycle",architecture.getRepeatCycle());
            arches.add(arch);
            results.put("architectures",arches);
            try{
                FileWriter writer = new FileWriter("reflradoutput_4_7.json"); // may want to change this!
                writer.write(results.toJSONString());
                writer.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        System.out.println("DONE");
    }
}
