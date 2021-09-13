package seakers.vassar;

/**
 *
 * @author dani
 */
import jess.Defrule;

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

    public HashMap<String, Double> revtimes;
//    public HashMap<String, HashMap<String, Double>> revtimes;
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

        // Paths for common xls files
        this.templateDefinitionXls      = problemPath + "/xls/AttributeSet.xls";
        this.missionAnalysisDatabaseXls = problemPath + "/xls/Mission Analysis Database.xls";
        this.capabilityRulesXls         = problemPath + "/xls/Instrument Capability Definition.xls";
        this.requirementSatisfactionXls = problemPath + "/xls/Requirement Rules.xls";
        this.aggregationXls             = problemPath + "/xls/Aggregation Rules.xls";

        this.revtimesDatFile            = problemPath + "/dat/revtimes.dat";
        this.scoresDatFile              = problemPath + "/dat/scores.dat";
        this.dsmDatFile                 = problemPath + "/dat/all_dsms.dat";

        // Paths for common clp files
        this.moduleDefinitionClp            = problemPath + "/clp/modules.clp";
        this.templateDefinitionClp          = problemPath + "/clp/templates.clp";
        this.functionsClp[0]                = problemPath + "/clp/jess_functions.clp";
        this.functionsClp[1]                = problemPath + "/clp/functions.clp";
        this.attributeInheritanceClp        = problemPath + "/clp/attribute_inheritance_rules.clp";
        this.orbitRulesClp                  = problemPath + "/clp/orbit_rules.clp";
        this.massBudgetRulesClp             = problemPath + "/clp/mass_budget_rules.clp";
        this.subsystemMassBudgetRulesClp    = problemPath + "/clp/subsystem_mass_budget_rules.clp";
        this.deltaVBudgetRulesClp           = problemPath + "/clp/deltaV_budget_rules.clp";
        this.epsDesignRulesClp              = problemPath + "/clp/eps_design_rules.clp";
        this.adcsDesignRulesClp             = problemPath + "/clp/adcs_design_rules.clp";
        this.propulsionDesignRulesClp       = problemPath + "/clp/propulsion_design_rules.clp";
        this.costEstimationRulesClp         = problemPath + "/clp/cost_estimation_rules.clp";
        this.fuzzyCostEstimationRulesClp    = problemPath + "/clp/fuzzy_cost_estimation_rules.clp";
        this.launchVehicleSelectionRulesClp = problemPath + "/clp/launch_cost_estimation_rules.clp";
        this.capabilityRulesClp             = problemPath + "/clp/capability_rules.clp";
        this.synergyRulesClp                = problemPath + "/clp/synergy_rules.clp";
        this.assimilationRulesClp           = problemPath + "/clp/assimilation_rules.clp";
        this.adhocRulesClp                  = problemPath + "/clp/smap_rules_test.clp";
        this.downSelectionRulesClp          = problemPath + "/clp/down_selection_rules_smap.clp";
        this.searchHeuristicRulesClp    = problemPath + "/clp/search_heuristic_rules_smap_improveOrbit.clp";
        this.explanationRulesClp            = problemPath + "/clp/explanation_rules.clp";
        this.aggregationRulesClp            = problemPath + "/clp/aggregation_rules.clp";
        this.fuzzyAggregationRulesClp       = problemPath + "/clp/fuzzy_aggregation_rules.clp";

        this.critiqueCostClp                       = problemPath + "/clp/critique/critique_cost.clp";
        this.critiquePerformanceClp                = problemPath + "/clp/critique/critique_performance.clp";
        this.critiquePerformancePrecalculationClp  = problemPath + "/clp/critique/critique_performance_precalculation.clp";
        this.critiqueCostPrecalculationClp         = problemPath + "/clp/critique/critique_cost_precalculation.clp";
        this.critiquePerformanceInitializeFactsClp = problemPath + "/clp/critique/critique_performance_initialize_facts.clp";
        this.critiqueCostInitializeFactsClp        = problemPath + "/clp/critique/critique_cost_initialize_facts.clp";
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
//                this.revtimes = (HashMap<String, HashMap<String, Double>>) ois.readObject();
                this.revtimes = RawSafety.castHashMap(ois.readObject());
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