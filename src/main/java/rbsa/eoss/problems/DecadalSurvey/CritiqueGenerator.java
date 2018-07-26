package rbsa.eoss.problems.DecadalSurvey;

import jess.Rete;
import rbsa.eoss.QueryBuilder;
import rbsa.eoss.Resource;
import rbsa.eoss.ResourcePool;
import rbsa.eoss.Result;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.utils.MatlabFunctions;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

/**
 *
 * @author bang
 */
public class CritiqueGenerator extends ArchitectureEvaluator {
    
    public CritiqueGenerator (Params params, ResourcePool resourcePool, AbstractArchitecture arch)
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
            list1 = (Vector<String>) r.getGlobalContext().getVariable("*p*").externalAddressValue(null);

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
        
        super.freeResource(res);
        return list;
    }
    
    
}
