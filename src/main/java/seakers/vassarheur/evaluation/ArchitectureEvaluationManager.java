package seakers.vassarheur.evaluation;

import seakers.vassarheur.ResourcePool;
import seakers.vassarheur.Result;
import seakers.vassarheur.architecture.AbstractArchitecture;
import seakers.vassarheur.BaseParams;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

public class ArchitectureEvaluationManager {

    private BaseParams params;

    private int numCPU;
    private AbstractArchitectureEvaluator evaluator;
    private ResourcePool resourcePool;
    private ExecutorService executorService;
    private Stack<Result> results;
    private ArrayList<Future<Result>> futures;

    public ArchitectureEvaluationManager(BaseParams params, AbstractArchitectureEvaluator evaluator) {
        this.params = params;
        this.numCPU = -1;
        this.evaluator = evaluator;
        reset();
    }

    public void init(int numCPU) {
        this.numCPU = numCPU;
        resourcePool = new ResourcePool(this.params, numCPU);
        executorService = Executors.newFixedThreadPool(numCPU);
        results.clear();
        futures.clear();
    }

    public void init() {
        if(this.numCPU == -1){
            throw new IllegalStateException("numCPU must be specified!");
        }
        resourcePool = new ResourcePool(this.params, numCPU);
        executorService = Executors.newFixedThreadPool(numCPU);
        results.clear();
        futures.clear();
    }

    public void reset() {
        results = new Stack<>();
        resourcePool = null;
        executorService = null;
        futures = new ArrayList<>();
    }

    public void clear() {
        executorService.shutdownNow();
        reset();
    }

    public void evaluatePopulation(List<AbstractArchitecture> population, BaseParams params, double dcThreshold, double massThreshold, double packEffThreshold) {

        int populationSize = population.size();

        for (AbstractArchitecture arch: population) {
            AbstractArchitectureEvaluator t = evaluator.getNewInstance(resourcePool, arch, "Slow", evaluator.getConsiderFeasibility(), dcThreshold, massThreshold, packEffThreshold);
            futures.add(executorService.submit(t));
        }
        int cnt = 1;
        for (Future<Result> future: futures) {
            try {
                Result resu = future.get(); // Do something with the results..
                pushResult(resu);
                System.out.println("Evaluated " + cnt + "/" + populationSize + ": " + resu.getScience() + ", " + resu.getCost());
                cnt++;

                // TODO: Add a quality check to see if science < 1 and arch is not empty. Push only if it passes quality control
            }
            catch (Exception e) {
                System.out.println(e.getMessage());
            }
        }
    }

    public Result evaluateArchitectureSync(AbstractArchitecture arch, String mode, double dcThreshold, double massThreshold, double packEffThreshold) {
        return evaluateArchitectureSync(arch, mode, false, dcThreshold, massThreshold, packEffThreshold);
    }

    public Result evaluateArchitectureSync(AbstractArchitecture arch, String mode, boolean debug, double dcThreshold, double massThreshold, double packEffThreshold) {
        AbstractArchitectureEvaluator t = evaluator.getNewInstance(resourcePool, arch, "Slow", evaluator.getConsiderFeasibility(), dcThreshold, massThreshold, packEffThreshold);
        t.setDebug(debug);

        Future<Result> future = executorService.submit(t);

        Result result = null;
        try {
            result = future.get();
        }
        catch (ExecutionException e) {
            System.out.println("Exception when evaluating an architecture");
            e.printStackTrace();
            this.clear();
            System.exit(-1);
        }
        catch (InterruptedException e) {
            System.out.println("Execution got interrupted while evaluating an architecture");
            e.printStackTrace();
            this.clear();
            System.exit(-1);
        }
        return result;
    }

    public Future<Result> evaluateArchitectureAsync(AbstractArchitecture arch, String mode, double dcThreshold, double massThreshold, double packEffThreshold) {
        return evaluateArchitectureAsync(arch, mode, false, dcThreshold, massThreshold, packEffThreshold);
    }

    public Future<Result> evaluateArchitectureAsync(AbstractArchitecture arch, String mode, boolean debug, double dcThreshold, double massThreshold, double packEffThreshold) {
        AbstractArchitectureEvaluator t = evaluator.getNewInstance(resourcePool, arch, "Slow", evaluator.getConsiderFeasibility(), dcThreshold, massThreshold, packEffThreshold);
        t.setDebug(debug);

        return executorService.submit(t);
    }

    public void clearResults() {
        results.clear();
        futures.clear();
    }

    public AbstractArchitectureEvaluator getEvaluator() {
        return evaluator;
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
}
