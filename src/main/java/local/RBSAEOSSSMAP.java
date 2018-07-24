package rbsa.eoss.local;

import rbsa.eoss.*;
import java.util.ArrayList;

/**
 *
 * @author dani
 */

public class RBSAEOSSSMAP {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
        //PATH
        String path = ".";

        int POP_SIZE = 200;
        int MAX_SEARCH_ITS = 4;

        Params.initInstance(path, "FUZZY-ATTRIBUTES", "test","normal","search_heuristic_rules_smap_127");
        ArchitectureEvaluator AE = ArchitectureEvaluator.getInstance();
        ArchTradespaceExplorer ATE = ArchTradespaceExplorer.getInstance();
        ResultManager RM = ResultManager.getInstance();
        ResultCollection c = null;

        ArrayList<Architecture> initialPopulation = ArchitectureGenerator.getInstance().getInitialPopulation(POP_SIZE);
        for (int i = 0; i < 20; i++) {
            if (i > 0) {
                if (initialPopulation != null) {
                    initialPopulation = c.getPopulation();
                }
                Params.initInstance(path, "FUZZY-ATTRIBUTES", "test","normal","search_heuristic_rules_smap_127");//FUZZY or CRISP
                AE.clear();
            }
            AE.init(8);
            AE.evalMinMax();
            ATE.clear();
            ATE.setTermCrit(new SearchOptions(POP_SIZE, MAX_SEARCH_ITS, 0.5, 0.1, 0.5, initialPopulation));
            ATE.searchNSGA2();
            System.out.println("PERF: " + ATE.getSp().toString());
            c = new ResultCollection(AE.getResults());
            RM.saveResultCollection(c);
        }

        System.out.println("DONE");
    }
}