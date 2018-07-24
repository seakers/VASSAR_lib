package rbsa.eoss;

import jess.Fact;
import jess.Rete;
import jess.ValueVector;
import rbsa.eoss.local.Params;

import java.util.*;

/**
 *
 * @author Ana-Dani
 */
public class ArchTradespaceExplorer {
    private static ArchTradespaceExplorer instance = null;

    public static ArchTradespaceExplorer getInstance() {
        if (instance == null) {
            instance = new ArchTradespaceExplorer();
        }
        return instance;
    }

    private Params params;
    private ArrayList<Architecture> currentPopulation;
    private ArrayList<Architecture> currentBestArchs;
    private Stack<Result> results;
    private int nits;
    private SearchOptions termCrit;
    private Random rnd;
    private SearchPerformance sp;
    
    private ArchTradespaceExplorer() {
        params = Params.getInstance();
        results = new Stack<>();
        currentPopulation = null;
        currentBestArchs = null;
        nits = 0;
        termCrit = null;
        rnd = new Random();
        sp = null;
    }

    public void clear() {
        params = Params.getInstance();
        results = new Stack<>();
        currentPopulation = null;
        currentBestArchs = null;
        nits = 0;
        termCrit = null;
        rnd = new Random();
        sp = null;
    }



    public void searchNSGA2() {
        Boolean converged = false;
        //Init population
        currentPopulation = termCrit.getInitPopulation();
        ArchitectureEvaluator AE = ArchitectureEvaluator.getInstance();
        nits = 0;
        sp = new SearchPerformance();
        while (!converged) {
            //extend population using search rules
            System.out.println("Evaluating...");
            long t0 = System.currentTimeMillis();
            //extendPopulation();
            extendPopulationWithCooperation();
            //evaluate extended population
            AE.clearResults();
            AE.setPopulation(currentPopulation);
            AE.evaluatePopulation();
            //results = ArchEval.getResults();
            
            //Down-select population based on pareto ranking and crowding distance
            selection_NSGA2();
            
            //Check termination criteria
            nits++;
            sp.updateSearchPerformance(results, nits);
            converged = termCrit.checkTerminationCriteria(sp);
            System.out.println(sp.toString());
            long t1 = System.currentTimeMillis();
            System.out.println("Generation " + nits + " done in " + String.valueOf((t1-t0)/60000) + ". Approx time remaining " + String.valueOf((t1-t0)/60000*(termCrit.getMAX_ITS()-nits-1)));
        }
    }

    public void extendPopulationWithCooperation() {
        if (nits > 0) {
            // Mark small fraction for random mutation
            for (Architecture arch: currentPopulation) {
                if(rnd.nextDouble() < termCrit.getMutationRate()) {
                    arch.setMutate("yes");
                }
            }

            Collections.shuffle(currentPopulation);
            Resource res = ArchitectureEvaluator.getInstance().getSearchResource();
            Rete r = res.getRete();
            String str_list = "";
//            try {
//                r.setFocus("DATABASE");
//                r.run();
//                ArrayList<Fact> ff = res.getQueryBuilder().makeQuery("SEARCH-HEURISTICS::list-improve-heuristics");
//                Fact f = ff.get(0);
//                ValueVector vv = f.getSlotValue("list").listValue(r.getGlobalContext());
//                ArrayList<String> list = res.getM().jessList2ArrayList(vv, r);
//                for (String heur: list) {
//                    str_list += " " + heur; //Initial extra space is irrelevant
//                }
//            }
//            catch (Exception e) {
//                System.out.println("EXC in ArchTradespaceExplorer:extendPopulation: " + e.getClass() + " " + e.getMessage());
//                e.printStackTrace();
//                ArchitectureEvaluator.getInstance().freeSearchResource();
//            }

            String impr;
            for (long i = 0; i < currentPopulation.size(); i++) {
                if (str_list.isEmpty()) {
                    impr = "crossover1point";
                }
                else {
                    impr = str_list;
                }
                currentPopulation.get((int)i).setHeuristicsToApply(impr);
            }

            // Apply heuristics, this needs to keep original architectures and produce new ones.
            try {
                assertArchs(res, currentPopulation);
                //r.eval("(watch rules)");r.eval("(watch facts)");
                r.eval("(focus SEARCH-HEURISTICS)");
                r.run();
                //r.eval("(unwatch all)");
                currentPopulation = retrieveArchs(res);
                System.out.println("Population size after expansion is " + currentPopulation.size());
            }
            catch (Exception e) {
                System.out.println("EXC in ArchTradespaceExplorer:generateNextPopulation: " + e.getClass() + " " + e.getMessage());
                e.printStackTrace();
                ArchitectureEvaluator.getInstance().freeSearchResource();
            }
            ArchitectureEvaluator.getInstance().freeSearchResource();
        } else {
            //currentPopulation.addAll(ArchitectureGenerator.getInstance().generateRandomPopulation(termCrit.getPopulationSize()));
        }
    }

