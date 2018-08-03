package rbsa.eoss.problems.Assigning;

import rbsa.eoss.local.BaseParams;

import java.util.HashMap;

public class SMAPParams extends AssigningParams {

    public SMAPParams(String path, String mode, String name, String runMode, String search_clp){
        super(path, mode, name, runMode, search_clp);

        // Instruments
        String[] instrumentList = {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
        String[] orbitList = {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};

        super.instrumentList = instrumentList;
        super.orbitList = orbitList;
        super.init();
    }
}