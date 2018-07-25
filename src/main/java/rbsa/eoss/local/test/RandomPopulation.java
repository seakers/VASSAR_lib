//package rbsa.eoss.local.test;
//
//import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
//import rbsa.eoss.architecture.AbstractArchitectureGenerator;
//import rbsa.eoss.*;
//
//import java.util.ArrayList;
//
//public class RandomPopulation {
//    /**
//     * @param args the command line arguments
//     */
//    public static void main(String[] args) {
//
//        //PATH
//        String path = ".";
//
//        int POP_SIZE = 500;
//
//        Params.initInstance(path, "CRISP-ATTRIBUTES", "test","normal","");
//        ArchitectureEvaluationManager AE = ArchitectureEvaluationManager.getInstance();
//        ResultManager RM = ResultManager.getInstance();
//        ResultCollection c = null;
//
//        ArrayList<TempArchitecture> initialPopulation = AbstractArchitectureGenerator.getInstance().generateBiasedRandomPopulation(POP_SIZE, 0.25);
//        AE.init(8);
//        AE.setPopulation(initialPopulation);
//        AE.evaluatePopulation();
//        c = new ResultCollection(AE.getResults());
//        RM.saveResultCollection(c);
//
//        AE.clear();
//        System.out.println("DONE");
//    }
//}
