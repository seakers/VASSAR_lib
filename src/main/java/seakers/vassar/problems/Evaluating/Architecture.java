package seakers.vassar.problems.Evaluating;

import seakers.vassar.architecture.AbstractArchitecture;

public class Architecture extends AbstractArchitecture {
    private String[] instrumentList;
    private String orbit;

    public Architecture(String[] instrumentList, String orbit) {
        this.instrumentList = instrumentList;
        this.orbit = orbit;
    }

    public String[] getInstrumentList() { return instrumentList; }
    public String getOrbit() { return orbit; }

    public void setInstrumentList(String[] instrumentList) {
        this.instrumentList = instrumentList;
    }
    public void setOrbit(String orbit) {
        this.orbit = orbit;
    }

    @Override
    public boolean isFeasibleAssignment() {
        return true;
    }

    @Override
    public String toString(String delimiter) {
        return null;
    }
}
