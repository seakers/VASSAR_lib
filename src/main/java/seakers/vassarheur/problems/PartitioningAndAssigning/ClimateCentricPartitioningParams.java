package seakers.vassarheur.problems.PartitioningAndAssigning;

import seakers.vassarheur.BaseParams;

public class ClimateCentricPartitioningParams extends PartitioningAndAssigningParams {

    public ClimateCentricPartitioningParams(String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, "ClimateCentric", mode, name, runMode);

        // Instruments
        String[] instrumentList = {"ACE_ORCA", "ACE_POL", "ACE_LID", "CLAR_ERB", "ACE_CPR", "DESD_SAR",
                "DESD_LID", "GACM_VIS", "GACM_SWIR", "HYSP_TIR", "POSTEPS_IRS", "CNES_KaRIN"};
        //String[] instrumentList = {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
        //String[] instrumentList = {"BIOMASS"};
        String[] orbitList = {"LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-DD"};

        super.instrumentList = instrumentList;
        super.orbitList = orbitList;
        this.adhocRulesClp = this.problemPath + "/clp/climate_centric_rules.clp";
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new ClimateCentricPartitioningParams(super.resourcesPath, super.reqMode, super.name, super.runMode);
    }



}
