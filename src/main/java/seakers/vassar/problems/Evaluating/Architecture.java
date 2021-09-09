package seakers.vassar.problems.Evaluating;

import seakers.vassar.architecture.AbstractArchitecture;

import java.util.Map;

public class Architecture extends AbstractArchitecture {
    private String[] instrumentList;
    private String orbit;
    private Map missionFacts;

    public Architecture(String[] instrumentList, String orbit) {
        this.instrumentList = instrumentList;
        this.orbit = orbit;
    }
    public Architecture(String[] instrumentList, String orbit, Map missionFacts) {
        this.instrumentList = instrumentList;
        this.orbit = orbit;
        this.missionFacts = missionFacts;
    }

    public String[] getInstrumentList() { return instrumentList; }
    public String getOrbit() { return orbit; }
    public Map getMissionFacts() { return missionFacts; }

    public void setInstrumentList(String[] instrumentList) {
        this.instrumentList = instrumentList;
    }
    public void setOrbit(String orbit) {
        this.orbit = orbit;
    }
    public void setMissionFacts(Map missionFacts) { this.missionFacts = missionFacts; }

    @Override
    public boolean isFeasibleAssignment() {
        return true;
    }

    @Override
    public String toString(String delimiter) {
        return null;
    }
}
