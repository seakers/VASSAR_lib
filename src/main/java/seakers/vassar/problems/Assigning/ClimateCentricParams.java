package seakers.vassar.problems.Assigning;

public class ClimateCentricParams extends AssigningParams {

    public ClimateCentricParams(String path, String mode, String name, String runMode, String search_clp){
        super(path, mode, name, runMode, search_clp);

        // Instruments
        String[] instrumentList = {"ACE_ORCA", "ACE_POL", "ACE_LID", "CLAR_ERB", "ACE_CPR", "DESD_SAR", "DESD_LID", "GACM_VIS", "GACM_SWIR", "HYSP_TIR", "POSTEPS_IRS", "CNES_KaRIN"};
        String[] orbitList = {"LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-DD", "SSO-800-SSO-PM"};

        super.instrumentList = instrumentList;
        super.orbitList = orbitList;

        this.adhocRulesClp = this.path + "/clp/climate_centric_rules.clp";

        super.init();
    }
}
