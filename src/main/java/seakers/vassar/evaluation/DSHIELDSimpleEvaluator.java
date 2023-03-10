package seakers.vassar.evaluation;

import jess.*;
import org.hipparchus.util.FastMath;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.data.DataProvidersManager;
import org.orekit.errors.OrekitException;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.orbits.KeplerianOrbit;
import org.orekit.orbits.PositionAngle;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;
import org.orekit.bodies.BodyShape;
import org.orekit.bodies.OneAxisEllipsoid;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.coverage.analysis.GroundEventAnalyzer;
import seakers.orekit.event.EventIntervalMerger;
import seakers.orekit.object.Instrument;
import seakers.orekit.object.Satellite;
import seakers.orekit.object.fieldofview.NadirRectangularFOV;
import seakers.orekit.object.fieldofview.NadirSimpleConicalFOV;
import seakers.vassar.*;
import seakers.vassar.SMDP.DSHIELDSimplePlanner;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.coverage.*;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.spacecraft.SpacecraftDescription;
import seakers.vassar.utils.MatlabFunctions;
import seakers.orekit.analysis.OverlapAnalysis;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.*;

@SuppressWarnings({"rawtypes"})

public class DSHIELDSimpleEvaluator extends AbstractArchitectureEvaluator {
    protected ArrayList<SpacecraftDescription> designs;
    protected String[][] factList;

    protected double[] smError;

    public DSHIELDSimpleEvaluator() {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = null;
        this.smError = null;
    }

    public DSHIELDSimpleEvaluator(double[] smError) {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = null;
        this.smError = smError;
    }

    public DSHIELDSimpleEvaluator(String[][] factList) {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = factList;
        this.smError = null;
    }

    public DSHIELDSimpleEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type, String[][] factList, double[] smError) {
        this.resourcePool = resourcePool;
        this.arch = arch;
        this.type = type;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = factList;
        this.smError = smError;
    }

    @Override
    public AbstractArchitectureEvaluator getNewInstance() {
        return new DSHIELDSimpleEvaluator(super.resourcePool, super.arch, super.type, this.factList,this.smError);
    }

    @Override
    public AbstractArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        return new DSHIELDSimpleEvaluator(resourcePool, arch, type, this.factList,this.smError);
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
        result.setExplanations(aggregate_performance_score_facts(params, r, m, qb).getExplanations());
        result.setCapabilities(aggregate_performance_score_facts(params, r, m, qb).getCapabilities());
        //result.setScience(0.0);
        try {
            r.eval("(reset)");
            assertMissions(params,r,arch,m);
        } catch (Exception e) {
            System.out.println("EXC in Task:call: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            this.resourcePool.freeResource(res);
        }

        //result.setCoverage(evaluateCoverage(params,r,arch,qb,m));

        result.setCost(evaluateCosts(params,r,arch,qb,m));


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
                    call += "(instruments " + payload + ") (lifetime 10) (launch-date 2023) (slew-rate 0.052) (select-orbit no) " + orb.toJessSlots() + ""
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
//            int planes = arch.getNumPlanes();
//            int satsPP = arch.getNumSatsPerPlane();
//            r.eval("(defrule MANIFEST::fixWalker ?v <- (MANIFEST::Mission (Name ?name) (launch-cost# ?c1&~nil)) => (modify ?v (num-of-sats-per-plane# "+satsPP+") (num-of-planes# "+planes+")))");
        } catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }

    protected void setOverlap(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m) throws JessException {
        OverlapAnalysis oa = new OverlapAnalysis(params.orekitResourcesPath);
        ArrayList<Double> orbitHeights = new ArrayList<>();
        ArrayList<Double> orbitInclinations = new ArrayList<>();
        ArrayList<Double> orbitRAANs = new ArrayList<>();
        ArrayList<Double> orbitAnomalies = new ArrayList<>();
        for (Orbit orb : this.orbitsUsed) {
            double inclination = orb.getInclinationNum(); // [deg]
            double altitude = orb.getAltitudeNum(); // [m]
            double raan = orb.getRaanNum();
            double trueAnom = orb.getTrueAnomNum();
            orbitHeights.add(altitude);
            orbitInclinations.add(inclination);
            orbitRAANs.add(raan);
            orbitAnomalies.add(trueAnom);
        }
        Double overlapResult = oa.evaluateOverlap(orbitHeights, orbitInclinations, orbitRAANs, orbitAnomalies,30.0);
        int javaAssertedFactID = 25;
        for (String param : params.measurementsToInstruments.keySet()) {
            String call2 = "(assert (ASSIMILATION2::UPDATE-OVERLAP (parameter " + param + ") "
                    + "(overlap-time# " + overlapResult + ") "
                    + "(factHistory J" + javaAssertedFactID + ")))";
            javaAssertedFactID++;
            r.eval(call2);
            //System.out.println(call2);
        }
    }

    public double arraySum(double[] array) {
        double sum = 0;
        for (double value : array) {
            sum += value;
        }
        return sum;
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
            //r.eval("(facts CAPABILITIES)");

            r.setFocus("MANIFEST0"); r.run();
            r.setFocus("MANIFEST"); r.run();

            r.setFocus("CAPABILITIES"); r.run();
            r.setFocus("CAPABILITIES-REMOVE-OVERLAPS"); r.run();
            r.setFocus("CAPABILITIES-GENERATE"); r.run();
            r.setFocus("CAPABILITIES-CROSS-REGISTER"); r.run();
            r.setFocus("CAPABILITIES-UPDATE"); r.run();
            r.setFocus("SYNERGIES"); r.run();

            //updateRevisitTimes(params, r, arch, qb, m, 1);
            long start = System.nanoTime();
            updateRevisitTimesPlanner(params, r, arch, qb, m, 1);
            long end = System.nanoTime();
            System.out.printf("updateRevisitTimesPlanner took %.4f sec\n", (end - start) / Math.pow(10, 9));
            //setOverlap(params, r, arch, qb, m);

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
//            r.eval("(rules REQUIREMENTS)");
//            r.eval("(facts REQUIREMENTS)");
//            r.eval("(facts CAPABILITIES)");
//            r.eval("(facts AGGREGATION)");
//            r.eval("(rules AGGREGATION)");
//            r.eval("(facts MANIFEST)");
//            r.eval("(facts CAPABILITIES-GENERATE)");
//            r.eval("(rules CAPABILITIES-GENERATE)");
            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.setFocus("FUZZY-REQUIREMENTS");
            } else {
                r.setFocus("REQUIREMENTS");
            }
