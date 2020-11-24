package seakers.vassar.evaluation;

import jess.*;
import org.hipparchus.util.FastMath;
import org.orekit.errors.OrekitException;
import org.orekit.frames.TopocentricFrame;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.event.EventIntervalMerger;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.coverage.CoverageAnalysis;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.spacecraft.SpacecraftDescription;
import seakers.vassar.utils.MatlabFunctions;

import java.util.*;

public class DSHIELDSimpleEvaluator extends AbstractArchitectureEvaluator {
    protected ArrayList<SpacecraftDescription> designs;
    protected String[][] factList;

    public DSHIELDSimpleEvaluator() {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = null;
    }

    public DSHIELDSimpleEvaluator(String[][] factList) {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = factList;
    }

    public DSHIELDSimpleEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type, String[][] factList) {
        this.resourcePool = resourcePool;
        this.arch = arch;
        this.type = type;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = factList;
    }

    @Override
    public AbstractArchitectureEvaluator getNewInstance() {
        return new DSHIELDSimpleEvaluator(super.resourcePool, super.arch, super.type, this.factList);
    }

    @Override
    public AbstractArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        return new DSHIELDSimpleEvaluator(resourcePool, arch, type, this.factList);
    }

    @Override
    public Result call() {
        checkInit();
        Resource res = this.resourcePool.getResource();
        BaseParams params = res.getParams();
        Rete r = res.getRete();
        QueryBuilder qb = res.getQueryBuilder();
        MatlabFunctions m = res.getM();
        Result result = new Result();

        result.setScience(evaluateScience(params,r,arch,qb,m));
        try {
            r.eval("(reset)");
            assertMissions(params,r,arch,m);
        } catch (Exception e) {
            System.out.println("EXC in Task:call: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            this.resourcePool.freeResource(res);
        }
        result.setCost(evaluateCosts(params,r,arch,qb,m));
        result.setCoverage(evaluateCoverage(params,r,arch,qb,m));

        this.resourcePool.freeResource(res);

        return result;
    }

    @Override
    protected void assertMissions(BaseParams params, Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {
        SimpleArchitecture arch = (SimpleArchitecture) inputArch;
        try {
            this.orbitsUsed = new HashSet<>();
            for (int i = 0; i < arch.getSatelliteList().size(); i++) {
                int ninstrs = arch.getSatelliteList().get(i).getInstrumentList().length;
                if (ninstrs > 0) {
                    String orbitName = arch.getSatelliteList().get(i).getOrbit();
                    Orbit orb = new Orbit(orbitName);
                    this.orbitsUsed.add(orb);

                    String payload = "";
                    String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";
                    for (int j = 0; j < ninstrs; j++) {
                        payload += " " + arch.getSatelliteList().get(i).getInstrumentList()[j];
                    }
                    call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                            + "(factHistory F" + params.nof + ")))";
                    params.nof++;

                    call += "(assert (SYNERGIES::cross-registered-instruments " +
                            " (instruments " + payload +
                            ") (degree-of-cross-registration spacecraft) " +
                            " (platform " + orbitName + " )"
                            + "(factHistory F" + params.nof + ")))";
                    params.nof++;
                    r.eval(call);
                }
            }
            int planes = arch.getNumPlanes();
            int satsPP = arch.getNumSatsPerPlane();
            r.eval("(defrule MANIFEST::fixWalker ?v <- (MANIFEST::Mission (Name ?name) (launch-cost# ?c1&~nil)) => (modify ?v (num-of-sats-per-plane# "+satsPP+") (num-of-planes# "+planes+")))");
        } catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }

    protected double evaluateScience(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m) {
        double science = 0;

        try {
            r.reset();
            assertMissions(params, r, arch, m);

            r.eval("(bind ?*science-multiplier* 1.0)");
            r.eval("(defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE))))");
            r.eval("(defadvice before (create$ sqrt + * **) (foreach ?xxx $?argv (if (eq ?xxx nil) then (bind ?xxx 0))))");

            //r.eval("(watch facts)");
            //r.eval("(rules CAPABILITIES)");

            r.setFocus("MANIFEST0"); r.run();
            r.setFocus("MANIFEST"); r.run();

            r.setFocus("CAPABILITIES"); r.run();
            r.setFocus("CAPABILITIES-REMOVE-OVERLAPS"); r.run();
            r.setFocus("CAPABILITIES-GENERATE"); r.run();
            r.setFocus("CAPABILITIES-CROSS-REGISTER"); r.run();
            r.setFocus("CAPABILITIES-UPDATE"); r.run();
            r.setFocus("SYNERGIES"); r.run();

            updateRevisitTimes(params, r, arch, qb, m, 1);

            r.setFocus("ASSIMILATION2");
            r.run();

            r.setFocus("ASSIMILATION");
            r.run();

            //r.setFocus("FUZZY");
            //r.run();

            r.setFocus("SYNERGIES");
            r.run();

            r.setFocus("SYNERGIES-ACROSS-ORBITS");
            r.run();

            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.setFocus("FUZZY-REQUIREMENTS");
            } else {
                r.setFocus("REQUIREMENTS");
            }
            r.run();

            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.setFocus("FUZZY-AGGREGATION");
            } else {
                r.setFocus("AGGREGATION");
            }
            r.run();
    
            if ((params.reqMode.equalsIgnoreCase("CRISP-ATTRIBUTES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                science = aggregate_performance_score_facts(params, r, m, qb).getScience();
            }

        } catch (JessException e) {
            System.out.println(e.getMessage() + " " + e.getClass() + " ");
            e.printStackTrace();
        } catch (OrekitException e) {
            e.printStackTrace();
            throw new Error();
        }
        return science;
    }

    protected double evaluateCosts(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m) {
        double cost = 0.0;
        try {
            long t0 = System.currentTimeMillis();

            r.setFocus("MANIFEST0");
            r.run();
            r.eval("(focus MANIFEST)");
            r.eval("(run)");

            r.setFocus("CAPABILITIES");                 r.run();
            r.setFocus("CAPABILITIES-REMOVE-OVERLAPS"); r.run();
            r.setFocus("CAPABILITIES-GENERATE");        r.run();
            r.setFocus("CAPABILITIES-CROSS-REGISTER");  r.run();
            r.setFocus("CAPABILITIES-UPDATE");          r.run();

            r.setFocus("SYNERGIES");
            r.run();

            updateRevisitTimes(params, r, arch, qb, m, 1);
            r.setFocus("ASSIMILATION2");
            r.run();
            r.setFocus("ASSIMILATION");
            r.run();

            designSpacecraft(r, arch, qb, m);
            r.eval("(focus SAT-CONFIGURATION)");
            r.eval("(run)");

            r.eval("(focus LV-SELECTION0)");
            r.eval("(run)");
            r.eval("(focus LV-SELECTION1)");
            r.eval("(run)");
            r.eval("(focus LV-SELECTION2)");
            r.eval("(run)");
            r.eval("(focus LV-SELECTION3)");
            r.eval("(run)");

            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.eval("(focus FUZZY-COST-ESTIMATION)");
            }
            else {
                r.eval("(focus COST-ESTIMATION)");
            }
            r.eval("(run)");


            FuzzyValue fzcost = new FuzzyValue("Cost", new Interval("delta",0,0),"FY04$M");
            ArrayList<Fact> missions = qb.makeQuery("MANIFEST::Mission");
            for (Fact mission: missions)  {
                cost = cost + mission.getSlotValue("lifecycle-cost#").floatValue(r.getGlobalContext());
                if (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES") || params.reqMode.equalsIgnoreCase("FUZZY-CASES")) {
                    fzcost = fzcost.add((FuzzyValue)mission.getSlotValue("lifecycle-cost").javaObjectValue(r.getGlobalContext()));
                }
            }


        }
        catch (JessException e) {
            System.out.println(e.toString());
            System.out.println("EXC in evaluateCost: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
        return cost;
    }

    protected ArrayList<Double> evaluateCoverage(BaseParams params, Rete r, AbstractArchitecture inputArch, QueryBuilder qb, MatlabFunctions m) {
        ArrayList<Double> coverage = new ArrayList<>();
        SimpleArchitecture arch = (SimpleArchitecture) inputArch;
        try {
            List<Map<TopocentricFrame, TimeIntervalArray>> fieldOfViewEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> pBandFieldOfViewEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> lBandFieldOfViewEvents = new ArrayList<>();
            int coverageGranularity = 20;
            CoverageAnalysis coverageAnalysis = new CoverageAnalysis(1, coverageGranularity, true, true, params.orekitResourcesPath);
            double[] latBounds = new double[]{FastMath.toRadians(-70), FastMath.toRadians(70)};
            double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};
            double maxInclination = 0;
            for(int i = 0; i < arch.getSatelliteList().size(); i++) {
                String orbName = arch.getSatelliteList().get(i).getOrbit();
                Orbit orb = new Orbit(orbName);


                double fieldOfView = 0.0;
                for(int j = 0; j < arch.getSatelliteList().get(i).getInstrumentList().length; j++) {
                    Value v = r.eval("(get-instrument-fov "+arch.getSatelliteList().get(i).getInstrumentList()[j]+")");
                    double temp = v.floatValue(r.getGlobalContext());
                    if(temp > fieldOfView) {
                        fieldOfView = temp;
                    }
                }
                double inclination = orb.getInclinationNum(); // [deg]
                if (inclination > maxInclination) {
                    maxInclination  = inclination;
                }
                double altitude = orb.getAltitudeNum(); // [m]
                double raan = orb.getRaanNum();
                double trueAnom = orb.getTrueAnomNum();
                String raanLabel = orb.getRaan();

                int numSatsPerPlane = 1;
                int numPlanes = 1;

                Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom);
                fieldOfViewEvents.add(accesses);
                List<String> insList = Arrays.asList(arch.getSatelliteList().get(i).getInstrumentList());
                if(insList.contains("P-band_SAR")) {
                    pBandFieldOfViewEvents.add(accesses);
                }
                if(insList.contains("L-band_SAR")) {
                    lBandFieldOfViewEvents.add(accesses);
                }

            }
            Map<TopocentricFrame, TimeIntervalArray> mergedEvents = new HashMap<>(fieldOfViewEvents.get(0));
            for (int i = 0; i < fieldOfViewEvents.size(); ++i) {
                Map<TopocentricFrame, TimeIntervalArray> event = fieldOfViewEvents.get(i);
                mergedEvents = EventIntervalMerger.merge(mergedEvents, event, false);
            }
            coverage.add(coverageAnalysis.getRevisitTime(mergedEvents,latBounds,lonBounds) / 3600);
            if(Math.toRadians(maxInclination) < Math.abs(latBounds[0])) {
                double[] newLatBounds = new double[]{FastMath.toRadians(-maxInclination), FastMath.toRadians(maxInclination)};
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedEvents,newLatBounds,lonBounds) / 3600);

            } else {
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedEvents,latBounds,lonBounds) / 3600);
            }


            if(pBandFieldOfViewEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                Map<TopocentricFrame, TimeIntervalArray> pBandMergedEvents = new HashMap<>(pBandFieldOfViewEvents.get(0));
                for (int i = 0; i < pBandFieldOfViewEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> pBandEvent = pBandFieldOfViewEvents.get(i);
                    pBandMergedEvents = EventIntervalMerger.merge(pBandMergedEvents, pBandEvent, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(pBandMergedEvents,latBounds,lonBounds) / 3600);
                if(Math.toRadians(maxInclination) < Math.abs(latBounds[0])) {
                    double[] newLatBounds = new double[]{FastMath.toRadians(-maxInclination), FastMath.toRadians(maxInclination)};
                    coverage.add(coverageAnalysis.getMaxRevisitTime(pBandMergedEvents,newLatBounds,lonBounds) / 3600);

                } else {
                    coverage.add(coverageAnalysis.getMaxRevisitTime(pBandMergedEvents,latBounds,lonBounds) / 3600);
                }
            }
            if(lBandFieldOfViewEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                Map<TopocentricFrame, TimeIntervalArray> lBandMergedEvents = new HashMap<>(lBandFieldOfViewEvents.get(0));
                for (int i = 0; i < lBandFieldOfViewEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> lBandEvent = lBandFieldOfViewEvents.get(i);
                    lBandMergedEvents = EventIntervalMerger.merge(lBandMergedEvents, lBandEvent, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(lBandMergedEvents,latBounds,lonBounds) / 3600);
                if(Math.toRadians(maxInclination) < Math.abs(latBounds[0])) {
                    double[] newLatBounds = new double[]{FastMath.toRadians(-maxInclination), FastMath.toRadians(maxInclination)};
                    coverage.add(coverageAnalysis.getMaxRevisitTime(lBandMergedEvents,newLatBounds,lonBounds) / 3600);

                } else {
                    coverage.add(coverageAnalysis.getMaxRevisitTime(lBandMergedEvents,latBounds,lonBounds) / 3600);
                }
            }
            coverage.add(coverageAnalysis.getPercentCoverage(mergedEvents,latBounds,lonBounds));

        } catch (Exception e) {
            System.out.println("EXC in evaluateCost: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            coverage.add(0.0);
            coverage.add(0.0);
            coverage.add(0.0);
            coverage.add(0.0);
            coverage.add(0.0);
            coverage.add(0.0);
            coverage.add(0.0);
        }
        return coverage;
    }

    protected void designSpacecraft(Rete r, SimpleArchitecture arch, QueryBuilder qb, MatlabFunctions m) {
        try {
            overrideFacts(r);

            r.eval("(focus PRELIM-MASS-BUDGET)");
            r.eval("(run)");

            ArrayList<Fact> missions = qb.makeQuery("MANIFEST::Mission");
            Double[] oldmasses = new Double[missions.size()];
            for (int i = 0; i < missions.size(); i++) {
                oldmasses[i] = missions.get(i).getSlotValue("satellite-dry-mass").floatValue(r.getGlobalContext());
            }
            Double[] diffs = new Double[missions.size()];
            double tolerance = 10*missions.size();
            boolean converged = false;
            while (!converged) {
                r.eval("(focus CLEAN1)");
                r.eval("(run)");

                r.eval("(focus MASS-BUDGET)");
                r.eval("(run)");

                r.eval("(focus CLEAN2)");
                r.eval("(run)");

                r.eval("(focus UPDATE-MASS-BUDGET)");
                r.eval("(run)");

                Double[] drymasses = new Double[missions.size()];
                double sumdiff = 0.0;
                double summasses = 0.0;
                for (int i = 0; i < missions.size(); i++) {
                    drymasses[i] = missions.get(i).getSlotValue("satellite-dry-mass").floatValue(r.getGlobalContext());
                    diffs[i] = Math.abs(drymasses[i] - oldmasses[i]);
                    sumdiff += diffs[i];
                    summasses += drymasses[i];
                }
                converged = sumdiff < tolerance || summasses == 0;
                oldmasses = drymasses;
            }
        }
        catch (Exception e) {
            System.out.println("EXC in evaluateCost: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }

    protected void overrideFacts(Rete r) throws JessException {
        // Overrides facts related to the architecture design

        if(this.factList != null) {
            Iterator modList = r.listFacts();
            Fact modFact;
            for (Iterator it = modList; it.hasNext(); ) {
                Fact factTemp = (Fact) it.next();
                if (factTemp.getName().equals("MANIFEST::Mission")) {
                    modFact = factTemp;
                    for (int i = 0; i < factList.length; i++) {
                        Value val = new Value(Double.parseDouble(factList[i][1]), 4);
                        r.modify(modFact, factList[i][0], val);
                    }
                    break;
                }
            }
        }
    }

    protected void updateRevisitTimes(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m, int javaAssertedFactID) throws JessException {
        // Check if all of the orbits in the original formulation are used
        double revTime = 0;
        int[] revTimePrecomputedIndex = new int[params.getOrbitList().length];
        String[] revTimePrecomputedOrbitList = {"LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-DD", "SSO-800-SSO-PM"};

        for (int i = 0; i < params.getOrbitList().length; i++) {
            String orb = params.getOrbitList()[i];
            int matchedIndex = -1;
            for (int j = 0; j < revTimePrecomputedOrbitList.length; j++) {
                if (revTimePrecomputedOrbitList[j].equalsIgnoreCase(orb)) {
                    matchedIndex = j;
                    break;
                }
            }

            // Assign -1 if unmatched. Otherwise, assign the corresponding index
            revTimePrecomputedIndex[i] = matchedIndex;
        }

        for (String param : params.measurementsToInstruments.keySet()) {
            Value v = r.eval("(update-fovs " + param + " (create$ " + m.stringArraytoStringWithSpaces(params.getOrbitList()) + "))");

            if (RU.getTypeName(v.type()).equalsIgnoreCase("LIST")) {

                ValueVector thefovs = v.listValue(r.getGlobalContext());
                String[] fovs = new String[thefovs.size()];
                for (int i = 0; i < thefovs.size(); i++) {
                    int tmp = thefovs.get(i).intValue(r.getGlobalContext());
                    fovs[i] = String.valueOf(tmp);
                }

                boolean recalculateRevisitTime = false;
                for (int i = 0; i < fovs.length; i++) {
                    if (revTimePrecomputedIndex[i] == -1) {
                        // If there exists a single orbit that is different from pre-calculated ones, re-calculate
                        recalculateRevisitTime = true;
                    }
                }

                Double therevtimesGlobal;
                Double therevtimesUS;

                if (recalculateRevisitTime) {
                    // Do the re-calculation of the revisit times

                    int coverageGranularity = 20;

                    //Revisit times
                    CoverageAnalysis coverageAnalysis = new CoverageAnalysis(1, coverageGranularity, true, true, params.orekitResourcesPath);
                    double[] latBounds = new double[]{FastMath.toRadians(-70), FastMath.toRadians(70)};
                    double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};

                    List<Map<TopocentricFrame, TimeIntervalArray>> fieldOfViewEvents = new ArrayList<>();

                    // For each fieldOfview-orbit combination
                    for (Orbit orb : this.orbitsUsed) {
                        int fov = thefovs.get(params.getOrbitIndexes().get(orb.toString())).intValue(r.getGlobalContext());

                        if (fov <= 0) {
                            continue;
                        }

                        double fieldOfView = fov; // [deg]
                        double inclination = orb.getInclinationNum(); // [deg]
                        double altitude = orb.getAltitudeNum(); // [m]
                        double raan = orb.getRaanNum();
                        //double trueAnom = orb.getTrueAnomNum();
                        String raanLabel = orb.getRaan();

                        int numSatsPerPlane = Integer.parseInt(orb.getNum_sats_per_plane());
                        int numPlanes = Integer.parseInt(orb.getNplanes());

                        Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, 0.0);
                        fieldOfViewEvents.add(accesses);
                    }

                    // Merge accesses to get the revisit time
                    Map<TopocentricFrame, TimeIntervalArray> mergedEvents = new HashMap<>(fieldOfViewEvents.get(0));

                    for (int i = 0; i < fieldOfViewEvents.size(); ++i) {
                        Map<TopocentricFrame, TimeIntervalArray> event = fieldOfViewEvents.get(i);
                        mergedEvents = EventIntervalMerger.merge(mergedEvents, event, false);
                    }
                    therevtimesGlobal = coverageAnalysis.getRevisitTime(mergedEvents, latBounds, lonBounds) / 3600;
                    therevtimesUS = therevtimesGlobal;

                } else {
                    // Re-assign fovs based on the original orbit formulation, if the number of orbits is less than 5
                    if (thefovs.size() < 5) {
                        String[] new_fovs = new String[5];
                        for (int i = 0; i < 5; i++) {
                            if (i < thefovs.size()) {
                                new_fovs[i] = fovs[revTimePrecomputedIndex[i]];
                            } else {
                                new_fovs[i] = "-1";
                            }
                        }
                        fovs = new_fovs;
                    }
//                        String key = "1" + " x " + m.stringArraytoStringWith(fovs, "  ");
                    String key = m.stringArraytoStringWith(fovs, "  ");
                    therevtimesUS = params.revtimes.get(key);
                    therevtimesGlobal = params.revtimes.get(key);
                }
                String call = "(assert (ASSIMILATION2::UPDATE-REV-TIME (parameter " + param + ") "
                        + "(avg-revisit-time-global# " + therevtimesGlobal + ") "
                        + "(avg-revisit-time-US# " + therevtimesUS + ")"
                        + "(factHistory J" + javaAssertedFactID + ")))";
                javaAssertedFactID++;
                r.eval(call);
            }
        }
    }
}
