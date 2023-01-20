package seakers.orekit.analysis;/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;
import java.util.List;
import java.util.logging.ConsoleHandler;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.hipparchus.util.FastMath;
import org.orekit.data.DataProvider;
import seakers.orekit.analysis.Analysis;
import seakers.orekit.analysis.ephemeris.GroundTrackAnalysis;
import seakers.orekit.coverage.analysis.GroundEventAnalyzer;
import seakers.orekit.event.EventAnalysis;
import seakers.orekit.event.FieldOfViewEventAnalysis;
import seakers.orekit.object.CoverageDefinition;
import seakers.orekit.object.Satellite;
import seakers.orekit.object.Instrument;
import seakers.orekit.analysis.Record;
import seakers.orekit.object.fieldofview.NadirRectangularFOV;
import seakers.orekit.object.fieldofview.NadirSimpleConicalFOV;
import seakers.orekit.parallel.ParallelRoutine;
import seakers.orekit.propagation.*;
import seakers.orekit.object.*;
import seakers.orekit.coverage.access.*;
import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.bodies.OneAxisEllipsoid;
import org.orekit.data.DataProvidersManager;
import org.orekit.data.DirectoryCrawler;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.orbits.KeplerianOrbit;
import org.orekit.orbits.Orbit;
import org.orekit.orbits.PositionAngle;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;
import seakers.orekit.scenario.Scenario;
import seakers.orekit.util.OrekitConfig;

import javax.imageio.ImageIO;

import static java.lang.Double.parseDouble;
import static java.util.stream.Collectors.toCollection;
import static org.apache.commons.io.FileUtils.getFile;

public class OverlapAnalysis {
    private String cwd;

