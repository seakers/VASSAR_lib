import seakers.vassar.Result;
import seakers.vassar.utils.designer.Designer;

public class ClimateCentricEvaluationTest {

    public static void main(String[] args) throws Exception {
        String resourcesPath = "../VASSAR_resources";

//        // Instruments
        String[][] payloads = {{""}, {""}, {""}, {"CYGNSS"}, {""}, {""}};
        String[] orbits = {"SSO-400-SSO-AM","SSO-400-SSO-DD","SSO-600-SSO-AM","SSO-500-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
        String[][] factList = null;
//        factList = {{"payload-power#", "69"}, {"payload-peak-power#", "69"}};

        Designer designer = new Designer("SAR_sizing_ref","Designer", payloads, orbits, resourcesPath, factList);
        designer.archDesign(true);

        int x = 1;
    }
}
