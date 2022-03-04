import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import seakers.orekit.util.OrekitConfig;
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

public class FullArchTest {
    public static void main(String[] args){
        String path = "../VASSAR_resources";
        OrekitConfig.init(16);
        ArrayList<SimpleArchitecture> architectures = new ArrayList<SimpleArchitecture>();
        ArrayList<String> orbitIncCombos = new ArrayList<>();
        ArrayList<String> orbitList = new ArrayList<>();
        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/reduced_subset.csv"))) { 
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
        int r = 1;
        int s = 3;
        ArrayList<OrbitInstrumentObject> radarOnlySatellites = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> radarRadiometerSatellites = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> fullSatellites = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> complementarySatellites = new ArrayList<>();
        for(int m = 0; m < r; m++) {
            for(int n = 0; n < s; n++) {
                int pu = 360 / (r*s);
                int delAnom = pu * r; //in plane spacing between satellites
                int delRAAN = pu * s; //node spacing
                int RAAN = delRAAN * m;
                int f = 1;
                int phasing = pu * f;
                int anom = (n * delAnom + phasing * m);
                String orbitName = "LEO-502.5-89"+"-"+RAAN+"-"+anom;
                int compAnom = anom+60;
                String complementaryOrbitName = "LEO-502.5-89"+"-"+RAAN+"-"+compAnom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                }
                OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"L-band_SAR","P-band_SAR"},orbitName);
                OrbitInstrumentObject fullSatellite = new OrbitInstrumentObject(new String[]{"FMPL-2","P-band_SAR","L-band_SAR"},orbitName);
                OrbitInstrumentObject complementarySatellite = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer","P-band_Reflectometer","FMPL-2"},complementaryOrbitName);
                radarOnlySatellites.add(radarOnlySatellite);
                radarRadiometerSatellites.add(radarOnlySatellite);
                fullSatellites.add(fullSatellite);
                complementarySatellites.add(complementarySatellite);
            }
        }
        //SimpleArchitecture radarArchitecture = new SimpleArchitecture(radarOnlySatellites);
        //radarArchitecture.setRepeatCycle(7);
        //radarArchitecture.setName("LEO-502.5-89, repeat cycle of 7 days, 1 planes, 3 satellites per plane, radar satellites only");
        //architectures.add(radarArchitecture);
        for(int i=0; i < 1; i++) {                   // Original value of 20
            for(int j = 1; j <= 1; j++) {           // Number of planes.     Original value of 4
                for(int k = 3; k <= 3; k++) {       // Satellites per plane. Original value of 4
                    ArrayList<OrbitInstrumentObject> radarSatellites = new ArrayList<>();
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
                            radarSatellites.add(satellite);
                        }
                    }
                    //radarRadiometerSatellites.add(arbitrarySatellites);
                    SimpleArchitecture radarArchitecture = new SimpleArchitecture(radarSatellites);
                    int rc = alt_repeat.get(orbitIncCombos.get(i));
                    radarArchitecture.setRepeatCycle(rc);
                    radarArchitecture.setName(orbitIncCombos.get(i)+", repeat cycle of "+rc+" days, "+j+" planes, "+k+" satellites per plane, radar only satellites");
                    architectures.add(radarArchitecture);
                }
            }
        }
        SimpleArchitecture fullArchitecture = new SimpleArchitecture(fullSatellites);
        fullArchitecture.setRepeatCycle(7);
        fullArchitecture.setName("LEO-502.5-89, repeat cycle of 7 days, 1 planes, 3 satellites per plane, full satellites only");
        //architectures.add(fullArchitecture);
        ArrayList<OrbitInstrumentObject> radarsAndComplementarySatellites = new ArrayList<>();
        radarsAndComplementarySatellites.addAll(radarOnlySatellites);
        radarsAndComplementarySatellites.addAll(complementarySatellites);
        SimpleArchitecture radarsCompArchitecture = new SimpleArchitecture(radarsAndComplementarySatellites);
        radarsCompArchitecture.setRepeatCycle(7);
        radarsCompArchitecture.setName("LEO-502.5-89, repeat cycle of 7 days, 1 planes, 3 satellites per plane, radar and complementary satellites only");
        //architectures.add(radarsCompArchitecture);
        ArrayList<OrbitInstrumentObject> fullAndComplementarySatellites = new ArrayList<>();
        fullAndComplementarySatellites.addAll(fullSatellites);
        fullAndComplementarySatellites.addAll(complementarySatellites);
        SimpleArchitecture fullCompArchitecture = new SimpleArchitecture(fullAndComplementarySatellites);
        fullCompArchitecture.setRepeatCycle(7);
        fullCompArchitecture.setName("LEO-502.5-89, repeat cycle of 7 days, 1 planes, 3 satellites per plane, full and complementary satellites only");
        //architectures.add(fullCompArchitecture);
        for(int i=1; i < 2; i++) {                   // Original value of 20
            for(int j = 4; j <= 4; j++) {           // Number of planes.     Original value of 4
                for(int k = 4; k <= 4; k++) {       // Satellites per plane. Original value of 4
                    ArrayList<OrbitInstrumentObject> arbitrarySatellites = new ArrayList<>();
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
                            OrbitInstrumentObject satellite = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer","P-band_Reflectometer","FMPL-2"},orbitName);
                            arbitrarySatellites.add(satellite);
                            radarRadiometerSatellites.add(satellite);
                        }
                    }
                    arbitrarySatellites.addAll(radarOnlySatellites);
                    //radarRadiometerSatellites.add(arbitrarySatellites);
                    SimpleArchitecture arbitraryArchitecture = new SimpleArchitecture(arbitrarySatellites);
                    int rc = alt_repeat.get(orbitIncCombos.get(i));
                    arbitraryArchitecture.setRepeatCycle(rc);
                    arbitraryArchitecture.setName(orbitIncCombos.get(i)+", repeat cycle of "+rc+" days, "+j+" planes, "+k+" satellites per plane, full satellites");
                    //architectures.add(arbitraryArchitecture);
                }
            }
        }
        SimpleArchitecture radarRadiometerArchitecture = new SimpleArchitecture(radarRadiometerSatellites);
        //architectures.add(radarRadiometerArchitecture);
        ArrayList<OrbitInstrumentObject> cygnssSatellites = new ArrayList<>();
        int j = 1;
        int k = 8;
        for(int m = 0; m < j; m++) {
            for(int n = 0; n < k; n++) {
                int pu = 360 / (j*k);
                int delAnom = pu * j; //in plane spacing between satellites
                int delRAAN = pu * k; //node spacing
                int RAAN = delRAAN * m;
                int f = 1;
                int phasing = pu * f;
                int anom = (n * delAnom + phasing * m);
                String orbitName = "LEO-510-35"+"-"+RAAN+"-"+anom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                }
                OrbitInstrumentObject satellite = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer"},orbitName);
                cygnssSatellites.add(satellite);

            }
        }
        cygnssSatellites.addAll(fullSatellites);
        //arbitrarySatellites.addAll(fullSatellites);
        SimpleArchitecture cygnssArchitecture = new SimpleArchitecture(cygnssSatellites);
        cygnssArchitecture.setRepeatCycle(1);
        cygnssArchitecture.setName("CYGNSS, repeat cycle of x days, "+j+" planes, "+k+" satellites per plane, full satellites");
        //architectures.add(cygnssArchitecture);


        String[] orbList = new String[orbitList.size()];
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        SimpleParams params = new SimpleParams(orbList, "Designer", path, "CRISP-ATTRIBUTES","test", "normal");
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);


        JSONObject results = new JSONObject();
        JSONArray arches = new JSONArray();
        System.out.println("Starting to process architectures");
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
            arch.put("combReflAvgRevisit",architecture.getCombReflRevisit());
            arch.put("combReflMaxRevisit",architecture.getCombReflMaxRevisit());
            arch.put("combReflCoverage",architecture.getCombReflCoverage());
            arch.put("reflAvgRevisitP",architecture.getReflRevisitP());
            arch.put("reflMaxRevisitP",architecture.getReflMaxRevisitP());
            arch.put("reflCoverageP",architecture.getReflCoverageP());
            arch.put("reflAvgRevisitL",architecture.getReflMaxRevisitL());
            arch.put("reflMaxRevisitL",architecture.getReflMaxRevisitL());
            arch.put("reflCoverageL",architecture.getReflCoverageL());
            arch.put("radioAvgRevisit",architecture.getRadioRevisit());
            arch.put("radioMaxRevisit",architecture.getRadioMaxRevisit());
            arch.put("radioCoverage",architecture.getRadioCoverage());
            arch.put("allAvgRevisit",architecture.getAllAvgRevisit());
            arch.put("allMaxRevisit",architecture.getAllMaxRevisit());
            arch.put("allCoverage",architecture.getAllCoverage());
            arch.put("percentCoverage",architecture.getPercentCoverage());
            arch.put("repeatCycle",architecture.getRepeatCycle());
            arch.put("overlap", architecture.getOverlap());
            arch.put("smRewardRefl", architecture.getSmRewardRefl());
            arch.put("smRewardRadio", architecture.getSmRewardRadio());
            arch.put("smRewardReflRadio", architecture.getSmRewardReflRadio());
            arch.put("smRewardRadar", architecture.getSmRewardRadar());
            arch.put("plannerReward", architecture.getPlannerReward());
            arches.add(arch);
            results.put("architectures",arches);
            try{
                FileWriter writer = new FileWriter("./src/test/output/fulloutput_1_26_22_drop_1day.json"); // may want to change this!
                writer.write(results.toJSONString());
                writer.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        OrekitConfig.end();
        System.out.println("DONE");
        System.exit(0);
    }
}
