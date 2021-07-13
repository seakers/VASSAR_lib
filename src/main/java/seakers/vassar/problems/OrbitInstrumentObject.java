package seakers.vassar.problems;

public class OrbitInstrumentObject {
    private String[] instrumentList;
    private String orbit;

    public OrbitInstrumentObject(String[] instrumentList, String orbit) {
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
}
