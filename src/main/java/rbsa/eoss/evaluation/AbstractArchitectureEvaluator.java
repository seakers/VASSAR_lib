package rbsa.eoss.evaluation;

import rbsa.eoss.*;
import rbsa.eoss.architecture.AbstractArchitecture;
import jess.*;
import rbsa.eoss.local.BaseParams;
import rbsa.eoss.utils.MatlabFunctions;
import java.util.concurrent.Callable;

/**
 *
 * @author Ana-Dani
 */

public abstract class AbstractArchitectureEvaluator implements Callable {

    protected BaseParams params;
    protected AbstractArchitecture arch;
    protected ResourcePool resourcePool;
    protected String type;

    public AbstractArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        this.resourcePool = resourcePool;
        this.arch = arch;
        this.type = type;
    }

    public abstract AbstractArchitectureEvaluator getNewInstance();
    public abstract AbstractArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type);

    @Override
    public Result call() {
        if (!arch.isFeasibleAssignment()) {
            return new Result(arch, 0.0, 1E5);
        }

        Resource res = this.getResource();
        Rete r = res.getRete();
        QueryBuilder qb = res.getQueryBuilder();
        MatlabFunctions m = res.getM();
        Result result = new Result();

        try {
            if (type.equalsIgnoreCase("Slow")) {
                result = evaluatePerformance(r, arch, qb, m);
                r.eval("(reset)");
                assertMissions(r, arch, m);
            }
            else {
                throw new Exception("Wrong type of task");
            }
            evaluateCost(r, arch, result, qb, m);
            result.setTaskType(type);
        }
        catch (Exception e) {
            System.out.println("EXC in Task:call: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            this.freeResource(res);
        }
        this.freeResource(res);

        return result;
    }

    public Resource getResource() {
        return this.resourcePool.getResource();
    }

    public void freeResource(Resource res) {
        this.resourcePool.freeResource(res);
    }

    protected abstract Result evaluatePerformance(Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m);
    protected abstract Result aggregate_performance_score_facts(Rete r, MatlabFunctions m, QueryBuilder qb);
    protected abstract void evaluateCost(Rete r, AbstractArchitecture arch, Result res, QueryBuilder qb, MatlabFunctions m);
    protected abstract void designSpacecraft(Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m);
    protected abstract void assertMissions(Rete r, AbstractArchitecture arch, MatlabFunctions m);
}

