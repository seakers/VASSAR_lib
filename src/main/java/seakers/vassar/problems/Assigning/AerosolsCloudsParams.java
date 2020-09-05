package seakers.vassar.problems.Assigning;

import seakers.vassar.BaseParams;

public class AerosolsCloudsParams extends AssigningParams {

    public AerosolsCloudsParams(String resourcesPath, String mode, String name, String runMode){
        super(resourcesPath, "Aerosols_Clouds", mode, name, runMode);

        // Instruments
        String[] instrumentList = {"ACE-CPR", "ACE-OCI", "ACE-POL", "ACE-LID", "CALIPSO-CALIOP", "CALIPSO-WFC",
                "CALIPSO-IIR", "EARTHCARE-ATLID", "EARTHCARE-BBR", "EARTHCARE-CPR", "EARTHCARE-MSI", "ICI", "AQUARIUS", "DIAL", "IR-Spectrometer"};
        String[] orbitList = {"LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-AM", "SSO-800-SSO-DD", "SSO-800-SSO-PM", "SSO-400-SSO-PM", "SSO-705-SSO-PM"};

        super.instrumentList = instrumentList;
        super.orbitList = orbitList;
        this.adhocRulesClp = this.problemPath + "/clp/aerosols_clouds_rules.clp";
        super.init();
    }

    @Override
    public BaseParams copy(){
        return new AerosolsCloudsParams(super.resourcesPath, super.reqMode, super.name, super.runMode);
    }
}
