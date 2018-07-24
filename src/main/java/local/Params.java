package rbsa.eoss.local;

/**
 *
 * @author dani
 */
import jess.Defrule;
import rbsa.eoss.NDSM;

import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;

public class Params {
    public static Params instance = null;

    public static Params initInstance(String p, String mode, String name, String runMode, String searchClp) {
        instance = new Params(p, mode, name, runMode, searchClp);
        return instance;
    }

    public static Params newInstance(String p, String mode, String name, String runMode, String searchClp) {
        return new Params(p, mode, name, runMode, searchClp);
    }

    public static Params getInstance() {
        return instance;
    }

    public String path;
    public String reqMode;
    public String name;
    public String runMode;
    public String initialPop;

    public String templateDefinitionXls;
    public String missionAnalysisDatabaseXls;
    public String capabilityRulesXls;
    public String requirementSatisfactionXls;
    public String aggregationXls;

    public String revtimesDatFile;
    public String scoresDatFile;
    public String dsmDatFile;

    public String moduleDefinitionClp;
    public String templateDefinitionClp;
    public String[] functionsClp = new String[2];
    public String attributeInheritanceClp;
    public String orbitRulesClp;
    public String massBudgetRulesClp;
    public String subsystemMassBudgetRulesClp;
    public String deltaVBudgetRulesClp;
    public String epsDesignRulesClp;
    public String adcsDesignRulesClp;
    public String propulsionDesignRulesClp;
    public String fuzzyCostEstimationRulesClp;
    public String launchVehicleSelectionRulesClp;
    public String capabilityRulesClp;
    public String synergyRulesClp;
    public String assimilationRulesClp;
    public String adhocRulesClp;
    public String downSelectionRulesClp;
    public String searchHeuristicRulesClp;
    public String explanationRulesClp;
    public String aggregationRulesClp;
    public String fuzzyAggregationRulesClp;

    public String critiqueCostClp;
    public String critiquePerformanceClp;
    public String critiquePerformancePrecalculationClp;
    public String critiqueCostPrecalculationClp;
    public String critiquePerformanceInitializeFactsClp;
    public String critiqueCostInitializeFactsClp;

    // Metrics for utility and pareto calculations
    public double minScience;
    public double maxScience;
    public double minCost;
    public double maxCost;
    public double probAccept = 0.8;

    // Instruments
    public String[] instrumentList = {"BIOMASS","SMAP_RAD","SMAP_MWR","CMIS","VIIRS"};
    public int numInstr;
    public String[] orbitList = {"LEO-600-polar-NA","SSO-600-SSO-AM","SSO-600-SSO-DD","SSO-800-SSO-AM","SSO-800-SSO-DD"};
    public int numOrbits;
    public HashMap<String, Integer> instrumentIndexes = new HashMap<>();
    public HashMap<String, Integer> orbitIndexes = new HashMap<>();
    public int[] numSatellites = {1};
    public int MAX_TOTAL_INSTR;

    // Results
    public String pathSaveResults;

    // Intermediate results
    public int nof; //number of facts
    public int nor; //number of rules
    public HashMap<String, Defrule> rulesDefruleMap;
    public HashMap<Integer, String> rulesIDtoNameMap;
    public HashMap<String, Integer> rulesNametoIDMap;
    public HashMap<String, HashMap<String, ArrayList<String>>> requirementRules;
    public HashMap<String, ArrayList<String>> measurementsToSubobjectives;
    public HashMap<String, ArrayList<String>> measurementsToObjectives;
    public HashMap<String, ArrayList<String>> measurementsToPanels;
    public ArrayList<String> parameterList;
    public ArrayList<ArrayList<ArrayList<String>>> subobjectives;
    public HashMap<String, ArrayList<String>> instrumentsToMeasurements;
    public HashMap<String, ArrayList<String>> instrumentsToSubobjectives;
    public HashMap<String, ArrayList<String>> instrumentsToObjectives;
    public HashMap<String, ArrayList<String>> instrumentsToPanels;
    public HashMap<String, ArrayList<String>> measurementsToInstruments;
    public HashMap<String, ArrayList<String>> subobjectivesToInstruments;
    public HashMap<String, ArrayList<String>> objectivesToInstruments;
    public HashMap<String, ArrayList<String>> panelsToInstruments;
    public HashMap<String, String> subobjectivesToMeasurements;
    public HashMap<String, ArrayList<String>> objectivesToMeasurements;
    public HashMap<String, ArrayList<String>> panelsToMeasurements;
    public int numPanels;
    public ArrayList<Double> panelWeights;
    public ArrayList<String> panelNames;
    public HashMap<String, String> panelDescriptions;
    public ArrayList<ArrayList<Double>> objWeights;
    public ArrayList<ArrayList<String>> objNames;
    public HashMap<String, String> objectiveDescriptions;
    public ArrayList<Integer> numObjectivesPerPanel;
    public ArrayList<ArrayList<ArrayList<Double>>> subobjWeights;
    public HashMap<String, String> subobjDescriptions;
    public HashMap<String, Double> subobjWeightsMap;

