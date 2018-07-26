package rbsa.eoss.problems.SMAP;

import rbsa.eoss.local.BaseParams;

import java.util.HashMap;

public class Params extends BaseParams {

    // Instruments
    private String[] instrumentList = {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
    private String[] orbitList = {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
    private int numInstr;
    private int numOrbits;
    private HashMap<String, Integer> instrumentIndexes;
    private HashMap<String, Integer> orbitIndexes;
    private int[] numSatellites = {1};
    public int MAX_TOTAL_INSTR;

    public Params(String path, String mode, String name, String runMode, String search_clp){
        super(path, mode, name, runMode, search_clp);
        init();
    }

    private void init(){
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
