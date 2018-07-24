package rbsa.eoss;

import rbsa.eoss.local.Params;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Stack;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

public class ArchitectureEvaluator {

    public static ArchitectureEvaluator getInstance() {
        if(instance == null) {
            instance = new ArchitectureEvaluator();
        }
        return instance;
    }

    public static ArchitectureEvaluator getNewInstance() {
        return new ArchitectureEvaluator();
    }
    
    private static ArchitectureEvaluator instance = null;

    private Params params;
    private ArrayList<Architecture> population;
    private ResourcePool resourcePool;
    private Resource searchRes;
    private ExecutorService executorService;
    private Stack<Result> results;
    private ArrayList<Future<Result>> futures;
    private HashMap<ArrayList<String>, HashMap<String, Double>> scores;
    private HashMap<ArrayList<String>, HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>>> subobjScores;
    private HashMap<String, NDSM> dsmMap;
    
    private ArchitectureEvaluator() {
        reset();
    }

    public void init(int numCPU) {
        params = Params.getInstance();
        resourcePool = new ResourcePool(numCPU);
        searchRes = new Resource();
        executorService = Executors.newFixedThreadPool(numCPU);
        results.clear();
        futures.clear();
        if (!params.runMode.equalsIgnoreCase("update_scores")) {
            setScores(params.scores);
            setSubobjScores(params.subobjScores);
        }
        if (!params.runMode.equalsIgnoreCase("update_dsms")) {
            setDsmMap(params.allDsms);
        }
    }

    public void reset() {
        population = null;
        results = new Stack<>();
        resourcePool = null;
        executorService = null;
        searchRes = null;
        futures = new ArrayList<>();
        scores = new HashMap<>();
        subobjScores = new HashMap<>();
    }

    public void clear() {
        executorService.shutdownNow();
        reset();
    }

    public void evaluatePopulation() {
        for (Architecture arch: population) {
            GenericTask t = new GenericTask(arch, "Slow");
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

    public Result evaluateArchitecture(Architecture arch, String mode) {
        if (arch.getResult().getScience() == -1) { //not yet evaluated
            GenericTask t = new GenericTask(arch, mode);

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
        else {
            return arch.getResult();
        }
    }

    public void clearResults() {
        results.clear();
        futures.clear();
    }

    public void evalMinMax() {
        Architecture max_arch = ArchitectureGenerator.getInstance().getMaxArch();
        Result r2 = evaluateArchitecture(max_arch,"Slow");
        params.maxScience = r2.getScience();
        params.maxCost = r2.getCost();

        Architecture min_arch = ArchitectureGenerator.getInstance().getMinArch();
        Result r1 = evaluateArchitecture(min_arch,"Slow");
        params.minScience = r1.getScience();
        params.minCost = r1.getCost();

        clearResults();
    }

    public ResourcePool getResourcePool()
    {
        return resourcePool;
    }

    public Stack<Result> getResults() {
        return results;
    }

    public void setResults(Stack<Result> results) {
        this.results = results;
    }

    public synchronized void pushResult(Result result) {
        this.results.push(result);
    }

    public Resource getSearchResource() {
        return searchRes;
    }

    public void freeSearchResource() {
        try {
            searchRes.getRete().eval("(reset)");
        }
        catch (Exception e) {
            System.out.println("HOLA");
        }
    }

    public ArrayList<Architecture> getPopulation()
    {
        return population;
    }

    public void setPopulation(ArrayList<Architecture> population) {
        this.population = population;
    }

    public HashMap<String,Double> getAllOrbitScores(ArrayList<String> instruments) {
        Collections.sort(instruments);
        return scores.get(instruments);
    }

    public HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>> getAllOrbitSubobjScores(ArrayList<String> instruments) {
        Collections.sort(instruments);
        HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>> ret = subobjScores.get(instruments);
        if (ret == null) {
            System.out.println("instruments " + instruments);
        }
        return ret;
    }

    public Double getScore(ArrayList<String> instruments,String orbit) {
        return getAllOrbitScores(instruments).get(orbit);
    }

    public void setScore(ArrayList<String> instruments, String orbit, Double score) {
        Collections.sort(instruments);
        HashMap<String, Double> hmap = getAllOrbitScores(instruments);
        if (hmap == null) {
            hmap = new HashMap<>();
            scores.put(instruments, hmap);
        }

        if (hmap.get(orbit) == null) {
            hmap.put(orbit, score);
        }
    }

    public HashMap<ArrayList<String>, HashMap<String,Double>> getScores() {
        return scores;
    }

    public HashMap<ArrayList<String>, HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>>> getSubobjScores() {
        return subobjScores;
    }

    public ArrayList<ArrayList<ArrayList<Double>>> getSubobjScores(ArrayList<String> instruments, String orbit) {
        Collections.sort(instruments);
        ArrayList<ArrayList<ArrayList<Double>>> ret;
        ret = getAllOrbitSubobjScores(instruments).get(orbit);
        if (ret == null) {
            System.out.println(instruments.toString() + " " + orbit);
        }
        return ret;
    }

    public void setScores(HashMap<ArrayList<String>, HashMap<String, Double>> scores) {
        this.scores = scores;
    }

    public void setSubobjScores(HashMap<ArrayList<String>, HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>>> subobjScores) {
        this.subobjScores = subobjScores;
    }

    public void setSubobjScores(ArrayList<String> instruments, String orbit, ArrayList<ArrayList<ArrayList<Double>>> scores) {
        Collections.sort(instruments);
        HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>> hmap = getAllOrbitSubobjScores(instruments);
        if (hmap == null) {
            hmap = new HashMap<>();
            subobjScores.put(instruments, hmap);
        }

        if (hmap.get(orbit) == null) {
            hmap.put(orbit, scores);
        }
    }

    public HashMap<String, NDSM> getDsmMap() {
        return dsmMap;
    }

    public void setDsmMap(HashMap<String, NDSM> dsmMap) {
        this.dsmMap = dsmMap;
    }
}
