import seakers.vassar.Result;
import seakers.vassar.spacecraft.SpacecraftDescription;
import seakers.vassar.utils.VassarPy;

import java.util.ArrayList;

public class ClimateCentricEvaluationTest {

    public static void main(String[] args) throws Exception {
        String resourcesPath = "../VASSAR_resources";

//        ClimateCentricParams params = new ClimateCentricParams(resourcesPath, "CRISP-ATTRIBUTES",
//                "test", "normal");
//        AbstractArchitectureEvaluator evaluator = new ArchitectureEvaluator();
//        ArchitectureGenerator archGenerator = new ArchitectureGenerator(params);
//        List<AbstractArchitecture> archs = archGenerator.generateRandomPopulation(1);

//        for(String key: params.revtimes.keySet()){
//            System.out.println(key + ": " + params.revtimes.get(key));
//        }

        // Instruments
//        String[] instrumentList = {"ACE_ORCA", "ACE_POL", "ACE_LID"};
        String[][] payloads = {{""}, {""}, {"SMAP_RAD", "SMAP_MWR"}, {""}, {""}};
        String[] orbits = {"LEO-600-polar-NA", "SSO-600-SSO-AM","SSO-780-SSO-DD","SSO-800-SSO-DD","SSO-800-SSO-PM"};
        String[][] factList = {{"payload-power#", "69"}, {"payload-peak-power#", "69"}};

        VassarPy python = new VassarPy("SMAP", payloads, orbits, resourcesPath, factList);

        ArrayList<SpacecraftDescription> designs = python.archDesign();
        Result designsEval = python.archEval();

        int x = 1;
    }
}
