package seakers.vassar.problems.PartitioningAndAssigning;

import jess.Rete;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.utils.MatlabFunctions;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

/**
 *
 * @author bang
 */
public class CritiqueGenerator extends ArchitectureEvaluator {
    
    public CritiqueGenerator (PartitioningAndAssigningParams params, ResourcePool resourcePool, AbstractArchitecture arch)
    {
        super(params, resourcePool, arch,"slow");
    }

    public List<String> getCritique() {

        Resource res = super.getResource();
        Rete r = res.getRete();
        QueryBuilder qb = res.getQueryBuilder();
        MatlabFunctions m = res.getM();
        AbstractArchitecture arch = super.arch;
        
        List<String> list = new ArrayList<>();

        // Criticize using rules
        try {
            // First evaluate performance
            Result result = super.evaluatePerformance(r, arch, qb, m);

            // Criticize performance rules
            r.batch(super.params.critiquePerformanceInitializeFactsClp);
            r.batch(super.params.critiquePerformanceClp);
            r.batch(super.params.critiquePerformancePrecalculationClp);
            
            r.setFocus("CRITIQUE-PERFORMANCE-PRECALCULATION");
            r.run();
            r.setFocus("CRITIQUE-PERFORMANCE");
            r.run();
            
            //Fetch the results for performance
            Vector<String> list1;
            list1 = RawSafety.castVector(r.getGlobalContext().getVariable("*p*").javaObjectValue(null));

            r.reset();
            
            // First evaluate cost
            evaluateCost(r, arch, result, qb, m);
            
            // Criticize cost rules
            r.batch(super.params.critiqueCostInitializeFactsClp);
            r.batch(super.params.critiqueCostClp);
            r.batch(super.params.critiqueCostPrecalculationClp);
            
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
        
        super.freeResource(res);
        return list;
    }
    
    
}
