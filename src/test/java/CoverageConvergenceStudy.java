import jess.Fact;
import jess.JessException;
import jess.Value;
import jess.ValueVector;
import org.hipparchus.util.FastMath;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.frames.TopocentricFrame;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.event.EventIntervalMerger;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.BaseParams;
import seakers.vassar.Resource;
import seakers.vassar.Result;
import seakers.vassar.SMDP.EarthExplorerAPI;
import seakers.vassar.coverage.CoverageAnalysis;
import seakers.vassar.coverage.CoverageAnalysisModified;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.SpectrometerDesign;

import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

public class CoverageConvergenceStudy {
    public static void main(String[] args) throws IOException {
        String path = "../VASSAR_resources";
        OrekitConfig.init(16);
        ArrayList<String> orbitList = new ArrayList<>();
        int r = 3;
        int s = 1;
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
                String orbitName = "LEO-878.5593138076877-85.98298985677306"+"-"+RAAN+"-"+anom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                }
                OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"CustomInstrument"},orbitName);
                radarOnlySatellites.add(radarOnlySatellite);
            }
        }
        //OrbitInstrumentObject testSatellite = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer"},orbitName);
        //constellation.add(testSatellite);
        SimpleArchitecture arch = new SimpleArchitecture(radarOnlySatellites);
        String[] orbList = new String[orbitList.size()];
        for (int i = 0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        ArrayList<Integer> granularities = new ArrayList<>();
        ArrayList<Double> maxRevisits = new ArrayList<>();
        for (int i = 20; i >= 2; i=i-2) {
            granularities.add(i);
        }
        for (Integer coverageGridGranularity : granularities) {
            CoverageAnalysis coverageAnalysis = new CoverageAnalysis(1, coverageGridGranularity, false, true, "../VASSAR_resources/orekit");
            double maxInclination = 0;
            List<Map<TopocentricFrame, TimeIntervalArray>> allEvents = new ArrayList<>();
            for(int i = 0; i < arch.getSatelliteList().size(); i++) {
                String orbName = arch.getSatelliteList().get(i).getOrbit();
                Orbit orb = new Orbit(orbName);

                double fieldOfView = 30.0;

                double inclination = orb.getInclinationNum(); // [deg]
                if (inclination > maxInclination) {
                    maxInclination  = inclination;
                }
                double altitude = orb.getAltitudeNum(); // [m]
                double raan = orb.getRaanNum();
                double trueAnom = orb.getTrueAnomNum();

                int numSatsPerPlane = 1;
                int numPlanes = 1;
                Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan, trueAnom);
                allEvents.add(accesses);
            }
            double[] latBounds = new double[]{FastMath.toRadians(-75), FastMath.toRadians(75)};
            double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};
            Map<TopocentricFrame, TimeIntervalArray> mergedAllEvents = new HashMap<>(allEvents.get(0));
            for (Map<TopocentricFrame, TimeIntervalArray> event : allEvents) {
                mergedAllEvents = EventIntervalMerger.merge(mergedAllEvents, event, false);
            }
            maxRevisits.add(coverageAnalysis.getMaxRevisitTime(mergedAllEvents, latBounds, lonBounds) / 3600);
            System.out.println(coverageAnalysis.getMaxRevisitTime(mergedAllEvents,latBounds,lonBounds)/3600);
        }
        FileWriter csvWriter = new FileWriter("CoverageConvergenceStudy.csv");
        for (int i = 0; i < maxRevisits.size(); i++) {
            csvWriter.append(String.valueOf(granularities.get(i))+","+String.valueOf(maxRevisits.get(i)));
            csvWriter.append("\n");
        }
        csvWriter.flush();
        csvWriter.close();
        OrekitConfig.end();
        System.exit(0);
    }
}
