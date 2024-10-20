package seakers.vassar.problems.Assigning;

import jess.*;
import org.orekit.errors.OrekitException;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.MatlabFunctions;

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

    protected void assertMissionsFromJSON(BaseParams params, JSONObject arch, Rete r, MatlabFunctions m) {

        try {

            JSONArray satellites = arch.getJSONArray("satellites");
            for (int i = 0; i < satellites.length(); i++) {
                JSONObject satellite = satellites.getJSONObject(i);
                JSONObject orbit = satellite.getJSONObject("orbit");
                String orbitType = orbit.getString("orbitType");
                double semimajorAxis = orbit.getDouble("semimajorAxis");
                double inclination = orbit.getDouble("inclination");
                double eccentricity = orbit.getDouble("eccentricity");
                double periapsisArgument = orbit.getDouble("periapsisArgument");
                double rightAscensionAscendingNode = orbit.getDouble("rightAscensionAscendingNode");
                double trueAnomaly = orbit.getDouble("trueAnomaly");

                String orbitName = orbitType + "-" +
                        String.format("%f", semimajorAxis) + "-" +
                        String.format("%f", inclination) + "-" +
                        String.format("%f", eccentricity) + "-" +
                        String.format("%f", periapsisArgument) + "-" +
                        String.format("%f", rightAscensionAscendingNode) + "-" +
                        String.format("%f", trueAnomaly);

                String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";

                String orbJessString = " (num-of-planes# " + "1" + ")" +
                        " (num-of-sats-per-plane# "  + "1" + ")"  +
                        " (mission-architecture " + "single_arch" + ")" +
                        " (orbit-type " + orbitType + ")"  +
                        " (orbit-altitude# "  + String.format("%f", semimajorAxis-6378) + ")"  +
                        " (orbit-eccentricity "  + String.format("%f", eccentricity) + ")"  +
                        " (orbit-RAAN " + String.format("%f", rightAscensionAscendingNode) + ")"  +
                        " (orbit-inclination " + String.format("%f", inclination) + ")"  +
                        " (orbit-string " + orbitName + ")";

                JSONArray payloads = satellite.getJSONArray("payload");

                String payloadString = "";
                for (int j = 0; j < payloads.length(); j++) {
                    JSONObject payload = payloads.getJSONObject(j);

                    // Extract instrument information
                    String instrumentName = payload.getString("name").replace(" ", "_");  // Replace spaces with underscores
                    payloadString += " " + instrumentName;
                    double dx = Math.cbrt(payload.getDouble("volume"));
                    double dy = dx;
                    double dz = dx;
                    double mass = payload.getDouble("mass");
                    double avgPower = payload.getDouble("power");
                    double peakPower = payload.getDouble("power");
                    double avgDataRate = payload.getDouble("dataRate");
                    double charPower = payload.getDouble("power");

                    // Assert facts into Jess for DATABASE::Instrument
                    String dbFact = "(assert (DATABASE::Instrument (Name " + instrumentName + ") " +
                            "(mass# " + mass + ") (average-power# " + avgPower + ") (peak-power# " + peakPower + ") " +
                            "(average-data-rate# " + avgDataRate + ") (dimension-x# " + dx + ") " +
                            "(dimension-y# " + dy + ") (dimension-z# " + dz + ") " +
                            "(characteristic-power# " + charPower + ") (cost# nil)))";
                    r.eval(dbFact);  // Assert DATABASE::Instrument fact

                    // Assert facts into Jess for CAPABILITIES::Manifested-instrument
                    String manifestFact = "(assert (CAPABILITIES::Manifested-instrument (Name " + instrumentName + ") " +
                            "(mass# " + mass + ") (average-power# " + avgPower + ") (peak-power# " + peakPower + ") " +
                            "(average-data-rate# " + avgDataRate + ") (dimension-x# " + dx + ") " +
                            "(dimension-y# " + dy + ") (dimension-z# " + dz + ") " +
                            "(characteristic-power# " + charPower + ") (cost# nil)))";
                    r.eval(manifestFact);  // Assert CAPABILITIES::Manifested-instrument fact
                }

                call += "(instruments " + payloadString + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orbJessString + ""
                        + "(factHistory F" + params.nof + ")))";
                params.nof++;

                call += "(assert (SYNERGIES::cross-registered-instruments " +
                        " (instruments " + payloadString +
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

    public Result evaluatePerformanceFromJSON(JSONObject inputData, BaseParams params) {
        Result result = new Result();
        try {
            // Initializations
            Rete r = new Rete();
            QueryBuilder qb = new QueryBuilder(r);
            MatlabFunctions m = new MatlabFunctions(new Resource(params));
            r.addUserfunction(m);
            JessInitializer.getInstance().initializeJess(params, r, qb, m);

            r.reset();
            assertMissionsFromJSON(params, inputData, r, m);

            r.eval("(bind ?*science-multiplier* 1.0)");
            r.eval("(defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE))))");
            r.eval("(defadvice before (create$ sqrt + * **) (foreach ?xxx $?argv (if (eq ?xxx nil) then (bind ?xxx 0))))");

            //r.eval("(watch rules)");
            //r.eval("(facts)");

            r.setFocus("MANIFEST0");
            r.run();

//
//            Fact fact;
//            Iterator factIterator = r.listFacts();
//
//            // Step 4: Loop through the facts and print them
//            while (factIterator.hasNext()) {
//                fact = (Fact) factIterator.next();
//                // Print the fact's details
//                System.out.println(fact);
//            }

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
                    Double therevtimesGlobal = 10.0;
                    Double therevtimesUS = 10.0;

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

            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.setFocus("FUZZY-REQUIREMENTS");
            }
            else {
                r.setFocus("REQUIREMENTS");
            }
            r.run();

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
