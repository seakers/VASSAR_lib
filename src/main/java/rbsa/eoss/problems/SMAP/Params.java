package rbsa.eoss.problems.SMAP;

import rbsa.eoss.local.BaseParams;

import java.util.HashMap;

public class Params extends BaseParams {

    // Instruments
    public String[] instrumentList = {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
    public int numInstr;
    public String[] orbitList = {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
    public int numOrbits;
    public HashMap<String, Integer> instrumentIndexes = new HashMap<>();
    public HashMap<String, Integer> orbitIndexes = new HashMap<>();
    public int[] numSatellites = {1};
    public int MAX_TOTAL_INSTR;

    public Params(String path, String mode, String name, String runMode, String search_clp){
        super(path, mode, name, runMode, search_clp);

        // Instruments & Orbits
        numInstr = instrumentList.length;
        numOrbits = orbitList.length;

        MAX_TOTAL_INSTR = numOrbits * numInstr;

        for (int i = 0; i < numInstr; i++) {
            instrumentIndexes.put(instrumentList[i], i);
        }
        for (int i = 0; i < numOrbits; i++) {
            orbitIndexes.put(orbitList[i], i);
        }
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
}
