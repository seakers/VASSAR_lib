/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar;

/**
 *
 * @author Ana-Dani
 */

import seakers.vassar.architecture.AbstractArchitecture;

import jess.*;

import java.io.Serializable;
import java.util.TreeMap;
import java.util.ArrayList;

public class Result implements Serializable {
    private static final long serialVersionUID = 1L;

    private double science;
    private double cost;
    private ArrayList<ArrayList<ArrayList<Double>>> subobjectiveScores;
    private ArrayList<ArrayList<Double>> objectiveScores;
    private ArrayList<Double> panelScores;
    private FuzzyValue fuzzyScience;
    private FuzzyValue fuzzyCost;
    private AbstractArchitecture arch;
    private TreeMap<String,ArrayList<Fact>> explanations;
    private TreeMap<String,Double> subobjectiveScoresMap;
    private ArrayList<Fact> capabilities;
    private ArrayList<Fact> costFacts;
    private String taskType;

    //Constructors
    public Result(){}

    public Result(AbstractArchitecture arch, double science, double cost) {
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
        taskType = "Fast";
        this.fuzzyScience = null;
        this.fuzzyCost = null;
    }

    public Result(AbstractArchitecture arch,
                  double science,
                  double cost,
                  FuzzyValue fuzzy_science,
                  FuzzyValue fuzzy_cost,
                  ArrayList<ArrayList<ArrayList<Double>>> subobj_scores,
                  ArrayList<ArrayList<Double>> obj_scores,
                  ArrayList<Double> panel_scores,
                  TreeMap<String,Double> subobj_scores_map){

        this.arch = arch;
        this.science = science;
        this.cost = cost;
        this.fuzzyScience = fuzzy_science;
        this.fuzzyCost = fuzzy_cost;
        this.subobjectiveScores = subobj_scores;
        this.objectiveScores = obj_scores;
        this.panelScores = panel_scores;
        this.subobjectiveScoresMap = subobj_scores_map;
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

    public AbstractArchitecture getArch() {
        return arch;
    }
    public void setArch(AbstractArchitecture arch) {
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
        return "Result{" + "science=" + science + ", cost=" + cost + " fuz_sc=" + fs + " fuz_co=" + fc + ", arch=" + arch.toString() + '}';
    }
   
}
