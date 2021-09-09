package seakers.vassarheur.problems.PartitioningAndAssigning;

import seakers.vassarheur.BaseParams;

public class Decadal2017AerosolsParams extends PartitioningAndAssigningParams {

    public Decadal2017AerosolsParams(String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, "Decadal2017Aerosols", mode, name, runMode);

        // Instruments
        String[] instrumentList = {"ACE_CPR","ACE_ORCA","ACE_POL","ACE_LID","CLAR_TIR","CLAR_VNIR"};
        //String[] instrumentList = {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
        String[] orbitList = {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
        super.instrumentList = instrumentList;
        super.orbitList = orbitList;
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new Decadal2017AerosolsParams(super.resourcesPath, super.reqMode, super.name, super.runMode);
    }
}
