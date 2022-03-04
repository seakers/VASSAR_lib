package seakers.vassar.problems;

import seakers.vassar.BaseParams;

import java.util.HashMap;

public class SimpleParams extends BaseParams {

    // Instruments
    protected String[] instrumentList;
    protected String[] orbitList;
    protected int numInstr;
    protected int numOrbits;
    protected HashMap<String, Integer> instrumentIndexes;
    protected HashMap<String, Integer> orbitIndexes;
    protected int[] numSatellites = {1};
    public int MAX_TOTAL_INSTR;
    protected double antennaMass;
    protected double electronicsMass;
    protected double dataRate;

    public SimpleParams(String[] orbitList, String problemName, String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, problemName, mode, name, runMode);

        // Uncomment for D-SHIELD
        this.instrumentList = new String[]{"CustomLANT","CustomLSAR"};
        // Uncomment for SMAP problem
        //this.instrumentList = new String[]{"VIIRS","CMIS","BIOMASS","SMAP_RAD","SMAP_MWR"};
        this.orbitList = orbitList;
        this.adhocRulesClp = this.problemPath + "/clp/sar_rules.clp";
        //this.adhocRulesClp = this.problemPath + "/clp/smap_rules_test.clp";
        this.numInstr = instrumentList.length;
        this.numOrbits = orbitList.length;
        instrumentIndexes = new HashMap<>();
        orbitIndexes = new HashMap<>();

        for (int i = 0; i < numInstr; i++) {
            instrumentIndexes.put(instrumentList[i], i);
        }
        for (int i = 0; i < numOrbits; i++) {
            orbitIndexes.put(orbitList[i], i);
        }
        super.init();
    }

    public SimpleParams(String[] orbitList, String problemName, String resourcesPath, String mode, String name, String runMode, double antennaMass, double electronicsMass, double dataRate){
        super(resourcesPath, problemName, mode, name, runMode);

        // Uncomment for D-SHIELD
        this.instrumentList = new String[]{"CustomLANT","CustomLSAR"};
        // Uncomment for SMAP problem
        //this.instrumentList = new String[]{"VIIRS","CMIS","BIOMASS","SMAP_RAD","SMAP_MWR"};
        this.orbitList = orbitList;
        this.adhocRulesClp = this.problemPath + "/clp/sar_rules.clp";
        //this.adhocRulesClp = this.problemPath + "/clp/smap_rules_test.clp";
        this.numInstr = instrumentList.length;
        this.numOrbits = orbitList.length;
        instrumentIndexes = new HashMap<>();
        orbitIndexes = new HashMap<>();

        for (int i = 0; i < numInstr; i++) {
            instrumentIndexes.put(instrumentList[i], i);
        }
        for (int i = 0; i < numOrbits; i++) {
            orbitIndexes.put(orbitList[i], i);
        }
        this.antennaMass = antennaMass;
        this.electronicsMass = electronicsMass;
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new SimpleParams(this.orbitList, this.problemName, super.resourcesPath, super.reqMode, super.name, super.runMode, this.antennaMass, this.electronicsMass, this.dataRate);
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
    public double getAntennaMass(){
        return this.antennaMass;
    }
    public double getElectronicsMass(){
        return this.electronicsMass;
    }
    public double getDataRate(){
        return this.dataRate;
    }
}
