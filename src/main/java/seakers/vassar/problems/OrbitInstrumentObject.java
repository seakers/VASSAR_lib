package seakers.vassar.problems;

public class OrbitInstrumentObject {
    private String[] instrumentList;
    private String orbit;
    private double fov;

    public OrbitInstrumentObject(String[] instrumentList, String orbit) {
        this.instrumentList = instrumentList;
        this.orbit = orbit;
    }
    public OrbitInstrumentObject(String[] instrumentList, String orbit, double fov) {
        this.instrumentList = instrumentList;
        this.orbit = orbit;
        this.fov = fov;
    }

    public String[] getInstrumentList() { return instrumentList; }
    public String getOrbit() { return orbit; }
    public double getFov() { return fov; }

    public void setInstrumentList(String[] instrumentList) {
        this.instrumentList = instrumentList;
    }
    public void setOrbit(String orbit) {
        this.orbit = orbit;
    }
}
