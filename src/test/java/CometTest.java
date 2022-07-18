import seakers.vassar.utils.designer.Designer;

public class CometTest {

    public static void main(String[] args) throws Exception {
        String resourcesPath = "../VASSAR_resources";

//        // Instruments
        String[][] payloads = {{"LM_SV2"}, {""}, {""}, {""}, {""}, {""}};
        String[] orbits = {"SSO-400-SSO-AM","SSO-400-SSO-DD","SSO-600-SSO-AM","SSO-500-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
        String[][] factList = null;
        String[][] epsFacts = null;


        //PARAMETERS (Constant intputs)
        String lifetime = "5"; //years
        //payload, bus power, detailed power budget

        //DESIGN VARIABLES (Variable inputs for the evaluation mode, do change across designs)
        //altitude
        String solar_cell_component = "XTE-SF"; //Acceptable inputs: XTE-SF
        String array_area = "10";
        String panel_orientation = "Body-mounted"; //Acceptable inputs: Body-mounted, Deployable
        String panel_DOF_articulation; //Degrees of freedom
        String battery_component = "Saft 8s4p"; //Acceptable inputs: Saft 8s4p, Saft 11s16p
        String num_battery = "4";

        epsFacts = new String[][]{{"SA-component", solar_cell_component}, {"battery-component", battery_component}, {"SA-orientation", panel_orientation}};
        factList = new String[][]{{"num-battery", num_battery}, {"solar-array-area", array_area}};

        Designer designer = new Designer("SAR_sizing_ref","Designer", payloads, orbits, resourcesPath, factList, epsFacts);
        designer.archDesign(true);

        int x = 1;
    }

}