    public OverlapAnalysis(String cwd) {
        this.cwd = cwd;
    }
    public double evaluateOverlap(ArrayList<Double> orbitHeights, ArrayList<Double> orbitInclinations, ArrayList<Double> orbitRAANs, ArrayList<Double> orbitAnomalies, double fov) {

        // Orekit initialization needs
//        OrekitConfig.init(1);
//        File orekitData = new File("./src/main/resources");
//        DataProvidersManager manager = DataProvidersManager.getInstance();
//        manager.addProvider(new DirectoryCrawler(orekitData));
        Locale.setDefault(new Locale("en", "US"));

        // Load default dataset saved in the project root directory
        StringBuffer pathBuffer = new StringBuffer();

        final File currrentDir = new File(this.cwd);
        if (currrentDir.exists() && (currrentDir.isDirectory() || currrentDir.getName().endsWith(".zip"))) {
            pathBuffer.append(currrentDir.getAbsolutePath());
            pathBuffer.append(File.separator);
            pathBuffer.append("resources");
        }
        System.setProperty(DataProvidersManager.OREKIT_DATA_PATH, pathBuffer.toString());
        Level level = Level.ALL;
        Logger.getGlobal().setLevel(level);
        ConsoleHandler handler = new ConsoleHandler();
        handler.setLevel(level);
        Logger.getGlobal().addHandler(handler);
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        Frame inertialFrame = FramesFactory.getEME2000();
        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate startDate = new AbsoluteDate(2020, 1, 1, 10, 30, 00.000, utc);
        double mu = Constants.WGS84_EARTH_MU;

        // Initializing
        ArrayList<Satellite> altimeters = new ArrayList<>();
        ArrayList<Satellite> imagers = new ArrayList<>();
        
        for (int i = 0; i < orbitHeights.size(); i++) {
            Orbit imagerOrbit = new KeplerianOrbit(6378000+orbitHeights.get(i), 0.0, FastMath.toRadians(orbitInclinations.get(i)), 0.0, FastMath.toRadians(orbitRAANs.get(i)), FastMath.toRadians(orbitAnomalies.get(i)), PositionAngle.MEAN, inertialFrame, startDate, mu);
            Collection<Instrument> imagerPayload = new ArrayList<>();
            double imagerFOVRadians = Math.toRadians(fov);
            NadirSimpleConicalFOV etmPlusFOV = new NadirSimpleConicalFOV(imagerFOVRadians,earthShape);
            Instrument etmPlus = new Instrument("ETM+", etmPlusFOV, 100.0, 100.0);
            imagerPayload.add(etmPlus);
            Satellite imager = new Satellite("imager"+i, imagerOrbit, imagerPayload);
            imagers.add(imager);
        }


        // Jason-3
        Orbit jason3Orbit = new KeplerianOrbit(6378000+1336001, 0.0, FastMath.toRadians(66.038), 0.0, 0.0, 0.0, PositionAngle.MEAN, inertialFrame, startDate, mu);
        Collection<Instrument> jason3Payload = new ArrayList<>();
        NadirSimpleConicalFOV poseidon3BFOV = new NadirSimpleConicalFOV(FastMath.toRadians(1.28),earthShape);
        Instrument poseidon3B = new Instrument("Poseidon-3B", poseidon3BFOV, 100.0, 100.0);
        jason3Payload.add(poseidon3B);
        Satellite jason3 = new Satellite("Jason-3", jason3Orbit, jason3Payload);
        altimeters.add(jason3);

        // Sentinel-6
        Orbit sentinel6Orbit = new KeplerianOrbit(6378000+1336000, 0.0, FastMath.toRadians(66.038), 0.0, 0.0, 0.0, PositionAngle.MEAN, inertialFrame, startDate, mu);
        Collection<Instrument> sentinel6Payload = new ArrayList<>();
        double poseidon4FOVRadians = Math.atan(20/1336.0/2);
        NadirSimpleConicalFOV poseidon4FOV = new NadirSimpleConicalFOV(poseidon4FOVRadians, earthShape);
        Instrument poseidon4 = new Instrument("Poseidon-4", poseidon4FOV, 100.0, 100.0);
        sentinel6Payload.add(poseidon4);
        Satellite sentinel6 = new Satellite("Sentinel-6", sentinel6Orbit, sentinel6Payload);
        altimeters.add(sentinel6);

        // Icesat-2
        Orbit icesat2Orbit = new KeplerianOrbit(6378000+481000, 0.0, FastMath.toRadians(66.038), 0.0, 0.0, 0.0, PositionAngle.MEAN, inertialFrame, startDate, mu);
        Collection<Instrument> icesat2Payload = new ArrayList<>();
        double atlasFOVRadians = Math.atan(5/481.0/2);
        NadirSimpleConicalFOV atlasFOV = new NadirSimpleConicalFOV(atlasFOVRadians, earthShape);
        Instrument atlas = new Instrument("ATLAS", atlasFOV, 100.0, 100.0);
        icesat2Payload.add(atlas);
        Satellite icesat2 = new Satellite("IceSat-2", icesat2Orbit, icesat2Payload);
        altimeters.add(icesat2);

        // SWOT
        Orbit swotOrbit = new KeplerianOrbit(6378000+891000, 0.0, FastMath.toRadians(78), 0.0, 0.0, 0.0, PositionAngle.MEAN, inertialFrame, startDate, mu);
        Collection<Instrument> swotPayload = new ArrayList<>();
        double swotCrossFOVRadians = Math.atan(60.0/891.0);
        double swotAlongFOVRadians = Math.atan(400.0/891.0);
        NadirRectangularFOV swotFOV = new NadirRectangularFOV(swotCrossFOVRadians,swotAlongFOVRadians,0.0,earthShape);
        Instrument swotAltimeter = new Instrument("SWOT Altimeter", swotFOV, 100.0, 100.0);
        swotPayload.add(swotAltimeter);
        Satellite SWOT = new Satellite("SWOT", swotOrbit, swotPayload);
        altimeters.add(SWOT);

        // Computing results
        double duration = 8.00; // in days
        GroundEventAnalyzer altimeterAnalyzer = coverageByConstellation(altimeters, duration, startDate);
        Map<TopocentricFrame, TimeIntervalArray> altimeterEvents = altimeterAnalyzer.getEvents();
        GroundEventAnalyzer imagerAnalyzer = coverageByConstellation(imagers, duration, startDate);
        Map<TopocentricFrame, TimeIntervalArray> imagerEvents = imagerAnalyzer.getEvents();
        // Analyzing overlap
        double altimeterObservationsCount = 0;
        for (TopocentricFrame tf : altimeterEvents.keySet()) {
            altimeterObservationsCount += altimeterEvents.get(tf).getDurations().length;
        }
        System.out.println("Number of altimeter observations per hour: "+altimeterObservationsCount/(duration*24));
        double altimeterObsPerHour = altimeterObservationsCount/(duration*24);

        Map<TopocentricFrame, ArrayList<Double>> results15min = analyzeOverlap(altimeterEvents, imagerEvents, 60.0*15);
        Map<TopocentricFrame, ArrayList<Double>> results1day = analyzeOverlap(altimeterEvents, imagerEvents, 3600.0*24);
        Map<TopocentricFrame, ArrayList<Double>> results3days = analyzeOverlap(altimeterEvents, imagerEvents, 3600.0*24*3);
        Map<TopocentricFrame, ArrayList<Double>> results7days = analyzeOverlap(altimeterEvents, imagerEvents, 3600.0*24*7);
        System.out.println("Number of overlapped points within 15 min: "+results15min.size());
        System.out.println("Number of overlapped points within 1 day: "+results1day.size());
        System.out.println("Number of overlapped points within 3 days: "+results3days.size());
        System.out.println("Number of overlapped points within 7 days: "+results7days.size());
        double overlapDuration15min = 0.0;
        double overlapEvents15min = 0.0;
        for(TopocentricFrame tf : results15min.keySet()) {
            overlapDuration15min += results15min.get(tf).get(0);
            overlapEvents15min += results15min.get(tf).get(1);
        }
        double overlapDuration1day = 0.0;
        double overlapEvents1day = 0.0;
        for(TopocentricFrame tf : results1day.keySet()) {
            overlapDuration1day += results1day.get(tf).get(0);
            overlapEvents1day += results1day.get(tf).get(1);
        }
        double overlapDuration3days = 0.0;
        double overlapEvents3days = 0.0;
        for(TopocentricFrame tf : results3days.keySet()) {
            overlapDuration3days += results3days.get(tf).get(0);
            overlapEvents3days += results3days.get(tf).get(1);
        }
        double overlapDuration7days = 0.0;
        double overlapEvents7days = 0.0;
        for(TopocentricFrame tf : results7days.keySet()) {
            overlapDuration7days += results7days.get(tf).get(0);
            overlapEvents7days += results7days.get(tf).get(1);
        }
        System.out.println("Overlap duration within 15 min: "+overlapDuration15min);
        System.out.println("Overlap duration within 1 day: "+overlapDuration1day);
        System.out.println("Overlap duration within 3 days: "+overlapDuration3days);
        System.out.println("Overlap duration within 7 days: "+overlapDuration7days);
        System.out.println("Number of overlap events within 15 min: "+overlapEvents15min);
        System.out.println("Number of overlap events within 1 day: "+overlapEvents1day);
        System.out.println("Number of overlap events within 3 days: "+overlapEvents3days);
        System.out.println("Number of overlap events within 7 days: "+overlapEvents7days);
        System.out.println("Overlap duration within 15 min, per hour: "+overlapDuration15min/(duration*24));
        System.out.println("Overlap duration within 1 day, per hour: "+overlapDuration1day/(duration*24));
        System.out.println("Overlap duration within 3 days, per hour: "+overlapDuration3days/(duration*24));
        System.out.println("Overlap duration within 7 days, per hour: "+overlapDuration7days/(duration*24));
        System.out.println("Number of overlap events within 15 min, per hour: "+overlapEvents15min/(duration*24));
        System.out.println("Number of overlap events within 1 day, per hour: "+overlapEvents1day/(duration*24));
        System.out.println("Number of overlap events within 3 days, per hour: "+overlapEvents3days/(duration*24));
        System.out.println("Number of overlap events within 7 days, per hour: "+overlapEvents7days/(duration*24));
        double result = 240000.0;
        if(overlapEvents15min/(duration*24) > altimeterObsPerHour){
            result = 14.99;
        } else if(overlapEvents1day/(duration*24) > altimeterObsPerHour) {
            result = 60.0*24 - 0.01;
        } else if(overlapEvents3days/(duration*24) > altimeterObsPerHour) {
            result = 60.0 * 24 * 3 - 0.01;
        } else if(overlapEvents7days/(duration*24) > altimeterObsPerHour) {
            result = 60.0 * 24 * 7 - 0.01;
        }
//        OrekitConfig.end();
        return result;
    }

