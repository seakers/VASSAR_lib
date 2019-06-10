package seakers.vassar.evaluation;

import jess.*;
import org.hipparchus.util.FastMath;
import org.orekit.errors.OrekitException;
import org.orekit.frames.TopocentricFrame;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.coverage.CoverageAnalysis;
import seakers.vassar.BaseParams;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.MatlabFunctions;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.event.EventIntervalMerger;

import java.util.*;
import java.util.concurrent.Callable;

/**
 *
 * @author Ana-Dani
 */

public abstract class AbstractArchitectureEvaluator implements Callable<Result> {

    protected AbstractArchitecture arch;
    protected ResourcePool resourcePool;
    protected String type;
    protected boolean debug;
    protected Set<Orbit> orbitsUsed;

    public AbstractArchitectureEvaluator() {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
    }

    public AbstractArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        this.resourcePool = resourcePool;
        this.arch = arch;
        this.type = type;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
    }

    public abstract AbstractArchitectureEvaluator getNewInstance();
    public abstract AbstractArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type);

    public void checkInit(){
        if(this.resourcePool == null || this.arch == null || this.type == null){
            throw new IllegalStateException(AbstractArchitectureEvaluator.class.getName() + " not initialized. " +
                    "Either set class attributes resourcePool, arch, and type from a constructor, " +
                    "or use getNewInstance() method to initialize this class.");
        }
    }

    @Override
    public Result call() {

        checkInit();

        if (!arch.isFeasibleAssignment()) {
            return new Result(arch, 0.0, 1E5);
        }

        Resource res = this.resourcePool.getResource();
        BaseParams params = res.getParams();
        Rete r = res.getRete();
        QueryBuilder qb = res.getQueryBuilder();
        MatlabFunctions m = res.getM();
        Result result = new Result();

        try {
            if (type.equalsIgnoreCase("Slow")) {
                result = evaluatePerformance(params, r, arch, qb, m);
                r.eval("(reset)");
                assertMissions(params, r, arch, m);
            }
            else {
                throw new Exception("Wrong type of task");
            }
            evaluateCost(params, r, arch, result, qb, m);
            result.setTaskType(type);
        }
        catch (Exception e) {
            System.out.println("EXC in Task:call: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            this.resourcePool.freeResource(res);
        }
        this.resourcePool.freeResource(res);

        return result;
    }

    protected Result evaluatePerformance(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m) {

        Result result = new Result();
        try {
            r.reset();
            assertMissions(params, r, arch, m);

            r.eval("(bind ?*science-multiplier* 1.0)");
            r.eval("(defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE))))");
            r.eval("(defadvice before (create$ sqrt + * **) (foreach ?xxx $?argv (if (eq ?xxx nil) then (bind ?xxx 0))))");

            //r.eval("(watch rules)");
            //r.eval("(facts)");

            r.setFocus("MANIFEST0");
            r.run();

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

            // Check if all of the orbits in the original formulation are used
            int[] revTimePrecomputedIndex = new int[params.getOrbitList().length];
            String[] revTimePrecomputedOrbitList = {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-DD","SSO-800-SSO-PM"};

            for(int i = 0; i < params.getOrbitList().length; i++){
                String orb = params.getOrbitList()[i];
                int matchedIndex = -1;
                for(int j = 0; j < revTimePrecomputedOrbitList.length; j++){
                    if(revTimePrecomputedOrbitList[j].equalsIgnoreCase(orb)){
                        matchedIndex = j;
                        break;
                    }
                }

                // Assign -1 if unmatched. Otherwise, assign the corresponding index
                revTimePrecomputedIndex[i] = matchedIndex;
            }

            for (String param: params.measurementsToInstruments.keySet()) {
                Value v = r.eval("(update-fovs " + param + " (create$ " + m.stringArraytoStringWithSpaces(params.getOrbitList()) + "))");

                if (RU.getTypeName(v.type()).equalsIgnoreCase("LIST")) {

                    ValueVector thefovs = v.listValue(r.getGlobalContext());
                    String[] fovs = new String[thefovs.size()];
                    for (int i = 0; i < thefovs.size(); i++) {
                        int tmp = thefovs.get(i).intValue(r.getGlobalContext());
                        fovs[i] = String.valueOf(tmp);
                    }

                    boolean recalculateRevisitTime = false;
                    for(int i = 0; i < fovs.length; i++){
                        if(revTimePrecomputedIndex[i] == -1){
                            // If there exists a single orbit that is different from pre-calculated ones, re-calculate
                            recalculateRevisitTime = true;
                        }
                    }

                    Double therevtimesGlobal;
                    Double therevtimesUS;

                    if(recalculateRevisitTime){
                        // Do the re-calculation of the revisit times

                        int coverageGranularity = 20;

                        //Revisit times
                        CoverageAnalysis coverageAnalysis = new CoverageAnalysis(1, coverageGranularity, true, true, params.orekitResourcesPath);
                        double[] latBounds = new double[]{FastMath.toRadians(-70), FastMath.toRadians(70)};
                        double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};

                        List<Map<TopocentricFrame, TimeIntervalArray>> fieldOfViewEvents = new ArrayList<>();

                        // For each fieldOfview-orbit combination
                        for(Orbit orb: this.orbitsUsed){
                            int fov = thefovs.get(params.getOrbitIndexes().get(orb.toString())).intValue(r.getGlobalContext());

                            if(fov <= 0){
                                continue;
                            }

                            double fieldOfView = fov; // [deg]
                            double inclination = orb.getInclinationNum(); // [deg]
                            double altitude = orb.getAltitudeNum(); // [m]
                            String raanLabel = orb.getRaan();

                            int numSats = Integer.parseInt(orb.getNum_sats_per_plane());
                            int numPlanes = Integer.parseInt(orb.getNplanes());

                            Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSats, numPlanes, raanLabel);
                            fieldOfViewEvents.add(accesses);
                        }

                        // Merge accesses to get the revisit time
                        Map<TopocentricFrame, TimeIntervalArray> mergedEvents = new HashMap<>(fieldOfViewEvents.get(0));

                        for(int i = 1; i < fieldOfViewEvents.size(); ++i) {
                            Map<TopocentricFrame, TimeIntervalArray> event = fieldOfViewEvents.get(i);
                            mergedEvents = EventIntervalMerger.merge(mergedEvents, event, false);
                        }

                        therevtimesGlobal = coverageAnalysis.getRevisitTime(mergedEvents, latBounds, lonBounds)/3600;
                        therevtimesUS = therevtimesGlobal;

                    }else{
                        // Re-assign fovs based on the original orbit formulation, if the number of orbits is less than 5
                        if (thefovs.size() < 5) {
                            String[] new_fovs = new String[5];
                            for (int i = 0; i < 5; i++) {
                                new_fovs[i] = fovs[revTimePrecomputedIndex[i]];
                            }
                            fovs = new_fovs;
                        }
                        String key = "1" + " x " + m.stringArraytoStringWith(fovs, "  ");
                        therevtimesUS = params.revtimes.get(key).get("US"); //key: 'Global' or 'US', value Double
                        therevtimesGlobal = params.revtimes.get(key).get("Global");
                    }

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

    protected Result aggregate_performance_score_facts(BaseParams params, Rete r, MatlabFunctions m, QueryBuilder qb) {

        ArrayList<ArrayList<ArrayList<Double>>> subobj_scores = new ArrayList<>();
        ArrayList<ArrayList<Double>> obj_scores = new ArrayList<>();
        ArrayList<Double> panel_scores = new ArrayList<>();
        double science = 0.0;
        double cost = 0.0;
        FuzzyValue fuzzy_science = null;
        FuzzyValue fuzzy_cost = null;
        TreeMap<String, ArrayList<Fact>> explanations = new TreeMap<>();
        TreeMap<String, Double> subobj_scores_map = new TreeMap<>();
        try {
            // General and panel scores
            ArrayList<Fact> vals = qb.makeQuery("AGGREGATION::VALUE");
            Fact val = vals.get(0);
            science = val.getSlotValue("satisfaction").floatValue(r.getGlobalContext());
            if (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES") || params.reqMode.equalsIgnoreCase("FUZZY-CASES")) {
                fuzzy_science = (FuzzyValue)val.getSlotValue("fuzzy-value").javaObjectValue(r.getGlobalContext());
            }
            for (String str_val: m.jessList2ArrayList(val.getSlotValue("sh-scores").listValue(r.getGlobalContext()), r)) {
                panel_scores.add(Double.parseDouble(str_val));
            }

            ArrayList<Fact> subobj_facts = qb.makeQuery("AGGREGATION::SUBOBJECTIVE");
            for (Fact f: subobj_facts) {
                String subobj = f.getSlotValue("id").stringValue(r.getGlobalContext());
                Double subobj_score = f.getSlotValue("satisfaction").floatValue(r.getGlobalContext());
                Double current_subobj_score = subobj_scores_map.get(subobj);
                if(current_subobj_score == null || subobj_score > current_subobj_score) {
                    subobj_scores_map.put(subobj, subobj_score);
                }
                if (!explanations.containsKey(subobj)) {
                    explanations.put(subobj, qb.makeQuery("AGGREGATION::SUBOBJECTIVE (id " + subobj + ")"));
                }
            }

            //Subobjective scores
            for (int p = 0; p < params.numPanels; p++) {
                int nob = params.numObjectivesPerPanel.get(p);
                ArrayList<ArrayList<Double>> subobj_scores_p = new ArrayList<>(nob);
                for (int o = 0; o < nob; o++) {
                    ArrayList<ArrayList<String>> subobj_p = params.subobjectives.get(p);
                    ArrayList<String> subobj_o = subobj_p.get(o);
                    int nsubob = subobj_o.size();
                    ArrayList<Double> subobj_scores_o = new ArrayList<>(nsubob);
                    for (String subobj : subobj_o) {
                        subobj_scores_o.add(subobj_scores_map.get(subobj));
                    }
                    subobj_scores_p.add(subobj_scores_o);
                }
                subobj_scores.add(subobj_scores_p);
            }

            //Objective scores
            for (int p = 0; p < params.numPanels; p++) {
                int nob = params.numObjectivesPerPanel.get(p);
                ArrayList<Double> obj_scores_p = new ArrayList<>(nob);
                for (int o = 0; o < nob; o++) {
                    ArrayList<ArrayList<Double>> subobj_weights_p = params.subobjWeights.get(p);
                    ArrayList<Double> subobj_weights_o = subobj_weights_p.get(o);
                    ArrayList<ArrayList<Double>> subobj_scores_p = subobj_scores.get(p);
                    ArrayList<Double> subobj_scores_o = subobj_scores_p.get(o);
                    try {
                        obj_scores_p.add(Result.sumProduct(subobj_weights_o, subobj_scores_o));
                    }
                    catch (Exception e) {
                        System.out.println(e.getMessage());
                    }
                }
                obj_scores.add(obj_scores_p);
            }
        }
        catch (Exception e) {
            System.out.println(e.getMessage() + " " + e.getClass());
            e.printStackTrace();
        }
        Result theresult = new Result(arch, science, cost, fuzzy_science, fuzzy_cost, subobj_scores, obj_scores,
                panel_scores, subobj_scores_map);
        if (this.debug) {
            theresult.setCapabilities(qb.makeQuery("REQUIREMENTS::Measurement"));
            theresult.setExplanations(explanations);
        }

        return theresult;
    }

    protected void evaluateCost(BaseParams params, Rete r, AbstractArchitecture arch, Result res, QueryBuilder qb, MatlabFunctions m) {

        try {
            long t0 = System.currentTimeMillis();

            r.setFocus("MANIFEST0");
            r.run();

            r.eval("(focus MANIFEST)");
            r.eval("(run)");

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

            double cost = 0.0;
            FuzzyValue fzcost = new FuzzyValue("Cost", new Interval("delta",0,0),"FY04$M");
            ArrayList<Fact> missions = qb.makeQuery("MANIFEST::Mission");
            for (Fact mission: missions)  {
                cost = cost + mission.getSlotValue("lifecycle-cost#").floatValue(r.getGlobalContext());
                if (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES") || params.reqMode.equalsIgnoreCase("FUZZY-CASES")) {
                    fzcost = fzcost.add((FuzzyValue)mission.getSlotValue("lifecycle-cost").javaObjectValue(r.getGlobalContext()));
                }
            }

            res.setCost(cost);
            res.setFuzzyCost(fzcost);

            if (debug) {
                res.setCostFacts(missions);
            }

        }
        catch (JessException e) {
            System.out.println(e.toString());
            System.out.println("EXC in evaluateCost: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }

    protected void designSpacecraft(Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m) {
        try {

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

    protected abstract void assertMissions(BaseParams params, Rete r, AbstractArchitecture arch, MatlabFunctions m);

    public void setDebug(boolean debug) {
        this.debug = debug;
    }
}

