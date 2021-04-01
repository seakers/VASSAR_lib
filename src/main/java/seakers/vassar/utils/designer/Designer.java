package seakers.vassar.utils.designer;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.problems.Assigning.Architecture;
import seakers.vassar.problems.Assigning.AssigningParams;
import seakers.vassar.spacecraft.SpacecraftDescription;

import java.io.FileWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;

public class Designer {
    String archName;
    String problemName;
    String[][] payloads;
    String[] orbits;
    AssigningParams params;
    Architecture arch;
    String resourcesPath;
    String[][] factList;
    private ArrayList<SpacecraftDescription> designs;

    public Designer(String archName, String problemName, String[][] payloads, String[] orbits, String resourcesPath, String[][] factList){
        this.archName = archName;
        this.problemName = problemName;
        this.payloads = payloads;
        this.orbits = orbits;
        this.params = new DesignerParams(orbits, problemName, resourcesPath, "CRISP-ATTRIBUTES","test", "normal");
        this.arch = new Architecture( mapPayloads(payloads, orbits), 1, params);
        this.resourcesPath = resourcesPath;
        this.factList = factList;

    }

    private HashMap<String, String[]> mapPayloads(String[][] payloads, String[] orbits){
        HashMap<String,String[]> map = new HashMap<>();

        for(int i = 0; i < orbits.length; i++){
            map.put(orbits[i], payloads[i]);
        }

        return map;
    }

    public void archDesign(boolean print){
        ArchitectureSizer evaluator = new ArchitectureSizer(this.factList);
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);

        Result result = evaluationManager.evaluateArchitectureSync(arch, "Slow");
        this.designs = result.getDesigns();

        evaluationManager.clear();

        if(print) {
            this.printJSON();
        }

