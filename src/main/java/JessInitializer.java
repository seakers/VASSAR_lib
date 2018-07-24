/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

/**
 *
 * @author dani
 */
import rbsa.eoss.local.Params;
import jess.*;
import jxl.*;
import java.io.File;
import java.util.*;

import org.apache.commons.lang3.StringUtils;

public class JessInitializer {

    private static JessInitializer instance = null;

    private Params params;

    private JessInitializer() { }

    public static JessInitializer getInstance() {
        if (instance == null) {
            instance = new JessInitializer();
        }
        return instance;
    }
    
    public void initializeJess(Rete r, QueryBuilder qb, MatlabFunctions m) {
        try {
            params = Params.getInstance();
            // Create global variable path
            String tmp = params.path.replaceAll("\\\\", "\\\\\\\\");
            r.eval("(defglobal ?*app_path* = \"" + tmp + "\")");
            r.eval("(import rbsa.eoss.*)");
            r.eval("(import java.util.*)");
            r.eval("(import jess.*)");
            r.eval("(defglobal ?*rulesMap* = (new java.util.HashMap))");
            r.eval("(set-reset-globals nil)");
            params.nof = 1;
            params.nor = 1;

            Locale.setDefault(Locale.ENGLISH);

            // Load modules
            loadModules(r);

            // Load templates
            Workbook templatesXls = Workbook.getWorkbook(new File(params.templateDefinitionXls));
            loadTemplates(r, templatesXls, params.templateDefinitionClp);

            // Load functions
            loadFunctions(r, params.functionsClp);
            
            // Load mission analysis database
            Workbook missionAnalysisXls = Workbook.getWorkbook(new File(params.missionAnalysisDatabaseXls));
            loadOrderedDeffacts(r, missionAnalysisXls, "Walker", "Walker-revisit-time-facts","DATABASE::Revisit-time-of");
            loadOrderedDeffacts(r, missionAnalysisXls, "Power", "orbit-information-facts", "DATABASE::Orbit");

            // Load launch vehicle database
            loadOrderedDeffacts(r, missionAnalysisXls, "Launch Vehicles", "DATABASE::launch-vehicle-information-facts", "DATABASE::Launch-vehicle");
            r.reset();
            ArrayList<Fact> facts = qb.makeQuery("DATABASE::Launch-vehicle");

            for (Fact lv: facts) {
                String id = lv.getSlotValue("id").stringValue(r.getGlobalContext());
                double cost = lv.getSlotValue("cost").floatValue(r.getGlobalContext());
                double diam = lv.getSlotValue("diameter").floatValue(r.getGlobalContext());
                double height = lv.getSlotValue("height").floatValue(r.getGlobalContext());
                HashMap<String, ValueVector> payload_coeffs = new HashMap<>();
                ValueVector payload_LEO_polar = lv.getSlotValue("payload-LEO-polar").listValue(r.getGlobalContext());
                ValueVector payload_SSO = lv.getSlotValue("payload-SSO").listValue(r.getGlobalContext());
                ValueVector payload_LEO_equat = lv.getSlotValue("payload-LEO-equat").listValue(r.getGlobalContext());
                ValueVector payload_MEO = lv.getSlotValue("payload-MEO").listValue(r.getGlobalContext());
                ValueVector payload_GEO = lv.getSlotValue("payload-GEO").listValue(r.getGlobalContext());
                ValueVector payload_HEO = lv.getSlotValue("payload-HEO").listValue(r.getGlobalContext());
//                ValueVector payload_ISS = lv.getSlotValue("payload-ISS").listValue(r.getGlobalContext());
                payload_coeffs.put("LEO-polar", payload_LEO_polar);
                payload_coeffs.put("SSO-SSO", payload_SSO);
                payload_coeffs.put("LEO-equat", payload_LEO_equat);
                payload_coeffs.put("MEO-polar", payload_MEO);
                payload_coeffs.put("GEO-equat", payload_GEO);
                payload_coeffs.put("HEO-polar", payload_HEO);
//                payload_coeffs.put("LEO-ISS", payload_ISS);
                LaunchVehicle lvh = new LaunchVehicle(id, payload_coeffs, diam, height, cost);
                m.addLaunchVehicletoDB(id, lvh);
            }

            // Load instrument database
            Workbook instrumentXls = Workbook.getWorkbook(new File(params.capabilityRulesXls));
            loadUnorderedDeffacts(r, instrumentXls, "CHARACTERISTICS", "instrument-database-facts","DATABASE::Instrument");

            // Load attribute inheritance rules
            loadAttributeInheritanceRules(r, templatesXls, "Attribute Inheritance", params.attributeInheritanceClp);
            
            // Load orbit rules;
            loadOrbitRules(r, params.orbitRulesClp);

            // Load mass budget rules;
            loadMassBudgetRules(r, params.massBudgetRulesClp);
            loadMassBudgetRules(r, params.subsystemMassBudgetRulesClp);
            loadMassBudgetRules(r, params.deltaVBudgetRulesClp);

            // Load eps design rules;
            loadSpacecraftDesignRules(r, params.epsDesignRulesClp);
            loadSpacecraftDesignRules(r, params.adcsDesignRulesClp);
            loadSpacecraftDesignRules(r, params.propulsionDesignRulesClp);
            
            // Load cost estimation rules;
            loadCostEstimationRules(r, new String[]{params.fuzzyCostEstimationRulesClp});

            // Load launch vehicle selection rules
            loadLaunchVehicleSelectionRules(r, params.launchVehicleSelectionRulesClp);
            
            // Load fuzzy attribute rules
            loadFuzzyAttributeRules(r, templatesXls, "Fuzzy Attributes", "REQUIREMENTS::Measurement");

            // Load requirement rules
            Workbook requirementsXls = Workbook.getWorkbook(new File(params.requirementSatisfactionXls));
            if (params.reqMode.equalsIgnoreCase("CRISP-ATTRIBUTES")) {
                loadRequirementRulesAttribs(r, requirementsXls, "Attributes", m);
            } else if (params.reqMode.equalsIgnoreCase("FUZZY-ATTRIBUTES")) {
                loadFuzzyRequirementRulesAttribs(r, requirementsXls, "Attributes", m);
            }

            // Load capability rules
            loadCapabilityRules(r, instrumentXls, params.capabilityRulesClp);

            // Load synergy rules
            loadSynergyRules(r, params.synergyRulesClp);
            
            // Load assimilation rules
            loadAssimilationRules(r, params.assimilationRulesClp);
            
            // Ad-hoc rules
            r.eval("(deftemplate DATABASE::list-of-instruments (multislot list) (slot factHistory))");
            r.eval("(deffacts DATABASE::list-of-instruments (DATABASE::list-of-instruments " +
                    "(list (create$ SMAP_RAD SMAP_MWR CMIS VIIRS BIOMASS)) (factHistory "+ params.nof +")))");
            params.nof++;
            if (!params.adhocRulesClp.isEmpty()) {
                System.out.println("WARNING: Loading ad-hoc rules");
                r.batch(params.adhocRulesClp);
            }

            // Load down-selection rules
            loadDownSelectionRules(r, params.downSelectionRulesClp);

            // Load search rules
            r.eval("(deffacts DATABASE::add-improve-orbit-list-of-improve-heuristics " +
                    "(SEARCH-HEURISTICS::improve-heuristic (id improveOrbit) (factHistory " + params.nof + ")" +
                    "))");
            params.nof++;

            loadSearchRules(r, params.searchHeuristicRulesClp);

            // Load explanation rules
            loadExplanationRules(r, params.explanationRulesClp);

            // Load aggregation rules
            Workbook aggregation_xls = Workbook.getWorkbook(new File(params.aggregationXls));

            loadAggregationRules(r, aggregation_xls, "Aggregation rules",
                    new String[]{ params.aggregationRulesClp, params.fuzzyAggregationRulesClp });
            
            ///////////////////////////////////////////////////////////////////////////// 

            Iterator ruleIter = r.listDefrules();
            Iterator ruleIterCheck = r.listDefrules();
            params.rulesDefruleMap = new HashMap<>();
            params.rulesNametoIDMap = new HashMap<>();
            params.rulesIDtoNameMap = new HashMap<>();

            Defrule targetRule = new Defrule("","",r);
            int cnt = 0;

            while (ruleIter.hasNext()) {
                if (ruleIterCheck.next().getClass().getName().equalsIgnoreCase("jess.Defquery")){
                    ruleIter.next();
                    ruleIter.remove();
                }
                else {
                    cnt++;
                    Defrule currentRule = ((Defrule) ruleIter.next());
                    String ruleName = currentRule.getName();
                    params.rulesDefruleMap.put(ruleName, currentRule);
                    params.rulesNametoIDMap.put(ruleName, cnt);
                    params.rulesIDtoNameMap.put(cnt, ruleName);
                    String tmpString = "(?*rulesMap* put " + ruleName + " " + cnt + ")";
                    r.eval(tmpString);
                }
            }
            
            //////////////////////////////////////////////////////////////////////////
            
            r.reset();
            
            //Create precomputed queries;
            loadPrecomputeQueries(qb);
        
        }
        catch (Exception e) {
            System.out.println("EXC in InitializerJess " +e.getClass() + " : " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void loadPrecomputeQueries(QueryBuilder qb) {
        HashMap<String,Fact> db_instruments = new HashMap<>();
        for (int i = 0; i < params.numInstr; i++) {
            String instr = params.instrumentList[i];
            ArrayList<Fact> facts = qb.makeQuery("DATABASE::Instrument (Name " + instr + ")");
            Fact f = facts.get(0);
            db_instruments.put(instr, f);
        }
        qb.addPrecomputedQuery("DATABASE::Instrument", db_instruments);
    }

    private void loadModules(Rete r) {
        try {
            r.batch(params.moduleDefinitionClp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadModules " + e.getMessage());
        }
    }

    private void loadOrbitRules( Rete r, String clp )
    {
        try {
            r.batch(clp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadOrbitRules " +e.getMessage());
        }
    }
    
    private void loadTemplates(Rete r, Workbook xls, String clp) {
        loadMeasurementTemplate(r, xls);
        loadInstrumentTemplate(r, xls);
        loadSimpleTemplate(r, xls, "Mission","MANIFEST::Mission");
        loadSimpleTemplate(r, xls, "Orbit","DATABASE::Orbit");
        loadSimpleTemplate(r, xls, "Launch-vehicle","DATABASE::Launch-vehicle");
        loadTemplatesCLP(r, clp);
    }
    
    private void loadMeasurementTemplate(Rete r, Workbook xls) {
        try {
            HashMap<String, Integer> attribsToKeys = new HashMap<>();
            HashMap<Integer, String> keysToAttribs = new HashMap<>();
            HashMap<String, String> attribsToTypes = new HashMap<>();
            HashMap<String, EOAttribute> attribSet = new HashMap<>();
            params.parameterList = new ArrayList<>();
            Sheet meas = xls.getSheet("Measurement");    
            String call = "(deftemplate REQUIREMENTS::Measurement ";
            int numSlots = meas.getRows();
            for (int i = 1; i < numSlots; i++) {
                Cell[] row = meas.getRow(i);
                String slotType = row[0].getContents();
                String name = row[1].getContents();
                String strId = row[2].getContents();
                int id = Integer.parseInt(strId);
                String type = row[3].getContents();
                                
                attribsToKeys.put(name, id);
                keysToAttribs.put(id, name);
                attribsToTypes.put(name, type);
                if (type.equalsIgnoreCase("NL") || type.equalsIgnoreCase("OL")) {
                    String strNumAtts = row[4].getContents();
                    int numVals = Integer.parseInt(strNumAtts);
                    Hashtable<String, Integer> acceptedValues = new Hashtable<>();
                    for (int j = 0; j < numVals; j++) {
                        acceptedValues.put(row[j+5].getContents(), j);
                    }
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attrib.acceptedValues = acceptedValues;
                    attribSet.put(name, attrib);
                    if (name.equalsIgnoreCase("Parameter")) {
                        params.parameterList.addAll(acceptedValues.keySet());
                    }
                }
                else {
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attribSet.put(name, attrib);
                }
                call = call.concat(" (" + slotType + " " + name + ") ");
            }
            GlobalVariables.defineMeasurement(attribsToKeys, keysToAttribs, attribsToTypes, attribSet);
            
            call = call.concat(")");
            r.eval(call);         
        }
        catch (Exception e) {
            System.out.println("EXC in loadMeasurementTemplate " + e.getMessage());
        }
    }

    private void loadInstrumentTemplate(Rete r, Workbook xls) {
        try {
            HashMap<String, Integer> attribsToKeys = new HashMap<>();
            HashMap<Integer, String> keysToAttribs = new HashMap<>();
            HashMap<String, String> attribsToTypes = new HashMap<>();
            HashMap<String, EOAttribute> attribSet = new HashMap<>();

            Sheet meas = xls.getSheet("Instrument");
            String call = "(deftemplate CAPABILITIES::Manifested-instrument ";
            String call2 = "(deftemplate DATABASE::Instrument ";
            int numSlots = meas.getRows();
            for (int i = 1; i < numSlots; i++) {
                Cell[] row = meas.getRow(i);
                String slotType = row[0].getContents();
                String name = row[1].getContents();
                String strId = row[2].getContents();
                int id = Integer.parseInt(strId);
                String type = row[3].getContents();

                attribsToKeys.put(name, id);
                keysToAttribs.put(id, name);
                attribsToTypes.put(name, type);
                if (type.equalsIgnoreCase("NL") || type.equalsIgnoreCase("OL")) {
                    String strNumAtts = row[4].getContents();
                    int numVals = Integer.parseInt(strNumAtts);
                    Hashtable<String, Integer> acceptedValues = new Hashtable<>();
                    for (int j = 0; j < numVals; j++) {
                        acceptedValues.put(row[j+5].getContents(), j);
                    }
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attrib.acceptedValues = acceptedValues;
                    attribSet.put(name, attrib);
                }
                else {
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attribSet.put(name, attrib);
                }

                call = call.concat(" (" + slotType + " " + name + ") ");
                call2 = call2.concat(" (" + slotType + " " + name + ") ");
            }
            GlobalVariables.defineInstrument(attribsToKeys, keysToAttribs, attribsToTypes, attribSet);

            call = call.concat(")");
            call2 = call2.concat(")");
            r.eval(call);
            r.eval(call2);
        }
        catch (Exception e) {
            System.out.println( "EXC in loadInstrumentTemplate " + e.getMessage());
        }
    }

    private void loadSimpleTemplate(Rete r, Workbook xls, String sheet, String templateName) {
        try {
            Sheet meas = xls.getSheet(sheet);
            String call = "(deftemplate " + templateName + " ";
            int numSlots = meas.getRows();
            for (int i = 1; i < numSlots; i++) {
                Cell[] row = meas.getRow(i);
                String slotType = row[0].getContents();
                String name = row[1].getContents();
                call = call.concat(" (" + slotType + " " + name + ") ");
            }

            call = call.concat(")");
            r.eval(call);
        }
        catch (Exception e) {
            System.out.println("EXC in loadSimpleTemplate " + e.getMessage());
        }
    }

    private void loadTemplatesCLP(Rete r, String clp) {
        try {
            r.batch(clp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadTemplatesCLP " + e.getClass() + " : " + e.getMessage());
        }
    }

    private void loadFunctions(Rete r, String[] clps) {
        try {
            r.addUserfunction(new SameOrBetter());
            r.addUserfunction(new Improve());
            r.addUserfunction(new Worsen());
            for (String clp: clps) {
                r.batch(clp);
            }
            r.eval("(deffunction update-objective-variable (?obj ?new-value) \"Update the value of the global variable with the new value only if it is better \" (bind ?obj (max ?obj ?new-value)))");
            r.eval("(deffunction ContainsRegion (?observed-region ?desired-region)  \"Returns true if the observed region i.e. 1st param contains the desired region i.e. 2nd param \" (bind ?tmp1 (eq ?observed-region Global)) (bind ?tmp2 (eq ?desired-region ?observed-region)) (if (or ?tmp1 ?tmp2) then (return TRUE) else (return FALSE)))");
            r.eval("(deffunction ContainsBands (?list-bands ?desired-bands)  \"Returns true if the list of bands contains the desired bands \" (if (subsetp ?desired-bands ?list-bands) then (return TRUE) else (return FALSE)))");

            r.eval("(deffunction numerical-to-fuzzy (?num ?values ?mins ?maxs)"  +
                    "(bind ?ind 1)"  +
                    "(bind ?n (length$ ?values))"  +
                    "(while (<= ?ind ?n)"  +
                    "(if (and (< ?num (nth$ ?ind ?maxs)) (>= ?num (nth$ ?ind ?mins))) then (return (nth$ ?ind ?values))"  +
                    "else (++ ?ind))))");
            r.eval("(deffunction revisit-time-to-temporal-resolution (?region ?values)"  +
                    "(if (eq ?region Global) then "  +
                    "(return (nth$ 1 ?values))"  +
                    " elif (eq ?region Tropical-regions) then"  +
                    "(return (nth$ 2 ?values))"  +
                    " elif (eq ?region Northern-hemisphere) then"  +
                    "(return (nth$ 3 ?values))"  +
                    " elif (eq ?region Southern-hemisphere) then"  +
                    "(return (nth$ 4 ?values))"  +
                    " elif (eq ?region Cold-regions) then"  +
                    "(return (nth$ 5 ?values))"  +
                    " elif (eq ?region US) then"  +
                    "(return (nth$ 6 ?values))"  +
                    " else (throw new JessException \"revisit-time-to-temporal-resolution: The region of interest is invalid\")" +
                    "))");

            r.eval("(deffunction fuzzy-max (?att ?v1 ?v2) "  +
                    "(if (>= (SameOrBetter ?att ?v1 ?v2) 0) then "  +
                    "?v1 else ?v2))");

            r.eval("(deffunction fuzzy-min (?att ?v1 ?v2) "  +
                    "(if (<= (SameOrBetter ?att ?v1 ?v2) 0) then "  +
                    "?v1 else ?v2))");


            r.eval("(deffunction fuzzy-avg (?v1 ?v2) "  +
                    "(if (or (and (eq ?v1 High) (eq ?v2 Low)) (and (eq ?v1 Low) (eq ?v2 High))) then "  +
                    " \"Medium\" "  +
                    " else (fuzzy-min Accuracy ?v1 ?v2)))");

            r.eval("(deffunction member (?elem ?list) "  +
                    "(if (listp ?list) then "  +
                    " (neq (member$ ?elem ?list) FALSE) "  +
                    " else (?list contains ?elem)))");

            r.eval("(deffunction valid-orbit (?typ ?h ?i ?raan) "  +
                    "(bind ?valid TRUE)"  +
                    "(if (and (eq ?typ GEO) (or (neq ?h GEO) (neq ?i 0))) then (bind ?valid FALSE))"  +
                    "(if (and (neq ?typ GEO) (eq ?h GEO)) then (bind ?valid FALSE))"  +
                    "(if (and (eq ?typ SSO) (neq ?i SSO)) then (bind ?valid FALSE))"  +
                    "(if (and (neq ?typ SSO) (eq ?i SSO)) then (bind ?valid FALSE))"  +
                    "(if (and (neq ?typ SSO) (neq ?raan NA)) then (bind ?valid FALSE))"  +
                    "(if (and (eq ?typ SSO) (eq ?raan NA)) then (bind ?valid FALSE))"  +
                    "(if (and (or (eq ?h 1000) (eq ?h 1300)) (neq ?i near-polar)) then (bind ?valid FALSE))"  +
                    "(if (and (< ?h 400) (or (neq ?typ LEO) (eq ?i SSO) (eq ?i near-polar))) then (bind ?valid FALSE))"  +
                    " (return ?valid))");

            r.eval("(deffunction worth-improving-measurement (?meas) "  +
                    "(bind ?worth TRUE)"  +
                    "(bind ?arr (matlabf get_related_suboj ?meas))"  +
                    "(if (eq ?arr nil) then (return FALSE))"  +
                    "(bind ?iter (?arr iterator))"  +
                    "(while (?iter hasNext) "  +
                    "(bind ?subobj (?iter next)) "  +
                    "(if (eq (eval ?subobj) 1) then (bind ?worth FALSE))) "  +
                    "(return ?worth))");

            r.eval("(deffunction meas-group (?p ?gr)"  +
                    "(if (eq (str-compare (sub-string 1 1 ?p) A) 0) then (return FALSE))"  +
                    "(bind ?pos (str-index \" \" ?p)) " +
                    "(bind ?str (sub-string 1 (- ?pos 1) ?p)) " +
                    "(bind ?meas-1 (nth$ 1 (get-meas-group ?str))) " +
                    "(bind ?meas-2 (nth$ 2 (get-meas-group ?str)))"  +
                    "(bind ?meas-3 (nth$ 3 (get-meas-group ?str))) " +
                    "(bind ?gr-1 (nth$ 1 (get-meas-group ?gr))) " +
                    "(bind ?gr-2 (nth$ 2 (get-meas-group ?gr))) " +
                    "(bind ?gr-3 (nth$ 3 (get-meas-group ?gr)))"  +
                    "(if (and (neq (str-compare ?gr-1 ?meas-1) 0) (neq (str-compare ?gr-1 0) 0)) then (return FALSE)) " +
                    "(if (and (neq (str-compare ?gr-2 ?meas-2) 0) (neq (str-compare ?gr-2 0) 0)) then (return FALSE))"  +
                    "(if (and (neq (str-compare ?gr-3 ?meas-3) 0) (neq (str-compare ?gr-3 0) 0)) then (return FALSE)) " +
                    " (return TRUE))");

            r.eval("(deffunction get-meas-group (?str)"  +
                    "(bind ?pos (str-index . ?str)) " +
                    "(bind ?gr1 (sub-string 1 (- ?pos 1) ?str)) " +
                    "(bind ?new-str (sub-string (+ ?pos 1) (str-length ?str) ?str)) " +
                    "(bind ?pos2 (str-index . ?new-str)) " +
                    "(bind ?gr2 (sub-string 1 (- ?pos2 1) ?new-str)) " +
                    "(bind ?gr3 (sub-string (+ ?pos2 1) (str-length ?new-str) ?new-str)) " +
                    "(return (create$ ?gr1 ?gr2 ?gr3)))");

        }
        catch (Exception e) {
            System.out.println("EXC in loadFunctions " + e.getMessage());
        }
    }

    private void loadOrderedDeffacts(Rete r, Workbook xls, String sheet, String name, String template) {
        try {
            Sheet meas = xls.getSheet(sheet);
            String call = "(deffacts " + name + " ";
            int numFacts = meas.getRows();
            int numSlots = meas.getColumns();
            Cell[] slotNameCells = meas.getRow(0);
            String[] slotNames = new String[numSlots];
            for (int i = 0; i < numSlots; i++) {
                slotNames[i] = slotNameCells[i].getContents();
            }
            for (int i = 1; i < numFacts; i++) {
                Cell[] row = meas.getRow(i);
                call = call.concat(" (" + template + " ");
                for (int j = 0; j < numSlots; j++) {
                    String slot_value = row[j].getContents();
                    if (slot_value.matches("\\[(.+)(,(.+))+\\]")) {
                        call = call.concat( " (" + slotNames[j] + " " + createJessList(slot_value) + ") ");
                    }
                    else {
                        call = call.concat( " (" + slotNames[j] + " " + slot_value + ") ");
                    }
                }
                call = call.concat("(factHistory F" + params.nof + ")");
                params.nof++;
                call = call.concat(") ");
            }
            call = call.concat(")");
            r.eval(call);
        }
        catch (Exception e) {
            System.out.println("EXC in loadOrderedDeffacts " + e.getMessage());
        }
    }

    private void loadUnorderedDeffacts(Rete r, Workbook xls, String sheet, String name, String template) {
        try {
            Sheet meas = xls.getSheet(sheet);
            String call = "(deffacts " + name + " ";
            int numFacts = meas.getRows();
            int numSlots = meas.getColumns();

            for (int i = 1; i < numFacts; i++) {
                Cell[] row = meas.getRow(i);

                call = call.concat(" (" + template + " ");
                for (int j = 0; j < numSlots; j++) {
                    String cell_value = row[j].getContents();
                    String[] splitted = cell_value.split(" ");
                    int len = splitted.length;
                    String slot_name;
                    String slot_value;
                    if (len < 2) {
                        System.out.println("EXC in loadUnorderedDeffacts, expected format is slot_name slot_value. Space not found.");
                    }
                    if (len == 2) {
                        slot_name = splitted[0];
                        slot_value = splitted[1];
                    }
                    else {
                        slot_name = splitted[0];
                        slot_value = splitted[1];
                        for (int k = 2; k < len; k++) {
                            slot_value += " " + splitted[k];
                        }
                    }

                    call = call.concat( " (" + slot_name + " " + slot_value + ") ");
                }
                call = call.concat("(factHistory F" + params.nof + ")");
                params.nof++;
                call = call.concat(") ");
            }
            call = call.concat(")");
            r.eval(call);
        }
        catch (Exception e) {
            System.out.println("EXC in loadUnorderedDeffacts " + e.getMessage());
        }
    }

    private void loadAttributeInheritanceRules(Rete r, Workbook xls, String sheet, String clp) {
        try {
            r.batch(clp);
            Sheet meas = xls.getSheet(sheet);

            int numRules = meas.getRows();
            for (int i = 1; i < numRules; i++) {
                Cell[] row = meas.getRow(i);
                String template1 = row[0].getContents();
                String copySlotType1 = row[1].getContents();
                String copySlotName1 = row[2].getContents();
                String matchingSlotType1 = row[3].getContents();
                String matchingSlotName1 = row[4].getContents();
                String template2 = row[5].getContents();
                String matchingSlotName2 = row[6].getContents();
                String copySlotName2 = row[7].getContents();
                String module = row[8].getContents();
                String call = "(defrule " + module + "::inherit-" + template1.split("::")[1] + "-" + copySlotName1 + "-TO-" + template2.split("::")[1].trim() + " ";
                String ruleName = (module + "::inherit-" + template1.split("::")[1] + "-" + copySlotName1 + "-TO-" + template2.split("::")[1]).trim();
                call += "(declare (no-loop TRUE))";
                if (copySlotType1.equalsIgnoreCase("slot")) {
                    call += " ?sub <- (" + template1 + " (" + copySlotName1 + " ?x&~nil) ";
                }
                else {
                    call += " ?sub <- (" + template1 + " (" + copySlotName1 + " $?x&:(> (length$ $?x) 0)) ";
                }
                if (matchingSlotType1.equalsIgnoreCase("slot")) {
                    call += " (" + matchingSlotName1 + " ?id&~nil) )  ";
                }
                else {
                    call += " (" + matchingSlotName1 + " $?id&:(> (length$ $?id) 0)) ) ";
                }
                call += " ?old <- (" + template2 + " ";
                if (matchingSlotType1.equalsIgnoreCase("slot")) {
                    call += " (" + matchingSlotName2 + " ?id) (factHistory ?fh) ";
                }
                else {
                    call += " (" + matchingSlotName2 + " $?id) (factHistory ?fh)";
                }
                if (copySlotType1.equalsIgnoreCase("slot")) {
                    call += " (" + copySlotName2 + " nil) ";
                }
                else {
                    call += " (" + copySlotName2 + " $?x&:(eq (length$ $?x) 0)) ";
                }

                String newFactHistory = "(str-cat \"{R\" (?*rulesMap* get " + ruleName + ") \" \" ?fh \" S\" (call ?sub getFactId) \"}\")";
                call += ") => (modify ?old (" + copySlotName2 + " ?x)"
                        + "(factHistory "+ newFactHistory +")"
                        + "))";
                r.eval(call);
            }
        }
        catch (Exception e) {
            System.out.println("EXC in loadAttributeInheritanceRules " + e.getMessage());
        }
    }

    private void loadFuzzyAttributeRules(Rete r, Workbook xls, String sheet, String template) {
        try {
            Sheet meas = xls.getSheet(sheet);

            int numRules = meas.getRows();

            for (int i = 1; i < numRules; i++) {
                Cell[] row = meas.getRow(i);
                String att = row[0].getContents();
                String param = row[1].getContents();
                int numValues = Integer.parseInt(row[3].getContents());
                String[] fuzzyValues = new String[numValues];
                String[] mins = new String[numValues];
                String[] means = new String[numValues];
                String[] maxs = new String[numValues];
                String callValues = "(create$ ";
                String callMins = "(create$ ";
                String callMaxs = "(create$ ";
                for (int j = 1; j <= numValues; j++) {
                    fuzzyValues[j-1] = row[4*j].getContents();
                    callValues += fuzzyValues[j-1] + " ";
                    mins[j-1] = Double.toString(((NumberCell)row[1+4*j]).getValue());
                    callMins += mins[j-1] +   " ";
                    means[j-1] = Double.toString(((NumberCell)row[2+4*j]).getValue());
                    maxs[j-1] = Double.toString(((NumberCell)row[3+4*j]).getValue());
                    callMaxs += maxs[j-1] + " ";
                }
                callValues += ")";
                callMins += ")";
                callMaxs += ")";

                String call = "(defrule FUZZY::numerical-to-fuzzy-" + att + " ";
                String ruleName = "FUZZY::numerical-to-fuzzy-" + att;
                if (param.equalsIgnoreCase("all")) {
                    call += "?m <- (" + template + " (" + att + "# ?num&~nil) (" + att + " nil) (factHistory ?fh)) => " ;
                    call += "(bind ?value (numerical-to-fuzzy ?num " + callValues + " " + callMins + " " + callMaxs + " )) (modify ?m (" + att  + " ?value)"
                            + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ruleName+") \" \" ?fh \"}\"))"
                            + ")) ";
                }
                else {
                    String att2 = att.substring(0, att.length()-1);
                    call += "?m <- (" + template + " (Parameter \"" + param + "\") (" + att2 + "# ?num&~nil) (" + att + " nil) (factHistory ?fh)) => " ;
                    call += "(bind ?value (numerical-to-fuzzy ?num " + callValues + " " + callMins + " " + callMaxs + " )) (modify ?m (" + att  + " ?value)"
                            + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ruleName+") \" \" ?fh \"}\"))"
                            + ")) ";
                }

                r.eval(call);
            }
        }
        catch (Exception e) {
            System.out.println("EXC in loadAttributeInheritanceRules " + e.getMessage());
        }
    }

    private void loadRequirementRulesAttribs(Rete r, Workbook xls, String sheet, MatlabFunctions m) {
        try {
            Sheet meas = xls.getSheet(sheet);
            int numLines = meas.getRows();
            String call2 = "(deffacts REQUIREMENTS::init-subobjectives ";
            String lhs = "";
            String rhs = "";
            String rhs2 = " (bind ?list (create$ ";
            String currentSubobj = "";
            int numAttrib = 0;
            String reqRule = "";
            String attribs = "";
            String param = "";
            String currentParam = "";
            String ruleName = "";
            HashMap<String, ArrayList<String>> subobjTests = new HashMap<>();
            params.requirementRules = new HashMap<>();
            for (int i = 1; i < numLines; i++) {
                Cell[] row = meas.getRow(i);
                String subobj = row[0].getContents();
                param = row[1].getContents();
                params.subobjMeasurementParams.put(subobj, param);

                ArrayList<String> attribTest = new ArrayList<>();
                if (!subobj.equalsIgnoreCase(currentSubobj)) {
                    if (numAttrib > 0) {
                        //finish this requirement rule
                        String[] tokens = currentSubobj.split("-",2);// limit = 2 so that remain contains RegionofInterest Global
                        String parent = tokens[0];
                        String index = tokens[1];
                        call2 += " (AGGREGATION::SUBOBJECTIVE (satisfaction 0.0) (id " + currentSubobj + ") (index " + index + ") (parent " + parent + ") (reasons (create$ " + StringUtils.repeat("N-A ", numAttrib) + " ))"
                                + "(factHistory F" + params.nof + ")) ";
                        params.nof++;
                        String rhs0 = ") => (bind ?reason \"\") (bind ?new-reasons (create$ "  + StringUtils.repeat("N-A ",numAttrib) + "))";
                        reqRule = lhs + rhs0 + rhs + rhs2 + ")) (assert (AGGREGATION::SUBOBJECTIVE (id " + currentSubobj + ") (attributes " + attribs + ") (index " + index + ") (parent " + parent + " ) (attrib-scores ?list) (satisfaction (*$ ?list)) (reasons ?new-reasons) (satisfied-by ?whom) (reason ?reason )"
                                + " (requirement-id (?m getFactId)) " + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ruleName+") \" A\" (call ?m getFactId) \"}\"))"
                                + "))";
                        reqRule += ")";
                        params.requirementRules.put(currentSubobj, subobjTests);

                        // Fill information
                        String objective = currentSubobj.split("-")[0];
                        String panel = objective.substring(0, 3);
                        params.subobjectivesToMeasurements.put(currentSubobj, currentParam);
                        if (params.objectivesToMeasurements.containsKey(objective)) {
                            params.objectivesToMeasurements.get(objective).add(currentParam);
                        }
                        else {
                            ArrayList<String> measurements = new ArrayList<>();
                            measurements.add(currentParam);
                            params.objectivesToMeasurements.put(objective, measurements);
                        }
                        if (params.panelsToMeasurements.containsKey(panel)) {
                            params.panelsToMeasurements.get(panel).add(currentParam);
                        }
                        else {
                            ArrayList<String> measurements = new ArrayList<>();
                            measurements.add(currentParam);
                            params.panelsToMeasurements.put(panel, measurements);
                        }
                        r.eval(reqRule);

                        //start next requirement rule
                        rhs = "";
                        rhs2 = " (bind ?list (create$ ";
                        attribs = "";

                        lhs = "(defrule REQUIREMENTS::"  + subobj + "-attrib ?m <- (REQUIREMENTS::Measurement (taken-by ?whom) (power-duty-cycle# ?pc) (data-rate-duty-cycle# ?dc)  (Parameter " + param + ")";
                        ruleName = "REQUIREMENTS::"  + subobj + "-attrib";
                        currentSubobj = subobj;
                        currentParam = param;
                        numAttrib = 0;
                        subobjTests = new HashMap<>();
                    }
                    else {
                        //start next requirement rule
                        rhs = "";
                        rhs2 = " (bind ?list (create$ ";
                        attribs = "";
                        lhs = "(defrule REQUIREMENTS::"  + subobj + "-attrib ?m <- (REQUIREMENTS::Measurement (taken-by ?whom)  (power-duty-cycle# ?pc) (data-rate-duty-cycle# ?dc)  (Parameter " + param + ")";
                        ruleName = "REQUIREMENTS::"  + subobj + "-attrib";
                        currentSubobj = subobj;
                        currentParam = param;
                        subobjTests = new HashMap<>();
                    }
                }

                String attrib = row[2].getContents();
                attribs += " " + attrib;
                String type = row[3].getContents();
                String thresholds = row[4].getContents();
                String scores = row[5].getContents();
                String justif = row[6].getContents();
                attribTest.add(type);
                attribTest.add(thresholds);
                attribTest.add(scores);
                subobjTests.put(attrib, attribTest);
                numAttrib++;
                lhs += " (" + attrib + " ?val" + numAttrib + "&~nil) ";
                rhs += "(bind ?x" + numAttrib + " (nth$ (find-bin-num ?val" + numAttrib + " " + m.toJessList(thresholds) + " ) " + m.toJessList(scores) + "))";
                rhs += "(if (< ?x" + numAttrib + " 1.0) then (bind ?new-reasons (replace$  ?new-reasons " + numAttrib + " " + numAttrib + " " + justif
                        + " )) (bind ?reason (str-cat ?reason " + " " + justif + "))) ";
                rhs2 += " ?x" + numAttrib;
            }
            //Last rule has not been processed
            String[] tokens = currentSubobj.split("-",2);// limit = 2 so that remain contains RegionofInterest Global
            String parent = tokens[0];
            String index = tokens[1];
            call2 += " (AGGREGATION::SUBOBJECTIVE (satisfaction 0.0) (id " + currentSubobj + ") (index " + index + ") (parent " + parent + ") (reasons (create$ " + StringUtils.repeat("N-A ",numAttrib) + " ))"
                    + " (requirement-id -1) (factHistory F" + params.nof + ")) ";
            params.nof++;
            String rhs0 = ") => (bind ?reason \"\") (bind ?new-reasons (create$ "  + StringUtils.repeat("N-A ",numAttrib) + "))";
            reqRule = lhs + rhs0 + rhs + rhs2 + ")) (assert (AGGREGATION::SUBOBJECTIVE (id " + currentSubobj + ") (attributes " + attribs + ") (index " + index + ") (parent " + parent + " ) (attrib-scores ?list) (satisfaction (*$ ?list)) (reasons ?new-reasons) (satisfied-by ?whom) (reason ?reason )"
                    + " (requirement-id (?m getFactId)) " + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ruleName+") \" A\" (call ?m getFactId) \"}\"))"
                    + "))";
            reqRule += ")";

            r.eval(reqRule);
            params.requirementRules.put(currentSubobj, subobjTests);

            String objective = currentSubobj.split("-")[0];
            String panel = objective.substring(0, 3);
            params.subobjectivesToMeasurements.put(currentSubobj, currentParam);
            if (params.objectivesToMeasurements.containsKey(objective)) {
                params.objectivesToMeasurements.get(objective).add(currentParam);
            }
            else {
                ArrayList<String> measurements = new ArrayList<>();
                measurements.add(currentParam);
                params.objectivesToMeasurements.put(objective, measurements);
            }
            if (params.panelsToMeasurements.containsKey(panel)) {
                params.panelsToMeasurements.get(panel).add(currentParam);
            }
            else {
                ArrayList<String> measurements = new ArrayList<>();
                measurements.add(currentParam);
                params.panelsToMeasurements.put(panel, measurements);
            }
            call2 += ")";
            r.eval(call2);

            params.measurementsToSubobjectives = getInverseHashMapSSToSAL(params.subobjectivesToMeasurements);
            params.measurementsToObjectives = getInverseHashMapSALToSAL(params.objectivesToMeasurements);
            params.measurementsToPanels = getInverseHashMapSALToSAL(params.panelsToMeasurements);
        }
        catch (Exception e) {
            e.printStackTrace();
            System.out.println("EXC in loadRequirementRulesAttribs " + e.getMessage());
        }
    }

    private void loadFuzzyRequirementRulesAttribs(Rete r, Workbook xls, String sheet, MatlabFunctions m) {
        try {
            Sheet meas = xls.getSheet(sheet);
            int numLines = meas.getRows();
            String call2 = "(deffacts REQUIREMENTS::init-subobjectives ";
            String lhs = "";
            String rhs = "";
            String rhs2 = " (bind ?list (create$ ";
            String currentSubobj = "";
            int numAttribs = 0;
            String req_rule = "";
            String attribs = "";
            String param = "";
            String currentParam = "";
            String ruleName = "";
            HashMap<String, ArrayList<String>> subobjTests = new HashMap<>();
            params.requirementRules = new HashMap<>();
            for (int i = 1; i < numLines; i++) {
                Cell[] row = meas.getRow(i);
                String subobj = row[0].getContents();
                param = row[1].getContents();
                params.subobjMeasurementParams.put(subobj, param);

                ArrayList<String> attribTest = new ArrayList<>();
                if (!subobj.equalsIgnoreCase(currentSubobj)) {
                    if (numAttribs > 0) {
                        //finish this requirement rule
                        String[] tokens = currentSubobj.split("-",2);// limit = 2 so that remain contains RegionofInterest Global
                        String parent = tokens[0];
                        String index = tokens[1];
                        call2 += " (AGGREGATION::SUBOBJECTIVE (satisfaction 0.0) (fuzzy-value (new FuzzyValue \"Value\" 0.0 0.0 0.0 \"utils\" (MatlabFunctions getValueInvHashmap))) (id " + currentSubobj + ") (index " + index + ") (parent " + parent + ") (reasons (create$ " + StringUtils.repeat("N-A ",numAttribs) + " ))"
                                + "(factHistory F" + params.nof + ")) ";
                        params.nof++;
                        String rhs0 = ") => (bind ?reason \"\") (bind ?new-reasons (create$ "  + StringUtils.repeat("N-A ",numAttribs + 2) + "))";
                        req_rule = lhs + rhs0 + rhs + rhs2 + " ?dc ?pc)) (assert (AGGREGATION::SUBOBJECTIVE (id " + currentSubobj + ") (attributes " + attribs + " data-rate-duty-cycle# power-duty-cycle#) (index " + index + ") (parent " + parent + " ) "
                                + "(attrib-scores ?list) (satisfaction (*$ ?list)) (fuzzy-value (new FuzzyValue \"Value\" (call "
                                + "(new FuzzyValue \"Value\" (new Interval \"interval\" (*$ ?list) (*$ ?list)) \"utils\" "
                                + "(MatlabFunctions getValueHashmap)) getFuzzy_val) \"utils\" (MatlabFunctions getValueInvHashmap))) "
                                + " (reasons ?new-reasons) (satisfied-by ?whom) (reason ?reason )"
                                + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ruleName+") \" A\" (call ?m getFactId) \"}\"))"
                                + "))";
                        req_rule += ")";
                        params.requirementRules.put(currentSubobj, subobjTests);
                        // Fill information
                        String objective = currentSubobj.split("-")[0];
                        String panel = objective.substring(0, 3);
                        params.subobjectivesToMeasurements.put(currentSubobj, currentParam);
                        if (params.objectivesToMeasurements.containsKey(objective)) {
                            params.objectivesToMeasurements.get(objective).add(currentParam);
                        }
                        else {
                            ArrayList<String> measurements = new ArrayList<>();
                            measurements.add(currentParam);
                            params.objectivesToMeasurements.put(objective, measurements);
                        }
                        if (params.panelsToMeasurements.containsKey(panel)) {
                            params.panelsToMeasurements.get(panel).add(currentParam);
                        }
                        else {
                            ArrayList<String> measurements = new ArrayList<>();
                            measurements.add(currentParam);
                            params.panelsToMeasurements.put(panel, measurements);
                        }
                        r.eval(req_rule);

                        //start next requirement rule
                        rhs = "";
                        rhs2 = " (bind ?list (create$ ";
                        attribs = "";

                        lhs = "(defrule FUZZY-REQUIREMENTS::"  + subobj + "-attrib ?m <- (REQUIREMENTS::Measurement (taken-by ?whom) (data-rate-duty-cycle# ?dc) (power-duty-cycle# ?pc) (Parameter " + param + ") ";
                        ruleName = "FUZZY-REQUIREMENTS::"  + subobj + "-attrib";
                        currentSubobj = subobj;
                        currentParam = param;
                        numAttribs = 0;
                        subobjTests = new HashMap<>();
                    }
                    else {
                        //start next requirement rule
                        rhs = "";
                        rhs2 = " (bind ?list (create$ ";
                        attribs = "";
                        lhs = "(defrule FUZZY-REQUIREMENTS::"  + subobj + "-attrib ?m <- (REQUIREMENTS::Measurement (taken-by ?whom) (data-rate-duty-cycle# ?dc) (power-duty-cycle# ?pc) (Parameter " + param + ") ";
                        ruleName = "FUZZY-REQUIREMENTS::"  + subobj + "-attrib";
                        currentSubobj = subobj;
                        currentParam = param;
                        subobjTests = new HashMap<>();
                    }
                }

                String attrib = row[2].getContents();
                attribs += " " + attrib;
                String type = row[3].getContents();
                String thresholds = row[4].getContents();
                String scores = row[5].getContents();
                String justif = row[6].getContents();
                attribTest.add(type);
                attribTest.add(thresholds);
                attribTest.add(scores);
                subobjTests.put(attrib, attribTest);
                numAttribs++;
                lhs += " (" + attrib + " ?val" + numAttribs + "&~nil) ";
                rhs += "(bind ?x" + numAttribs + " (nth$ (find-bin-num ?val" + numAttribs + " " + m.toJessList(thresholds) + " ) " + m.toJessList(scores) + "))";
                rhs += "(if (< ?x" + numAttribs + " 1.0) then (bind ?new-reasons (replace$  ?new-reasons " + numAttribs + " " + numAttribs + " " + justif
                        + " )) (bind ?reason (str-cat ?reason " + " " + justif + "))) ";
                rhs2 += " ?x" + numAttribs;
            }
            //Last rule has not been processed
            String[] tokens = currentSubobj.split("-",2);// limit = 2 so that remain contains RegionofInterest Global
            String parent = tokens[0];
            String index = tokens[1];
            call2 += " (AGGREGATION::SUBOBJECTIVE (satisfaction 0.0) (fuzzy-value "
                    + "(new FuzzyValue \"Value\" 0.0 0.0 0.0 \"utils\" (MatlabFunctions getValueInvHashmap)))"
                    + " (id " + currentSubobj + ") (index " + index + ") (parent " + parent + ") "
                    + "(reasons (create$ " + StringUtils.repeat("N-A ",numAttribs + 2) + " ))"
                    + "(factHistory F" + params.nof + ")) ";
            params.nof++;
            String rhs0 = ") => (bind ?reason \"\") (bind ?new-reasons (create$ "  + StringUtils.repeat("N-A ",numAttribs) + "))";
            req_rule = lhs + rhs0 + rhs + rhs2 + " ?dc ?pc)) (assert (AGGREGATION::SUBOBJECTIVE (id " + currentSubobj + ") (attributes " + attribs + " data-rate-duty-cycle# power-duty-cycle#) (index " + index + ") (parent " + parent + " ) "
                    + "(attrib-scores ?list) (satisfaction (*$ ?list)) (fuzzy-value (new FuzzyValue \"Value\" (call "
                    + "(new FuzzyValue \"Value\" (new Interval \"interval\" (*$ ?list) (*$ ?list)) \"utils\" "
                    + "(MatlabFunctions getValueHashmap)) getFuzzy_val) \"utils\" (MatlabFunctions getValueInvHashmap))) "
                    + " (reasons ?new-reasons) (satisfied-by ?whom) (reason ?reason ) (factHistory (str-cat \"{R\" (?*rulesMap* get "+ruleName+") \" A\" (call ?m getFactId) \"}\"))))";
            req_rule += ")";

            r.eval(req_rule);
            params.requirementRules.put(currentSubobj,subobjTests);
            // Fill information
            String objective = currentSubobj.split("-")[0];
            String panel = objective.substring(0, 3);
            params.subobjectivesToMeasurements.put(currentSubobj, currentParam);
            if (params.objectivesToMeasurements.containsKey(objective)) {
                params.objectivesToMeasurements.get(objective).add(currentParam);
            }
            else {
                ArrayList<String> measurements = new ArrayList<>();
                measurements.add(currentParam);
                params.objectivesToMeasurements.put(objective, measurements);
            }
            if (params.panelsToMeasurements.containsKey(panel)) {
                params.panelsToMeasurements.get(panel).add(currentParam);
            }
            else {
                ArrayList<String> measurements = new ArrayList<>();
                measurements.add(currentParam);
                params.panelsToMeasurements.put(panel, measurements);
            }
            call2 += ")";
            r.eval(call2);

            params.measurementsToSubobjectives = getInverseHashMapSSToSAL(params.subobjectivesToMeasurements);
            params.measurementsToObjectives = getInverseHashMapSALToSAL(params.objectivesToMeasurements);
            params.measurementsToPanels = getInverseHashMapSALToSAL(params.panelsToMeasurements);
        }
        catch (Exception e) {
            System.out.println("EXC in loadFuzzyRequirementRulesAttribs " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void loadCapabilityRules(Rete r, Workbook xls, String clp) {
        try {
            r.batch(clp);
            for (String instrument: params.instrumentList) {
                Sheet sh = xls.getSheet(instrument);
                int numMeasurements = sh.getRows();
                ArrayList<String> meas = new ArrayList<>();
                ArrayList<String> subobj = new ArrayList<>();
                ArrayList<String> obj = new ArrayList<>();
                ArrayList<String> pan = new ArrayList<>();
                String ruleName = "MANIFEST::" + instrument + "-init-can-measure";
                String call = "(defrule MANIFEST::" + instrument + "-init-can-measure " + "(declare (salience -20)) ?this <- (CAPABILITIES::Manifested-instrument  (Name ?ins&" + instrument
                        +  ") (Id ?id) (flies-in ?miss) (Intent ?int) (Spectral-region ?sr) (orbit-type ?typ) (orbit-altitude# ?h) (orbit-inclination ?inc) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) (Illumination ?il) (factHistory ?fh)) "
                        + " (not (CAPABILITIES::can-measure (instrument ?ins) (in-orbit ?miss) (can-take-measurements no))) => "
                        + "(assert (CAPABILITIES::can-measure (instrument ?ins) (orbit-type ?typ) (orbit-altitude# ?h) (orbit-inclination ?inc) (data-rate-duty-cycle# nil) (power-duty-cycle# nil)(orbit-RAAN ?raan)"
                        + "(in-orbit (eval (str-cat ?typ \"-\" ?h \"-\" ?inc \"-\" ?raan))) (can-take-measurements yes) (reason \"by default\") "
                        + "(copied-to-measurement-fact no)(factHistory (str-cat \"{R\" (?*rulesMap* get "+ ruleName +") \" A\" (call ?this getFactId) \"}\")))))";
                r.eval(call);

                ruleName = "CAPABILITIES::" + instrument + "-measurements";
                String call2 = "(defrule CAPABILITIES-GENERATE::" + instrument + "-measurements " + "?this <- (CAPABILITIES::Manifested-instrument  (Name ?ins&" + instrument
                        +  ") (Id ?id) (flies-in ?miss) (Intent ?int) (orbit-string ?orb) (Spectral-region ?sr) (orbit-type ?typ) (orbit-altitude# ?h) (orbit-inclination ?inc) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) (Illumination ?il) (factHistory ?fh1)) "
                        + " ?this2 <- (CAPABILITIES::can-measure (instrument ?ins) (in-orbit ?orb) (can-take-measurements yes) (data-rate-duty-cycle# ?dc-d) (power-duty-cycle# ?dc-p) (copied-to-measurement-fact no)(factHistory ?fh2)) => "
                        + " (if (and (numberp ?dc-d) (numberp ?dc-p)) then (bind ?*science-multiplier* (min ?dc-d ?dc-p)) else (bind ?*science-multiplier* 1.0)) "
                        + "(assert (CAPABILITIES::resource-limitations (data-rate-duty-cycle# ?dc-d) (power-duty-cycle# ?dc-p)"
                        + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ ruleName +") \" A\" (call ?this getFactId) \" A\" (call ?this2 getFactId) \"}\"))"
                        + ")) ";
                String listOfMeasurements = "";
                for (int i = 0; i < numMeasurements; i++) {
                    Cell[] row = sh.getRow(i);
                    call2 += "(assert (REQUIREMENTS::Measurement";

                    String capabilityType = row[0].getContents(); // Measurement
                    if (!capabilityType.equalsIgnoreCase("Measurement")) {
                        throw new Exception("loadCapabilityRules: Type of capability not recognized (use Measurement)");
                    }
                    String att_value_pair = row[1].getContents();
                    String[] tokens2 = att_value_pair.split(" ",2);
                    String att = tokens2[0]; // Parameter
                    String val = tokens2[1]; // "x.x.x Soil moisture"
                    meas.add(val);
                    for (int j = 1; j < row.length; j++) {
                        String att_value_pair2 = row[j].getContents();
                        tokens2 = att_value_pair2.split(" ",2);
                        if (tokens2[1].equalsIgnoreCase("nil")) {
                            continue;
                        }
                        call2 += " (" + att_value_pair2 + ") ";
                    }
                    call2 += "(taken-by " + instrument +  ") (flies-in ?miss) (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) (Id " + instrument + i + ") (Instrument " + instrument + ")"
                            + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ ruleName +") \" A\" (call ?this getFactId) \" A\" (call ?this2 getFactId) \"}\"))"
                            + ")) ";
                    listOfMeasurements += " " + instrument + i + " ";
                }
                call2 += "(assert (SYNERGIES::cross-registered (measurements " + listOfMeasurements + " ) (degree-of-cross-registration instrument) (platform ?id  )"
                        + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ ruleName +") \" A\" (call ?this getFactId) \" A\" (call ?this2 getFactId) \"}\"))"
                        + "))";
                call2 += "(modify ?this (measurement-ids " + listOfMeasurements + ")"
                        + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ ruleName +") \" \" ?fh1 \" S\" (call ?this2 getFactId) \"}\"))"
                        + ")";
                call2 += "(modify ?this2 (copied-to-measurement-fact yes)"
                        + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ ruleName +") \" \" ?fh1 \" S\" (call ?this2 getFactId) \"}\"))"
                        + "))";

                r.eval(call2);
                params.instrumentsToMeasurements.put(instrument, meas);
                for (String measurement: meas) {
                    ArrayList<String> subobjectives = params.measurementsToSubobjectives.get(measurement);
                    if (subobjectives != null) {
                        for (String subobjective: subobjectives) {
                            if (subobj.indexOf(subobjective) == -1) {
                                subobj.add(subobjective);
                            }
                        }
                    }
                }
                params.instrumentsToSubobjectives.put(instrument, subobj);
                for (String measurement: meas) {
                    ArrayList<String> objectives = params.measurementsToObjectives.get(measurement);
                    if (objectives != null) {
                        for (String objective : objectives) {
                            if (obj.indexOf(objective) == -1) {
                                obj.add(objective);
                            }
                        }
                    }
                }
                params.instrumentsToObjectives.put(instrument, obj);
                for (String measurement: meas) {
                    ArrayList<String> panels = params.measurementsToPanels.get(measurement);
                    if (panels != null) {
                        for (String panel: panels) {
                            if (pan.indexOf(panel) == -1) {
                                pan.add(panel);
                            }
                        }
                    }
                }
                params.instrumentsToPanels.put(instrument, pan);
            }
            params.measurementsToInstruments = getInverseHashMapSALToSAL(params.instrumentsToMeasurements);
            params.subobjectivesToInstruments = getInverseHashMapSALToSAL(params.instrumentsToMeasurements);
            params.objectivesToInstruments = getInverseHashMapSALToSAL(params.instrumentsToObjectives);
            params.panelsToInstruments = getInverseHashMapSALToSAL(params.instrumentsToPanels);
        }
        catch (Exception e) {
            System.out.println("EXC in loadCapabilityRules " + e.getMessage());
            e.printStackTrace();
            throw new Error();
        }
    }

    private HashMap<String, ArrayList<String>> getInverseHashMapSALToSAL(HashMap<String, ArrayList<String>> hm) {
        HashMap<String, ArrayList<String>> inverse = new HashMap<>();
        for (Map.Entry<String, ArrayList<String>> entr: hm.entrySet()) {
            String key = entr.getKey();
            ArrayList<String> vals = entr.getValue();
            for (String val: vals) {
                if (inverse.containsKey(val)) {
                    ArrayList<String> list = inverse.get(val);
                    if (!list.contains(key)) {
                        list.add(key);
                        inverse.put(val, list);
                    }
                }
                else {
                    ArrayList<String> list = new ArrayList<>();
                    list.add(key);
                    inverse.put(val, list);
                }
            }
        }
        return inverse;
    }

    private HashMap<String, ArrayList<String>> getInverseHashMapSSToSAL(HashMap<String, String> hm) {
        HashMap<String, ArrayList<String>> inverse = new HashMap<>();
        for (Map.Entry<String, String> entr: hm.entrySet()) {
            String key = entr.getKey();
            String val = entr.getValue();
            if (inverse.containsKey(val)) {
                ArrayList<String> list = inverse.get(val);
                if (!list.contains(key)) {
                    list.add(key);
                    inverse.put(val, list);
                }
            }
            else {
                ArrayList<String> list = new ArrayList<>();
                list.add(key);
                inverse.put(val, list);
            }
        }
        return inverse;
    }

    private void loadSynergyRules(Rete r, String clp) {
        try {
            r.batch(clp);
            for(Map.Entry<String, ArrayList<String>> es: params.measurementsToSubobjectives.entrySet()) {
                String meas = es.getKey();
                for (String subobj: es.getValue()) {
                    String call = "(defrule SYNERGIES::stop-improving-" + meas.substring(1, meas.indexOf(" ")) + " ";
                    String ruleName = "SYNERGIES::stop-improving-" + meas.substring(1, meas.indexOf(" "));
                    call += "?fsat <- (REASONING::fully-satisfied (subobjective " + subobj + ") (factHistory ?fh))";
                    call += " => (assert (REASONING::stop-improving (Measurement " + meas + ")"
                            + "(factHistory (str-cat \"{R\" (?*rulesMap* get "+ruleName+") \" A\" (call ?fsat getFactId) \"}\"))"
                            + ")))";
                    r.eval(call);
                }
            }
        }
        catch (Exception e) {
            System.out.println("EXC in loadSynergyRules " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void loadAggregationRules(Rete r, Workbook xls, String sheet, String[] clps) {
        try {
            for (String clp: clps) {
                r.batch(clp);
            }
            Sheet meas = xls.getSheet(sheet);

            //Stakeholders or panels
            Cell[] col = meas.getColumn(1);
            params.numPanels = col.length - 3;
            String call = "(deffacts AGGREGATION::init-aggregation-facts ";
            params.panelNames = new ArrayList<>(params.numPanels);
            params.panelWeights = new ArrayList<>(params.numPanels);
            params.panelDescriptions = new HashMap<>();
            params.objNames = new ArrayList<>(params.numPanels);
            params.objWeights = new ArrayList<>(params.numPanels);
            params.subobjWeights = new ArrayList<>(params.numPanels);
            params.numObjectivesPerPanel = new ArrayList<>(params.numPanels);
            params.subobjWeightsMap = new HashMap<>();
            for (int i = 0; i < params.numPanels; i++) {
                String panelName = meas.getCell(1, i+2).getContents();
                String panelDescription = meas.getCell(2, i+2).getContents();
                params.panelNames.add(panelName);
                NumberCell nc = (NumberCell)meas.getCell(3, i+2);
                params.panelWeights.add(nc.getValue());
                params.panelDescriptions.put(panelName, panelDescription);
            }
            call = call.concat(" (AGGREGATION::VALUE (sh-scores (repeat$ -1.0 " + params.numPanels + ")) (sh-fuzzy-scores (repeat$ -1.0 " + params.numPanels + ")) (weights " + javaArrayList2JessList(params.panelWeights) + ")"
                    + "(factHistory F" + params.nof + "))");
            params.nof++;

            // Objectives
            Cell[] obj_w = meas.getColumn(8);
            Cell[] obj_n = meas.getColumn(6);
            Cell[] obj_d = meas.getColumn(7);
            int i = 3;
            int p = 0;

            HashMap<String, String> objDescriptions = new HashMap<>();
            while (p < params.numPanels) {
                Boolean new_panel = false;
                ArrayList<Double> obj_weights_p = new ArrayList<>();
                ArrayList<String> obj_names_p = new ArrayList<>();
                while (!new_panel) {
                    NumberCell nc2 = (NumberCell) obj_w[i];
                    obj_weights_p.add(nc2.getValue());
                    String obj = obj_n[i].getContents();
                    objDescriptions.put(obj, obj_d[i].getContents());
                    new_panel = obj_d[i+1].getContents().equalsIgnoreCase("");
                    obj_names_p.add(obj);
                    i++;
                }
                params.objWeights.add(obj_weights_p);
                params.objNames.add(obj_names_p);
                params.numObjectivesPerPanel.add(obj_weights_p.size());

                call = call.concat(" (AGGREGATION::STAKEHOLDER (id " + params.panelNames.get(p) + " ) (index " + (p + 1) + " ) (obj-fuzzy-scores (repeat$ -1.0 " +  obj_weights_p.size() + ")) (obj-scores (repeat$ -1.0 " + obj_weights_p.size() + ")) (weights " +  javaArrayList2JessList(obj_weights_p) + ")"
                        + "(factHistory F" + params.nof + ")) ");
                params.nof++;
                p++;
                i += 4;
            }
            params.objectiveDescriptions = objDescriptions;

            // Subobjectives
            p = 0;
            params.subobjectives = new ArrayList<>();
            HashMap<String, String> subobjDescriptions = new HashMap<>();
            while (p < params.numPanels) {
                Cell[] subobj_w = meas.getColumn(13+p*5);
                Cell[] subobj_n = meas.getColumn(11+p*5);
                Cell[] subobj_d = meas.getColumn(12+p*5);
                ArrayList<ArrayList<Double>> subobj_weights_p = new ArrayList<>();
                ArrayList<ArrayList<String>> subobj_p = new ArrayList<>(params.numObjectivesPerPanel.get(p));
                i = 4;
                int o = 0;
                while (o < params.numObjectivesPerPanel.get(p)) {
                    Boolean new_obj = false;
                    ArrayList<Double> subobj_weights_o = new ArrayList<>();
                    ArrayList<String> subobj_o = new ArrayList<>();
                    int so = 1;
                    while (!new_obj) {
                        NumberCell nc3 = (NumberCell) subobj_w[i];
                        double weight = nc3.getValue();
                        subobj_weights_o.add(weight);
                        String subobj_name = params.panelNames.get(p) + (o + 1) + "-" + so;
                        subobjDescriptions.put(subobj_name, subobj_d[i].getContents());
                        params.subobjWeightsMap.put(subobj_name, weight);
                        subobj_o.add(subobj_name);
                        i++;
                        so++;
                        if (i >= subobj_n.length) {
                            new_obj = true;
                        }
                        else {
                            String subobj = subobj_n[i].getContents();
                            new_obj = subobj.equalsIgnoreCase("");
                        }
                    }
                    subobj_weights_p.add(subobj_weights_o);
                    subobj_p.add(subobj_o);
                    call = call.concat(" (AGGREGATION::OBJECTIVE (id " + params.panelNames.get(p) + (o + 1) + " ) (parent " + params.panelNames.get(p) + ") (index " + (o + 1)+ " ) (subobj-fuzzy-scores (repeat$ -1.0 " +  subobj_weights_o.size() + ")) (subobj-scores (repeat$ -1.0 " + subobj_weights_o.size() + ")) (weights " +  javaArrayList2JessList(subobj_weights_o) + ")"
                            + "(factHistory F" + params.nof + ")) ");
                    params.nof++;
                    o++;
                    i += 4;
                }
                p++;
                params.subobjWeights.add(subobj_weights_p);
                params.subobjectives.add(subobj_p);
            }
            params.subobjDescriptions = subobjDescriptions;
            call = call.concat(")"); //close deffacts
            r.eval(call);
        }
        catch (Exception e) {
            System.out.println("EXC in loadAggregationRules " +e.getMessage());
        }
    }

    private String javaArrayList2JessList(ArrayList<Double> list) {
        String call = "(create$";
        for (Double elem: list) {
            call += " " + elem.toString();
        }
        call += ")";
        return call;
    }

    private void loadAssimilationRules(Rete r, String clp) {
        try {
            r.batch(clp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadAssimilationRules " + e.getMessage());
        }
    }

    private void loadMassBudgetRules(Rete r, String clp) {
        try {
            r.batch(clp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadMassBudgetRules " + e.getMessage());
        }
    }

    private void loadSpacecraftDesignRules(Rete r, String clp) {
        try {
            r.batch(clp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadEpsDesignRules " + e.getMessage());
        }
    }

    private void loadCostEstimationRules(Rete r, String[] clps) {
        try {
            for (String clp:clps) {
                r.batch(clp);
            }
        }
        catch (Exception e) {
            System.out.println("EXC in loadCostEstimationRules " + e.getMessage());
        }
    }

    private void loadLaunchVehicleSelectionRules(Rete r, String clp) {
        try {
            r.batch(clp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadLaunchVehicleSelectionRules " + e.getMessage());
        }
    }

    private void loadSearchRules(Rete r, String clp) {
        try {
            r.batch(clp);
            r.reset();
            r.setFocus("DATABASE");
            r.run();
        }
        catch (Exception e) {
            System.err.println("EXC in loadSearchRules " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void loadDownSelectionRules(Rete r, String clp) {
        try {
            r.batch(clp);
        }
        catch (Exception e) {
            System.out.println("EXC in loadDownSelectionRules " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void loadExplanationRules(Rete r, String clp) {
        try {
            r.batch(clp);
            String call = "(defquery REQUIREMENTS::search-all-measurements-by-parameter \"Finds all measurements of this parameter in the campaign\" " +
                    "(declare (variables ?param)) " +
                    "(REQUIREMENTS::Measurement (Parameter ?param) (flies-in ?flies) (launch-date ?ld) (lifetime ?lt) (Instrument ?instr)" +
                    " (Temporal-resolution ?tr) (All-weather ?aw) (Horizontal-Spatial-Resolution ?hsr) (Spectral-sampling ?ss)" +
                    " (taken-by ?tk) (Vertical-Spatial-Resolution ?vsr) (sensitivity-in-low-troposphere-PBL ?tro) (sensitivity-in-upper-stratosphere ?str)))";
            r.eval(call);
        }
        catch (Exception e) {
            System.out.println("EXC in loadExplanationRules " + e.getMessage());
        }
    }

    private String createJessList(String str) {
        String s = "(create$ ";
        
        str = str.substring(1, str.length()-1);
        String[] list = str.split(",");
        
        for(String elem: list)
            s += elem + " ";
        
        return s + ")";
    }
}