    public void selection_NSGA2() {
        ArrayList<Architecture> newPopulation = new ArrayList<>();
        //non-dominated sorting, returns fronts
        HashMap<Integer, ArrayList<Architecture>> fronts = nonDominatedSorting(true);
        
        //take n first fronts so as to leave some room
        int i = 1;
        while (newPopulation.size() + fronts.get(i).size() <= termCrit.getPopulationSize() && i < fronts.size()) {
            newPopulation.addAll(fronts.get(i));
            i++;
        }
        
        //Take remaining archs from sorted next front
        int NA = termCrit.getPopulationSize() - newPopulation.size();
        if (NA > 0) {
            ArrayList<Architecture> sortedLastFront = new ArrayList<>(fronts.get(i));
            computeCrowdingDistance(sortedLastFront);
            sortedLastFront.sort(Architecture.ArchCrowdDistComparator);
            ArrayList<Architecture> partialSortedLastFront = new ArrayList<>(sortedLastFront.subList(0, NA));
            newPopulation.addAll(partialSortedLastFront);
        }
        //Update population and results
        currentPopulation = newPopulation;
        results.clear();
        for (Architecture arch: currentPopulation) {
            results.push(arch.getResult());
        }
    }

    public void computeCrowdingDistance(ArrayList<Architecture> front) {
        int nsol = front.size();

        // Science
        front.sort(Architecture.ArchScienceComparator);
        front.get(0).getResult().setCrowdingDistance(1000);
        front.get(front.size() - 1).getResult().setCrowdingDistance(1000);
        for (int i = 1; i < nsol - 1; i++) {
            front.get(i).getResult().setCrowdingDistance(
                front.get(i).getResult().getCrowdingDistance() + Math.abs(
                    (front.get(i + 1).getResult().getScience() - front.get(i - 1).getResult().getScience()) / (params.maxScience - params.minScience)));
        }
        
        // Cost
        front.sort(Architecture.ArchCostComparator);
        front.get(0).getResult().setCrowdingDistance(1000);
        front.get(front.size()-1).getResult().setCrowdingDistance(1000);
        for (int i = 1; i < nsol - 1; i++) {
            front.get(i).getResult().setCrowdingDistance(
                front.get(i).getResult().getCrowdingDistance() + Math.abs(
                        (front.get(i + 1).getResult().getCost() - front.get(i - 1).getResult().getCost()) / (params.maxCost - params.minCost)));
        }
    }

    public HashMap<Integer, ArrayList<Architecture>> nonDominatedSorting(boolean compute_all_fronts) {
        HashMap<Integer, ArrayList<Architecture>> fronts = new HashMap<>(); //archs in front i
        HashMap<Architecture, ArrayList<Integer>> dominatesList = new HashMap<>(); //indexes of archs that arch dominates
        int[] dominationCounters = new int[currentPopulation.size()]; //number of archs that dominate arch i
        for (int i = 0; i < dominationCounters.length; i++) {
            dominationCounters[i] = 0;
        }
        
        for (int i = 0; i < currentPopulation.size(); i++) {
            Architecture a1 = currentPopulation.get(i);
            Result r1 = a1.getResult();

            for (int j = 0; j < currentPopulation.size(); j++) {
                Architecture a2 = currentPopulation.get(j);
                Result r2 = a2.getResult();
                int r1domr2 = dominates(r1, r2);
                if (r1domr2 == 1) { //if a1 dominates a2
                    ArrayList<Integer> existing = dominatesList.get(a1);
                    if (existing == null) {
                        existing = new ArrayList<>();
                    }
                    existing.add(j); //add j to indexes of archs that arch a1 dominates
                    dominatesList.put(a1, existing);
                }
                else if(r1domr2 == -1) {
                    dominationCounters[i]++; //increment counter of archs that dominate a1
                }
            }

            if (dominationCounters[i] == 0) { //no one dominates arch i
                ArrayList<Architecture> existing = fronts.get(1);
                if (existing == null) {
                    existing = new ArrayList<>();
                }
                existing.add(a1);
                //System.out.println("Arch " + i + " added to Front 1");
                fronts.put(1, existing);//add a1 to first front
            }
        }
        if (!compute_all_fronts) {
            return fronts;
        }
        int i = 1;
        ArrayList<Architecture> nextFront = fronts.get(i);
        while (!nextFront.isEmpty()) {
            nextFront = new ArrayList<>();
            for (int j = 0; j < fronts.get(i).size(); j++) { //iterate over archs of front i
                Architecture a1 = fronts.get(i).get(j); //arch j of front i
                ArrayList<Integer> doms = dominatesList.get(a1); //set of solutions dominated by a1
                if (doms != null) {
                    for (Integer sol: doms) {
                        Architecture a2 = currentPopulation.get(sol);
                        dominationCounters[sol]--; //decrease domination counter of arch a2 since a1 is removed from tradespace
                        if (dominationCounters[sol] <= 0) {
                            nextFront.add(a2);
                            //System.out.println("Arch " + doms.get(k) + " added to Front " + (i+1));
                        }
                    }
                }
            }
            i++;
            if (!nextFront.isEmpty()) {
                fronts.put(i, nextFront);
            }
        }
        return fronts;
    }

