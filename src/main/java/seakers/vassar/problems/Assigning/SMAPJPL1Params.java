package seakers.vassar.problems.Assigning;

import seakers.vassar.BaseParams;

public class SMAPJPL1Params extends AssigningParams {

    public SMAPJPL1Params(String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, "SMAP_JPL1", mode, name, runMode);

        // Instruments
        String[] instrumentList = {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
        String[] orbitList = {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};

        super.instrumentList = instrumentList;
        super.orbitList = orbitList;
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new SMAPJPL1Params(super.resourcesPath, super.reqMode, super.name, super.runMode);
    }
}
