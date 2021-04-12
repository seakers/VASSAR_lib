package seakers.vassar.evaluation;

import jess.Fact;
import jess.JessException;
import jess.Rete;
import org.orekit.errors.OrekitException;
import seakers.vassar.*;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.problems.Assigning.Architecture;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.spacecraft.SpacecraftDescription;
import seakers.vassar.utils.MatlabFunctions;

import java.util.ArrayList;
import java.util.HashSet;
public class DSHIELDArchitectureSizer extends DSHIELDArchitectureEvaluator {

    public DSHIELDArchitectureSizer() {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = null;
    }

    public DSHIELDArchitectureSizer(String[][] factList) {
        this.resourcePool = null;
        this.arch = null;
        this.type = null;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = factList;
    }

    public DSHIELDArchitectureSizer(ResourcePool resourcePool, AbstractArchitecture arch, String type, String[][] factList) {
        this.resourcePool = resourcePool;
        this.arch = arch;
        this.type = type;
        this.debug = false;
        this.orbitsUsed = new HashSet<>();
        this.designs = new ArrayList<>();
        this.factList = factList;
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
                result = size_spacecraft(params, r, arch, qb, m);
            } else {
                throw new Exception("Wrong type of task");
            }

            evaluateCost(params, r, arch, result, qb, m);
            result.setDesigns(this.designs);
            result.setTaskType(type);
        } catch (Exception e) {
            System.out.println("EXC in Task:call: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
            this.resourcePool.freeResource(res);
        }
        this.resourcePool.freeResource(res);

        return result;
    }

    @Override
    public AbstractArchitectureEvaluator getNewInstance() {
        return new DSHIELDArchitectureSizer(super.resourcePool, super.arch, super.type, super.factList);
    }

    @Override
    public AbstractArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        return new DSHIELDArchitectureSizer(resourcePool, arch, type,this.factList);
    }


    protected Result size_spacecraft(BaseParams params, Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m){
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

        try {
            r.eval("(reset)");
        } catch (JessException e) {
            e.printStackTrace();
        }

        Architecture inputArch = (Architecture) arch;

        boolean[][] mat = inputArch.getBitMatrix();
        try {
            this.orbitsUsed = new HashSet<>();

            for (int i = 0; i < params.getNumOrbits(); i++) {
                int ninstrs = m.sumRowBool(mat, i);
                if (ninstrs > 0) {
                    String orbitName = params.getOrbitList()[i];

                    Orbit orb = new Orbit(orbitName, 1, inputArch.getNumSatellites());
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

        return result;
    }

    @Override
    protected void evaluateCost(BaseParams params, Rete r, AbstractArchitecture arch, Result res, QueryBuilder qb, MatlabFunctions m) {

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

    @Override
    protected void designSpacecraft(Rete r, AbstractArchitecture arch, QueryBuilder qb, MatlabFunctions m) {
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
                System.out.println("dry-mass: " + drymasses[0]);
            }

            for (int i = 0; i < missions.size(); i++) {
                this.designs.add( new SpacecraftDescription(missions.get(i), r) );
            }
        }
        catch (Exception e) {
            System.out.println("EXC in evaluateCost: " + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }
}

