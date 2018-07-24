/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

import java.io.Serializable;
import java.util.*;

/**
 *
 * @author Ana-Dani
 */
public class SearchPerformance implements Serializable {
    private Result cheapestMaxBenefitArch;
    private Stack<Result> results;
    private ArrayList<Result> currentParetoFront;
    private double avgParetoDistance;
    private int narch;
    private int narchFront;
    private Float[] benefits;
    private Float[] costs;
    private ArrayList<Result> historyCheapestMaxBenefitArchs;
    private ArrayList<Double> historyAvgParetoDistance;
    private ArrayList<ArrayList<Result>> historyFronts;
    int nits;
    
    //Constructors
    public SearchPerformance() {
        results = null;
        narch = 0;
        narchFront = 0;
        cheapestMaxBenefitArch = null;
        avgParetoDistance = 0.0;
        benefits = null;
        costs = null;
        historyCheapestMaxBenefitArchs = new ArrayList<>();
        historyAvgParetoDistance = new ArrayList<>();
        nits = 0;
        currentParetoFront = new ArrayList<>();
        historyFronts = new ArrayList<>();
    }
    
    //Public methods
    public void updateSearchPerformance(Stack<Result> results, int nits) {
        this.results = results;
        narch = results.size();
        currentParetoFront = computeParetoFront(results);
        narchFront = currentParetoFront.size();
        getBenefits();
        getCosts();
        cheapestMaxBenefitArch = computeCheapestMaxBenefitArch();
        avgParetoDistance = computeAvgParetoDistance();
        historyCheapestMaxBenefitArchs.add(cheapestMaxBenefitArch);
        historyAvgParetoDistance.add(avgParetoDistance);
        historyFronts.add(currentParetoFront);
        this.nits = nits;
    }

    @Override
    public String toString() {
        String str;
        if (cheapestMaxBenefitArch == null)
            str = "SearchPerformance after= " + nits + " its: cheapest max benefit is null";
        else if (avgParetoDistance == Double.NaN)
            str = "SearchPerformance after= " + nits + " its: cheapest max benefit is null";
        else
            str = "SearchPerformance after= " + nits + " its: avgParetoDistance: " + avgParetoDistance +
                " cheapestMaxBenefitArch: " + cheapestMaxBenefitArch.getScience() + " " + cheapestMaxBenefitArch.getCost() + " " + cheapestMaxBenefitArch.toString();
        return str;
    }

    public int compareTo(SearchPerformance other) {
        if (other == null || other.getCheapestMaxBenefitArch() == null) return 1;
        if(cheapestMaxBenefitArch ==null)
            System.out.println("hi");
        if (cheapestMaxBenefitArch.getCost() < other.getCheapestMaxBenefitArch().getCost())  {
            return 1;
        } else if (cheapestMaxBenefitArch.getCost() > other.getCheapestMaxBenefitArch().getCost())  {
            return -1;
        } else return 0;
    }

    public final Float[] getBenefits() {
        benefits = new Float[narchFront];
        for (int i = 0; i< narchFront; i++) {
            benefits[i] = (float)currentParetoFront.get(i).getScience();
        }
        return benefits;
    }

    public final Float[] getCosts() {
        costs = new Float[narchFront];
        for (int i = 0; i< narchFront; i++) {
            costs[i] = (float)currentParetoFront.get(i).getCost();
        }
        return costs;
    }
    
    //Private methods
    private Result computeCheapestMaxBenefitArch() {
        Result res = null;
        double min_cost = 1e10;
        double max_science = 0;
        for (int i = 0; i < narchFront; i++) {
            Result re = currentParetoFront.get(i);
            if (re.getScience() > max_science && re.getCost() < min_cost) {
                min_cost = re.getCost();
                res = re;
            }
        }
        return res;
    }

    private double computeAvgParetoDistance() {
        //sort sciences
        Map<Float, Integer> map = new TreeMap<>();
        for (int i = 0; i < benefits.length; ++i) {
            map.put(benefits[i], i);
        }
        Iterator indices = map.values().iterator();
        //compute gaps between consecutive archs
        Result old = new Result(null, 0.0, 0.0);
        int i = 0;
        double average = 0.0;
        while (indices.hasNext()) {
            Integer index = (Integer)indices.next();
            Result res = currentParetoFront.get(index);
            double distance = res.distance(old);
            average += distance;
            old = res;
            i++;
        }
        //return average
        return average/i;
    }

    private ArrayList<Result> computeParetoFront(Stack<Result> stack) {
        ArrayList<Result> thefront = new ArrayList<>();
        for (int i = 0; i < stack.size(); i++) {
            Result r1 = stack.get(i);
            boolean dominated = false;
            for (int j = 0; j < stack.size(); j++) {
                if (r1.dominates(stack.get(j))==-1) {
                    dominated = true;
                    break;//dominated
                }
            }
            if (!dominated) {
                thefront.add(r1);
            }
        }
        return thefront;
    }
    
    
    //Getters and setters
    public Result getCheapestMaxBenefitArch() {
        return cheapestMaxBenefitArch;
    }
    public Stack<Result> getResults() {
        return results;
    }
    public double getAvgParetoDistance() {
        return avgParetoDistance;
    }
    public int getNarch() {
        return narch;
    }
    public ArrayList<Result> getHistoryCheapestMaxBenefitArchs() {
        return historyCheapestMaxBenefitArchs;
    }
    public void setHistoryCheapestMaxBenefitArchs(ArrayList<Result> historyCheapestMaxBenefitArchs) {
        this.historyCheapestMaxBenefitArchs = historyCheapestMaxBenefitArchs;
    }
    public ArrayList<Double> getHistoryAvgParetoDistance() {
        return historyAvgParetoDistance;
    }
    public void setHistoryAvgParetoDistance(ArrayList<Double> historyAvgParetoDistance) {
        this.historyAvgParetoDistance = historyAvgParetoDistance;
    }
    public ArrayList<Result> getCurrentParetoFront() {
        return currentParetoFront;
    }
    public void setCurrentParetoFront(ArrayList<Result> currentParetoFront) {
        this.currentParetoFront = currentParetoFront;
    }
    public ArrayList<ArrayList<Result>> getHistoryFronts() {
        return historyFronts;
    }
    public void setHistoryFronts(ArrayList<ArrayList<Result>> historyFronts) {
        this.historyFronts = historyFronts;
    }
   
}
