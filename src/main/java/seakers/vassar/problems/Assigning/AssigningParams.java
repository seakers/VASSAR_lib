package seakers.vassar.problems.Assigning;

import seakers.vassar.BaseParams;

import java.util.HashMap;

public abstract class AssigningParams extends BaseParams {

    // Instruments
    protected String[] instrumentList;
    protected String[] orbitList;
    protected int numInstr;
    protected int numOrbits;
    protected HashMap<String, Integer> instrumentIndexes;
    protected HashMap<String, Integer> orbitIndexes;
    protected int[] numSatellites = {1};
    public int MAX_TOTAL_INSTR;

    public AssigningParams(String resourcesPath, String problemName, String mode, String name, String runMode){
        super(resourcesPath, problemName, mode, name, runMode);
    }

    @Override
    public void init(){

        super.init();

        // Instruments & Orbits
        numInstr = instrumentList.length;
        numOrbits = orbitList.length;

        MAX_TOTAL_INSTR = numOrbits * numInstr;

        instrumentIndexes = new HashMap<>();
        orbitIndexes = new HashMap<>();

        for (int i = 0; i < numInstr; i++) {
            instrumentIndexes.put(instrumentList[i], i);
        }
        for (int i = 0; i < numOrbits; i++) {
            orbitIndexes.put(orbitList[i], i);
        }
    }

    public void setInstrumentList(String[] instrumentList){
        this.instrumentList = instrumentList;
        this.init();
    }

    public void setOrbitList(String[] orbitList){
        this.orbitList = orbitList;
        this.init();
    }

    public String[] getInstrumentList(){
        return this.instrumentList;
    }

    public String[] getOrbitList(){
        return this.orbitList;
    }

    public int getNumInstr(){
        return this.numInstr;
    }

    public int getNumOrbits(){
        return this.numOrbits;
    }

    public HashMap<String, Integer> getOrbitIndexes() {
        return orbitIndexes;
    }

    public HashMap<String, Integer> getInstrumentIndexes() {
        return instrumentIndexes;
    }

    public int[] getNumSatellites(){
        return this.numSatellites;
    }

}