        System.out.println("Designer DONE\n");
    }

    public void archDesign(){
        this.archDesign(false);
    }

    private void printJSON(){
        // create a JSON File with design outputs
        JSONObject out = this.createJSON();
        try{
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd_HHmm");
            LocalDateTime now = LocalDateTime.now();

            String filename = archName + "_ArchDesign_" + dtf.format(now) + ".json";
            String location = resourcesPath + "/problems/" + problemName + "/results/";
            FileWriter writer = new FileWriter(location + filename);
            writer.write(out.toJSONString());
            writer.close();

            System.out.println("Architecture design saved as: " + filename);
            System.out.println("In folder: " + location + "\n");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JSONObject createJSON(){
        JSONObject out = new JSONObject();
        JSONArray archs = new JSONArray();

        for(SpacecraftDescription d : designs){
            JSONObject arch = new JSONObject();

            JSONObject mission = this.getMissionInfo(d);
            JSONObject massBudget = this.getMassBudget(d);
            JSONObject powerBudget = this.getPowerBudget(d);
            JSONObject avionicsDesign = this.getAvionicsDesign(d);
            JSONObject commsDesign = this.getCommsDesign(d);
            JSONObject epsDesign = this.getEPSDesign(d);
            JSONObject propDesign = this.getPropDesign(d);
            JSONObject thermalDesign = this.getThermalDesign(d);
            JSONObject payloadDesign = this.getPayloadDesign(d);

            arch.put("Mission", mission);
            arch.put("Mass-Budget", massBudget);
            arch.put("Power-Budget", powerBudget);
            arch.put("Avionics-Design", avionicsDesign);
            arch.put("Comms-Design", commsDesign);
            arch.put("EPS-Design", epsDesign);
            arch.put("Prop-Design", propDesign);
            arch.put("Thermal-Design", thermalDesign);
            arch.put("Payload-Design", payloadDesign);

            archs.add(arch);
        }
        out.put("name", archName);
        out.put("designs", archs);

        return out;
    }

    private JSONObject getMissionInfo(SpacecraftDescription design){
        JSONObject mission = new JSONObject();
            mission.put("Lifespan", design.getValue("lifetime"));
            mission.put("Fraction-Sunlight", design.getValue("fraction-sunlight"));
            mission.put("Worst-Sun-Angle", design.getValue("worst-sun-angle"));
            mission.put("Num-Accesses-Per-Day", design.getValue("num-accesses-per-day"));
            mission.put("Satellite-Dimensions", design.getValue("satellite-dimensions"));

        JSONObject orbit = new JSONObject();
            orbit.put("Name", design.getValue("orbit-string"));
            orbit.put("Altitude", design.getValue("orbit-altitude#"));
            orbit.put("Altitude", design.getValue("orbit-anomaly#"));
            orbit.put("Altitude", design.getValue("orbit-arg-of-perigee"));
            orbit.put("Altitude", design.getValue("orbit-central-body"));
            orbit.put("Altitude", design.getValue("orbit-eccentricity"));
            orbit.put("Altitude", design.getValue("orbit-inclination"));
            orbit.put("Altitude", design.getValue("orbit-period#"));
            orbit.put("Altitude", design.getValue("orbit-RAAN"));
            orbit.put("Altitude", design.getValue("orbit-semimajor-axis"));
        mission.put("Orbit", orbit);

        return mission;
    }

    private JSONObject getMassBudget(SpacecraftDescription design){
        JSONObject budget = new JSONObject();

        JSONObject subsystems = new JSONObject();
            subsystems.put("Avionics-Mass", design.getValue("avionics-mass#"));
            subsystems.put("ADCS-Mass", design.getValue("ADCS-mass#"));
            subsystems.put("Comms-Mass", design.getValue("comm-OBDH-mass#"));
            subsystems.put("EPS-Mass", design.getValue("EPS-mass#"));
            subsystems.put("Thermal-Mass", design.getValue("thermal-mass#"));
            subsystems.put("Structure-Mass", design.getValue("structure-mass#"));
            subsystems.put("Propulsion-Mass", design.getValue("propulsion-mass#"));
            double propellantMass = Double.parseDouble( design.getValue("propellant-mass-ADCS") )
                    + Double.parseDouble( design.getValue("propellant-mass-injection") );
            subsystems.put("Propellant-Mass", propellantMass);
            subsystems.put("Payload-Mass", design.getValue("payload-mass#"));
        budget.put("Subsystems", subsystems);

        JSONObject misc = new JSONObject();
            misc.put("Adapter-Mass", design.getValue("adapter-mass"));
            misc.put("Bus-Mass", design.getValue("bus-mass"));
        budget.put("Misc", misc);

        JSONObject system = new JSONObject();
            system.put("Satellite-Dry-Mass", design.getValue("satellite-dry-mass"));
            system.put("Satellite-Wet-Mass", design.getValue("satellite-wet-mass"));
            system.put("Satellite-Launch-Mass", design.getValue("satellite-launch-mass"));
            system.put("Satellite-Mass", design.getValue("satellite-mass#"));
        budget.put("Overall", system);

        return budget;
    }

    private JSONObject getPowerBudget(SpacecraftDescription design){
        JSONObject budget = new JSONObject();

        JSONObject subsystems = new JSONObject();
            subsystems.put("Avionics-Power", design.getValue("avionics-power#"));
            subsystems.put("Comms-Power", design.getValue("comm-OBDH-power#"));
            subsystems.put("Payload-Power", design.getValue("payload-power#"));
            subsystems.put("Payload-Peak-Power", design.getValue("payload-peak-power#"));
            subsystems.put("Payload-Duty-Cycle", design.getValue("power-duty-cycle#"));
        budget.put("Subsystems", subsystems);

        JSONObject misc = new JSONObject();
            misc.put("Bus-Power", design.getValue("bus-BOL-power"));
        budget.put("Misc", misc);

        JSONObject system = new JSONObject();
            system.put("Satellite-BOL-Power", design.getValue("satellite-BOL-power#"));
        budget.put("Overall", system);

        return budget;
    }

    private JSONObject getAvionicsDesign(SpacecraftDescription design){
        JSONObject des = new JSONObject();

        return des;
    }

    private JSONObject getCommsDesign(SpacecraftDescription design){
        JSONObject des = new JSONObject();
            des.put("Antennae", design.getValue("antennae"));
            des.put("Antennae-Dimensions", design.getValue("antennae-dimensions"));
            des.put("Bus-Datarate", design.getValue("bus-datarate"));
            des.put("Datarate-Per-Orbit", design.getValue("sat-data-rate-per-orbit#"));
            des.put("Datarate-Duty-Cycle", design.getValue("datarate-duty-cycle#"));
            des.put("GS-Antenna", design.getValue("gs-antenna"));
            des.put("GS-Payload", design.getValue("gs-payload"));
            des.put("ISL-Antenna", design.getValue("isl-antenna"));
            des.put("ISL-Payload", design.getValue("isl-payload"));
        return des;
    }

    private JSONObject getEPSDesign(SpacecraftDescription design){
        JSONObject des = new JSONObject();
            des.put("DOD", design.getValue("depth-of-discharge"));
            des.put("Solar-Array-Area", design.getValue("solar-array-area"));
            des.put("Solar-Array-Mass", design.getValue("solar-array-mass"));
        return des;
    }
    private JSONObject getPropDesign(SpacecraftDescription design){
        JSONObject des = new JSONObject();

        JSONObject deltaVBudget = new JSONObject();
            deltaVBudget.put("Delta-V", design.getValue("delta-V"));
            deltaVBudget.put("Delta-V#", design.getValue("delta-V#"));
            deltaVBudget.put("ADCS", design.getValue("delta-V-ADCS"));
            deltaVBudget.put("Deorbit", design.getValue("delta-V-deorbit"));
            deltaVBudget.put("Drag", design.getValue("delta-V-drag"));
            deltaVBudget.put("Injection", design.getValue("delta-V-injection"));
        des.put("Delta-V-Budget", deltaVBudget);

            des.put("propellant-ADCS", design.getValue("propellant-ADCS"));
            des.put("propellant-injection", design.getValue("propellant-injection"));
        return des;
    }
    private JSONObject getThermalDesign(SpacecraftDescription design){
        JSONObject des = new JSONObject();

        return des;
    }

    private JSONObject getPayloadDesign(SpacecraftDescription design){
        JSONObject des = new JSONObject();
            des.put("Number-of-Instruments", design.getValue("num-of-instruments#"));
            des.put("Datarate", design.getValue("payload-data-rate#"));
            des.put("Dimensions", design.getValue("payload-dimensions"));
            des.put("Dimensions#", design.getValue("payload-dimensions#"));
            des.put("Slew-Angle", design.getValue("slew-angle"));
        return des;
    }
}
