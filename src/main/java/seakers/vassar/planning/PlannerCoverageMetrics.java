package seakers.vassar.planning;

import org.hipparchus.stat.descriptive.DescriptiveStatistics;
import org.hipparchus.util.FastMath;
import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.frames.TopocentricFrame;
import org.orekit.time.AbsoluteDate;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.coverage.access.TimeIntervalMerger;
import seakers.orekit.coverage.analysis.AnalysisMetric;
import seakers.orekit.coverage.analysis.GroundEventAnalyzer;

import java.io.*;
import java.util.*;

import static java.lang.Double.parseDouble;

@SuppressWarnings({"unchecked"})

public class PlannerCoverageMetrics {

    public String plannerRepoFilePath;
    public double durationDays;
    public AbsoluteDate startDate;

    public HashMap<String, HashMap<TopocentricFrame,TimeIntervalArray>> accessEvents;

    private Properties propertiesPropagator;
    private double maximumRevisitTime;
    private Map<GeodeticPoint,Double> covPoints;

    public PlannerCoverageMetrics(AbsoluteDate startDate, AbsoluteDate endDate, BodyShape earthShape, HashMap<String, HashMap<TopocentricFrame,TimeIntervalArray>> accesses, Map<String,Map<GeodeticPoint,ArrayList<TimeIntervalArray>>> plannerAccesses, Map<GeodeticPoint,Double> covPoints) {
        durationDays = endDate.durationFrom(startDate);
        propertiesPropagator = new Properties();
        accessEvents = accesses;
        this.covPoints = covPoints;
        ArrayList<TopocentricFrame> tfPoints = new ArrayList<>();
        for (GeodeticPoint gp : covPoints.keySet()) {
            tfPoints.add(new TopocentricFrame(earthShape,gp,""));
        }
        Map<GeodeticPoint,TimeIntervalArray> fovEventsPlannedGP = new HashMap<>();
        for (String sat : plannerAccesses.keySet()){
            Map<GeodeticPoint,ArrayList<TimeIntervalArray>> plannerAccessesPerSat = plannerAccesses.get(sat);
            for (GeodeticPoint gp : plannerAccessesPerSat.keySet()) {
                ArrayList<TimeIntervalArray> tias = plannerAccessesPerSat.get(gp);
                TimeIntervalArray baseTIA = new TimeIntervalArray(startDate,endDate);
                for(GeodeticPoint gp2 : fovEventsPlannedGP.keySet()) {
                    if(gp == gp2) {
                        baseTIA = fovEventsPlannedGP.get(gp2);
                    }
                }
                tias.add(baseTIA);
                TimeIntervalMerger merger = new TimeIntervalMerger(tias);
                TimeIntervalArray combinedArray = merger.orCombine();
                fovEventsPlannedGP.put(gp,combinedArray);
            }
        }
        Map<TopocentricFrame,TimeIntervalArray> fovEventsPlanned = new HashMap<>();
        for (GeodeticPoint gp : fovEventsPlannedGP.keySet()) {
            TopocentricFrame tf = new TopocentricFrame(earthShape,gp,"");
            fovEventsPlanned.put(tf,fovEventsPlannedGP.get(gp));
        }
        Map<TopocentricFrame,TimeIntervalArray> forEvents = new HashMap<>();
//        forEvents = accessEvents.get("smallsat00");
//        for(String sat : accessEvents.keySet()) {
//            Map<TopocentricFrame, TimeIntervalArray> forAccessesPerSat = accessEvents.get(sat);
//            for (TopocentricFrame tf : forAccessesPerSat.keySet()) {
//                for(TopocentricFrame tf2 : forEvents.keySet()) {
//                    if(tf.getPoint().getLatitude() == tf2.getPoint().getLatitude() && tf.getPoint().getLongitude() == tf2.getPoint().getLongitude()) {
//                        TimeIntervalArray tia = forEvents.get(tf);
//                        TimeIntervalArray tia2 = forAccessesPerSat.get(tf2);
//                        ArrayList<TimeIntervalArray> tias = new ArrayList<>();
//                        tias.add(tia);
//                        tias.add(tia2);
//                        TimeIntervalMerger merger = new TimeIntervalMerger(tias);
//                        TimeIntervalArray combinedArray = merger.orCombine();
//                        forEvents.put(tf,combinedArray);
//                    }
//                }
//            }
//        }
        double[] latBounds = new double[]{FastMath.toRadians(-75), FastMath.toRadians(75)};
        double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};
        double fovMaxRevisitPlanned = getMaxRevisitTime(fovEventsPlanned,latBounds,lonBounds)/3600;
        System.out.printf("FOV max revisit time: %.2f\n",fovMaxRevisitPlanned);
//        double forMaxRevisit = getMaxRevisitTime(forEvents,latBounds,lonBounds)/3600;
//        System.out.printf("FOR max revisit time, all points: %.2f\n",forMaxRevisit);
        maximumRevisitTime = fovMaxRevisitPlanned;
    }

    public double returnMaximumRevisitTime() {
        return maximumRevisitTime;
    }

    public double getMaxRevisitTime(Map<TopocentricFrame, TimeIntervalArray> accesses, double[] latBounds, double[] lonBounds){
        // Method to compute average revisit time from accesses

        GroundEventAnalyzer eventAnalyzer = new GroundEventAnalyzer(accesses);

        DescriptiveStatistics stat;

        if(latBounds.length == 0 && lonBounds.length == 0){
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, this.propertiesPropagator);

        } else {
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, latBounds, lonBounds, this.propertiesPropagator);
        }
        return stat.getMax();
    }

    public double getPercentCoverage(Map<TopocentricFrame, TimeIntervalArray> accesses, double[] latBounds, double[] lonBounds){
        // Method to compute average revisit time from accesses

        GroundEventAnalyzer eventAnalyzer = new GroundEventAnalyzer(accesses);

        DescriptiveStatistics stat;

        if(latBounds.length == 0 && lonBounds.length == 0){
            stat = eventAnalyzer.getStatistics(AnalysisMetric.PERCENT_COVERAGE, true, this.propertiesPropagator);

        } else {
            stat = eventAnalyzer.getStatistics(AnalysisMetric.PERCENT_COVERAGE, true, latBounds, lonBounds, this.propertiesPropagator);
        }

        return stat.getMean();
    }

    public Map<GeodeticPoint,Double> loadCoveragePoints() {
        Map<GeodeticPoint, Double> pointRewards = new HashMap<>();
        if (!new File(plannerRepoFilePath + "/coveragePoints.dat").exists()) {
            // Loading river and lake constant scores
            List<List<String>> riverRecords = new ArrayList<>();
            try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/grwl_river_output.csv"))) { // CHANGE THIS FOR YOUR IMPLEMENTATION
                String line;
                while ((line = br.readLine()) != null) {
                    String[] values = line.split(",");
                    riverRecords.add(Arrays.asList(values));
                }
            } catch (Exception e) {
                System.out.println("Exception occurred in loadCoveragePoints: " + e);
            }
            for (int i = 0; i < 1000; i++) {
                double lon = Math.toRadians(parseDouble(riverRecords.get(i).get(0)));
                double lat = Math.toRadians(parseDouble(riverRecords.get(i).get(1)));
                double width = parseDouble(riverRecords.get(i).get(2));
                GeodeticPoint riverPoint = new GeodeticPoint(lat, lon, 0.0);
                pointRewards.put(riverPoint, width / 5000.0 / 2);
            }
            List<List<String>> lakeRecords = new ArrayList<>();
            try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/hydrolakes.csv"))) { // CHANGE THIS FOR YOUR IMPLEMENTATION
                String line;
                while ((line = br.readLine()) != null) {
                    String[] values = line.split(",");
                    lakeRecords.add(Arrays.asList(values));
                }
            } catch (Exception e) {
                System.out.println("Exception occurred in loadCoveragePoints: " + e);
            }
            for (int i = 1; i < 1000; i++) {
                double lat = Math.toRadians(parseDouble(lakeRecords.get(i).get(0)));
                double lon = Math.toRadians(parseDouble(lakeRecords.get(i).get(1)));
                double area = parseDouble(lakeRecords.get(i).get(2));
                GeodeticPoint lakePoint = new GeodeticPoint(lat, lon, 0.0);
                pointRewards.put(lakePoint, area / 30000.0);
            }
            try {
                File file = new File(plannerRepoFilePath + "/coveragePoints.dat");
                FileOutputStream fos = new FileOutputStream(file);
                ObjectOutputStream oos = new ObjectOutputStream(fos);

                oos.writeObject(pointRewards);
                oos.flush();
                oos.close();
                fos.close();
            } catch (Exception e) {
                System.out.println("Exception in loadCoveragePoints: " + e);
            }

        } else {
            try {
                File toRead = new File(plannerRepoFilePath + "/coveragePoints.dat");
                FileInputStream fis = new FileInputStream(toRead);
                ObjectInputStream ois = new ObjectInputStream(fis);

                pointRewards = (Map<GeodeticPoint, Double>) ois.readObject();

                ois.close();
                fis.close();
            } catch (Exception e) {
                System.out.println("Exception in loadCoveragePoints: " + e);
            }
        }

        return pointRewards;
    }

}