    public int dominates(Result r1, Result r2) {
        // Feasibility before fitness
        if (r1.getArch().isFeasibleAssignment() && !r2.getArch().isFeasibleAssignment()) {
            return 1;
        }
        if (!r1.getArch().isFeasibleAssignment() && r2.getArch().isFeasibleAssignment()) {
            return -1;
        }
        if (!r1.getArch().isFeasibleAssignment() && !r2.getArch().isFeasibleAssignment()) {
            if (r1.getArch().getTotalInstruments() < r2.getArch().getTotalInstruments()) {
                return 1;
            }
            else if (r1.getArch().getTotalInstruments() > r2.getArch().getTotalInstruments()) {
                return -1;
            }
            else { //Both are infeasible, and both to teh same degree (i.e., both have the same number of total instruments)
                return 0;
            }
        }
        
        // Both feasible ==> Sorting by fitness
        double x1 = r1.getScience() - r2.getScience();
        double x2 = r1.getCost() - r2.getCost();
        if ((x1 >= 0 && x2 <= 0) && !(x1 == 0 && x2 == 0)) {
            return 1;
        }
        else if((x1 <= 0 && x2 >= 0) && !(x1 == 0 && x2 == 0)) {
            return -1;
        }
        else {
            return 0;
        }
    }

    public void assertArchs(Resource res, ArrayList<Architecture> archs) {
        try {
            Rete r = res.getRete();
            r.reset();
            for (Architecture arch: archs)
                r.assertString(arch.toFactString());
        }
        catch (Exception e) {
            System.out.println("EXC in ArchTradespaceExplorer:assertArchs: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            ArchitectureEvaluator.getInstance().freeSearchResource();
        }
    }

    public ArrayList<Architecture> retrieveArchs(Resource res) {
        ArrayList<Architecture> archs = new ArrayList<>();
        results.clear();
        try {
            Rete r = res.getRete();
            ArrayList<Fact> facts = res.getQueryBuilder().makeQuery("MANIFEST::ARCHITECTURE");
            for (int i = 0; i < facts.size(); i++) {
                Fact f = facts.get(i);
                String bs = f.getSlotValue("bitString").stringValue(r.getGlobalContext());
                int nsat = f.getSlotValue("num-sats-per-plane").intValue(r.getGlobalContext());
                Architecture arch = new Architecture(bs, nsat);
                double science = f.getSlotValue("benefit").floatValue(r.getGlobalContext());
                double cost = f.getSlotValue("lifecycle-cost").floatValue(r.getGlobalContext());
                int pr = f.getSlotValue("pareto-ranking").intValue(r.getGlobalContext());
                Result result = new Result(arch, science, cost, pr);
                arch.setResult(result);
                results.push(result);
                archs.add(arch);
            }
        }
        catch (Exception e) {
            System.out.println("EXC in ArchTradespaceExplorer:retrieveArchs: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            ArchitectureEvaluator.getInstance().freeSearchResource();
        }
        return archs;
    }

    public SearchPerformance getSp() {
        return sp;
    }

    public void setTermCrit(SearchOptions termCrit) {
        this.termCrit = termCrit;
    }
    
}
