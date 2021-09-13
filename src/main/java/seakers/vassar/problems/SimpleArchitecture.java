package seakers.vassar.problems;

import seakers.vassar.architecture.AbstractArchitecture;

import java.util.ArrayList;

public class SimpleArchitecture extends AbstractArchitecture {
    private ArrayList<OrbitInstrumentObject> satelliteList;
    private String name;
    private int repeatCycle;
    private double percentCoverage;
    private double avgRevisit;
    private double maxRevisit;
    private double avgRevisitP;
    private double maxRevisitP;
    private double avgRevisitL;
    private double maxRevisitL;
    private double cost;
    private int numSatsPerPlane;
    private int numPlanes;


    public SimpleArchitecture(ArrayList<OrbitInstrumentObject> satelliteList) {
        this.satelliteList = satelliteList;
    }

    public ArrayList<OrbitInstrumentObject> getSatelliteList() { return satelliteList; }
    public int getRepeatCycle() { return repeatCycle; }
    public double getAvgRevisit() { return avgRevisit; }
    public double getMaxRevisit() { return maxRevisit; }
    public double getAvgRevisitP() { return avgRevisitP; }
    public double getMaxRevisitP() { return maxRevisitP; }
    public double getAvgRevisitL() { return avgRevisitL; }
    public double getMaxRevisitL() { return maxRevisitL; }
    public double getPercentCoverage() { return percentCoverage; }
    public double getCost() { return cost; }
    public String getName() { return name; }
    public int getNumSatsPerPlane() { return numSatsPerPlane; }
    public int getNumPlanes() { return numPlanes; }

    public void setRepeatCycle(int repeatCycle) {
        this.repeatCycle = repeatCycle;
    }

    public void setName(String name) {
        this.name = name;
    }
    public void setCoverage(ArrayList<Double> coverage) {
        this.avgRevisit = coverage.get(0);
        this.maxRevisit = coverage.get(1);
        this.avgRevisitP = coverage.get(2);
        this.maxRevisitP = coverage.get(3);
        this.avgRevisitL = coverage.get(4);
        this.maxRevisitL = coverage.get(5);
        this.percentCoverage = coverage.get(6);
    }
    public void setCost(double cost) {
        this.cost = cost;
    }
    public void setNumSatsPerPlane (int satsPerPlane) { this.numSatsPerPlane = satsPerPlane; }
    public void setNumPlanes (int numPlanes) { this.numPlanes = numPlanes; }

    @Override
    public boolean isFeasibleAssignment() {
        return false;
    }

    @Override
    public String toString(String delimiter) {
        String response = "";
        response = response + "Instrument(s) "+String.join(", ",satelliteList.get(0).getInstrumentList())+" in orbit "+satelliteList.get(0).getOrbit();
        if(satelliteList.size() > 1) {
            for(int i = 1; i < satelliteList.size(); i++) {
                response = response + " & "+ "instrument(s) "+String.join(",",satelliteList.get(i).getInstrumentList())+" in orbit "+satelliteList.get(i).getOrbit();
            }
        }
        response = response + ": ";
        return response;
    }
}

