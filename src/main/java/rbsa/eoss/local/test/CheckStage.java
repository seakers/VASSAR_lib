//package rbsa.eoss.local.test;
//
//import rbsa.eoss.architecture.TempArchitecture;
//import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
//import rbsa.eoss.Result;
//
//import java.io.*;
//
//public class CheckStage {
//    public static void main(String[] args) {
//
//        String csvFile = "./results/stage2.csv";
//        BufferedReader br = null;
//        String line = "";
//        String cvsSplitBy = ",";
//
//        BaseParams.initInstance(".", "FUZZY-ATTRIBUTES", "test","normal","search_heuristic_rules_smap_127");
//        ArchitectureEvaluationManager AE = ArchitectureEvaluationManager.getInstance();
//        AE.init(1);
//
//        try {
//
//            br = new BufferedReader(new FileReader(csvFile));
//            while ((line = br.readLine()) != null) {
//                // use comma as separator
//                String[] arch = line.split(cvsSplitBy);
//                TempArchitecture rbsa.eoss.architecture = new TempArchitecture(arch[0].substring(1, 61), 1);
//                Result res = AE.evaluateArchitecture(rbsa.eoss.architecture, "Slow");
//                System.out.println("next");
//                System.out.println(Double.toString(res.getScience()).equals(arch[1]));
//                System.out.println(Double.toString(res.getCost()).equals(arch[2]));
//            }
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        } catch (IOException e) {
//            e.printStackTrace();
//        } finally {
//            if (br != null) {
//                try {
//                    br.close();
//                } catch (IOException e) {
//                    e.printStackTrace();
//                }
//            }
//        }
//
//        AE.clear();
//    }
//}
