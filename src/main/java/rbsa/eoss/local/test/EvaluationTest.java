//package rbsa.eoss.local.test;
//
//import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
//import rbsa.eoss.local.BaseParams;
//
//import rbsa.eoss.*;
//
//import java.util.HashMap;
//
//public class EvaluationTest {
//
//    public static void main(String[] args){
//
//        //PATH
//        String path = ".";
//
//        BaseParams.initInstance(path, "CRISP-ATTRIBUTES", "test","normal","");
//        ArchitectureEvaluationManager AE = ArchitectureEvaluationManager.getInstance();
//
//        TempArchitecture testArch;
//
//        // List of instruments and orbits
////      {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS","NEWINSTR"};
////      {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
//
//        //Reference rbsa.eoss.architecture #1
//        HashMap<String,String[]> map = new HashMap<>();
//        String[] payl_polar = {""};map.put("LEO-600-polar-NA",payl_polar);
//        String[] payl_AM = {"BIOMASS"};map.put("SSO-600-SSO-AM", payl_AM);
//        String[] payl_600DD = {""};map.put("SSO-600-SSO-DD",payl_600DD);
//        String[] payl_800AM = {"SMAP_MWR","VIIRS"};map.put("SSO-800-SSO-AM",payl_800AM);
//        String[] payl_800DD = {""};map.put("SSO-800-SSO-DD",payl_800DD);
//        testArch = new TempArchitecture(map, 1);
//
//        AE.init(1);
//        Result resu = AE.evaluateArchitecture(testArch, "Slow");
//
//        System.out.println(resu.getScience());
//        System.out.println(resu.getCost());
//
//        System.out.println("DONE");
//    }
//}