    //public HashMap<String, HashMap<String, Double>> revtimes;
    public HashMap<String, Double> revtimes;
    public HashMap<ArrayList<String>, HashMap<String, Double>> scores;
    public HashMap<ArrayList<String>, HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>>> subobjScores;
    public HashMap<String, NDSM> allDsms;

    public HashMap<String, String> subobjMeasurementParams;

    private Params(String path, String mode, String name, String runMode, String search_clp) {
        this.path = path;
        this.reqMode = mode;
        this.name = name;
        this.runMode = runMode;
        this.initialPop = "";
        this.pathSaveResults = this.path + "/results";

        // Paths for common xls files
        this.templateDefinitionXls      = this.path + "/xls/SMAP/AttributeSet.xls";
        this.missionAnalysisDatabaseXls = this.path + "/xls/SMAP/Mission Analysis Database.xls";
        this.capabilityRulesXls         = this.path + "/xls/SMAP/SMAP Instrument Capability Definition.xls";
        this.requirementSatisfactionXls = this.path + "/xls/SMAP/SMAP Requirement Rules.xls";
        this.aggregationXls             = this.path + "/xls/SMAP/SMAP Aggregation Rules.xls";

        this.revtimesDatFile            = this.path + "/dat/SMAP/revtimes";
        this.scoresDatFile              = this.path + "/dat/SMAP/scores2013-10-29-15-31-49.dat";
        this.dsmDatFile                 = this.path + "/dat/SMAP/all_dsms2013-10-29-15-35-13.dat";

        // Paths for common clp files
        this.moduleDefinitionClp            = this.path + "/clp/modules.clp";
        this.templateDefinitionClp          = this.path + "/clp/templates.clp";
        this.functionsClp[0]                = this.path + "/clp/jess_functions.clp";
        this.functionsClp[1]                = this.path + "/clp/functions.clp";
        this.attributeInheritanceClp        = this.path + "/clp/attribute_inheritance_rules.clp";
        this.orbitRulesClp                  = this.path + "/clp/orbit_rules.clp";
        this.massBudgetRulesClp             = this.path + "/clp/mass_budget_rules.clp";
        this.subsystemMassBudgetRulesClp    = this.path + "/clp/subsystem_mass_budget_rules.clp";
        this.deltaVBudgetRulesClp           = this.path + "/clp/deltaV_budget_rules.clp";
        this.epsDesignRulesClp              = this.path + "/clp/eps_design_rules.clp";
        this.adcsDesignRulesClp             = this.path + "/clp/adcs_design_rules.clp";
        this.propulsionDesignRulesClp       = this.path + "/clp/propulsion_design_rules.clp";
        this.fuzzyCostEstimationRulesClp    = this.path + "/clp/cost_estimation_rules.clp";
        this.launchVehicleSelectionRulesClp = this.path + "/clp/launch_cost_estimation_rules.clp";
        this.capabilityRulesClp             = this.path + "/clp/capability_rules.clp";
        this.synergyRulesClp                = this.path + "/clp/synergy_rules.clp";
        this.assimilationRulesClp           = this.path + "/clp/assimilation_rules.clp";
        this.adhocRulesClp                  = this.path + "/clp/smap_rules_test.clp";
        this.downSelectionRulesClp          = this.path + "/clp/down_selection_rules_smap.clp";
        if (search_clp.isEmpty()) {
            this.searchHeuristicRulesClp    = this.path + "/clp/search_heuristic_rules_smap_improveOrbit.clp";
        }
        else {
            this.searchHeuristicRulesClp    = this.path + "/clp/" + search_clp + ".clp";
        }
        this.explanationRulesClp            = this.path + "/clp/explanation_rules.clp";
        this.aggregationRulesClp            = this.path + "/clp/aggregation_rules.clp";
        this.fuzzyAggregationRulesClp       = this.path + "/clp/fuzzy_aggregation_rules.clp";

        this.critiqueCostClp                       = this.path + "/clp/critique/critique_cost.clp";
        this.critiquePerformanceClp                = this.path + "/clp/critique/critique_performance.clp";
        this.critiquePerformancePrecalculationClp  = this.path + "/clp/critique/critique_performance_precalculation.clp";
        this.critiqueCostPrecalculationClp         = this.path + "/clp/critique/critique_cost_precalculation.clp";
        this.critiquePerformanceInitializeFactsClp = this.path + "/clp/critique/critique_performance_initialize_facts.clp";
        this.critiqueCostInitializeFactsClp        = this.path + "/clp/critique/critique_cost_initialize_facts.clp";

        // Instruments & Orbits
        numInstr = instrumentList.length;
        numOrbits = orbitList.length;

        MAX_TOTAL_INSTR = numOrbits * numInstr;

        for (int i = 0; i < numInstr; i++) {
            instrumentIndexes.put(instrumentList[i], i);
        }
        for (int i = 0; i < numOrbits; i++) {
            orbitIndexes.put(orbitList[i], i);
        }

        // Intermediate results
        this.requirementRules = new HashMap<>();
        this.measurementsToSubobjectives = new HashMap<>();
        this.measurementsToObjectives = new HashMap<>();
        this.measurementsToPanels = new HashMap<>();
        this.subobjectives = new ArrayList<>();
        this.instrumentsToMeasurements = new HashMap<>();
        this.instrumentsToSubobjectives = new HashMap<>();
        this.instrumentsToObjectives = new HashMap<>();
        this.instrumentsToPanels = new HashMap<>();

        this.measurementsToInstruments = new HashMap<>();
        this.subobjectivesToInstruments = new HashMap<>();
        this.objectivesToInstruments = new HashMap<>();
        this.panelsToInstruments = new HashMap<>();

        this.subobjectivesToMeasurements = new HashMap<>();
        this.objectivesToMeasurements = new HashMap<>();
        this.panelsToMeasurements = new HashMap<>();

        this.subobjMeasurementParams = new HashMap<>();

        try {
            if (!this.runMode.equalsIgnoreCase("update_revtimes")) {
                FileInputStream fis = new FileInputStream(revtimesDatFile);
                ObjectInputStream ois = new ObjectInputStream(fis);
                //this.revtimes = (HashMap<String, HashMap<String, Double>>) ois.readObject();
                this.revtimes = (HashMap<String, Double>) ois.readObject();
                ois.close();
            }
            if (!this.runMode.equalsIgnoreCase("update_scores")) {
                FileInputStream fis = new FileInputStream(scoresDatFile);
                ObjectInputStream ois = new ObjectInputStream(fis);
                this.scores = (HashMap<ArrayList<String>, HashMap<String, Double>>) ois.readObject();
                this.subobjScores = (HashMap<ArrayList<String>, HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>>>) ois.readObject();
                ois.close();
            }
            if (!this.runMode.equalsIgnoreCase("update_dsms")) {
                FileInputStream fis = new FileInputStream(dsmDatFile);
                ObjectInputStream ois = new ObjectInputStream(fis);
                this.allDsms = (HashMap<String, NDSM>) ois.readObject();
                ois.close();
            }
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
            e.printStackTrace();
        }

    }

    public String getName() {
        return name;
    }
}