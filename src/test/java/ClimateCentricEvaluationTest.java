import seakers.vassar.Result;
import seakers.vassar.spacecraft.SpacecraftDescription;
import seakers.vassar.utils.VassarPy;

import java.util.ArrayList;

public class ClimateCentricEvaluationTest {

    public static void main(String[] args) throws Exception {
        String resourcesPath = "../VASSAR_resources";

//        // Instruments
//        String[][] payloads = {{""}, {""}, {"SMAP_RAD"}, {""}, {""}, {"SMAP_RAD"}};
        String[][] payloads = {{""}, {""}, {""}, {"SAR_1"}, {""}, {""}};
        String[] orbits = {"SSO-400-SSO-AM","SSO-400-SSO-DD","SSO-600-SSO-AM","SSO-500-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
//        String[][] factList = {{"payload-power#", "69"}, {"payload-peak-power#", "69"}};

        VassarPy python = new VassarPy("DSHIELD", payloads, orbits, resourcesPath, null);

//        ArrayList<SpacecraftDescription> designs = python.archDesign();
        Result designsEval = python.archEval();

        int x = 1;
    }
}
