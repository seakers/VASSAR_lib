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

public class EnumerationTest {
    public static void main(String[] args){
        String path = "D:/Documents/VASSAR/VASSAR_resources"; 
        ArrayList<SimpleArchitecture> architectures = new ArrayList<>();
        ArrayList<String> orbitIncCombos = new ArrayList<>();
        ArrayList<String> orbitList = new ArrayList<>();
        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("D:/Documents/VASSAR/VASSAR_lib/src/test/java/repeat_orbits_nonSSO_varinc.csv"))) { 
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println("Exception in reading csv:"+e);
        }
        int startingIndex = 0;
        HashMap<String,Integer> alt_repeat = new HashMap<>();
        for(int i = 0; i < 20; i++) {
            int repeat_cycle = parseInt(records.get(i+startingIndex).get(0));
            double alt = parseDouble(records.get(i+startingIndex).get(1));
            int inc = parseInt(records.get(i+startingIndex).get(4));
            alt = (double)Math.round(alt * 100d) / 100d;
            orbitIncCombos.add("LEO-"+alt+"-"+inc);
            alt_repeat.put("LEO-"+alt+"-"+inc,repeat_cycle);
        }

        //Modify for bounds to change problem size
        for(int i=0; i < 20; i++) {                 // Number of orbits to consider. Original value of 20
            for(int j = 1; j <= 4; j++) {           // Number of planes.             Original value of 4
                for(int k = 1; k <= 4; k++) {       // Satellites per plane.         Original value of 4
                    for(int l = 0; l < 1; l++) {    // Instrument distribution.      Original value of 3
                        if(j*k > 7) {
                            continue;
                        }
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
                                    OrbitInstrumentObject satellite = new OrbitInstrumentObject(new String[]{"L-band_SAR","P-band_SAR"},orbitName);
                                    satellites.add(satellite);
                                }
                            }
                            SimpleArchitecture architecture = new SimpleArchitecture(satellites);
                            int rc = alt_repeat.get(orbitIncCombos.get(i));
                            architecture.setRepeatCycle(rc);
                            architecture.setName(orbitIncCombos.get(i)+", repeat cycle of "+rc+" days, "+j+" planes, "+k+" satellites per plane, every satellite has both instruments");
                            architectures.add(architecture);
                        } else if (l == 1 && (k == 2 || k == 6)) {
                            ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
                            int count = 0;
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
                                    OrbitInstrumentObject satellite;
                                    if(count%2==0) {
                                        satellite = new OrbitInstrumentObject(new String[]{"L-band_SAR"}, orbitName);
                                    } else {
                                        satellite = new OrbitInstrumentObject(new String[]{"P-band_SAR"}, orbitName);
                                    }
                                    satellites.add(satellite);
                                    count++;
                                }
                            }
                            SimpleArchitecture architecture = new SimpleArchitecture(satellites);
                            int rc = alt_repeat.get(orbitIncCombos.get(i));
                            architecture.setRepeatCycle(rc);
                            architecture.setName(orbitIncCombos.get(i)+", repeat cycle of "+rc+" days, "+j+" planes, "+k+" satellites per plane, instruments alternate every satellite");
                            architectures.add(architecture);
                        } else if (l==2 && j > 1) {
                            ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
                            int count = 0;
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
                                    OrbitInstrumentObject satellite;
                                    if(count%2==0) {
                                        satellite = new OrbitInstrumentObject(new String[]{"L-band_SAR"}, orbitName);
                                    } else {
                                        satellite = new OrbitInstrumentObject(new String[]{"P-band_SAR"}, orbitName);
                                    }
                                    satellites.add(satellite);
                                }
                                count++;
                            }

                            SimpleArchitecture architecture = new SimpleArchitecture(satellites);
                            int rc = alt_repeat.get(orbitIncCombos.get(i));
                            architecture.setRepeatCycle(rc);
                            architecture.setName(orbitIncCombos.get(i)+", repeat cycle of "+rc+" days, "+j+" planes, "+k+" satellites per plane, instruments alternate planes");
                            architectures.add(architecture);
                        }

                    }
                }
            }
        }


        String[] orbList = new String[orbitList.size()];
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        SimpleParams params = new SimpleParams(orbList, "Designer", path, "CRISP-ATTRIBUTES","test", "normal");
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);


        JSONObject results = new JSONObject();
        JSONArray arches = new JSONArray();
        for(SimpleArchitecture architecture : architectures) {
            evaluationManager.init(1);
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            evaluationManager.clear();
            architecture.setCost(result.getCost());
            architecture. setCoverage(result.getCoverage());
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
            arch.put("percentCoverage",architecture.getPercentCoverage());
            arch.put("repeatCycle",architecture.getRepeatCycle());
            arches.add(arch);
            results.put("architectures",arches);
            try{
                FileWriter writer = new FileWriter("output_7_8.json"); // may want to change this!
                writer.write(results.toJSONString());
                writer.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        System.out.println("DONE");
    }
}