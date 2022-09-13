import seakers.orekit.util.OrekitConfig;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.problems.Assigning.AssigningParams;
import seakers.vassar.problems.Assigning.SMAPParams;
import seakers.vassar.Result;
import seakers.vassar.problems.Assigning.Architecture;
import seakers.vassar.problems.Assigning.ArchitectureEvaluator;

import java.util.HashMap;


public class SMAPEvaluationTest {

    public static void main(String[] args){

        //PATH
        String resourcesPath = "../VASSAR_resources";

        AssigningParams params = new SMAPParams(resourcesPath,
                "CRISP-ATTRIBUTES","test","normal");
        AbstractArchitectureEvaluator eval = new ArchitectureEvaluator();
        ArchitectureEvaluationManager AE = new ArchitectureEvaluationManager(params, eval);
        AbstractArchitecture testArch;

        // List of instruments and orbits
//      {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS","NEWINSTR"};
//      {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};

        //Reference rbsa.eoss.architecture #1
        HashMap<String,String[]> map = new HashMap<>();
        String[] payl_polar = {""};map.put("LEO-600-polar-NA",payl_polar);
        String[] payl_AM = {"BIOMASS"};map.put("SSO-600-SSO-AM", payl_AM);
        String[] payl_600DD = {""};map.put("SSO-600-SSO-DD",payl_600DD);
        String[] payl_800AM = {"SMAP_MWR","VIIRS"};map.put("SSO-800-SSO-AM",payl_800AM);
        String[] payl_800DD = {""};map.put("SSO-800-SSO-DD",payl_800DD);
        testArch = new Architecture(map, 1, params);

        AE.init(1);
        OrekitConfig.init(1, params.orekitResourcesPath);
        Result result = AE.evaluateArchitectureSync(testArch, "Slow");
        OrekitConfig.end();
        AE.clear();

        System.out.println(result.getScience());
        System.out.println(result.getCost());
        System.out.println("DONE");
    }
}
