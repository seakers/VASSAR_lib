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

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

public class DesignEvaluatorFromFile {
    public static double getSSOInclination(double alt) {
        double RE = 6378;
        double a = RE + alt;
        double J2 = 1.08e-3;
        double mu = 398600.0;
        double rate = 2*Math.PI/365.25/86400;
        double n = Math.sqrt(mu/Math.pow(a,3));
        return Math.acos(-2*rate*Math.pow(a,2)/(3*J2*Math.pow(RE,2)*n));
    }
    public static void main(String[] args) throws IOException {
        String path = "../VASSAR_resources";
        OrekitConfig.init(12);
        ArrayList<String> orbitList = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("C:/Users/Ben/Documents/xgrants_downloads/combined_results.csv"))) { // CHANGE THIS FOR YOUR IMPLEMENTATION
            String line;
            int count = 0;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                int r = Integer.parseInt(values[1]); // planes
                int s = Integer.parseInt(values[0]); // satellites per plane
                double alt = Double.parseDouble(values[2]);
                double inc = getSSOInclination(alt)*180/Math.PI;
                ArrayList<OrbitInstrumentObject> radarOnlySatellites = new ArrayList<>();
                for(int m = 0; m < r; m++) {
                    for(int n = 0; n < s; n++) {
                        int pu = 360 / (r*s);
                        int delAnom = pu * r; //in plane spacing between satellites
                        int delRAAN = pu * s; //node spacing
                        int RAAN = delRAAN * m;
                        int f = 1;
                        int phasing = pu * f;
                        int anom = (n * delAnom + phasing * m);
                        String orbitName = "LEO-"+alt+"-"+inc+"-"+RAAN+"-"+anom;
                        if(!orbitList.contains(orbitName)) {
                            orbitList.add(orbitName);
                        }
                        OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"CustomInstrument"},orbitName);
                        radarOnlySatellites.add(radarOnlySatellite);
                    }
                }
                //OrbitInstrumentObject testSatellite = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer"},orbitName);
                //constellation.add(testSatellite);
                SimpleArchitecture architecture = new SimpleArchitecture(radarOnlySatellites);
                String[] orbList = new String[orbitList.size()];
                for (int i =0; i < orbitList.size(); i++)
                    orbList[i] = orbitList.get(i);
                int numVNIRSpec = Integer.parseInt(values[3]);
                int numSWIRSpec = Integer.parseInt(values[4]);
                int tir_bool = Integer.parseInt(values[5]);
                boolean tir = tir_bool == 1;
                double focalLength = Double.parseDouble(values[6]);
                double FOV = Double.parseDouble(values[7]);
                double aperture = Double.parseDouble(values[8]);
                double vnirPixelSize = Double.parseDouble(values[9]);
                double swirPixelSize = Double.parseDouble(values[10]);
                double agility = Double.parseDouble(values[11]);
                SpectrometerDesign sd = new SpectrometerDesign(alt,numVNIRSpec,numSWIRSpec,tir,focalLength,FOV,aperture,vnirPixelSize,swirPixelSize,agility);
                SimpleParams simpleParams = new SimpleParams(orbList, "XGrants", path, "CRISP-ATTRIBUTES","test", "normal", sd);
                DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
                ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(simpleParams, evaluator);
                evaluationManager.init(1);
                long start = System.nanoTime();
                Resource res = evaluationManager.getResourcePool().getResource();
                BaseParams params = res.getParams();
                evaluationManager.getResourcePool().freeResource(res);
                Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
                ArrayList<String> subobjs = new ArrayList<>();
                ArrayList<String> rows = new ArrayList<>();
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
                    int measurementId = -1;
                    Fact realExplanation = result.getExplanations().get(subobj).get(0);
                    for (Fact explanation : result.getExplanations().get(subobj)) {
                        try{
                            realExplanation = explanation;
                            measurementId = explanation.getSlotValue("requirement-id").intValue(null);
                            if(measurementId == -1) {
                                continue;
                            }
                            break;
                        } catch (JessException e) {
                            continue;
                        }
                    }
                    try {
                        // Try to find the requirement fact!
                        Fact measurement = null;
                        for (Fact capability: result.getCapabilities()) {
                            if (capability.getFactId() == measurementId) {
                                measurement = capability;
                                break;
                            }
                        }
                        // Start by putting all attribute values into list
                        ArrayList<String> rowValues = new ArrayList<>();
                        Double[] dblArray = new Double[9];
                        for (int i = 0; i < 9; i++) {
                            dblArray[i] = 0.0;
                        }
                        for (String attrName: attrNames) {
                            if(Objects.equals(attrName, "VSWIR-Accuracy") || Objects.equals(attrName, "lifetime") || Objects.equals(attrName, "TIR-Sensitivity")) {
                                continue;
                            }
                            String attrType = requirementRules.get(attrName).get(0);
                            // Check type and convert to String if needed
                            Value attrValue = measurement.getSlotValue(attrName);
                            switch (attrType) {
                                case "SIB":
                                {
                                    Double value = attrValue.floatValue(null);
                                    double scale = 100;
                                    if (numDecimals.containsKey(attrName)) {
                                        scale = Math.pow(10, numDecimals.get(attrName));
                                    }
                                    value = Math.round(value * scale) / scale;
                                    rowValues.add(attrName+", Measured: "+value.toString()+", Required: "+requirementRules.get(attrName).get(1).toString()+"\n");
                                    Double itemScore = 0.0;
                                    String thresholds = requirementRules.get(attrName).get(1);
                                    thresholds = thresholds.replaceAll("[-+^:\\[\\]]","");
                                    if(value <= Double.parseDouble(thresholds.split(",")[0])) {
                                        itemScore = 1.0;
                                    } else if (value <= Double.parseDouble(thresholds.split(",")[1])) {
                                        itemScore = 0.5;
                                    }
                                    if(Objects.equals(attrName, "VSWIR-Spatial")) {
                                        dblArray[0] = itemScore;
                                    }
                                    if(Objects.equals(attrName, "VSWIR-Temporal")) {
                                        dblArray[1] = itemScore;
                                    }
                                    if(Objects.equals(attrName, "VSWIR-Spectral-Resolution")) {
                                        dblArray[2] = itemScore;
                                    }
                                    break;
                                }
                                case "LIB": {
                                    Double value = attrValue.floatValue(null);
                                    double scale = 100;
                                    if (numDecimals.containsKey(attrName)) {
                                        scale = Math.pow(10, numDecimals.get(attrName));
                                    }
                                    value = Math.round(value * scale) / scale;
                                    rowValues.add(attrName+", Measured: "+value.toString()+", Required: "+requirementRules.get(attrName).get(1).toString()+"\n");
                                    Double itemScore = 0.0;
                                    String thresholds = requirementRules.get(attrName).get(1);
                                    thresholds = thresholds.replaceAll("[-+^:\\[\\]]","");
                                    if(value >= Double.parseDouble(thresholds.split(",")[0])) {
                                        itemScore = 1.0;
                                    } else if (value >= Double.parseDouble(thresholds.split(",")[1])) {
                                        itemScore = 0.5;
                                    }
                                    if(Objects.equals(attrName, "VSWIR-Spectral-Range")) {
                                        dblArray[3] = itemScore;
                                    }
                                    if(Objects.equals(attrName, "VSWIR-Swath")) {
                                        dblArray[4] = itemScore;
                                    }
                                    if(Objects.equals(attrName, "VNIR-SNR")) {
                                        dblArray[5] = itemScore;
                                    }
                                    if(Objects.equals(attrName, "SWIR-SNR")) {
                                        dblArray[6] = itemScore;
                                    }
                                    if(Objects.equals(attrName, "Opt-Alt-Coincidence#")) {
                                        dblArray[8] = itemScore;
                                    }
                                    if(Objects.equals(attrName, "TIR-Spectral-Resolution")) {
                                        dblArray[7] = itemScore;
                                    }
                                    break;
                                }
                                default: {
                                    rowValues.add(attrValue.toString());
                                    break;
                                }
                            }
                        }
                        // Get information from explanation fact
                        Double score = realExplanation.getSlotValue("satisfaction").floatValue(null);
                        String satisfiedBy = realExplanation.getSlotValue("satisfied-by").stringValue(null);
                        ArrayList<String> rowJustifications = new ArrayList<>();
                        ValueVector reasons = realExplanation.getSlotValue("reasons").listValue(null);
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
                        int size = dblArray.length;
                        String[] str = new String[size];

                        for(int i=0; i<size; i++) {
                            str[i] = dblArray[i].toString();
                        }
                        String collect = String.join(",", str);
                        rows.add(collect);
                    }
                    catch (JessException e) {
                        System.err.println(e.toString());
                    }
                }
                FileWriter writer = new FileWriter("./arch_"+count+"_scores.csv");
                for (String row : rows) {
                    writer.write(row);
                    writer.write(System.getProperty( "line.separator" ));
                }
                writer.close();
                long end = System.nanoTime();
                System.out.printf("Full constellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
                evaluationManager.clear();
                //architecture.setCost(result.getCost());
                //architecture.setCoverage(result.getCoverage());
                System.out.println(result.getScience());
                System.out.println(architecture.toString("")+"Cost: "+result.getCost()+", Revisit Time: "+result.getCoverage());
                count++;
            }
        }
        catch (Exception e) {
            System.out.println("Exception occurred in DesignEvaluatorFromFile: "+e);
        }

        System.exit(0);
    }
}
