package rbsa.eoss;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;
import jess.Rete;
import rbsa.eoss.local.Params;

/**
 *
 * @author bang
 */
public class CritiqueGenerator extends GenericTask {
    
    
    public CritiqueGenerator (Architecture arch)
    {
        super(arch,"slow");
    }

    public List<String> getCritique() {

        super.getResource();
        Rete r = res.getRete();
        QueryBuilder qb = res.getQueryBuilder();
        MatlabFunctions m = res.getM();
        Architecture arch = super.arch;
        
        List<String> list = new ArrayList<>();

        // Criticize using rules
        try {
            // First evaluate performance
            Result result = super.evaluatePerformance(r, arch, qb, m);

            // Criticize performance rules
            r.batch(params.critiquePerformanceInitializeFactsClp);
            r.batch(params.critiquePerformanceClp);
            r.batch(params.critiquePerformancePrecalculationClp);
            
            r.setFocus("CRITIQUE-PERFORMANCE-PRECALCULATION");
            r.run();
            r.setFocus("CRITIQUE-PERFORMANCE");
            r.run();
            
            //Fetch the results for performance
            Vector<String> list1;
            list1 = (Vector<String>) r.getGlobalContext().getVariable("*p*").externalAddressValue(null);

            r.reset();
            
            // First evaluate cost
            evaluateCost(r, arch, result, qb, m);
            
            // Criticize cost rules
            r.batch(params.critiqueCostInitializeFactsClp);
            r.batch(params.critiqueCostClp);
            r.batch(params.critiqueCostPrecalculationClp);
            
            r.setFocus("CRITIQUE-COST-PRECALCULATION");
            r.run();
            r.setFocus("CRITIQUE-COST");
            r.run();
                        
            //Fetch the results for cost
            Vector<String> list2;
            list2 = (Vector<String>) r.getGlobalContext().getVariable("*q*").externalAddressValue(null);
            
            //Combine results and save to result
            list.addAll(list1);
            list.addAll(list2);
        }
        catch(Exception e) {
            System.out.println("Exc in generating a critique");
            System.out.println(e.getMessage()+" "+e.getClass());
            e.printStackTrace();
        }
        
        super.freeResource();
        return list;
    }
    
    
}
