package seakers.vassar;

/**
 *
 * @author dani
 */
import jess.Defrule;
import seakers.orekit.util.OrekitConfig;

import java.io.File;
import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;

public abstract class BaseParams {

    public String resourcesPath;
    public String problemName;
    public String orekitResourcesPath;
    public String problemPath;
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
    public String costEstimationRulesClp;
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

    // Results
    public String pathSaveResults;

    // Jess-initialization data
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

//    public HashMap<String, Double> revtimes;
    public HashMap<String, HashMap<String, Double>> revtimes;
    public HashMap<ArrayList<String>, HashMap<String, Double>> scores;
    public HashMap<ArrayList<String>, HashMap<String, ArrayList<ArrayList<ArrayList<Double>>>>> subobjScores;
    public HashMap<String, String> subobjMeasurementParams;

    protected BaseParams(String resourcesPath, String problemName, String mode, String name, String runMode) {
        this.resourcesPath = resourcesPath;
        this.problemName = problemName;
        this.reqMode = mode;
        this.name = name;
        this.runMode = runMode;
        this.initialPop = "";
        this.configurePath(resourcesPath, problemName);
    }

    private void configurePath(String resourcesPath, String problemName){
        this.problemPath = resourcesPath + File.separator + "problems" + File.separator + problemName;
        this.orekitResourcesPath = resourcesPath + File.separator + "orekit";
        this.pathSaveResults = problemPath + File.separator + "results";



        //        String clp_set = "/clp2/";
        String clp_set = "/clp/";

        // Paths for common xls files
        this.templateDefinitionXls      = problemPath + "/xls/AttributeSet.xls";
        this.missionAnalysisDatabaseXls = problemPath + "/xls/Mission Analysis Database.xls";
        this.capabilityRulesXls         = problemPath + "/xls/Instrument Capability Definition.xls";
//        this.requirementSatisfactionXls = problemPath + "/xls/Requirement Rules.xls";
        this.requirementSatisfactionXls = problemPath + "/xls/Decadal Objective Rule Definition.xls";
        this.aggregationXls             = problemPath + "/xls/Aggregation Rules.xls";

        this.revtimesDatFile            = problemPath + "/dat/revtimes.dat";
        this.scoresDatFile              = problemPath + "/dat/scores.dat";
        this.dsmDatFile                 = problemPath + "/dat/all_dsms.dat";

        // Paths for common clp files
        this.moduleDefinitionClp            = problemPath + clp_set + "modules.clp";
        this.templateDefinitionClp          = problemPath + clp_set + "templates.clp";
        this.functionsClp[0]                = problemPath + clp_set + "jess_functions.clp";
        this.functionsClp[1]                = problemPath + clp_set + "functions.clp";
        this.attributeInheritanceClp        = problemPath + clp_set + "attribute_inheritance_rules.clp";
        this.orbitRulesClp                  = problemPath + clp_set + "orbit_rules.clp";
        this.massBudgetRulesClp             = problemPath + clp_set + "mass_budget_rules.clp";
        this.subsystemMassBudgetRulesClp    = problemPath + clp_set + "subsystem_mass_budget_rules.clp";
        this.deltaVBudgetRulesClp           = problemPath + clp_set + "deltaV_budget_rules.clp";
        this.epsDesignRulesClp              = problemPath + clp_set + "eps_design_rules.clp";
        this.adcsDesignRulesClp             = problemPath + clp_set + "adcs_design_rules.clp";
        this.propulsionDesignRulesClp       = problemPath + clp_set + "propulsion_design_rules.clp";
        this.costEstimationRulesClp         = problemPath + clp_set + "cost_estimation_rules.clp";
        this.fuzzyCostEstimationRulesClp    = problemPath + clp_set + "fuzzy_cost_estimation_rules.clp";
        this.launchVehicleSelectionRulesClp = problemPath + clp_set + "launch_cost_estimation_rules.clp";
        this.capabilityRulesClp             = problemPath + clp_set + "capability_rules.clp";
        this.synergyRulesClp                = problemPath + clp_set + "synergy_rules.clp";
        this.assimilationRulesClp           = problemPath + clp_set + "assimilation_rules.clp";
        this.adhocRulesClp                  = problemPath + clp_set + "smap_rules_test.clp";
        this.downSelectionRulesClp          = problemPath + clp_set + "down_selection_rules_smap.clp";
        this.searchHeuristicRulesClp    = problemPath + clp_set + "search_heuristic_rules_smap_improveOrbit.clp";
        this.explanationRulesClp            = problemPath + clp_set + "explanation_rules.clp";
        this.aggregationRulesClp            = problemPath + clp_set + "aggregation_rules.clp";
        this.fuzzyAggregationRulesClp       = problemPath + clp_set + "fuzzy_aggregation_rules.clp";
//        this.designHeuristicsRulesClp       = problemPath + clp_set + "design_heuristics_rules.clp";
//        this.constellationRulesClp          = problemPath + clp_set + "constellation_rules.clp";

        this.critiqueCostClp                       = problemPath + clp_set + "critique/critique_cost.clp";
        this.critiquePerformanceClp                = problemPath + clp_set + "critique/critique_performance.clp";
        this.critiquePerformancePrecalculationClp  = problemPath + clp_set + "critique/critique_performance_precalculation.clp";
        this.critiqueCostPrecalculationClp         = problemPath + clp_set + "critique/critique_cost_precalculation.clp";
        this.critiquePerformanceInitializeFactsClp = problemPath + clp_set + "critique/critique_performance_initialize_facts.clp";
        this.critiqueCostInitializeFactsClp        = problemPath + clp_set + "critique/critique_cost_initialize_facts.clp";
    }

    /**
     * Resets all jess-initialization data
     */
    public void init(){

        // Intermediate results
        this.rulesDefruleMap = new HashMap<>();
        this.rulesNametoIDMap = new HashMap<>();
        this.requirementRules = new HashMap<>();
        this.parameterList = new ArrayList<>();
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

        FileInputStream fis;
        ObjectInputStream ois;
        try {
            if (!this.runMode.equalsIgnoreCase("update_revtimes")) {
                fis = new FileInputStream(revtimesDatFile);
                ois = new ObjectInputStream(fis);
                this.revtimes = (HashMap<String, HashMap<String, Double>>) ois.readObject();
//                this.revtimes = RawSafety.castHashMap(ois.readObject());
                fis.close();
                ois.close();
            }
            if (!this.runMode.equalsIgnoreCase("update_scores")) {
                fis = new FileInputStream(scoresDatFile);
                ois = new ObjectInputStream(fis);
                this.scores = RawSafety.castHashMap(ois.readObject());
                this.subobjScores = RawSafety.castHashMap(ois.readObject());
                fis.close();
                ois.close();
            }
            if (!this.runMode.equalsIgnoreCase("update_dsms")) {
                fis = new FileInputStream(dsmDatFile);
                ois = new ObjectInputStream(fis);
                fis.close();
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

    public abstract BaseParams copy();
    public abstract String[] getInstrumentList();
    public abstract String[] getOrbitList();
    public abstract int getNumInstr();
    public abstract int getNumOrbits();
    public abstract HashMap<String, Integer> getInstrumentIndexes();
    public abstract HashMap<String, Integer> getOrbitIndexes();
}