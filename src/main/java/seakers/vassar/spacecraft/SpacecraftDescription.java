package seakers.vassar.spacecraft;

import jess.Fact;
import jess.JessException;
import jess.Rete;
import jess.ValueVector;
import seakers.vassar.Result;

import java.util.ArrayList;
import java.util.HashMap;

public class SpacecraftDescription {
    private final String[] fieldNames;
    private final String[] fieldValues;
    private String science;
    private String cost;
    private HashMap<String, String> description;

    public SpacecraftDescription(SpacecraftDescription newDesign){
        this.fieldNames = new String[newDesign.getFieldNames().length];
        this.fieldValues = new String[newDesign.getFieldValues().length];
        this.description = new HashMap<>();

        for(int i = 0; i < newDesign.getFieldValues().length; i++){
            fieldNames[i] = newDesign.getFieldNames()[i];
            fieldValues[i] = newDesign.getFieldValues()[i];

            description.put(fieldNames[i], fieldValues[i]);
        }

        this.science = newDesign.getScience();
        this.cost = newDesign.getCost();
        description.put("science", this.science );
        description.put("cost", this.cost );
    }

    public SpacecraftDescription(Fact scDesign, Rete r) throws JessException {
        fieldNames = new String[]{
            "adapter-mass",
            "ADCS-mass#",
            "ADCS-penalty",
            "ADCS-requirement",
            "ADCS-type",
            "antennae",
            "antennae-dimensions",
            "avionics-mass#",
            "bus",
            "bus-BOL-power",
            "bus-cost",
            "bus-cost#",
            "bus-datarate",
            "bus-dimensions",
            "bus-mass",
            "bus-mass-margin",
            "bus-non-recurring-cost",
            "bus-non-recurring-cost#",
            "bus-power-margin",
            "bus-recurring-cost",
            "bus-recurring-cost#",
            "bus-volume-margin",
            "comm-OBDH-mass#",
            "constellation",
            "contract-modality",
            "datarate-duty-cycle#",
            "datarate-penalty",
            "delta-V",
            "delta-V#",
            "delta-V-ADCS",
            "delta-V-deorbit",
            "delta-V-drag",
            "delta-V-injection",
            "deorbiting-strategy",
            "depth-of-discharge",
            "drag-coefficient",
            "EMC-penalty",
            "EPS-mass#",
            "fraction-sunlight",
            "gs-antenna",
            "gs-payload",
            "IAT-cost",
            "IAT-cost#",
            "IAT-non-recurring-cost",
            "IAT-non-recurring-cost#",
            "IAT-recurring-cost",
            "IAT-recurring-cost#",
            "id",
            "in-orbit",
            "instruments",
            "isl-antenna",
            "isl-payload",
            "Isp-ADCS",
            "Isp-injection",
            "launch-cost",
            "launch-cost#",
            "launch-date",
            "launch-vehicle",
            "lifecycle-cost",
            "lifecycle-cost#",
            "lifetime",
            "lowest-TRL-instrument-value#",
            "low-TRL-instruments#",
            "lv-pack-efficiency#",
            "max-outage-time",
            "mechanisms-penalty",
            "mission-architecture",
            "mission-cost",
            "mission-cost#",
            "mission-non-recurring-cost",
            "mission-non-recurring-cost#",
            "mission-recurring-cost",
            "mission-recurring-cost#",
            "moments-of-inertia",
            "Name",
            "num-accesses-per-day",
            "num-of-instruments#",
            "num-launches",
            "num-of-planes#",
            "num-of-sats-per-plane#",
            "operations-cost",
            "operations-cost#",
            "orbit-altitude#",
            "orbit-anomaly#",
            "orbit-arg-of-perigee",
            "orbit-central-body",
            "orbit-eccentricity",
            "orbit-inclination",
            "orbit-period#",
            "orbit-RAAN",
            "orbit-semimajor-axis",
            "orbit-string",
            "orbit-type",
            "overhead-cost",
            "partnership-type",
            "payload-cost",
            "payload-cost#",
            "payload-data-rate#",
            "payload-dimensions",
            "payload-dimensions#",
            "payload-mass#",
            "payload-non-recurring-cost",
            "payload-non-recurring-cost#",
            "payload-peak-power#",
            "payload-power#",
            "payload-recurring-cost",
            "payload-recurring-cost#",
            "payloads",
            "power-duty-cycle#",
            "program-cost",
            "program-cost#",
            "program-non-recurring-cost",
            "program-non-recurring-cost#",
            "program-recurring-cost",
            "program-recurring-cost#",
            "propellant-ADCS",
            "propellant-injection",
            "propellant-mass-ADCS",
            "propellant-mass-injection",
            "propulsion-mass#",
            "residual-dipole",
            "sat-data-rate-per-orbit#",
            "satellite-BOL-power",
            "satellite-BOL-power#",
            "satellite-cost",
            "satellite-cost#",
            "satellite-dimensions",
            "satellite-dry-mass",
            "satellite-launch-mass",
            "satellite-mass#",
            "satellite-volume#",
            "satellite-wet-mass",
            "scanning-penalty",
            "select-orbit",
            "service-fee",
            "slew-angle",
            "solar-array-area",
            "solar-array-mass",
            "spacecraft-non-recurring-cost",
            "spacecraft-non-recurring-cost#",
            "spacecraft-recurring-cost",
            "spacecraft-recurring-cost#",
            "standard-bus",
            "STK-DB",
            "structure-mass#",
            "thermal-mass#",
            "thermal-penalty",
            "worst-sun-angle",
            "updated",
            "updated2",
            "factHistory",
            "avionics-power#",
            "comm-OBDH-power#"
        };

        fieldValues = new String[fieldNames.length];
        for(int i = 0; i < fieldNames.length; i++){
            fieldValues[i] = scDesign.getSlotValue(fieldNames[i]).toString();
        }

        this.description = new HashMap<>();
        this.science = "";
        this.cost = "";
    }

    public String[] getFieldNames() {
        return fieldNames;
    }

    public String[] getFieldValues() {
        return fieldValues;
    }

    public String getScience(){ return this.science; }

    public String getCost(){ return this.cost; }

    public HashMap<String,String> getDescription(){ return description; }

    public String getValue(String field){
        return description.get(field);
    }

    public void setEval(Result result){
        this.science = String.valueOf(result.getScience());
        this.cost = String.valueOf(result.getCost());
        description.put("science", String.valueOf(result.getScience()) );
        description.put("cost", String.valueOf(result.getCost()) );
    }
}

