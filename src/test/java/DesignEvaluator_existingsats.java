import jess.Fact;
import jess.JessException;
import jess.Value;
import jess.ValueVector;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.BaseParams;
import seakers.vassar.Resource;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;
import seakers.vassar.utils.SpectrometerDesign;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class DesignEvaluator_existingsats {
    public static void main(String[] args) {
        String path = "../VASSAR_resources";
        OrekitConfig.init(16);
        ArrayList<String> orbitList = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> existingSatellites = new ArrayList<>();
        String landsatOrbitName = "LEO-705-98.2-0.0-0.0";
        OrbitInstrumentObject landsat = new OrbitInstrumentObject(new String[]{"Landsat"},landsatOrbitName);
        existingSatellites.add(landsat);
        String sbgOrbitName = "LEO-623-97.2-0.0-180.0";
        OrbitInstrumentObject sbg = new OrbitInstrumentObject(new String[]{"SBG"},sbgOrbitName);
        existingSatellites.add(sbg);
        String sentinel2aOrbitName = "LEO-786-98.62-0.0-90.0";
        OrbitInstrumentObject sentinel2a = new OrbitInstrumentObject(new String[]{"Sentinel2A"},sentinel2aOrbitName);
        existingSatellites.add(sentinel2a);
        String sentinel2bOrbitName = "LEO-786-98.62-0.0-270.0";
        OrbitInstrumentObject sentinel2b = new OrbitInstrumentObject(new String[]{"Sentinel2B"},sentinel2bOrbitName);
        existingSatellites.add(sentinel2b);
        SimpleArchitecture architecture = new SimpleArchitecture(existingSatellites);
        String[] orbList = new String[orbitList.size()];
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        SimpleParams simpleParams = new SimpleParams(orbList, "XGrants", path, "CRISP-ATTRIBUTES","test", "fast");
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(simpleParams, evaluator);
        evaluationManager.init(1);
        long start = System.nanoTime();
        Resource res = evaluationManager.getResourcePool().getResource();
        BaseParams params = res.getParams();
        evaluationManager.getResourcePool().freeResource(res);
        Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
        ArrayList<String> subobjs = new ArrayList<>();
        ArrayList<ArrayList<ArrayList<String>>> subobjectives = params.subobjectives;
        for (ArrayList<ArrayList<String>> panel : subobjectives) {
            for(ArrayList<String> objective : panel) {
                subobjs.addAll(objective);
            }
        }
        for (String subobj : subobjs) {
            String parameter = params.subobjectivesToMeasurements.get(subobj);

            // Obtain list of attributes for this parameter
            ArrayList<String> attrNames = new ArrayList<>();
            HashMap<String, ArrayList<String>> requirementRules = params.requirementRules.get(subobj);
            attrNames.addAll(requirementRules.keySet());
            HashMap<String, Integer> numDecimals = new HashMap<>();
            numDecimals.put("Horizontal-Spatial-Resolution#", 0);
            numDecimals.put("Temporal-resolution#", 0);
            numDecimals.put("Swath#", 0);

            // Loop to get rows of details for each data product
            ArrayList<List<String>> attrValues = new ArrayList<>();
            ArrayList<Double> scores = new ArrayList<>();
            ArrayList<String> takenBy = new ArrayList<>();
            ArrayList<List<String>> justifications = new ArrayList<>();
            for (Fact explanation: result.getExplanations().get(subobj)) {
                try {
                    // Try to find the requirement fact!
                    int measurementId = -1;
                    try{
                        measurementId = explanation.getSlotValue("requirement-id").intValue(null);
                    } catch (JessException e) {
                        continue;
                    }
                    if (measurementId == -1) {
                        continue;
                    }
                    Fact measurement = null;
                    for (Fact capability: result.getCapabilities()) {
                        if (capability.getFactId() == measurementId) {
                            measurement = capability;
                            break;
                        }
                    }
                    // Start by putting all attribute values into list
                    ArrayList<String> rowValues = new ArrayList<>();
                    for (String attrName: attrNames) {
                        String attrType = requirementRules.get(attrName).get(0);
                        // Check type and convert to String if needed
                        Value attrValue = measurement.getSlotValue(attrName);
                        switch (attrType) {
                            case "SIB":
                            case "LIB": {
                                Double value = attrValue.floatValue(null);
                                double scale = 100;
                                if (numDecimals.containsKey(attrName)) {
                                    scale = Math.pow(10, numDecimals.get(attrName));
                                }
                                value = Math.round(value * scale) / scale;
                                rowValues.add(attrName+", Measured: "+value.toString()+", Required: "+requirementRules.get(attrName).get(1).toString()+"\n");
                                break;
                            }
                            default: {
                                rowValues.add(attrValue.toString());
                                break;
                            }
                        }
                    }
                    // Get information from explanation fact
                    Double score = explanation.getSlotValue("satisfaction").floatValue(null);
                    String satisfiedBy = explanation.getSlotValue("satisfied-by").stringValue(null);
                    ArrayList<String> rowJustifications = new ArrayList<>();
                    ValueVector reasons = explanation.getSlotValue("reasons").listValue(null);
                    for (int i = 0; i < reasons.size(); ++i) {
                        String reason = reasons.get(i).stringValue(null);
                        if (!reason.equals("N-A")) {
                            rowJustifications.add(reason);
                        }
                    }
                    System.out.println("Subobj: "+subobj);
                    System.out.println("Attr values: "+rowValues);
                    System.out.println("Score: "+score);
                    System.out.println("-------------------------------------------------");
                    //System.out.println("Justifications: "+rowJustifications);
                    // Put everything in their lists
                    attrValues.add(rowValues);
                    scores.add(score);
                    takenBy.add(satisfiedBy);
                    justifications.add(rowJustifications);
                }
                catch (JessException e) {
                    System.err.println(e.toString());
                }
            }
        }
        long end = System.nanoTime();
        System.out.printf("Full constellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
        evaluationManager.clear();
        //architecture.setCost(result.getCost());
        //architecture.setCoverage(result.getCoverage());
        System.out.println(result.getScience());
        System.out.println(architecture.toString("")+"Cost: "+result.getCost()+", Revisit Time: "+result.getCoverage());
        System.exit(0);
    }
}