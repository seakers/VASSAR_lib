import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.moeaframework.core.*;
import org.moeaframework.util.TypedProperties;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.problems.Evaluating.Architecture;
import seakers.vassar.problems.Evaluating.ArchitectureEvaluator;
import seakers.vassar.problems.Evaluating.CommonParams;
import seakers.vassar.spacecraft.SpacecraftDescription;

import java.io.FileReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.*;

public class VASSARUpdateTest {
    private static String resourcesPath = "../VASSAR_resources";
    private CommonParams params;
    private ArrayList<SpacecraftDescription> designs;
    private static ArrayList<String> orbitList = new ArrayList<>();
    private static ArrayList<String> totalInstrumentList = new ArrayList<>();
    public static ArrayList<Architecture> loadMissionInfo(String filename) {
        ArrayList<Architecture> arches = new ArrayList<>();
        try {
            Object obj = new JSONParser().parse(new FileReader(filename));
            JSONObject jo = (JSONObject) obj;
            JSONArray missions = (JSONArray) jo.get("missions");

            Iterator missionItr = missions.iterator();

            while(missionItr.hasNext()) {
                JSONObject mission = (JSONObject) missionItr.next();
                String missionName = (String) mission.get("name");
                String orbit = (String) mission.get("orbit");
                orbitList.add(orbit);
                JSONArray instruments = (JSONArray) mission.get("instruments");
                Iterator instrumentItr = instruments.iterator();
                ArrayList<String> instrumentList = new ArrayList<>();
                while(instrumentItr.hasNext()) {
                    JSONObject instrument = (JSONObject) instrumentItr.next();
                    String name = (String) instrument.get("name");
                    instrumentList.add(name);
                    totalInstrumentList.add(name);
                }
                Map factMap = ((Map)mission.get("facts"));
                Architecture arch = new Architecture(instrumentList.toArray(new String[0]),orbit,factMap);
                arches.add(arch);
            }
        } catch (Exception e) {
            System.out.println("Exception in loadMissionInfo: " + e);
        }
        return arches;
    }

    public static void main(String[] args){
        System.out.println("Evaluating architectures...");

        String path = "../VASSAR_resources";
        ArrayList<Architecture> loadedArches = loadMissionInfo("./src/test/java/Missions.json");
//        ArrayList<String> orbitList = new ArrayList<>();
//        ArrayList<String> instrumentList = new ArrayList<>();
//        String smapOrbit = "SSO-680-SSO-DD";
//        String[] smapInstrumentList = {"SMAP_MWR","SMAP_RAD"};
//        orbitList.add(smapOrbit);
//        instrumentList.addAll(Arrays.asList(smapInstrumentList));
//        String landsat8Orbit = "SSO-800-SSO-DD";
//        String[] landsat8InstrumentList = {"OLI","TIRS"};
//        orbitList.add(landsat8Orbit);
//        instrumentList.addAll(Arrays.asList(landsat8InstrumentList));
        CommonParams params = new CommonParams(orbitList.toArray(new String[0]),"Designer", path, "CRISP-ATTRIBUTES", "test", "normal");
        params.setInstrumentList(totalInstrumentList.toArray(new String[0]));
        ArchitectureEvaluator evaluator = new ArchitectureEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);
        OrekitConfig.init(1, params.orekitResourcesPath);
//        ArrayList<Architecture> arches = new ArrayList<>();
//        Architecture smap = new Architecture(smapInstrumentList,smapOrbit);
//        arches.add(smap);
//        Architecture landsat8 = new Architecture(landsat8InstrumentList,landsat8Orbit);
//        arches.add(landsat8);

        for (Architecture arch : loadedArches) {
            Result result = evaluationManager.evaluateArchitectureSync(arch, "Slow");
            System.out.println("Architecture evaluation done.");
            System.out.println("Science: " + result.getScience() + ", Cost:" + result.getCost());
        }

        evaluationManager.clear();

        OrekitConfig.end();

        System.out.println("All arches done.");
    }

}