//            r.eval("(rules REQUIREMENTS)");
//            r.eval("(facts REQUIREMENTS)");
//            r.eval("(watch facts)");
//            r.eval("(watch rules)");
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

//            r.setFocus("CAPABILITIES");                 r.run();
//            r.setFocus("CAPABILITIES-REMOVE-OVERLAPS"); r.run();
//            r.setFocus("CAPABILITIES-GENERATE");        r.run();
//            r.setFocus("CAPABILITIES-CROSS-REGISTER");  r.run();
//            r.setFocus("CAPABILITIES-UPDATE");          r.run();
//
//            r.setFocus("SYNERGIES");
//            r.run();

            //updateRevisitTimes(params, r, arch, qb, m, 1);
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
            r.eval("(focus LV-SELECTION4)");
            r.eval("(run)");
            r.eval("(focus LV-SELECTION5)");
            r.eval("(run)");
            // LV SELECTION 4 and 5?

            if ((params.reqMode.equalsIgnoreCase("FUZZY-CASES")) || (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES"))) {
                r.eval("(focus FUZZY-COST-ESTIMATION)");
            }
            else {
                r.eval("(focus COST-ESTIMATION)");
            }
            r.eval("(run)");
            r.eval("(focus INFLATION)");
            r.eval("(run)");


            FuzzyValue fzcost = new FuzzyValue("Cost", new Interval("delta",0,0),"FY04$M");
            ArrayList<Fact> missions = qb.makeQuery("MANIFEST::Mission");
            for (Fact mission: missions)  {
                cost = cost + mission.getSlotValue("lifecycle-cost#").floatValue(r.getGlobalContext());
                if (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES") || params.reqMode.equalsIgnoreCase("FUZZY-CASES")) {
                    fzcost = fzcost.add((FuzzyValue)mission.getSlotValue("lifecycle-cost").javaObjectValue(r.getGlobalContext()));
                }
            }
            r.eval("(facts MANIFEST)");

        }
        catch (JessException e) {
            System.out.println(e.toString());
            System.out.println("EXC in evaluateCosts: " + e.getClass() + " " + e.getMessage());
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
            List<Map<TopocentricFrame, TimeIntervalArray>> radiometerEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> radiometerPlannerEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> reflectometerEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> lBandReflectometerEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> pBandReflectometerEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> allEvents = new ArrayList<>();
            List<Map<TopocentricFrame, TimeIntervalArray>> smEvents = new ArrayList<>();
            int coverageGridGranularity = 20;
            CoverageAnalysisModified coverageAnalysis = new CoverageAnalysisModified(1, coverageGridGranularity, false, true, params.orekitResourcesPath);
            ReflectometerCoverageAnalysis reflAnalysis = new ReflectometerCoverageAnalysis(1, coverageGridGranularity, false, true, params.orekitResourcesPath);
            //CoverageAnalysisIGBP coverageAnalysisIGBP = new CoverageAnalysisIGBP(1, coverageGridGranularity, false, true, params.orekitResourcesPath, getCovPoints());
            double[] latBounds = new double[]{FastMath.toRadians(-75), FastMath.toRadians(75)};
            double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};
            double maxInclination = 0;
            for(int i = 0; i < arch.getSatelliteList().size(); i++) {
                String orbName = arch.getSatelliteList().get(i).getOrbit();
                Orbit orb = new Orbit(orbName);
                double radiometerFOV = arch.getSatelliteList().get(0).getFov();

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


                List<String> insList = Arrays.asList(arch.getSatelliteList().get(i).getInstrumentList());
//                if(insList.contains("P-band_Reflectometer")) {
//                    //Map<TopocentricFrame, TimeIntervalArray> reflAccesses = reflAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "P-band");
//                    Map<TopocentricFrame, TimeIntervalArray> reflAccesses = coverageAnalysis.getAccesses(fieldOfView,inclination,altitude,numSatsPerPlane,numPlanes,raan,trueAnom,"reflectometer");
//                    reflectometerEvents.add(reflAccesses);
//                    pBandReflectometerEvents.add(reflAccesses);
//                    allEvents.add(reflAccesses);
//                }
                if(insList.contains("L-band_Reflectometer")) {
                    Map<TopocentricFrame, TimeIntervalArray> reflAccesses = reflAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "L-band");
                    //Map<TopocentricFrame, TimeIntervalArray> reflAccesses = coverageAnalysis.getAccesses(fieldOfView,inclination,altitude,numSatsPerPlane,numPlanes,raan,trueAnom,"reflectometer");
                    reflectometerEvents.add(reflAccesses);
                    lBandReflectometerEvents.add(reflAccesses);
                    allEvents.add(reflAccesses);
                }
                if(insList.contains("Aquarius")) {
                    Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(16.5, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "radiometer");
                    radiometerEvents.add(accesses);
                    allEvents.add(accesses);
                }
                if(insList.contains("FMPL-2") || insList.contains("FMPL_2")) {
                    Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(19.6, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "radiometer");
                    radiometerEvents.add(accesses);
                    allEvents.add(accesses);
                    //Map<TopocentricFrame, TimeIntervalArray> plannerAccesses = coverageAnalysis.getPlannerAccesses(19.6, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "radiometer");
                    radiometerPlannerEvents.add(accesses);
                }
                if(insList.contains("CustomRadiometer")) {
                    Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(radiometerFOV, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "radiometer");
                    radiometerEvents.add(accesses);
                    allEvents.add(accesses);
                }
                if(insList.contains("P-band_SAR") || insList.contains("CustomPSAR")) {
                    Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "radar");
                    allEvents.add(accesses);
                    pBandFieldOfViewEvents.add(accesses);
                }
                if(insList.contains("L-band_SAR") || insList.contains("CustomLSAR")) {
                    Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "radar");
                    allEvents.add(accesses);
                    lBandFieldOfViewEvents.add(accesses);
                }
