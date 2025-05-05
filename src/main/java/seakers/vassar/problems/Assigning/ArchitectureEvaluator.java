package seakers.vassar.problems.Assigning;

import jess.*;
import org.orekit.errors.OrekitException;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.MatlabFunctions;

import java.io.PrintWriter;
import java.util.*;
import org.json.JSONObject;
import org.json.JSONArray;

/**
 *
 * @author Ana-Dani
 */

public class ArchitectureEvaluator extends AbstractArchitectureEvaluator {

    public ArchitectureEvaluator(){
        super();
    }

    public ArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        super(resourcePool, arch, type);
    }

    public ArchitectureEvaluator getNewInstance(){
        return new ArchitectureEvaluator(super.resourcePool, super.arch, super.type);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type){
        return new ArchitectureEvaluator(resourcePool, arch, type);
    }

    protected void assertMissions(BaseParams params, Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {

        Architecture arch = (Architecture) inputArch;

        boolean[][] mat = arch.getBitMatrix();
        try {
            this.orbitsUsed = new HashSet<>();

            for (int i = 0; i < params.getNumOrbits(); i++) {
                int ninstrs = m.sumRowBool(mat, i);
                if (ninstrs > 0) {
                    String orbitName = params.getOrbitList()[i];

                    Orbit orb = new Orbit(orbitName, 1, arch.getNumSatellites());
                    this.orbitsUsed.add(orb);

                    String payload = "";
                    String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";
                    for (int j = 0; j < params.getNumInstr(); j++) {
                        if (mat[i][j]) {
                            payload += " " + params.getInstrumentList()[j];
                        }
                    }
                    call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                            + "(factHistory F" + params.nof + ")))";
                    params.nof++;

                    call += "(assert (SYNERGIES::cross-registered-instruments " +
                            " (instruments " + payload +
                            ") (degree-of-cross-registration spacecraft) " +
                            " (platform " + orbitName +  " )"
                            + "(factHistory F" + params.nof + ")))";
                    params.nof++;
                    r.eval(call);
                }
            }
        }
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }

//    public void assertMissionsFromJSON(BaseParams params, JSONObject arch, QueryBuilder qb, Rete r, MatlabFunctions m) {
//
//        try {
//
//            JSONArray satellites = arch.getJSONArray("satellites");
//            for (int i = 0; i < satellites.length(); i++) {
//                JSONObject satellite = satellites.getJSONObject(i);
//                JSONObject orbit = satellite.getJSONObject("orbit");
//                String orbitType = orbit.getString("orbitType");
//                double semimajorAxis = orbit.getDouble("semimajorAxis");
//                double inclination = orbit.getDouble("inclination");
//                double eccentricity = orbit.getDouble("eccentricity");
//                double periapsisArgument = orbit.getDouble("periapsisArgument");
//                double rightAscensionAscendingNode = orbit.getDouble("rightAscensionAscendingNode");
//                double trueAnomaly = orbit.getDouble("trueAnomaly");
//
//                String orbitName = orbitType + "-" +
//                        String.format("%f", semimajorAxis) + "-" +
//                        String.format("%f", inclination) + "-" +
//                        String.format("%f", eccentricity) + "-" +
//                        String.format("%f", periapsisArgument) + "-" +
//                        String.format("%f", rightAscensionAscendingNode) + "-" +
//                        String.format("%f", trueAnomaly);
//
//                String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";
//
//                String orbJessString = " (num-of-planes# " + "1" + ")" +
//                        " (num-of-sats-per-plane# "  + "1" + ")"  +
//                        " (mission-architecture " + "single_arch" + ")" +
//                        " (orbit-type " + orbitType + ")"  +
//                        " (orbit-altitude# "  + String.format("%f", semimajorAxis-6378) + ")"  +
//                        " (orbit-eccentricity "  + String.format("%f", eccentricity) + ")"  +
//                        " (orbit-RAAN " + String.format("%f", rightAscensionAscendingNode) + ")"  +
//                        " (orbit-inclination " + String.format("%f", inclination) + ")"  +
//                        " (orbit-string " + orbitName + ")";
//
//                JSONArray payloads = satellite.getJSONArray("payload");
//
//                HashMap<String,Fact> db_instruments = new HashMap<>();
//                String payloadString = "";
//                for (int j = 0; j < payloads.length(); j++) {
//                    JSONObject payload = payloads.getJSONObject(j);
//
//                    // Extract instrument information
//                    String instrumentName = payload.getString("name").replace(" ", "_");  // Replace spaces with underscores
//                    payloadString += " " + instrumentName;
//                    double dx = Math.cbrt(payload.getDouble("volume"));
//                    double dy = dx;
//                    double dz = dx;
//                    double mass = payload.getDouble("mass");
//                    double avgPower = payload.getDouble("power");
//                    double peakPower = payload.getDouble("power");
//                    double avgDataRate = payload.getDouble("dataRate");
//                    double charPower = payload.getDouble("power");
//                    double apertureDia = payload.getDouble("apertureDia");
//                    double bandwidth = payload.getDouble("bandwidth");
//                    double FOV = payload.getJSONObject("fieldOfView").getDouble("crossTrackFieldOfView");
//                    double frequency = 299792458/payload.getDouble("operatingWavelength");
//                    String hasDeploymentMechanism = "yes";
//                    if (payload.getString("mountType") == "BODY") {
//                        hasDeploymentMechanism = "no";
//                    }
////                    String scanning = payload.getString("scanTechnique");
//                    String scanning = "cross-track";
//                    int TRL = payload.getInt("techReadinessLevel");
//                    String geometry;
//                    if (payload.getJSONObject("orientation").getDouble("sideLookAngle") == 0) {
//                        geometry = "nadir";
//                    }
//                    else {
//                        geometry = "slant";
//                    }
//
//                    // Assert facts into Jess for DATABASE::Instrument
//                    String dbFact = "(assert (DATABASE::Instrument (Name " + instrumentName + ") " +
//                            "(mass# " + mass + ") (average-power# " + avgPower + ") (peak-power# " + peakPower + ") " +
//                            "(average-data-rate# " + avgDataRate + ") (dimension-x# " + dx + ") " +
//                            "(dimension-y# " + dy + ") (dimension-z# " + dz + ") " +
//                            "(characteristic-power# " + charPower + ") (cost# nil) (All-weather yes) (Aperture# " + apertureDia + ") " +
//                            "(bandwidth# " + bandwidth + ") (characteristic-orbit " + (semimajorAxis-6378) + ") (Day-Night Day-and-night) " +
//                            "(Field-of-view# " + FOV + ") (frequency# " + frequency + ") (has-deployment-mechanism " + hasDeploymentMechanism + ") " +
//                            "(scanning " + scanning + ") (Technology-Readiness-Level " + TRL + ") (factHistory "+ params.nof +") (Geometry " + geometry + ")))";
//                    params.nof++;
//                    r.eval(dbFact);  // Assert DATABASE::Instrument fact
//
//                    // Assert facts into Jess for CAPABILITIES::Manifested-instrument
//                    String manifestFact = "(assert (CAPABILITIES::Manifested-instrument (Name " + instrumentName + ") " +
//                            "(mass# " + mass + ") (average-power# " + avgPower + ") (peak-power# " + peakPower + ") " +
//                            "(average-data-rate# " + avgDataRate + ") (dimension-x# " + dx + ") " +
//                            "(dimension-y# " + dy + ") (dimension-z# " + dz + ") " +
//                            "(characteristic-power# " + charPower + ") (cost# nil) (factHistory "+ params.nof +")))";
//                    params.nof++;
//                    r.eval(manifestFact);  // Assert CAPABILITIES::Manifested-instrument fact
//
//                    ArrayList<Fact> facts = qb.makeQuery("DATABASE::Instrument (Name " + instrumentName + ")");
//                    Fact f = facts.get(0);
//                    db_instruments.put(instrumentName, f);
//
//                    String canMeasure = "(assert (CAPABILITIES::can-measure (instrument " + instrumentName + ") (in-orbit " + orbitName + ") " +
//                            "(orbit-type " + orbitType + ") (orbit-altitude# " + (semimajorAxis-6378) + ") (data-rate-duty-cycle# nil) " +
//                            "(power-duty-cycle# nil) (data-rate-constraint nil) (orbit-inclination " + inclination + ") " +
//                            "(orbit-RAAN " + rightAscensionAscendingNode + ") (can-take-measurements yes) (reason \"by default\") (copied-to-measurement-fact no) (factHistory " + params.nof + ")))";
//                    params.nof++;
//                    r.eval(canMeasure);
//
//                }
//
//                qb.addPrecomputedQuery("DATABASE::Instrument", db_instruments);
//
////                String listOfInstruments = "(assert (DATABASE::list-of-instruments (list " + payloadString + ")))";
//                r.eval("(deftemplate DATABASE::list-of-instruments (multislot list) (slot factHistory))");
//                r.eval("(deffacts DATABASE::list-of-instruments (DATABASE::list-of-instruments " +
//                        "(list (create$ " + payloadString + ")) (factHistory "+ params.nof +")))");
//                params.nof++;
//
//                call += "(instruments " + payloadString + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orbJessString + ""
//                        + "(factHistory F" + params.nof + ")))";
//                params.nof++;
//
//                call += "(assert (SYNERGIES::cross-registered-instruments " +
//                        " (instruments " + payloadString +
//                        ") (degree-of-cross-registration spacecraft) " +
//                        " (platform " + orbitName +  " )"
//                        + "(factHistory F" + params.nof + ")))";
//                params.nof++;
//                r.eval(call);
//            }
//        }
//        catch (Exception e) {
//            System.out.println("" + e.getClass() + " " + e.getMessage());
//            e.printStackTrace();
//        }
//    }

    public void assertMissionsFromJSON(BaseParams params, JSONObject arch, QueryBuilder qb, Rete r, MatlabFunctions m) {

        try {
            this.orbitsUsed = new HashSet<>();
            JSONArray satList = arch.getJSONArray("satellites");
            for (int i = 0; i < satList.length(); i++){
                JSONObject satellite = satList.getJSONObject(i);

                JSONObject orbit = satellite.getJSONObject("orbit");
                String orbitType = orbit.getString("orbitType");
                String inclination_type;
                String raan;
                String type = "LEO";
                int semimajorAxis = orbit.getInt("semimajorAxis");
                double inclination = orbit.getDouble("inclination");
                double eccentricity = orbit.getDouble("eccentricity");
                double periapsisArgument = orbit.getDouble("periapsisArgument");
                double trueAnomaly = orbit.getDouble("trueAnomaly");

                // Determine inclination type
                if (orbitType.contains("SSO")) {
                    inclination_type = "SSO";
                } else if (orbitType.contains("LEO") && inclination == 90) {
                    inclination_type = "polar";
                } else {
                    inclination_type = String.valueOf(inclination);
                }

                // Determine RAAN based on orbit type
                if (orbitType.contains("AM")) {
                    raan = "AM";
                } else if (orbitType.contains("DD")) {
                    raan = "DD";
                } else if (orbitType.contains("PM")) {
                    raan = "PM";
                } else {
                    raan = "NA";
                }

                String orbitName = type + "-" + (semimajorAxis-6378) + "-" + inclination_type + "-" + raan;

                Orbit orb = new Orbit(orbitName, 1, 1);
                this.orbitsUsed.add(orb);

                String payload = "";
                String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";

                JSONArray payloads = satellite.getJSONArray("payload");
                for (int j = 0; j < payloads.length(); j++) {
                    JSONObject payloadObj = payloads.getJSONObject(j);
                    payload += " " + payloadObj.getString("name").replace(" ", "_");
                }

                call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                        + "(factHistory F" + params.nof + ")))";
                params.nof++;

                call += "(assert (SYNERGIES::cross-registered-instruments " +
                        " (instruments " + payload +
                        ") (degree-of-cross-registration spacecraft) " +
                        " (platform " + orbitName +  " )"
                        + "(factHistory F" + params.nof + ")))";
                params.nof++;
                r.eval(call);
            }
        }
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }

    public Result evaluatePerformanceFromJSON(JSONObject inputData, Double revisitTime, BaseParams params) {
        Result result = new Result();
        try {
            // Initializations
            Rete r = new Rete();
            QueryBuilder qb = new QueryBuilder(r);
            MatlabFunctions m = new MatlabFunctions(new Resource(params));
            r.addUserfunction(m);
            JessInitializer.getInstance().initializeJess(params, r, qb, m);

            r.reset();

            r.eval("(watch rules)");
            r.eval("(watch facts)");
//            r.eval("(watch all)");

            assertMissionsFromJSON(params, inputData, qb, r, m);



            r.eval("(bind ?*science-multiplier* 1.0)");
            r.eval("(defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE))))");
            r.eval("(defadvice before (create$ sqrt + * **) (foreach ?xxx $?argv (if (eq ?xxx nil) then (bind ?xxx 0))))");

            r.setFocus("MANIFEST0");
            r.run();

//

            r.setFocus("MANIFEST");
            r.run();

            r.setFocus("CAPABILITIES");
            r.run();

            r.setFocus("CAPABILITIES-REMOVE-OVERLAPS");
            r.run();

            r.setFocus("CAPABILITIES-GENERATE");
            r.run();

            r.setFocus("CAPABILITIES-CROSS-REGISTER");
            r.run();

            r.setFocus("CAPABILITIES-UPDATE");
            r.run();

            r.setFocus("SYNERGIES");
            r.run();

            int javaAssertedFactID = 1;

            for(int i = 0; i < params.getOrbitList().length; i++){
                for (String param: params.measurementsToInstruments.keySet()) {
                    Double therevtimesGlobal = revisitTime;
                    Double therevtimesUS = revisitTime;

                    String call = "(assert (ASSIMILATION2::UPDATE-REV-TIME (parameter " +  param + ") "
                            + "(avg-revisit-time-global# " + therevtimesGlobal + ") "
                            + "(avg-revisit-time-US# " + therevtimesUS + ")"
                            + "(factHistory J" + javaAssertedFactID + ")))";
                    javaAssertedFactID++;
                    r.eval(call);
                }
            }

            r.setFocus("ASSIMILATION2");
            r.run();

            r.setFocus("ASSIMILATION");
            r.run();

            r.setFocus("FUZZY");
            r.run();

            r.setFocus("SYNERGIES");
            r.run();

            r.setFocus("SYNERGIES-ACROSS-ORBITS");
            r.run();

//            r.eval("(facts MEASUREMENT)");

            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.setFocus("FUZZY-REQUIREMENTS");
            }
            else {
                r.setFocus("REQUIREMENTS");
            }
            r.run();

//            Fact fact;
//            Iterator factIterator = r.listFacts();
//
//            // Step 4: Loop through the facts and print them
//            while (factIterator.hasNext()) {
//                fact = (Fact) factIterator.next();
//                // Print the fact's details
//                System.out.println(fact);
//            }

            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.setFocus("FUZZY-AGGREGATION");
            }
            else {
                r.setFocus("AGGREGATION");
            }
            r.run();

            if ((params.reqMode.equalsIgnoreCase("CRISP-ATTRIBUTES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                result = aggregate_performance_score_facts(params, r, m, qb);
            }

            //////////////////////////////////////////////////////////////

            if (this.debug) {
                ArrayList<Fact> partials = qb.makeQuery("REASONING::partially-satisfied");
                ArrayList<Fact> fulls = qb.makeQuery("REASONING::fully-satisfied");
                fulls.addAll(partials);
                //result.setExplanations(fulls);
            }
        }
        catch (JessException e) {
            System.out.println(e.getMessage() + " " + e.getClass() + " ");
            e.printStackTrace();
        }
        catch (OrekitException e) {
            e.printStackTrace();
            throw new Error();
        }
        return result;
    }
}
