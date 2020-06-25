package seakers.vassar.problems.Assigning;

import seakers.vassar.BaseParams;

public class DSHIELDParams extends AssigningParams {

    public DSHIELDParams(String[] orbitsList, String problemName, String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, problemName, mode, name, runMode);
//        super.orbitList = new String[] {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-DD","SSO-800-SSO-PM"};

        super.instrumentList = new String[]{"VIIRS", "CMIS", "SMAP_ANT", "SMAP_RAD", "SMAP_MWR", "BIOMASS", "CLOUD_MASK"};
        super.orbitList = orbitsList;
        this.adhocRulesClp = this.problemPath + "/clp/smap_rules_test.clp";
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new DSHIELDParams(super.orbitList, this.problemName, super.resourcesPath, super.reqMode, super.name, super.runMode);
    }
}
