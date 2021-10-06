import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.problems.Evaluating.Architecture;
import seakers.vassar.problems.Evaluating.ArchitectureEvaluator;
import seakers.vassar.problems.Evaluating.CommonParams;

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
        String path = "../VASSAR_resources"; // CHANGE THIS FOR YOUR IMPLEMENTATION
        ArrayList<String> orbitIncCombos = new ArrayList<>();
        ArrayList<String> orbitList = new ArrayList<>();
        ArrayList<String> totalInstrumentList = new ArrayList<>();
        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/java/reduced_subset.csv"))) { // CHANGE THIS FOR YOUR IMPLEMENTATION
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
        for(int i = 0; i < 14; i++) {
            int repeat_cycle = parseInt(records.get(i+startingIndex).get(0));
            double alt = parseDouble(records.get(i+startingIndex).get(1));
            int inc = parseInt(records.get(i+startingIndex).get(4));
            alt = (double)Math.round(alt * 100d) / 100d;
            orbitIncCombos.add("LEO-"+alt+"-"+inc);
        }
        int r = 1;
        int s = 3;
        ArrayList<Architecture> radarOnlySatellites = new ArrayList<>();
        ArrayList<Architecture> fullSatellites = new ArrayList<>();
        ArrayList<Architecture> complementarySatellites = new ArrayList<>();
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
                Architecture radarOnlySatellite = new Architecture(new String[]{"L-band_SAR"},orbitName);
                totalInstrumentList.add("L-band_SAR");
                //Architecture fullSatellite = new Architecture(new String[]{"L-band_Reflectometer","P-band_Reflectometer","FMPL-2","P-band_SAR","L-band_SAR"},orbitName);
                //Architecture complementarySatellite = new Architecture(new String[]{"L-band_Reflectometer","P-band_Reflectometer","FMPL-2"},complementaryOrbitName);
                radarOnlySatellites.add(radarOnlySatellite);
                //fullSatellites.add(fullSatellite);
                //complementarySatellites.add(complementarySatellite);
            }
        }
        for(int i=1; i < 2; i++) {                   // Original value of 20
            for(int j = 3; j <= 3; j++) {           // Number of planes.     Original value of 4
                for(int k = 4; k <= 4; k++) {       // Satellites per plane. Original value of 4
                    ArrayList<Architecture> arbitrarySatellites = new ArrayList<>();
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
                            Architecture satellite = new Architecture(new String[]{"FMPL-2"},orbitName);
                            totalInstrumentList.add("FMPL-2");
                            arbitrarySatellites.add(satellite);
                        }
                    }
                    arbitrarySatellites.addAll(fullSatellites);
                }
            }
        }
        CommonParams params = new CommonParams(orbitList.toArray(new String[0]), "Designer", path, "CRISP-ATTRIBUTES","test", "normal");
        params.setInstrumentList(totalInstrumentList.toArray(new String[0]));
        ArchitectureEvaluator evaluator = new ArchitectureEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);


        JSONObject results = new JSONObject();
        JSONArray arches = new JSONArray();
        System.out.println("Starting to process architectures");
        System.out.println(System.getProperty("user.home"));
        for(Architecture architecture : radarOnlySatellites) {
            evaluationManager.init(1);
            long start = System.nanoTime();
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            long end = System.nanoTime();
            System.out.printf("Full constellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
            evaluationManager.clear();
            System.out.println(architecture.toString("")+"Cost: "+result.getCost()+", Revisit Time: "+result.getCoverage());
            JSONObject arch = new JSONObject();
            arch.put("cost",result.getCost());
            arch.put("coverage",result.getCoverage());
            arches.add(arch);
            results.put("architectures",arches);
            try{
                FileWriter writer = new FileWriter("fulloutput.json"); // may want to change this!
                writer.write(results.toJSONString());
                writer.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        System.out.println("DONE");
        System.exit(0);
    }
}
