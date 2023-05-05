package seakers.vassar;

import jess.Fact;
import jess.JessException;
import jess.Value;
import jess.ValueVector;
import org.orekit.frames.TopocentricFrame;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.event.FieldOfViewEventAnalysis;
import seakers.orekit.util.OrekitConfig;
import seakers.orekit.util.RawSafety;
import seakers.vassar.BaseParams;
import seakers.vassar.Resource;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;
import seakers.vassar.utils.SpectrometerDesign;

import java.io.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CoverageDBChecker {
    private static HashMap<TopocentricFrame, TimeIntervalArray> readAccesses(File file) {
        HashMap<TopocentricFrame, TimeIntervalArray> out = new HashMap<>();
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file))) {
            out = RawSafety.castHashMap(ois.readObject());
        } catch (FileNotFoundException ex) {
            Logger.getLogger(FieldOfViewEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(FieldOfViewEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(FieldOfViewEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        }
        return out;
    }

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
        int r = 1; // planes
        int s = 1; // satellites per plane
        double alt = 650;
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
        int numVNIRSpec = 1000;
        int numSWIRSpec = 1000;
        boolean tir = false;
        double focalLength = 2.0;
        double FOV = 5.0;
        double aperture = 2.0;
        double vnirPixelSize = 1.0e-6;
        double swirPixelSize= 5.0e-6;
        SpectrometerDesign sd = new SpectrometerDesign(alt,numVNIRSpec,numSWIRSpec,tir,focalLength,FOV,aperture,vnirPixelSize,swirPixelSize,0.1);
        SimpleParams simpleParams = new SimpleParams(orbList, "XGrants", path, "CRISP-ATTRIBUTES","test", "reduced", sd);
        DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(simpleParams, evaluator);
        evaluationManager.init(1);
        Resource res = evaluationManager.getResourcePool().getResource();
        BaseParams params = res.getParams();
        evaluationManager.getResourcePool().freeResource(res);
        Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
        File[] files = new File("/home/ec2-user/VASSAR/VASSAR_lib/CoverageDatabase").listFiles();
        Map<Set<TopocentricFrame>,String> tfMap = new HashMap<>();
        for (File file : files) {
            if(file.isFile() && file.canRead() && file.getName().contains("ATLASPoints") && !file.getName().contains("ATLASPointsReduced")) {
                //System.out.println(file.getName());
                HashMap<TopocentricFrame, TimeIntervalArray> satAccesses = readAccesses(file);
                if(satAccesses.keySet().size() != 2000) {
                    System.out.println(file.getName());
                    System.out.println(satAccesses.keySet().size());
                }
                tfMap.put(satAccesses.keySet(),file.getName());
            }
        }
        System.out.println("Done loading!");
        Set<TopocentricFrame> ptKeys = tfMap.keySet().iterator().next();
        System.out.println("Base file: "+tfMap.get(ptKeys));
        for (Set<TopocentricFrame> tfSet : tfMap.keySet()) {
            if (!tfSet.equals(ptKeys)) {
                System.out.println("Error in file:");
                System.out.println(tfMap.get(tfSet));
                //throw new IllegalArgumentException("Failed to merge event time series. Expected grid points between sets to be equal. Found sets containing different points.");
            }
        }
        System.out.println("All done.");
    }
}