    public static Collection<Record<String>> getGroundTrack(Orbit orbit, double duration, AbsoluteDate startDate) {
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate endDate = startDate.shiftedBy(duration*86400);

        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);

        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);
        ArrayList<Instrument> payload = new ArrayList<>();
        Satellite sat1 = new Satellite(orbit.toString(), orbit,  payload);
        Properties propertiesPropagator = new Properties();
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.J2,propertiesPropagator);


        Collection<Analysis<?>> analyses = new ArrayList<>();
        double analysisTimeStep = 5;
        GroundTrackAnalysis gta = new GroundTrackAnalysis(startDate, endDate, analysisTimeStep, sat1, earthShape, pf);
        analyses.add(gta);
        Scenario scen = new Scenario.Builder(startDate, endDate, utc).
                analysis(analyses).name(orbit.toString()).propagatorFactory(pf).build();
        try {
            scen.call();
        } catch (Exception ex) {
            throw new IllegalStateException("Ground track scenario failed to complete.");
        }
        return gta.getHistory();
    }
    public static Map<TopocentricFrame, ArrayList<Double>> analyzeOverlap(Map<TopocentricFrame, TimeIntervalArray> base, Map<TopocentricFrame, TimeIntervalArray> addl, double delay) {
        Map<TopocentricFrame, ArrayList<Double>> results = new HashMap<>();
        Map<TopocentricFrame, TimeIntervalArray> overlapTimes = new HashMap<>();

        for(TopocentricFrame tf : base.keySet()) {
            ArrayList<Double> overlapDelayTimes = new ArrayList<>();
            TimeIntervalArray baseTimes = base.get(tf);
            TimeIntervalArray addlTimes = addl.get(tf);
            TimeIntervalArray delayTimes = overlapWithDelay(baseTimes, addlTimes, delay, false);
            if(!delayTimes.isEmpty()) {
                double overlapTimeNoDelay = arraySum(delayTimes.getDurations());
                overlapDelayTimes.add(overlapTimeNoDelay);
                overlapDelayTimes.add((double)delayTimes.getDurations().length);
                results.put(tf, overlapDelayTimes);
            }
            overlapTimes.put(tf,delayTimes);
        }
        return results;
    }

    public static TimeIntervalArray overlapWithDelay(TimeIntervalArray base, TimeIntervalArray addl, double delay, Boolean onesided) {
        double[] rasBase = base.getRiseAndSetTimesList();
        double[] rasAddl = addl.getRiseAndSetTimesList();
        TimeIntervalArray overlapArray = new TimeIntervalArray(base.getHead(), base.getTail());
        for (int j=0;j<rasBase.length;j=j+2) {
            for (int k=0;k<rasAddl.length;k=k+2) {
                if(onesided) {
                    if(rasBase[j] < rasAddl[k] && rasBase[j+1]+delay > rasAddl[k]) {
                        if(rasBase[j] < rasAddl[k+1] && rasBase[j+1]+delay > rasAddl[k+1]) {
                            overlapArray.addRiseTime(rasAddl[k]);
                            overlapArray.addSetTime(rasAddl[k+1]);
                        } else {
                            overlapArray.addRiseTime(rasAddl[k]);
                            overlapArray.addSetTime(rasBase[j+1]+delay);
                        }
                    } else if(rasBase[j] < rasAddl[k+1] && rasBase[j+1]+delay > rasAddl[k+1]) {
                        overlapArray.addRiseTime(rasBase[j]);
                        overlapArray.addSetTime(rasAddl[k+1]);
                    } else if(rasBase[j]>=rasAddl[k] && rasBase[j+1]+delay<=rasAddl[k+1]) {
                        overlapArray.addRiseTime(rasBase[j]);
                        overlapArray.addSetTime(rasBase[j+1]+delay);
                    }
                } else {
                    if(rasBase[j+1]+delay > rasAddl[k+1] && rasBase[j]-delay < rasAddl[k]) {
                        overlapArray.addRiseTime(rasAddl[k]);
                        overlapArray.addSetTime(rasAddl[k+1]);
                    }
                }

            }
        }
        return overlapArray;
    }

    public static GroundEventAnalyzer coverageByConstellation(ArrayList<Satellite> satelliteList, double durationDays, AbsoluteDate startDate) {
        long start = System.nanoTime();
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate endDate = startDate.shiftedBy(durationDays*86400);
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        Frame inertialFrame = FramesFactory.getEME2000();
        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.KEPLERIAN);

        List<List<String>> riverRecords = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/grwl_river_output.csv"))) { // CHANGE THIS FOR YOUR IMPLEMENTATION
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                riverRecords.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println("Exception occurred in coverageByConstellation: "+e);
        }
        Set<GeodeticPoint> covPoints = new HashSet<>();
        for (int i = 0; i < 1000; i++) {
            double lon = Math.toRadians(parseDouble(riverRecords.get(i).get(0)));
            double lat = Math.toRadians(parseDouble(riverRecords.get(i).get(1)));
            GeodeticPoint riverPoint = new GeodeticPoint(lat, lon, 0.0);
            covPoints.add(riverPoint);
        }
        List<List<String>> lakeRecords = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/hydrolakes.csv"))) { // CHANGE THIS FOR YOUR IMPLEMENTATION
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                lakeRecords.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println("Exception occurred in coverageByConstellation: "+e);
        }
        for (int i = 0; i < 1000; i++) {
            double lat = Math.toRadians(parseDouble(lakeRecords.get(i).get(0)));
            double lon = Math.toRadians(parseDouble(lakeRecords.get(i).get(1)));
            GeodeticPoint lakePoint = new GeodeticPoint(lat, lon, 0.0);
            covPoints.add(lakePoint);
        }

