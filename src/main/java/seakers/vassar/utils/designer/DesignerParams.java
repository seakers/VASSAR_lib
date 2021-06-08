package seakers.vassar.utils.designer;

import seakers.vassar.BaseParams;
import seakers.vassar.problems.Assigning.AssigningParams;

public class DesignerParams extends AssigningParams {

    public DesignerParams(String[] orbitsList, String problemName, String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, problemName, mode, name, runMode);

        String[] instruments = new String[]{"CYGNSS", "BIOMASS", "SMAP_ANT",
                "SMAP_RAD", "SMAP_MWR", "BIOMASS",
                "P-band_SAR", "P-band_ANT", "L-band_SAR",
                "L-band_ANT", "Pleiades", "PRISMA",
                "TROPICS", "Aquarius", "CALIPSO",
                "SENTINEL_1", "SENTINEL_2", "SENTINEL_5P",
                "RAINCUBE", "SAR_ANT", "SAR_INS"};
//        String[] instruments = new String[]{"CYGNSS", "BIOMASS", "SMAP_ANT", "SMAP_RAD", "SMAP_MWR", "BIOMASS",
//                "P-band_SAR", "P-band_ANT", "L-band_SAR", "L-band_ANT"};

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
        return new DesignerParams(super.orbitList, this.problemName, super.resourcesPath, super.reqMode, super.name, super.runMode);
    }
}