//                if(insList.contains("CustomLSAR") && this.smError != null) {
//                    Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysisIGBP.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom, "radar");
//                    smEvents.add(accesses);
//                }
            }
            double[] newLatBounds = new double[]{0,0};
            if (maxInclination < 75) {
                newLatBounds = new double[]{FastMath.toRadians(-maxInclination), FastMath.toRadians(maxInclination)};
            } else if (maxInclination > 90) {
                newLatBounds = new double[]{FastMath.toRadians(-(180-maxInclination)), FastMath.toRadians(180-maxInclination)};
            } else {
                newLatBounds = new double[]{FastMath.toRadians(-maxInclination), FastMath.toRadians(maxInclination)};
            }
            //Combined Radars
            if(fieldOfViewEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                Map<TopocentricFrame, TimeIntervalArray> mergedEvents = new HashMap<>(fieldOfViewEvents.get(0));
                for (int i = 0; i < fieldOfViewEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = fieldOfViewEvents.get(i);
                    mergedEvents = EventIntervalMerger.merge(mergedEvents, event, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(mergedEvents,newLatBounds,lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedEvents,newLatBounds,lonBounds) / 3600);
                coverage.add(coverageAnalysis.getPercentCoverage(mergedEvents,latBounds,lonBounds));
            }
            if(lBandReflectometerEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                //L-band Reflectometers
                Map<TopocentricFrame, TimeIntervalArray> mergedReflEventsL = new HashMap<>(lBandReflectometerEvents.get(0));
                for (int i = 0; i < lBandReflectometerEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = lBandReflectometerEvents.get(i);
                    mergedReflEventsL = EventIntervalMerger.merge(mergedReflEventsL, event, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(mergedReflEventsL, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedReflEventsL, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getPercentCoverage(mergedReflEventsL, newLatBounds, lonBounds));
            }
            if(reflectometerEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                //Combined Reflectometers
                Map<TopocentricFrame, TimeIntervalArray> mergedReflEvents = new HashMap<>(reflectometerEvents.get(0));
                for (int i = 0; i < reflectometerEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = reflectometerEvents.get(i);
                    mergedReflEvents = EventIntervalMerger.merge(mergedReflEvents, event, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(mergedReflEvents, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedReflEvents, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getPercentCoverage(mergedReflEvents, latBounds, lonBounds));
            }
            if(pBandReflectometerEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                //P-band Reflectometers
                Map<TopocentricFrame, TimeIntervalArray> mergedReflEventsP = new HashMap<>(pBandReflectometerEvents.get(0));
                for (int i = 0; i < pBandReflectometerEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = pBandReflectometerEvents.get(i);
                    mergedReflEventsP = EventIntervalMerger.merge(mergedReflEventsP, event, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(mergedReflEventsP, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedReflEventsP, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getPercentCoverage(mergedReflEventsP, latBounds, lonBounds));
            }
            if(radiometerEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                //Radiometers
                Map<TopocentricFrame, TimeIntervalArray> mergedRadiometerEvents = new HashMap<>(radiometerEvents.get(0));
                for (int i = 0; i < radiometerEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = radiometerEvents.get(i);
                    mergedRadiometerEvents = EventIntervalMerger.merge(mergedRadiometerEvents, event, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(mergedRadiometerEvents, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedRadiometerEvents, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getPercentCoverage(mergedRadiometerEvents, latBounds, lonBounds));
            }
            if(allEvents.isEmpty()) {
                coverage.add(0.0);
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                // Combined revisit
                Map<TopocentricFrame, TimeIntervalArray> mergedAllEvents = new HashMap<>(allEvents.get(0));
                for (int i = 0; i < allEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = allEvents.get(i);
                    mergedAllEvents = EventIntervalMerger.merge(mergedAllEvents, event, false);
                }
                coverage.add(coverageAnalysis.getRevisitTime(mergedAllEvents, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(mergedAllEvents, newLatBounds, lonBounds) / 3600);
                coverage.add(coverageAnalysis.getPercentCoverage(mergedAllEvents, latBounds, lonBounds));
                System.out.println("All avg revisit time: "+coverageAnalysis.getRevisitTime(mergedAllEvents, newLatBounds, lonBounds) / 3600);
                System.out.println("All max revisit time: "+coverageAnalysis.getMaxRevisitTime(mergedAllEvents, newLatBounds, lonBounds) / 3600);
                System.out.println("All coverage: "+coverageAnalysis.getPercentCoverage(mergedAllEvents, newLatBounds, lonBounds));
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
                coverage.add(coverageAnalysis.getRevisitTime(pBandMergedEvents,newLatBounds,lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(pBandMergedEvents,newLatBounds,lonBounds) / 3600);
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
                coverage.add(coverageAnalysis.getRevisitTime(lBandMergedEvents,newLatBounds,lonBounds) / 3600);
                coverage.add(coverageAnalysis.getMaxRevisitTime(lBandMergedEvents,newLatBounds,lonBounds) / 3600);
            }
            if(!lBandFieldOfViewEvents.isEmpty() && !radiometerPlannerEvents.isEmpty()) {
                Map<TopocentricFrame, TimeIntervalArray> lBandMergedEvents = new HashMap<>(lBandFieldOfViewEvents.get(0));
                for (int i = 0; i < lBandFieldOfViewEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> lBandEvent = lBandFieldOfViewEvents.get(i);
                    lBandMergedEvents = EventIntervalMerger.merge(lBandMergedEvents, lBandEvent, false);
                }
                Map<TopocentricFrame, TimeIntervalArray> mergedRadiometerEvents = new HashMap<>(radiometerPlannerEvents.get(0));
                for (int i = 0; i < radiometerPlannerEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = radiometerPlannerEvents.get(i);
                    mergedRadiometerEvents = EventIntervalMerger.merge(mergedRadiometerEvents, event, false);
                }
//                for (int f = 0; f < 11; f++) {
//                    overlapResults(lBandMergedEvents, mergedRadiometerEvents, coverageAnalysis, newLatBounds, lonBounds, f);
//                }
                coverage.add(overlapResults(lBandMergedEvents, mergedRadiometerEvents, coverageAnalysis, newLatBounds, lonBounds, 2));

            } else {
                coverage.add(0.0);
            }
            if(false) {
                Map<TopocentricFrame, TimeIntervalArray> mergedReflEvents = new HashMap<>(reflectometerEvents.get(0));
                for (int i = 0; i < reflectometerEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = reflectometerEvents.get(i);
                    mergedReflEvents = EventIntervalMerger.merge(mergedReflEvents, event, false);
                }
                Map<TopocentricFrame, TimeIntervalArray> mergedRadioEvents = new HashMap<>(radiometerEvents.get(0));
                for (int i = 0; i < radiometerEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> event = radiometerEvents.get(i);
                    mergedRadioEvents = EventIntervalMerger.merge(mergedRadioEvents, event, false);
                }

                Map<TopocentricFrame, TimeIntervalArray> mergedReflRadioEvents = new HashMap<>();
                mergedReflRadioEvents = EventIntervalMerger.merge(mergedReflEvents,mergedRadioEvents,false);
                coverage.add(getSMRewards(mergedReflEvents));
                coverage.add(getSMRewards(mergedRadioEvents));
                coverage.add(getSMRewards(mergedReflRadioEvents));
            } else {
                coverage.add(0.0);
                coverage.add(0.0);
                coverage.add(0.0);
            }
            if(true) { // TODO: hardcoded true
                coverage.add(0.0);
                coverage.add(0.0);
            } else {
                Map<TopocentricFrame, TimeIntervalArray> pBandMergedEvents = new HashMap<>(pBandFieldOfViewEvents.get(0));
                for (int i = 0; i < pBandFieldOfViewEvents.size(); ++i) {
                    Map<TopocentricFrame, TimeIntervalArray> pBandEvent = pBandFieldOfViewEvents.get(i);
                    pBandMergedEvents = EventIntervalMerger.merge(pBandMergedEvents, pBandEvent, false);
                }
                TimeScale utc = TimeScalesFactory.getUTC();
                AbsoluteDate startDate = new AbsoluteDate(2020, 1, 1, 0, 0, 0.000, utc);
                double duration = 1.0; // days
                ArrayList<org.orekit.orbits.Orbit> orbits = new ArrayList<>();
                for (int i = 0; i < arch.getSatelliteList().size(); i++) {
                    List<String> insList = Arrays.asList(arch.getSatelliteList().get(i).getInstrumentList());
                    if(insList.contains("P-band_SAR") || insList.contains("L-band_SAR") || insList.contains("CustomLSAR")) {
                        String orbitName = arch.getSatelliteList().get(i).getOrbit();
                        Orbit orb = new Orbit(orbitName);
                        double mu = Constants.WGS84_EARTH_MU;
                        Frame inertialFrame = FramesFactory.getEME2000();
                        org.orekit.orbits.Orbit orekitOrbit = new KeplerianOrbit(orb.getAltitudeNum()+6371000, 0.0, Math.toRadians(orb.getInclinationNum()), 0.0, Math.toRadians(orb.getRaanNum()), Math.toRadians(orb.getTrueAnomNum()), PositionAngle.MEAN, inertialFrame, startDate, mu);
                        orbits.add(orekitOrbit);
                    }
                }
                DSHIELDSimplePlanner planner = new DSHIELDSimplePlanner(pBandFieldOfViewEvents, getRewardGrid(), orbits, startDate, duration);
                coverage.add(getSMRewards(pBandMergedEvents));
                coverage.add(planner.getReward());
            }
//            if(this.smError != null) {
//                Map<TopocentricFrame, TimeIntervalArray> mergedSMEvents = new HashMap<>(smEvents.get(0));
//                for (int i = 0; i < smEvents.size(); ++i) {
//                    Map<TopocentricFrame, TimeIntervalArray> event = smEvents.get(i);
//                    mergedSMEvents = EventIntervalMerger.merge(mergedSMEvents, event, false);
//                }
//                coverage.add(getScienceValueFOR(mergedSMEvents,coverageAnalysisIGBP.getCovPoints()));
//            } else {
//                coverage.add(0.0);
//            }


            System.out.println("Done processing coverage");
        } catch (Exception e) {
            System.out.println("EXC in evaluateCoverage: " + e.getClass() + " " + e.getMessage());
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

    protected double overlapResults(Map<TopocentricFrame, TimeIntervalArray> lBandMergedEvents, Map<TopocentricFrame, TimeIntervalArray> mergedRadiometerEvents, CoverageAnalysisModified coverageAnalysis, double[] newLatBounds, double[] lonBounds, int delay) {
        Map<TopocentricFrame, TimeIntervalArray> radiometerRadarOverlapEvents = new HashMap<>();
        ArrayList<Double> radiometerRadarDelay = new ArrayList<>();
        for(TopocentricFrame tf : lBandMergedEvents.keySet()) {
            TimeIntervalArray radarTimeArray = lBandMergedEvents.get(tf);
            TimeIntervalArray radiometerTimeArray = mergedRadiometerEvents.get(tf);
            double timeDiff = 60.0*60*delay;
            double[] radarRAS = radarTimeArray.getRiseAndSetTimesList();
            double[] radiometerRAS = radiometerTimeArray.getRiseAndSetTimesList();
            ArrayList<Double> correlatedRASList = new ArrayList<>();
            for(int i = 0; i < radarRAS.length; i = i + 2) {
                for (int j = 0; j < radiometerRAS.length; j = j + 2) {
                    if(radiometerRAS[j] > radarRAS[i]-timeDiff && radiometerRAS[j+1] < radarRAS[i+1]) {
                        correlatedRASList.add(radiometerRAS[j]);
                        correlatedRASList.add(radiometerRAS[j+1]);
                        radiometerRadarDelay.add(Math.abs(radarRAS[i]-radiometerRAS[j+1]));
                    }
                }
            }
            TimeScale utc = TimeScalesFactory.getUTC();
            AbsoluteDate startDate = new AbsoluteDate(2020, 1, 1, 0, 0, 0.000, utc);
            AbsoluteDate endDate = startDate.shiftedBy(1 * 24 * 60 * 60); // 7 days in seconds
            TimeIntervalArray correlatedTimeArray = new TimeIntervalArray(startDate, endDate);
            for (int x = 0; x < correlatedRASList.size(); x = x + 2 ) {
                correlatedTimeArray.addRiseTime(correlatedRASList.get(x));
                if(correlatedRASList.get(x+1) > correlatedTimeArray.getTail().durationFrom(startDate)) {
                    correlatedTimeArray.addSetTime(correlatedTimeArray.getTail().durationFrom(startDate));
                } else {
                    correlatedTimeArray.addSetTime(correlatedRASList.get(x+1));
                }

            }
            radiometerRadarOverlapEvents.put(tf,correlatedTimeArray);
        }
        double sum = 0;
        for (int y = 0; y < radiometerRadarDelay.size(); y++) {
            sum = sum + radiometerRadarDelay.get(y);
        }
        if(radiometerRadarDelay.isEmpty()) {
            return 0.0;
        } else {
            double averageDelayWithinXHours = sum/radiometerRadarDelay.size();
            System.out.println("Average delay within " + delay + " hours: "+averageDelayWithinXHours);
            System.out.println("Correlated percent coverage for " + delay + " hours: "+coverageAnalysis.getPercentCoverage(radiometerRadarOverlapEvents,newLatBounds,lonBounds));
            return coverageAnalysis.getPercentCoverage(radiometerRadarOverlapEvents,newLatBounds,lonBounds);
        }
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
            double tolerance = 25*missions.size();
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

    public double getScienceValueFOR(Map<TopocentricFrame,TimeIntervalArray> events, Map<GeodeticPoint,Integer> igbpClasses) {
        double score = 0.0;
        for(TopocentricFrame tf : events.keySet()) {
            TimeIntervalArray tia = events.get(tf);
            if(!tia.isEmpty()) {
                Integer igbpClass = igbpClasses.get(tf.getPoint());
                score += (2.0 - this.smError[igbpClass-1]);
            }
        }
        return score;
    }

    public double getSMRewards(Map<TopocentricFrame,TimeIntervalArray> events) {
        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/20200101013000.csv"))) { 
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }
        Map<GeodeticPoint,Double> simPoints = new HashMap<>();
        double gridGranularity = 1.0;
        for (List<String> record : records) {
            if (Objects.equals(record.get(1), "lat[deg]")) {
                continue;
            }
            if(simPoints.size()==0) {
                simPoints.put(new GeodeticPoint(Math.toRadians(Double.parseDouble(record.get(1))), Math.toRadians(Double.parseDouble(record.get(2))), 0.0),Double.parseDouble(record.get(7)));
                continue;
            }
            GeodeticPoint newPoint = new GeodeticPoint(Math.toRadians(Double.parseDouble(record.get(1))), Math.toRadians(Double.parseDouble(record.get(2))), 0.0);
            boolean tooClose = false;
            for (GeodeticPoint gp : simPoints.keySet()) {
                double dist = Math.sqrt(Math.pow(gp.getLatitude()-newPoint.getLatitude(),2)+Math.pow(gp.getLongitude()-newPoint.getLongitude(),2));
                if (dist < Math.toRadians(gridGranularity)) {
                    tooClose = true;
                    break;
                }
            }
            if(!tooClose) {
                simPoints.put(newPoint,Double.parseDouble(record.get(7)));
            }
        }
        double reward = 0.0;
        for (TopocentricFrame tf : events.keySet()) {
            if(!events.get(tf).isEmpty()) {
                reward = reward + simPoints.get(tf.getPoint());
            }
        }
        return reward;
    }

    public Map<GeodeticPoint,Double> getRewardGrid() {
        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/20200101013000.csv"))) { 
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }
        Map<GeodeticPoint,Double> simPoints = new HashMap<>();
        double gridGranularity = 1.0;
        for (List<String> record : records) {
            if (Objects.equals(record.get(1), "lat[deg]")) {
                continue;
            }
            if(simPoints.size()==0) {
                simPoints.put(new GeodeticPoint(Math.toRadians(Double.parseDouble(record.get(1))), Math.toRadians(Double.parseDouble(record.get(2))), 0.0),Double.parseDouble(record.get(7)));
                continue;
            }
            GeodeticPoint newPoint = new GeodeticPoint(Math.toRadians(Double.parseDouble(record.get(1))), Math.toRadians(Double.parseDouble(record.get(2))), 0.0);
            boolean tooClose = false;
            for (GeodeticPoint gp : simPoints.keySet()) {
                double dist = Math.sqrt(Math.pow(gp.getLatitude()-newPoint.getLatitude(),2)+Math.pow(gp.getLongitude()-newPoint.getLongitude(),2));
                if (dist < Math.toRadians(gridGranularity)) {
                    tooClose = true;
                    break;
                }
            }
            if(!tooClose) {
                simPoints.put(newPoint,Double.parseDouble(record.get(7)));
            }
        }
        return simPoints;
    }

    public Map<GeodeticPoint,Integer> getCovPoints() {
        List<List<String>> records = new ArrayList<>();
        Map<GeodeticPoint,Integer> covPoints = new HashMap<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/IGBP.csv"))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }
        Map<GeodeticPoint,Integer> igbpPoints = new HashMap<>();
        double[] longitudes = linspace(-180.0,180.0,records.get(0).size());
        double[] latitudes = linspace(-84.66,84.66,records.size());
        Map<String,Integer> biomeMap = new HashMap<>();
        biomeMap.put("1",1);
        biomeMap.put("2",1);
        biomeMap.put("4",1);
        biomeMap.put("5",1);
        biomeMap.put("6",2);
        biomeMap.put("7",2);
        biomeMap.put("8",3);
        biomeMap.put("9",3);
        biomeMap.put("10",3);
        biomeMap.put("12",4);
        biomeMap.put("14",4);
        biomeMap.put("16",5);
        for (int j = 0; j < records.get(0).size(); j++) {
            for (int k = 0; k < records.size(); k++) {
                // Check for IGBP biome types
                String biome = records.get(k).get(j);
                if (biomeMap.containsKey(biome)) {
                    GeodeticPoint point = new GeodeticPoint(Math.toRadians(latitudes[k]), Math.toRadians(longitudes[j]), 0.0);
                    igbpPoints.put(point,biomeMap.get(biome));
                }
            }
        }
        while (covPoints.size() < 500) {
            Object[] keys = igbpPoints.keySet().toArray();
            GeodeticPoint key = (GeodeticPoint) keys[new Random().nextInt(keys.length)];
            covPoints.put(key,igbpPoints.get(key));
        }
        return covPoints;
    }

    public double[] linspace(double min, double max, int points) {
        double[] d = new double[points];
        for (int i = 0; i < points; i++){
            d[i] = min + i * (max - min) / (points - 1);
        }
        return d;
    }

    protected void updateRevisitTimesPlanner(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m, int javaAssertedFactID) throws JessException {
        SimpleArchitecture simpleArch = (SimpleArchitecture) arch;
        Locale.setDefault(new Locale("en", "US"));

        // Load default dataset saved in the project root directory
        StringBuffer pathBuffer = new StringBuffer();

        final File currrentDir = new File(params.orekitResourcesPath);
        if (currrentDir.exists() && (currrentDir.isDirectory() || currrentDir.getName().endsWith(".zip"))) {
            pathBuffer.append(currrentDir.getAbsolutePath());
            pathBuffer.append(File.separator);
            pathBuffer.append("resources");
        }
        System.setProperty(DataProvidersManager.OREKIT_DATA_PATH, pathBuffer.toString());
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);
        ArrayList<Satellite> satellites = new ArrayList<>();
        int i = 0;
        for(OrbitInstrumentObject oio : simpleArch.getSatelliteList()) {
            KeplerianOrbit orbit = convertOrbitStringToOrbit(oio.getOrbit());
            Collection<Instrument> imagerPayload = new ArrayList<>();
            double ssCrossFOVRadians = Math.toRadians(10.0);
            double ssAlongFOVRadians = Math.toRadians(15.0); // make sure to change fovea if you change this!!!
            NadirRectangularFOV ssFOV = new NadirRectangularFOV(ssCrossFOVRadians,ssAlongFOVRadians,0.0,earthShape);
            Instrument etmPlus = new Instrument("ETM+", ssFOV, 100.0, 100.0);
            imagerPayload.add(etmPlus);
            Satellite smallsat = new Satellite("sat"+i, orbit, imagerPayload);
            satellites.add(smallsat);
            i = i+1;
        }

        boolean fastCov = Objects.equals(params.runMode, "fast");
        CoverageAnalysisPlannerOverlap capo = new CoverageAnalysisPlannerOverlap(satellites,fastCov);
        double overlapResult = capo.computeOverlap();
        System.out.println("Computed overlap: "+overlapResult);
        double therevtimesGlobal;
        if(fastCov) {
            therevtimesGlobal = capo.computeMaximumRevisitTimeFast();
        } else {
            therevtimesGlobal = capo.computeMaximumRevisitTime(params.getSpectrometerDesign().getAgility());
        }

        System.out.println("Computed maximum revisit time: "+therevtimesGlobal);
        for (String param : params.measurementsToInstruments.keySet()) {
            String call2 = "(assert (ASSIMILATION2::UPDATE-OVERLAP (parameter " + param + ") "
                    + "(overlap-time# " + overlapResult + ") "
                    + "(factHistory J" + javaAssertedFactID + ")))";
            javaAssertedFactID++;
            r.eval(call2);

            String call = "(assert (ASSIMILATION2::UPDATE-REV-TIME (parameter " + param + ") "
                    + "(avg-revisit-time-global# " + therevtimesGlobal/24.0 + ") "
                    + "(avg-revisit-time-US# " + therevtimesGlobal/24.0 + ")"
                    + "(factHistory J" + javaAssertedFactID + ")))";
            javaAssertedFactID++;
            r.eval(call);
        }
    }

    private KeplerianOrbit convertOrbitStringToOrbit(String orbit) {
        String[] tokens = orbit.split("-");
        double mu = Constants.WGS84_EARTH_MU;
        Frame inertialFrame = FramesFactory.getEME2000();
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate startDate = new AbsoluteDate(2020, 6, 1, 0, 0, 0.000, utc);
        KeplerianOrbit kepOrbit = new KeplerianOrbit(6378000+Double.parseDouble(tokens[1])*1000,0.01,FastMath.toRadians(Double.parseDouble(tokens[2])),0.0,FastMath.toRadians(Double.parseDouble(tokens[3])),FastMath.toRadians(Double.parseDouble(tokens[4])),PositionAngle.MEAN, inertialFrame, startDate, mu);
        return kepOrbit;
    }

    protected void updateRevisitTimes(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m, int javaAssertedFactID) throws JessException {
        // Check if all of the orbits in the original formulation are used
        double revTime = 0;
        int[] revTimePrecomputedIndex = new int[params.getOrbitList().length];
        System.out.println("Updating revisit times");
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
                    CoverageAnalysis coverageAnalysis = new CoverageAnalysis(4, coverageGranularity, true, true, params.orekitResourcesPath);
                    double[] latBounds = new double[]{FastMath.toRadians(-75), FastMath.toRadians(75)};
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
                        double trueAnom = orb.getTrueAnomNum();
                        String raanLabel = orb.getRaan();

                        int numSatsPerPlane = Integer.parseInt(orb.getNum_sats_per_plane());
                        int numPlanes = Integer.parseInt(orb.getNplanes());

                        Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom);
                        fieldOfViewEvents.add(accesses);
                    }

                    // Merge accesses to get the revisit time
                    Map<TopocentricFrame, TimeIntervalArray> mergedEvents = new HashMap<>(fieldOfViewEvents.get(0));

                    for (int i = 0; i < fieldOfViewEvents.size(); ++i) {
                        Map<TopocentricFrame, TimeIntervalArray> event = fieldOfViewEvents.get(i);
                        mergedEvents = EventIntervalMerger.merge(mergedEvents, event, false);
                    }

                    therevtimesGlobal = coverageAnalysis.getMaxRevisitTime(mergedEvents, latBounds, lonBounds) / 3600;
                    //System.out.println("Max revisit time: "+therevtimesGlobal);
                    //System.out.println("Percent coverage: "+coverageAnalysis.getPercentCoverage(mergedEvents,latBounds,lonBounds));
                    if(coverageAnalysis.getPercentCoverage(mergedEvents, latBounds, lonBounds) != 1.0) {
                        therevtimesGlobal = 24.0*30.0;
                    }

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
                        + "(avg-revisit-time-global# " + therevtimesGlobal/24.0 + ") "
                        + "(avg-revisit-time-US# " + therevtimesUS/24.0 + ")"
                        + "(factHistory J" + javaAssertedFactID + ")))";
                javaAssertedFactID++;
                r.eval(call);
//                String call2 = "(assert (ASSIMILATION2::UPDATE-REV-TIME2 (parameter " + param + ") "
//                        + "(avg-revisit-time-global# " + therevtimesGlobal + ") "
//                        + "(avg-revisit-time-US# " + therevtimesUS + ")"
//                        + "(factHistory J" + javaAssertedFactID + ")))";
//                javaAssertedFactID++;
//                r.eval(call2);
//                System.out.println(call);
//                System.out.println(call2);
            }
        }
    }
}
