package seakers.vassar.problems.Evaluating;

import seakers.vassar.BaseParams;

import java.util.HashMap;

public class CommonParams extends BaseParams {

    protected String[] instrumentList;
    protected String[] orbitList;
    protected int numInstr;
    protected int numOrbits;
    protected HashMap<String, Integer> instrumentIndexes;
    protected HashMap<String, Integer> orbitIndexes;

    public CommonParams(String[] orbitsList, String problemName, String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, problemName, mode, name, runMode);
        String[] instruments = new String[]{"SMAP_RAD","SMAP_MWR"};
        this.instrumentList = instruments;
        this.orbitList = orbitsList;
        this.numInstr = instrumentList.length;
        this.numOrbits = orbitList.length;
        this.execOrder = "new";
        instrumentIndexes = new HashMap<>();
        orbitIndexes = new HashMap<>();

        for (int i = 0; i < numInstr; i++) {
            instrumentIndexes.put(instrumentList[i], i);
        }
        for (int i = 0; i < numOrbits; i++) {
            orbitIndexes.put(orbitList[i], i);
        }
        this.adhocRulesClp = this.problemPath + "/clp/sar_rules.clp";
//        this.adhocRulesClp = this.problemPath + "/clp/smap_rules_test.clp";
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new CommonParams(this.orbitList, this.problemName, super.resourcesPath, super.reqMode, super.name, super.runMode);
    }

    public void setInstrumentList(String[] instrumentList){
        this.instrumentList = instrumentList;
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
}
