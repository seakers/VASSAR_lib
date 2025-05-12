package seakers.vassar.problems.Assigning;

import jess.*;
import org.orekit.errors.OrekitException;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.MatlabFunctions;
import org.hipparchus.util.FastMath;
import org.orekit.frames.TopocentricFrame;
import seakers.vassar.coverage.CoverageAnalysis;
import seakers.vassar.BaseParams;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.event.EventIntervalMerger;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.DateComponents;
import org.orekit.time.TimeComponents;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;

import java.util.*;
import java.util.concurrent.Callable;
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
                double rightAscensionAscendingNode = orbit.getDouble("rightAscensionAscendingNode");
                double trueAnomaly = orbit.getDouble("trueAnomaly");

                // Determine inclination type
                if (orbitType.contains("SSO")) {
                    type = "SSO";
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

                String orbitName = type + "-" + orbit.getInt("altitude") + "-" + inclination_type + "-" + raan;
                System.out.println("orbitName: " + orbitName);

                Orbit orb = new Orbit(orbitName, 1, 1);
                this.orbitsUsed.add(orb);
                r.reset();
                r.eval("(deftemplate ORBIT (slot orbitName) (slot altitude#) (slot inclination) (slot RAAN) (slot type))");
                String orbitFact = String.format(
                    "(assert (ORBIT (orbitName \"%s\") (altitude# %d) (inclination %f) (RAAN %f) (type \"%s\")))",
                    orbitName, orbit.getInt("altitude"), inclination, rightAscensionAscendingNode, orbitType
                );
                System.out.println("Asserting ORBIT fact: " + orbitFact);
                r.eval(orbitFact);
            
                String payload = "";
                String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";

                JSONArray payloads = satellite.getJSONArray("payload");
                HashMap<String,Fact> db_instruments = new HashMap<>();
                String payloadString = "";

                for (int j = 0; j < payloads.length(); j++) {
                    JSONObject payloadObj = payloads.getJSONObject(j);
                    String instrumentName = payloadObj.getString("name").replace(" ", "_");
                    payload += " " + instrumentName;
                    payloadString += " " + instrumentName;

                    // Extract instrument information
                    double dx = Math.cbrt(payloadObj.getDouble("volume"));
                    double dy = dx;
                    double dz = dx;
                    double mass = payloadObj.getDouble("mass");
                    double avgPower = payloadObj.getDouble("power");
                    double peakPower = payloadObj.getDouble("power");
                    double avgDataRate = payloadObj.getDouble("dataRate");
                    double charPower = payloadObj.getDouble("power");
                    double apertureDia = payloadObj.getDouble("apertureDia");
                    double bandwidth = payloadObj.getDouble("bandwidth");
                    double FOV = payloadObj.getJSONObject("fieldOfView").getDouble("crossTrackFieldOfView");
                    System.out.println("FOV: " + FOV);
                    
                    // Validate FOV value
                    if (FOV <= 0 || Double.isInfinite(FOV)) {
                        System.err.println("Warning: Invalid FOV value for instrument " + instrumentName + ". Using default value.");
                        FOV = 55.0; // Default FOV value
                    }
                    
                    double frequency = 299792458/payloadObj.getDouble("operatingWavelength");
                    
                    // Add validation for critical values
                    if (frequency <= 0 || Double.isInfinite(frequency)) {
                        System.err.println("Warning: Invalid frequency value for instrument " + instrumentName + ". Using default value.");
                        frequency = 10.0e9; // Default to 10 GHz (X-band) which is common for Earth observation
                    }
                    
                    String hasDeploymentMechanism = "yes";
                    if (payloadObj.getString("mountType").equals("BODY")) {
                        hasDeploymentMechanism = "no";
                    }
                    String scanning = "cross-track";
                    int TRL = payloadObj.getInt("techReadinessLevel");
                    String geometry;
                    if (payloadObj.getJSONObject("orientation").getDouble("sideLookAngle") == 0) {
                        geometry = "nadir";
                    }
                    else {
                        geometry = "slant";
                    }

                    // Assert facts into Jess for DATABASE::Instrument
                    String dbFact = "(assert (DATABASE::Instrument (Name " + instrumentName + ") " +
                            "(mass# " + mass + ") (average-power# " + avgPower + ") (peak-power# " + peakPower + ") " +
                            "(average-data-rate# " + avgDataRate + ") (dimension-x# " + dx + ") " +
                            "(dimension-y# " + dy + ") (dimension-z# " + dz + ") " +
                            "(characteristic-power# " + charPower + ") (cost# nil) (All-weather yes) (Aperture# " + apertureDia + ") " +
                            "(bandwidth# " + bandwidth + ") (characteristic-orbit " + (semimajorAxis-6378) + ") (Day-Night Day-and-night) " +
                            "(Field-of-view# " + FOV + ") (frequency# " + frequency + ") (has-deployment-mechanism " + hasDeploymentMechanism + ") " +
                            "(scanning " + scanning + ") (Technology-Readiness-Level " + TRL + ") (factHistory "+ params.nof +") (Geometry " + geometry + ")))";
                    params.nof++;
                    r.eval(dbFact);  // Assert DATABASE::Instrument fact

                    // Assert facts into Jess for CAPABILITIES::Manifested-instrument
                    String manifestFact = "(assert (CAPABILITIES::Manifested-instrument (Name " + instrumentName + ") " +
                            "(mass# " + mass + ") (average-power# " + avgPower + ") (peak-power# " + peakPower + ") " +
                            "(average-data-rate# " + avgDataRate + ") (dimension-x# " + dx + ") " +
                            "(dimension-y# " + dy + ") (dimension-z# " + dz + ") " +
                            "(characteristic-power# " + charPower + ") (cost# nil) (factHistory "+ params.nof +")))";
                    params.nof++;
                    r.eval(manifestFact);  // Assert CAPABILITIES::Manifested-instrument fact

                    ArrayList<Fact> facts = qb.makeQuery("DATABASE::Instrument (Name " + instrumentName + ")");
                    Fact f = facts.get(0);
                    db_instruments.put(instrumentName, f);

                    String canMeasure = "(assert (CAPABILITIES::can-measure (instrument " + instrumentName + ") (in-orbit " + orbitName + ") " +
                            "(orbit-type " + orbitType + ") (orbit-altitude# " + (semimajorAxis-6378) + ") (data-rate-duty-cycle# nil) " +
                            "(power-duty-cycle# nil) (data-rate-constraint nil) (orbit-inclination " + inclination + ") " +
                            "(orbit-RAAN " + rightAscensionAscendingNode + ") (can-take-measurements yes) (reason \"by default\") (copied-to-measurement-fact no) (factHistory " + params.nof + ")))";
                    params.nof++;
                    r.eval(canMeasure);
                }

                qb.addPrecomputedQuery("DATABASE::Instrument", db_instruments);

                r.eval("(deftemplate DATABASE::list-of-instruments (multislot list) (slot factHistory))");
                r.eval("(deffacts DATABASE::list-of-instruments (DATABASE::list-of-instruments " +
                        "(list (create$ " + payloadString + ")) (factHistory "+ params.nof +")))");
                params.nof++;

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
        System.out.println("THIS IS THE REAL SOURCE FILE BEING COMPILED");
        Result result = new Result();
        long startTime = System.currentTimeMillis();
        final long TIMEOUT_MS = 300000; // 5 minutes timeout

        // Create a timeout thread
        Thread timeoutThread = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                if (System.currentTimeMillis() - startTime > TIMEOUT_MS) {
                    System.err.println("Timeout reached after " + (System.currentTimeMillis() - startTime)/1000 + " seconds");
                    return; // Just return from the thread, don't force exit
                }
                try {
                    Thread.sleep(1000); // Check every second
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        });
        timeoutThread.setDaemon(true);
        timeoutThread.start();

        try {
            // Initializations
            System.out.println("Initializing Jess engine...");
            Rete r = new Rete();
            QueryBuilder qb = new QueryBuilder(r);
            MatlabFunctions m = new MatlabFunctions(new Resource(params));
            r.addUserfunction(m);
            JessInitializer.getInstance().initializeJess(params, r, qb, m);
            r.reset();

            // Check timeout before each major operation
            if (System.currentTimeMillis() - startTime > TIMEOUT_MS) {
                System.err.println("Timeout reached after " + (System.currentTimeMillis() - startTime)/1000 + " seconds");
                return new Result(); // Return empty result with default score of 0
            }
    
            System.out.println("Asserting missions from JSON...");
            assertMissionsFromJSON(params, inputData, qb, r, m);
            // Iterator factIterator = r.listFacts();
            // while (factIterator.hasNext()) {
            //     Fact f = (Fact) factIterator.next();
            //     System.out.println(f.getName() + ": " + f.toString());
            // }

    
            // Check timeout
            if (System.currentTimeMillis() - startTime > TIMEOUT_MS) {
                System.err.println("Timeout reached after " + (System.currentTimeMillis() - startTime)/1000 + " seconds");
                return new Result();
            }

            System.out.println("Setting up Jess rules...");
            r.eval("(bind ?*science-multiplier* 1.0)");
            r.eval("(defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE))))");
            r.eval("(defadvice before (create$ sqrt + * **) (foreach ?xxx $?argv (if (eq ?xxx nil) then (bind ?xxx 0))))");
    
            // Run Jess rules with timeout checks
            String[] ruleModules = {
                "MANIFEST0", "MANIFEST", "CAPABILITIES", "CAPABILITIES-REMOVE-OVERLAPS",
                "CAPABILITIES-GENERATE", "CAPABILITIES-CROSS-REGISTER", "CAPABILITIES-UPDATE",
                "SYNERGIES", "SYNERGIES-ACROSS-ORBITS"
            };

            for (String module : ruleModules) {
                if (System.currentTimeMillis() - startTime > TIMEOUT_MS) {
                    System.err.println("Timeout reached while running " + module + " rules");
                    return new Result();
                }

                System.out.println("Running " + module + " rules...");
                try {
                    r.setFocus(module);
                    System.out.println("Executing " + module + " rules...");
                    
                    // Set a timeout for the rule execution
                    Thread ruleThread = new Thread(() -> {
                        try {
                            r.run();
                        } catch (Exception e) {
                            System.err.println("Error in rule execution: " + e.getMessage());
                            e.printStackTrace();
                        }
                    });
                    ruleThread.start();
                    
                    // Wait for the rule execution with a timeout
                    ruleThread.join(60000); // 30 seconds per module
                    
                    if (ruleThread.isAlive()) {
                        System.err.println("Rule execution timed out for module: " + module);
                        ruleThread.interrupt();
                        return new Result();
                    }
                    
                    System.out.println(module + " rules completed successfully");
                } catch (Exception e) {
                    System.err.println("Error in " + module + " rules: " + e.getMessage());
                    e.printStackTrace();
                    if (e.getCause() instanceof OutOfMemoryError) {
                        System.err.println("OutOfMemoryError detected, returning default result");
                        return new Result();
                    }
                }
            }

            int javaAssertedFactID = 1;
    
            int[] revTimePrecomputedIndex = new int[params.getOrbitList().length];
            String[] revTimePrecomputedOrbitList = {
                "LEO-600-polar-NA", "SSO-600-SSO-AM", 
                "SSO-600-SSO-DD", "SSO-800-SSO-DD", "SSO-800-SSO-PM"
            };
    
            for (int i = 0; i < params.getOrbitList().length; i++) {
                String orb = params.getOrbitList()[i];
                int matchedIndex = -1;
                for (int j = 0; j < revTimePrecomputedOrbitList.length; j++) {
                    if (revTimePrecomputedOrbitList[j].equalsIgnoreCase(orb)) {
                        matchedIndex = j;
                        break;
                    }
                }
                revTimePrecomputedIndex[i] = matchedIndex;
            }
    
            System.out.println("Processing measurements...");
            
            // Remove debug prints for precomputed FOV combinations
            Set<String> availableKeys = new HashSet<>();
            for (String key : params.revtimes.keySet()) {
                Map<String, Double> revs = params.revtimes.get(key);
                if (revs != null && (revs.containsKey("US") || revs.containsKey("Global"))) {
                    availableKeys.add(key);
                }
            }

            for (String param : params.measurementsToInstruments.keySet()) {
                Value v = r.eval("(update-fovs " + param + " (create$ " 
                    + m.stringArraytoStringWithSpaces(params.getOrbitList()) + "))");

                
    
                if (!RU.getTypeName(v.type()).equalsIgnoreCase("LIST")) {
                    continue;  // skip this param since no FOVs
                }
    
                // Extract thefovs[] first
                ValueVector thefovs = v.listValue(r.getGlobalContext());
                String[] fovs = new String[thefovs.size()];
                for (int i = 0; i < thefovs.size(); i++) {
                    int tmp = thefovs.get(i).intValue(r.getGlobalContext());
                    fovs[i] = String.valueOf(tmp);
                }

                // THEN map orbitsUsed to the correct index in thefovs[]
                int l = 0;
                for (Orbit orb : this.orbitsUsed) {
                    if (!params.getOrbitIndexes().containsKey(orb.toString())) {
                        params.getOrbitIndexes().put(orb.toString(), l);
                    }
                    l++;
                }
                                // Create the key for this combination
                StringBuilder keyBuilder = new StringBuilder("1 x");
                for (String fov : fovs) {
                    keyBuilder.append(" ").append(fov);
                }
                String key = keyBuilder.toString();

                Map<String, Double> revs = params.revtimes.get(key);

                boolean fallbackToOrekit = false;

                if (revs == null) {
                    // Attempt closest match by replacing -1 with 55
                    String[] modifiedFovs = fovs.clone();
                    boolean hadMinusOne = false;
                    for (int i = 0; i < modifiedFovs.length; i++) {
                        if (modifiedFovs[i].equals("-1")) {
                            modifiedFovs[i] = "55";
                            hadMinusOne = true;
                        }
                    }
                    StringBuilder modifiedKeyBuilder = new StringBuilder("1 x");
                    for (String fov : modifiedFovs) {
                        modifiedKeyBuilder.append(" ").append(fov);
                    }
                    String modifiedKey = modifiedKeyBuilder.toString();
                    revs = params.revtimes.get(modifiedKey);

                    if (revs == null) {
                        // No lookup match found → trigger Orekit
                        fallbackToOrekit = true;
                    }
                }

                // Fallback using Orekit-based calculation if needed
                double revGlobal, revUS;
                if (fallbackToOrekit) {
                    System.out.println("Revisit key not found, recalculating revisit using Orekit for param: " + param);
                    CoverageAnalysis coverageAnalysis = new CoverageAnalysis(1, 20, true, true, params.orekitResourcesPath);
                    double[] latBounds = {FastMath.toRadians(-70), FastMath.toRadians(70)};
                    double[] lonBounds = {FastMath.toRadians(-180), FastMath.toRadians(180)};
                    List<Map<TopocentricFrame, TimeIntervalArray>> fieldOfViewEvents = new ArrayList<>();

                    for (int i = 0; i < params.getOrbitList().length; i++) {
                        String orbitName = params.getOrbitList()[i];
                        Orbit orb = this.orbitsUsed.stream().filter(o -> o.toString().equals(orbitName)).findFirst().orElse(null);
                        if (orb == null) {
                            System.err.println("Orbit " + orbitName + " not found in orbitsUsed, skipping.");
                            continue;
                        }
                    
                        int fov = thefovs.get(i).intValue(r.getGlobalContext());
                        if (fov <= 0) {
                            System.err.println("Invalid FOV " + fov + " for orbit: " + orb);
                            continue;
                        }
                    
                        try {
                            Map<TopocentricFrame, TimeIntervalArray> accesses =
                                coverageAnalysis.getAccesses(fov, orb.getInclinationNum(), orb.getAltitudeNum(),
                                    Integer.parseInt(orb.getNum_sats_per_plane()),
                                    Integer.parseInt(orb.getNplanes()), orb.getRaan());
                            fieldOfViewEvents.add(accesses);
                        } catch (Exception e) {
                            System.err.println("Error computing accesses for orbit: " + orb + " → " + e.getMessage());
                        }
                    }
                    
                    

                    if (fieldOfViewEvents.isEmpty()) {
                        revGlobal = revUS = 24.0; // Safe fallback if Orekit returns empty
                    } else {
                        Map<TopocentricFrame, TimeIntervalArray> mergedEvents = fieldOfViewEvents.get(0);
                        for (int i = 1; i < fieldOfViewEvents.size(); i++) {
                            mergedEvents = EventIntervalMerger.merge(mergedEvents, fieldOfViewEvents.get(i), false);
                        }
                        revGlobal = coverageAnalysis.getRevisitTime(mergedEvents, latBounds, lonBounds) / 3600.0;
                        revUS = revGlobal;
                    }
                } else {
                    revGlobal = revs.getOrDefault("Global", 24.0);
                    revUS = revs.getOrDefault("US", 24.0);
                }
                if (fallbackToOrekit) {
                    HashMap<String, Double> newRevs = new HashMap<>();
                    newRevs.put("Global", revGlobal);
                    newRevs.put("US", revUS);
                    params.revtimes.put(key, newRevs);
                    System.out.println("Cached new revisit times for key: " + key);
                }
                

                r.eval("(assert (ASSIMILATION2::UPDATE-REV-TIME (parameter " + param + ") "
                    + "(avg-revisit-time-global# " + revGlobal + ") "
                    + "(avg-revisit-time-US# " + revUS + ")"
                    + "(factHistory J" + javaAssertedFactID++ + ")))");
            }
                    
            r.setFocus("ASSIMILATION2"); r.run();
            r.setFocus("ASSIMILATION"); r.run();
            r.setFocus("FUZZY"); r.run();
            r.setFocus("SYNERGIES"); r.run();
            r.setFocus("SYNERGIES-ACROSS-ORBITS"); r.run();
    
            String reqMode = params.reqMode;
            r.setFocus(reqMode.contains("FUZZY") ? "FUZZY-REQUIREMENTS" : "REQUIREMENTS"); r.run();
            r.setFocus(reqMode.contains("FUZZY") ? "FUZZY-AGGREGATION" : "AGGREGATION"); r.run();
    
            if (reqMode.contains("ATTRIBUTES")) {
                result = aggregate_performance_score_facts(params, r, m, qb);
            }
    
        } catch (OutOfMemoryError e) {
            System.err.println("OutOfMemoryError caught: " + e.getMessage());
            e.printStackTrace();
            return new Result(); // Return empty result with default score of 0
        } catch (Exception e) {
            System.err.println("Exception caught: " + e.getMessage());
            e.printStackTrace();
            return new Result(); // Return empty result with default score of 0
        } finally {
            timeoutThread.interrupt(); // Clean up the timeout thread
        }
        return result;
    }
    
}
