package rbsa.eoss.evaluation;

import rbsa.eoss.ResourcePool;
import rbsa.eoss.Resource;
import rbsa.eoss.Result;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.local.BaseParams;

import java.util.ArrayList;
import java.util.Stack;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

public class ArchitectureEvaluationManager {

    private BaseParams params;
    private AbstractArchitectureEvaluator evaluator;
    private ArrayList<AbstractArchitecture> population;
    private ResourcePool resourcePool;
    private ExecutorService executorService;
    private Stack<Result> results;
    private ArrayList<Future<Result>> futures;

    public ArchitectureEvaluationManager(AbstractArchitectureEvaluator evaluator) {
        this.params = evaluator.getParams();
        this.evaluator = evaluator;
        reset();
    }

    public void init(int numCPU) {
        resourcePool = new ResourcePool(this.params, numCPU);
        executorService = Executors.newFixedThreadPool(numCPU);
        results.clear();
        futures.clear();
    }

    public void reset() {
        population = null;
        results = new Stack<>();
        resourcePool = null;
        executorService = null;
        futures = new ArrayList<>();
    }

    public void clear() {
        executorService.shutdownNow();
        reset();
    }

    public void evaluatePopulation() {
        for (AbstractArchitecture arch: population) {
            AbstractArchitectureEvaluator t = evaluator.getNewInstance(resourcePool, arch, "Slow");
            futures.add(executorService.submit(t));
        }

        for (Future<Result> future: futures) {
            try {
                Result resu = future.get(); // Do something with the results..
                pushResult(resu);
                System.out.println(resu.getScience() + " " + resu.getCost());
                // TODO: Add a quality check to see if science < 1 and arch is not empty. Push only if it passes quality control
            }
            catch (Exception e) {
                System.out.println(e.getMessage());
            }
        }
    }

    public Result evaluateArchitecture(AbstractArchitecture arch, String mode) {
        AbstractArchitectureEvaluator t = evaluator.getNewInstance(resourcePool, arch, mode);

        Future<Result> future = (Future<Result>) executorService.submit(t);
        Result result = null;
        try {
            result = future.get();
        }
        catch (Exception e) {
            System.out.println(e.getClass() + " : " + e.getMessage());
        }
        return result;
    }

    public void clearResults() {
        results.clear();
        futures.clear();
    }

    public ResourcePool getResourcePool()
    {
        return resourcePool;
    }

    public Stack<Result> getResults() {
        return results;
    }

    public synchronized void pushResult(Result result) {
        this.results.push(result);
    }

    public ArrayList<AbstractArchitecture> getPopulation()
    {
        return population;
    }

    public void setPopulation(ArrayList<AbstractArchitecture> population) {
        this.population = population;
    }
}