//        Set<GeodeticPoint> subSet = landPoints.stream()
//                // .skip(10) // Use this to get elements later in the stream
//                .limit(5000)
//                .collect(toCollection(LinkedHashSet::new));
        //create a coverage definition
        CoverageDefinition covDef = new CoverageDefinition("covdef1", covPoints, earthShape);
        //CoverageDefinition covDef = new CoverageDefinition("Whole Earth", granularity, earthShape, UNIFORM);
        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        Constellation constellation = new Constellation("Constellation", satelliteList);
        covDef.assignConstellation(constellation);
        covDefs.add(covDef);

        ArrayList<EventAnalysis> eventAnalyses = new ArrayList<>();
        FieldOfViewEventAnalysis fovea = new FieldOfViewEventAnalysis(startDate, endDate, inertialFrame,covDefs,pf,false, false);
        eventAnalyses.add(fovea);

        Scenario scene = new Scenario.Builder(startDate, endDate, utc).eventAnalysis(eventAnalyses).covDefs(covDefs).name("CoverageByConstellation").propagatorFactory(pf).build();

        try {
            scene.call();
        } catch (Exception e) {
            e.printStackTrace();
        }

        GroundEventAnalyzer gea = new GroundEventAnalyzer(fovea.getEvents(covDef));
        long end = System.nanoTime();
        System.out.printf("coverageByConstellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
        return gea;
    }

    public static double arraySum(double[] array) {
        double sum = 0;
        for (double value : array) {
            sum += value;
        }
        return sum;
    }
}