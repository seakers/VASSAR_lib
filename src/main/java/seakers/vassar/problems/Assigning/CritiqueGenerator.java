package seakers.vassar.problems.Assigning;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

import jess.Rete;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.BaseParams;
import seakers.vassar.utils.MatlabFunctions;

/**
 *
 * @author bang
 */
public class CritiqueGenerator extends ArchitectureEvaluator {
    
    public CritiqueGenerator (ResourcePool resourcePool, AbstractArchitecture arch)
    {
        super(resourcePool, arch,"slow");
    }

    public List<String> getCritique() {

        Resource res = super.resourcePool.getResource();
        BaseParams params = res.getParams();
        Rete r = res.getRete();
        QueryBuilder qb = res.getQueryBuilder();
        MatlabFunctions m = res.getM();
        AbstractArchitecture arch = super.arch;
        
        List<String> list = new ArrayList<>();

        // Criticize using rules
        try {
            // First evaluate performance
            Result result = super.evaluatePerformance(params, r, arch, qb, m);

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
            list1 = RawSafety.castVector(r.getGlobalContext().getVariable("*p*").javaObjectValue(null));

            r.reset();
            
            // First evaluate cost
            evaluateCost(params, r, arch, result, qb, m);
            
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
            list2 = RawSafety.castVector(r.getGlobalContext().getVariable("*q*").javaObjectValue(null));
            
            //Combine results and save to result
            list.addAll(list1);
            list.addAll(list2);
        }
        catch(Exception e) {
            System.out.println("Exc in generating a critique");
            System.out.println(e.getMessage()+" "+e.getClass());
            e.printStackTrace();
        }
        
        super.resourcePool.freeResource(res);
        return list;
    }
    
    
}
