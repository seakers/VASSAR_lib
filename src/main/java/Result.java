/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

/**
 *
 * @author Ana-Dani
 */
import java.util.ArrayList;
import jess.*;
import rbsa.eoss.local.Params;

import java.util.TreeMap;
public class Result implements java.io.Serializable {
    private double science;
    private double cost;
    private double normScience;
    private double normCost;
    private ArrayList<ArrayList<ArrayList<Double>>> subobjectiveScores;
    private ArrayList<ArrayList<Double>> objectiveScores;
    private ArrayList<Double> panelScores;
    private FuzzyValue fuzzyScience;
    private FuzzyValue fuzzyCost;
    private Architecture arch;
    private TreeMap<String,ArrayList<Fact>> explanations;
    private TreeMap<String,Double> subobjectiveScoresMap;
    private ArrayList<Fact> capabilities;
    private ArrayList<Fact> costFacts;
    private int paretoRanking;
    private double crowdingDistance;
    private double utility;
    private String taskType;

    //Constructors
    public Result() { }

    public Result(Architecture arch, double science, double cost, FuzzyValue fs, FuzzyValue fc,
                  ArrayList<ArrayList<ArrayList<Double>>> subobjectiveScores,
                  ArrayList<ArrayList<Double>> objectiveScores, ArrayList<Double> panelScores,
                  TreeMap<String, Double> subobjectiveScoresMap) {
        Params params = Params.getInstance();
        this.science = science;
        this.cost = cost;
        this.subobjectiveScores = subobjectiveScores;
        this.subobjectiveScoresMap = subobjectiveScoresMap;
        this.objectiveScores = objectiveScores;
        this.panelScores = panelScores;
        this.arch = arch;
        explanations = null;
        capabilities = null;
        costFacts = null;
        paretoRanking = -1;
        crowdingDistance = 0.0;
        utility = -1.0;
        this.normScience = (science - params.minScience)/(params.maxScience - params.minScience);
        this.normCost = (cost - params.minCost)/(params.maxCost - params.minCost);
        taskType = "Fast";
        this.fuzzyScience = fs;
        this.fuzzyCost = fc;
    }

    public Result(Architecture arch, double science, double cost, int pr) {
        Params params = Params.getInstance();
        this.science = science;
        this.cost = cost;
        this.subobjectiveScores = null;
        this.subobjectiveScoresMap = null;
        this.objectiveScores = null;
        this.panelScores = null;
        this.arch = arch;
        explanations = null;
        capabilities = null;
        costFacts = null;
        paretoRanking = pr;
        crowdingDistance = 0.0;
        utility = -1.0;
        this.normScience = (science - params.minScience)/(params.maxScience-params.minScience);
        this.normCost = (cost - params.minCost)/(params.maxCost - params.minCost);
        taskType = "Fast";
        this.fuzzyScience = null;
        this.fuzzyCost = null;
    }

    public Result(Architecture arch, double science, double cost) {
        Params params = Params.getInstance();
        this.science = science;
        this.cost = cost;
        this.subobjectiveScores = null;
        this.subobjectiveScoresMap = null;
        this.objectiveScores = null;
        this.panelScores = null;
        this.arch = arch;
        explanations = null;
        capabilities = null;
        costFacts = null;
        paretoRanking = -1;
        crowdingDistance = 0.0;
        utility = -1.0;
        this.normScience = (science - params.minScience)/(params.maxScience-params.minScience);
        this.normCost = (cost - params.minCost)/(params.maxCost - params.minCost);
        taskType = "Fast";
        this.fuzzyScience = null;
        this.fuzzyCost = null;
    }
    
    //Getters and Setters
    public ArrayList<Fact> getCapabilities() {
        return capabilities;
    }
    public void setCapabilities(ArrayList<Fact> capabilities) {
        this.capabilities = capabilities;
    }

    public TreeMap<String,ArrayList<Fact>> getExplanations() {
        return explanations;
    }
    public void setExplanations(TreeMap<String,ArrayList<Fact>> explanations) {
        this.explanations = explanations;
    }

    public String getTaskType() {
        return taskType;
    }
    public void setTaskType(String taskType) {
        this.taskType = taskType;
    }

    public Architecture getArch() {
        return arch;
    }
    public void setArch(Architecture arch) {
        this.arch = arch;
    }

