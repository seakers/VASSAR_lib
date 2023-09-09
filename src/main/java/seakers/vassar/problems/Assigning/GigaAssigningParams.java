package seakers.vassar.problems.Assigning;

import seakers.orekit.util.OrekitConfig;
import seakers.vassar.BaseParams;

import java.io.File;

public class GigaAssigningParams extends AssigningParams {

    public int orekit_threads;

    public GigaAssigningParams(String resourcesPath, String mode, String name, String runMode, int orekit_threads){
        super(resourcesPath, "GigaProblem", mode, name, runMode);
        this.orekit_threads = orekit_threads;

        // Instruments
        String[] instrumentList = {"ACE_CPR", "ACE_ORCA", "ACE_POL", "ACE_LID", "ASC_LID", "ASC_GCR", "ASC_IRR", "CLAR_TIR", "CLAR_VNIR", "CLAR_GPS", "DESD_SAR", "DESD_LID", "GACM_SWIR", "GACM_MWSP", "GACM_VIS", "GACM_DIAL", "GEO_STEER", "GEO_WAIS", "GEO_GCR", "GPS", "GRAC_RANG", "HYSP_TIR", "HYSP_VIS", "ICE_LID", "LIST_LID", "PATH_GEOSTAR", "SCLP_SAR", "SCLP_MWR", "SMAP_RAD", "SMAP_MWR", "SWOT_GPS", "SWOT_KaRIN", "SWOT_RAD", "SWOT_MWR", "XOV_SAR", "XOV_RAD", "XOV_MWR", "3D_CLID", "3D_NCLID", "CLOUD_MASK"};

        // String[] orbitList = {"GEO-36000-equat-NA", "LEO-275-polar-NA", "LEO-275-equat-NA", "LEO-300-equat-NA", "LEO-300-polar-NA", "LEO-320-equat-NA", "LEO-320-polar-NA", "LEO-340-equat-NA", "LEO-340-polar-NA", "LEO-360-equat-NA", "LEO-360-polar-NA", "LEO-380-equat-NA", "LEO-380-polar-NA", "LEO-400-equat-NA", "LEO-400-polar-NA", "SSO-400-SSO-AM", "SSO-400-SSO-DD", "SSO-400-SSO-PM", "SSO-400-SSO-noon", "LEO-420-equat-NA", "LEO-420-polar-NA", "SSO-420-SSO-AM", "SSO-420-SSO-DD", "SSO-420-SSO-PM", "SSO-420-SSO-noon", "LEO-440-equat-NA", "LEO-440-polar-NA", "SSO-440-SSO-AM", "SSO-440-SSO-DD", "SSO-440-SSO-PM", "SSO-440-SSO-noon", "LEO-460-equat-NA", "LEO-460-polar-NA", "SSO-460-SSO-AM", "SSO-460-SSO-DD", "SSO-460-SSO-PM", "SSO-460-SSO-noon", "LEO-480-equat-NA", "LEO-480-polar-NA", "SSO-480-SSO-AM", "SSO-480-SSO-DD", "SSO-480-SSO-PM", "SSO-480-SSO-noon", "LEO-500-equat-NA", "LEO-500-polar-NA", "SSO-500-SSO-AM", "SSO-500-SSO-DD", "SSO-500-SSO-PM", "SSO-500-SSO-noon", "LEO-520-equat-NA", "LEO-520-polar-NA", "SSO-520-SSO-AM", "SSO-520-SSO-DD", "SSO-520-SSO-PM", "SSO-520-SSO-noon", "LEO-540-equat-NA", "LEO-540-polar-NA", "SSO-540-SSO-AM", "SSO-540-SSO-DD", "SSO-540-SSO-PM", "SSO-540-SSO-noon", "LEO-560-equat-NA", "LEO-560-polar-NA", "SSO-560-SSO-AM", "SSO-560-SSO-DD", "SSO-560-SSO-PM", "SSO-560-SSO-noon", "LEO-580-equat-NA", "LEO-580-polar-NA", "SSO-580-SSO-AM", "SSO-580-SSO-DD", "SSO-580-SSO-PM", "SSO-580-SSO-noon", "LEO-600-equat-NA", "LEO-600-near-polar-NA", "LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-600-SSO-PM", "SSO-600-SSO-noon", "LEO-620-near-polar-NA", "LEO-620-polar-NA", "SSO-620-SSO-AM", "SSO-620-SSO-DD", "SSO-620-SSO-PM", "SSO-620-SSO-noon", "LEO-640-near-polar-NA", "LEO-640-polar-NA", "SSO-640-SSO-AM", "SSO-640-SSO-DD", "SSO-640-SSO-PM", "SSO-640-SSO-noon", "LEO-660-near-polar-NA", "LEO-660-polar-NA", "SSO-660-SSO-AM", "SSO-660-SSO-DD", "SSO-660-SSO-PM", "SSO-660-SSO-noon", "LEO-680-near-polar-NA", "LEO-680-polar-NA", "SSO-680-SSO-AM", "SSO-680-SSO-DD", "SSO-680-SSO-PM", "SSO-680-SSO-noon", "LEO-700-near-polar-NA", "LEO-700-polar-NA", "SSO-700-SSO-AM", "SSO-700-SSO-DD", "SSO-700-SSO-PM", "SSO-700-SSO-noon", "LEO-720-near-polar-NA", "LEO-720-polar-NA", "SSO-720-SSO-AM", "SSO-720-SSO-DD", "SSO-720-SSO-PM", "SSO-720-SSO-noon", "LEO-740-near-polar-NA", "LEO-740-polar-NA", "SSO-740-SSO-AM", "SSO-740-SSO-DD", "SSO-740-SSO-PM", "SSO-740-SSO-noon", "LEO-760-near-polar-NA", "LEO-760-polar-NA", "SSO-760-SSO-AM", "SSO-760-SSO-DD", "SSO-760-SSO-PM", "SSO-760-SSO-noon", "LEO-780-near-polar-NA", "LEO-780-polar-NA", "SSO-780-SSO-AM", "SSO-780-SSO-DD", "SSO-780-SSO-PM", "SSO-780-SSO-noon", "LEO-800-near-polar-NA", "LEO-800-polar-NA", "SSO-800-SSO-AM", "SSO-800-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-noon", "LEO-820-near-polar-NA", "SSO-820-SSO-AM", "LEO-840-near-polar-NA", "SSO-840-SSO-AM", "LEO-860-near-polar-NA", "SSO-860-SSO-AM", "LEO-880-near-polar-NA", "SSO-880-SSO-AM", "LEO-900-near-polar-NA", "SSO-900-SSO-AM", "LEO-920-near-polar-NA", "SSO-920-SSO-AM", "LEO-940-near-polar-NA", "SSO-940-SSO-AM", "LEO-960-near-polar-NA", "SSO-960-SSO-AM", "LEO-980-near-polar-NA", "SSO-980-SSO-AM", "LEO-1000-near-polar-NA", "SSO-1000-SSO-AM", "LEO-1020-near-polar-NA", "LEO-1040-near-polar-NA", "LEO-1060-near-polar-NA", "LEO-1080-near-polar-NA", "LEO-1100-near-polar-NA", "LEO-1120-near-polar-NA", "LEO-1140-near-polar-NA", "LEO-1160-near-polar-NA", "LEO-1180-near-polar-NA", "LEO-1200-near-polar-NA", "LEO-1220-near-polar-NA", "LEO-1240-near-polar-NA", "LEO-1260-near-polar-NA", "LEO-1280-near-polar-NA", "LEO-1300-near-polar-NA"};
        String[] orbitList = {"GEO-36000-equat-NA", "LEO-275-polar-NA", "LEO-275-equat-NA", "LEO-300-equat-NA", "LEO-300-polar-NA", "LEO-320-equat-NA", "LEO-320-polar-NA", "LEO-340-equat-NA", "LEO-340-polar-NA", "LEO-360-equat-NA", "LEO-360-polar-NA", "LEO-380-equat-NA", "LEO-380-polar-NA", "LEO-400-equat-NA", "LEO-400-polar-NA", "SSO-400-SSO-AM", "SSO-400-SSO-DD", "SSO-400-SSO-PM", "SSO-400-SSO-noon", "LEO-420-equat-NA", "LEO-420-polar-NA", "SSO-420-SSO-AM", "SSO-420-SSO-DD", "SSO-420-SSO-PM", "SSO-420-SSO-noon", "LEO-440-equat-NA", "LEO-440-polar-NA", "SSO-440-SSO-AM", "SSO-440-SSO-DD", "SSO-440-SSO-PM", "SSO-440-SSO-noon", "LEO-460-equat-NA", "LEO-460-polar-NA", "SSO-460-SSO-AM", "SSO-460-SSO-DD", "SSO-460-SSO-PM", "SSO-460-SSO-noon", "LEO-480-equat-NA", "LEO-480-polar-NA", "SSO-480-SSO-AM", "SSO-480-SSO-DD", "SSO-480-SSO-PM", "SSO-480-SSO-noon", "LEO-500-equat-NA", "LEO-500-polar-NA", "SSO-500-SSO-AM", "SSO-500-SSO-DD", "SSO-500-SSO-PM", "SSO-500-SSO-noon", "LEO-520-equat-NA", "LEO-520-polar-NA", "SSO-520-SSO-AM", "SSO-520-SSO-DD", "SSO-520-SSO-PM", "SSO-520-SSO-noon", "LEO-540-equat-NA", "LEO-540-polar-NA", "SSO-540-SSO-AM", "SSO-540-SSO-DD", "SSO-540-SSO-PM", "SSO-540-SSO-noon", "LEO-560-equat-NA", "LEO-560-polar-NA", "SSO-560-SSO-AM", "SSO-560-SSO-DD", "SSO-560-SSO-PM", "SSO-560-SSO-noon", "LEO-580-equat-NA", "LEO-580-polar-NA", "SSO-580-SSO-AM", "SSO-580-SSO-DD", "SSO-580-SSO-PM", "SSO-580-SSO-noon", "LEO-600-equat-NA", "LEO-600-np-NA", "LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-600-SSO-PM", "SSO-600-SSO-noon", "LEO-620-np-NA", "LEO-620-polar-NA", "SSO-620-SSO-AM", "SSO-620-SSO-DD", "SSO-620-SSO-PM", "SSO-620-SSO-noon", "LEO-640-np-NA", "LEO-640-polar-NA", "SSO-640-SSO-AM", "SSO-640-SSO-DD", "SSO-640-SSO-PM", "SSO-640-SSO-noon", "LEO-660-np-NA", "LEO-660-polar-NA", "SSO-660-SSO-AM", "SSO-660-SSO-DD", "SSO-660-SSO-PM", "SSO-660-SSO-noon", "LEO-680-np-NA", "LEO-680-polar-NA", "SSO-680-SSO-AM", "SSO-680-SSO-DD", "SSO-680-SSO-PM", "SSO-680-SSO-noon", "LEO-700-np-NA", "LEO-700-polar-NA", "SSO-700-SSO-AM", "SSO-700-SSO-DD", "SSO-700-SSO-PM", "SSO-700-SSO-noon", "LEO-720-np-NA", "LEO-720-polar-NA", "SSO-720-SSO-AM", "SSO-720-SSO-DD", "SSO-720-SSO-PM", "SSO-720-SSO-noon", "LEO-740-np-NA", "LEO-740-polar-NA", "SSO-740-SSO-AM", "SSO-740-SSO-DD", "SSO-740-SSO-PM", "SSO-740-SSO-noon", "LEO-760-np-NA", "LEO-760-polar-NA", "SSO-760-SSO-AM", "SSO-760-SSO-DD", "SSO-760-SSO-PM", "SSO-760-SSO-noon", "LEO-780-np-NA", "LEO-780-polar-NA", "SSO-780-SSO-AM", "SSO-780-SSO-DD", "SSO-780-SSO-PM", "SSO-780-SSO-noon", "LEO-800-np-NA", "LEO-800-polar-NA", "SSO-800-SSO-AM", "SSO-800-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-noon", "LEO-820-np-NA", "SSO-820-SSO-AM", "LEO-840-np-NA", "SSO-840-SSO-AM", "LEO-860-np-NA", "SSO-860-SSO-AM", "LEO-880-np-NA", "SSO-880-SSO-AM", "LEO-900-np-NA", "SSO-900-SSO-AM", "LEO-920-np-NA", "SSO-920-SSO-AM", "LEO-940-np-NA", "SSO-940-SSO-AM", "LEO-960-np-NA", "SSO-960-SSO-AM", "LEO-980-np-NA", "SSO-980-SSO-AM", "LEO-1000-np-NA", "SSO-1000-SSO-AM", "LEO-1020-np-NA", "LEO-1040-np-NA", "LEO-1060-np-NA", "LEO-1080-np-NA", "LEO-1100-np-NA", "LEO-1120-np-NA", "LEO-1140-np-NA", "LEO-1160-np-NA", "LEO-1180-np-NA", "LEO-1200-np-NA", "LEO-1220-np-NA", "LEO-1240-np-NA", "LEO-1260-np-NA", "LEO-1280-np-NA", "LEO-1300-np-NA"};


//        for(int x = 0; x < orbitList.length; x++){
//            String orbit = orbitList[x];
//            if(orbit.contains("-np-")){
//                System.out.println("--> NEAR POLAR ORBIT IDX: " + x);
//            }
//        }

        super.instrumentList = instrumentList;
        super.orbitList = orbitList;
//        this.adhocRulesClp = this.problemPath + "/clp/climate_centric_rules.clp";
//        this.adhocRulesClp = this.problemPath + "/clp/unused/Decadal_specific_rules.clp";

        // Initialize Orekit
        String coverageDatabase = this.orekitResourcesPath + File.separator + "CoverageDatabase";
        System.setProperty("orekit.coveragedatabase", coverageDatabase);
        OrekitConfig.init(orekit_threads, this.orekitResourcesPath);

        super.init();
    }

    @Override
    public BaseParams copy(){
        return new GigaAssigningParams(super.resourcesPath, super.reqMode, super.name, super.runMode, this.orekit_threads);
    }



}
