package seakers.vassar.problems.PartitioningAndAssigning;

import seakers.vassar.local.BaseParams;

import java.util.HashMap;

public class PartitioningAndAssigningParams extends BaseParams {

    // Instruments
    protected String[] instrumentList;
    protected String[] orbitList;
    protected int numInstr;
    protected int numOrbits;
    protected HashMap<String, Integer> instrumentIndexes;
    protected HashMap<String, Integer> orbitIndexes;
    protected int[] numSatellites = {1};
    public int MAX_TOTAL_INSTR;

    public PartitioningAndAssigningParams(String resourcesPath, String problemName, String mode, String name, String runMode, String search_clp){
        super(resourcesPath, problemName, mode, name, runMode, search_clp);
    }

    protected void init(){
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
        init();
    }

    public void setOrbitList(String[] orbitList){
        this.orbitList = orbitList;
        init();
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