    public double getScience() {
        return science;
    }
    public void setScience(double science) {
        this.science = science;
    }

    public double getCost() {
        return cost;
    }
    public void setCost(double cost) {
        this.cost = cost;
    }

    public double getNormScience() {
        return normScience;
    }
    public double getNormCost() {
        return normCost;
    }

    public int getParetoRanking() {
        return paretoRanking;
    }
    public void setParetoRanking(int paretoRanking) {
        this.paretoRanking = paretoRanking;
    }

    public double getCrowdingDistance() {
        return crowdingDistance;
    }
    public void setCrowdingDistance(double crowdingDistance) {
        this.crowdingDistance = crowdingDistance;
    }

    public double getUtility() {
        return utility;
    }
    public void setUtility(double utility) {
        this.utility = utility;
    }

    public ArrayList<ArrayList<ArrayList<Double>>> getSubobjectiveScores() {
        return subobjectiveScores;
    }
    public ArrayList<ArrayList<Double>> getObjectiveScores() {
        return objectiveScores;
    }
    public TreeMap<String, Double> getSubobjectiveScoresMap() {
        return subobjectiveScoresMap;
    }
    public ArrayList<Double> getPanelScores() {
        return panelScores;
    }

    public ArrayList<Fact> getCostFacts() {
        return costFacts;
    }
    public void setCostFacts(ArrayList<Fact> cost_facts) {
        this.costFacts = cost_facts;
    }

    public FuzzyValue getFuzzyScience() {
        return fuzzyScience;
    }
    public FuzzyValue getFuzzyCost() {
        return fuzzyCost;
    }

    public void setFuzzyScience(FuzzyValue fuzzyScience) {
        this.fuzzyScience = fuzzyScience;
    }
    public void setFuzzyCost(FuzzyValue fuzzyCost) {
        this.fuzzyCost = fuzzyCost;
    }

    //Public methods
    public int dominates(Result r2) {
        if (this.getArch().isFeasibleAssignment() && !r2.getArch().isFeasibleAssignment())
            return 1;
        if (!this.getArch().isFeasibleAssignment() && r2.getArch().isFeasibleAssignment())
            return -1;
        if (!this.getArch().isFeasibleAssignment() && !r2.getArch().isFeasibleAssignment())
            if(this.getArch().getTotalInstruments() < r2.getArch().getTotalInstruments())
                return 1;
            else if(this.getArch().getTotalInstruments() > r2.getArch().getTotalInstruments()) 
                return -1;
            else //Both are infeasible, and both to teh same degree (i.e., both have the same number of total instruments)
                return 0;
        double x1 = this.getScience() - r2.getScience();
        double x2 = this.getCost() - r2.getCost();
        if((x1>=0 && x2<=0) && !(x1==0 && x2==0)) 
            return 1;
        else if((x1<=0 && x2>=0) && !(x1==0 && x2==0))
            return -1;
        else return 0;
    }

    public static double SumDollar(ArrayList<Double> a) {
        double res = 0.0;
        for (Double num: a) {
            res += num;
        }
        return res;
    }

    public static ArrayList<Double> dotMult(ArrayList<Double> a, ArrayList<Double> b) throws Exception {
        int n1 = a.size();
        int n2 = b.size();
        if (n1 != n2) {
            throw new Exception("dotSum: Arrays of different sizes");
        }
        ArrayList<Double> c = new ArrayList<>(n1);
        for (int i = 0; i < n1; i++) {
            Double t = a.get(i) * b.get(i);
            c.add(t);
        }
        return c;
    }

    public static double sumProduct(ArrayList<Double> a, ArrayList<Double> b) throws Exception {
        return SumDollar(dotMult(a, b));
    }

    public double distance(Result other) {
        return Math.sqrt(Math.pow(normScience-other.getNormScience(),2) + Math.pow(normCost-other.getNormCost(),2));
    }

    @Override
    public String toString() {
        String fs;
        if (fuzzyScience == null)
            fs = "null";
        else
            fs = fuzzyScience.toString();
        String fc;
        if (fuzzyCost == null)
            fc = "null";
        else
            fc = fuzzyCost.toString();
        return "Result{" + "science=" + science + ", cost=" + cost + " fuz_sc=" + fs + " fuz_co=" + fc + ", arch=" + arch.toString() + ", paretoRanking=" + paretoRanking + '}';
    }
   
}
