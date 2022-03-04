package seakers.vassar.problems.Assigning;

import seakers.vassar.BaseParams;

public class DSHIELDParams extends AssigningParams {

    public DSHIELDParams(String[] orbitsList, String problemName, String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, problemName, mode, name, runMode);
//        super.orbitList = new String[] {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-DD","SSO-800-SSO-PM"};
//        String[] instruments = new String[]{"VIIRS", "CMIS", "SMAP_ANT", "SMAP_RAD", "SMAP_MWR", "BIOMASS", "CLOUD_MASK"};
        String[] instruments = new String[]{"SAR_1", "SAR_2", "SAR_3"};
//        String[] instruments = new String[]{"VIIRS", "CMIS", "SMAP_ANT", "SMAP_RAD", "SMAP_MWR", "BIOMASS", "SAR_1", "SAR_2", "SAR_3"};
        int[] numsats = new int[]{4};
        super.numSatellites = numsats;
        super.instrumentList = instruments;
        super.orbitList = orbitsList;
        this.adhocRulesClp = this.problemPath + "/clp/sar_rules.clp";
//        this.adhocRulesClp = this.problemPath + "/clp/smap_rules_test.clp";
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new DSHIELDParams(super.orbitList, this.problemName, super.resourcesPath, super.reqMode, super.name, super.runMode);
    }

    public double getAntennaMass() {
        return 0.0;
    }

    public double getElectronicsMass() {
        return 0.0;
    }

    public double getDataRate() { return 0.0; }
}
