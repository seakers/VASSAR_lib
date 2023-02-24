/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar.coverage;

import org.hipparchus.stat.descriptive.DescriptiveStatistics;
import org.hipparchus.util.FastMath;
import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.bodies.OneAxisEllipsoid;
import org.orekit.data.DataProvidersManager;
import org.orekit.errors.OrekitException;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.orbits.KeplerianOrbit;
import org.orekit.orbits.Orbit;
import org.orekit.orbits.PositionAngle;
import org.orekit.propagation.Propagator;
import org.orekit.propagation.SpacecraftState;
import org.orekit.time.*;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;
import org.orekit.utils.PVCoordinates;
import seakers.orekit.analysis.Analysis;
import seakers.orekit.analysis.Record;
import seakers.orekit.analysis.ephemeris.GroundTrackAnalysis;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.coverage.analysis.AnalysisMetric;
import seakers.orekit.coverage.analysis.GroundEventAnalyzer;
import seakers.orekit.event.EventAnalysis;
import seakers.orekit.event.FieldOfViewEventAnalysis;
import seakers.orekit.object.*;
import seakers.orekit.object.fieldofview.NadirRectangularFOV;
import seakers.orekit.object.fieldofview.NadirSimpleConicalFOV;
import seakers.orekit.propagation.PropagatorFactory;
import seakers.orekit.propagation.PropagatorType;
import seakers.orekit.scenario.Scenario;
import seakers.vassar.planning.EqualSimulator;
import seakers.vassar.planning.Observation;
import seakers.vassar.planning.PlannerCoverageMetrics;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.*;

import static java.lang.Double.parseDouble;
import static seakers.orekit.analysis.OverlapAnalysis.arraySum;
import static seakers.orekit.object.CoverageDefinition.GridStyle.EQUAL_AREA;
import static seakers.orekit.object.CoverageDefinition.GridStyle.UNIFORM;

/**
 *
 * @author Ben
 */
public class CoverageAnalysisPlannerOverlap {

    private int numThreads;
    private String cwd; //current working directory
    private Properties propertiesPropagator;
    private CoverageDefinition.GridStyle gridStyle;
    private boolean binaryEncoding;
    private AbsoluteDate startDate;
    private AbsoluteDate endDate;
    private ArrayList<Satellite> satellites;

    private Map<TopocentricFrame, TimeIntervalArray> imagerEvents;
    private Map<TopocentricFrame, TimeIntervalArray> altimeterEvents;
    private HashSet<GeodeticPoint> covPoints;

    private boolean fastCov;

    private HashMap<String, HashMap<TopocentricFrame, TimeIntervalArray>> eventsBySatellite;
    BodyShape earthShape;

    public CoverageAnalysisPlannerOverlap(ArrayList<Satellite> satellites,boolean fastCov) throws OrekitException{
        this(satellites, 4, true, true, fastCov);

    }

    public CoverageAnalysisPlannerOverlap(ArrayList<Satellite> satellites, int numThreads, boolean saveAccessData, boolean binaryEncoding, boolean fastCov) throws OrekitException {
        this(satellites,numThreads, saveAccessData, binaryEncoding, System.getProperty("user.dir"),fastCov);
    }

    public CoverageAnalysisPlannerOverlap(ArrayList<Satellite> satellites, int numThreads, boolean saveAccessData, boolean binaryEncoding, String cwd, boolean fastCov) throws OrekitException {

        this.cwd = cwd;
        this.satellites = satellites;
        this.fastCov = fastCov;
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        Frame inertialFrame = FramesFactory.getEME2000();
        earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);
        //if running on a non-US machine, need the line below
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

        // Default start date and end date with 7-day run time
        TimeScale utc = TimeScalesFactory.getUTC();
        this.startDate = new AbsoluteDate(2020, 1, 1, 0, 0, 0.000, utc);
        this.endDate = startDate.shiftedBy(16.1 * 24 * 60 * 60); // 16 days in seconds

        this.numThreads = numThreads;
        this.gridStyle = EQUAL_AREA;
        this.binaryEncoding = binaryEncoding;
        //define coverage params
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
        covPoints = new HashSet<>();
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

        computeImagerAccesses();
        computeAltimeterAccesses();
        reset();
    }

    public void setDuration(double durationInSeconds) throws OrekitException{

        this.endDate = this.startDate.shiftedBy(durationInSeconds);

        if(this.endDate.compareTo(this.startDate) < 1){
            throw new IllegalStateException("The end date cannot be set before the start date");
        }
    }

    public void reset(){

        //can set the properties/number of resources available
        //to the satellite but we don't need them right now
        //so we are just instantiating it
        this.propertiesPropagator = new Properties();
    }

    public double computeOverlap() {
        double overlap = 0.0;
        double uniqueAltimeterLocations = 0;
        for (TopocentricFrame tf : altimeterEvents.keySet()) {
            if(altimeterEvents.get(tf).getDurations().length > 0) {
                uniqueAltimeterLocations += 1;
            }

        }
        for (int i = 10; i > 0; i--) {
            Map<TopocentricFrame, ArrayList<Double>> overlapPeriods = analyzeOverlap(altimeterEvents, imagerEvents, 60*15+i*3600.0*24.0*7.0/10.0);
            if(overlapPeriods.size() == uniqueAltimeterLocations) {
                overlap = 1-0.1*i;
            }
        }
        return overlap;
    }

    public double computeMaximumRevisitTime(double maxTorque) {
        double mrt = 10000.0;
        Map<String,String> settings = new HashMap<>();
        settings.put("crosslinkEnabled","true");
        settings.put("downlinkEnabled","true");
        settings.put("downlinkSpeedMbps","1000.1");
        settings.put("cameraOnPower","0.0");
        settings.put("chargePower","5.0");
        settings.put("downlinkOnPower","0.0");
        settings.put("crosslinkOnPower","0.0");
        settings.put("chlBonusReward","100.0");
        settings.put("maxTorque",Double.toString(maxTorque));
        settings.put("planner","greedy_coverage");
        settings.put("resources","false");
        Map<String,ArrayList<Observation>> obsMap = computeObservations();
        Map<GeodeticPoint, Double> pointRewards = new HashMap<>();
        for (GeodeticPoint gp : covPoints) {
            pointRewards.put(gp, 1.0);
        }
        EqualSimulator equalSimulator = new EqualSimulator(settings,startDate,endDate,pointRewards,obsMap);
        Map<String,Map<GeodeticPoint, ArrayList<TimeIntervalArray>>> plannerAccesses = equalSimulator.getPlannerAccesses();
        PlannerCoverageMetrics pcm = new PlannerCoverageMetrics(startDate,endDate,earthShape,eventsBySatellite,plannerAccesses,pointRewards);
        mrt = pcm.returnMaximumRevisitTime();
        return mrt;
    }

    public double computeMaximumRevisitTimeFast() {
        double[] latBounds = new double[]{FastMath.toRadians(-85), FastMath.toRadians(85)};
        double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};
        return getMaxRevisitTime(imagerEvents,latBounds,lonBounds)/3600;
    }

    private void computeAltimeterAccesses() throws OrekitException{
        ArrayList<Satellite> altimeters = new ArrayList<>();
        TimeScale utc = TimeScalesFactory.getUTC();

        //define the scenario parameters
        double mu = Constants.WGS84_EARTH_MU; // gravitation coefficient
        //must use IERS_2003 and EME2000 frames to be consistent with STK
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        Frame inertialFrame = FramesFactory.getEME2000();

        PropagatorFactory pf = new PropagatorFactory(PropagatorType.J2, new Properties());
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
        CoverageDefinition covDef;
        if(fastCov) {
            covDef = new CoverageDefinition("Whole Earth", 10.0, earthShape, EQUAL_AREA);
        } else {
            covDef = new CoverageDefinition("ATLASPoints", covPoints, earthShape);
        }
        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        Constellation constellation = new Constellation("Constellation", altimeters);
        covDef.assignConstellation(constellation);
        covDefs.add(covDef);

        ArrayList<EventAnalysis> eventAnalyses = new ArrayList<>();
        FieldOfViewEventAnalysis fovea = new FieldOfViewEventAnalysis(startDate, endDate, inertialFrame, covDefs,pf,true, true,30.0);
        eventAnalyses.add(fovea);

        Scenario scene = new Scenario.Builder(startDate, endDate, utc).eventAnalysis(eventAnalyses).covDefs(covDefs).name("computeAltimeterAccesses").propagatorFactory(pf).build();

        long start = System.nanoTime();
        try {
            scene.call();
        } catch (Exception e) {
            e.printStackTrace();
        }
        long end = System.nanoTime();
        //System.out.printf("altimeteraccesses took %.4f sec\n", (end - start) / Math.pow(10, 9));
        GroundEventAnalyzer gea = new GroundEventAnalyzer(fovea.getEvents(covDef));
        //System.out.printf("coverageByConstellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
        altimeterEvents = gea.getEvents();
    }

    private Map<String, ArrayList<Observation>> computeObservations() {
        Map<String, ArrayList<Observation>> obsMap = new HashMap<>();
        for (Satellite satellite : satellites) {
            Map<Double, GeodeticPoint> groundTrack = getGroundTrack(satellite.getOrbit());
            ArrayList<Observation> observations = new ArrayList<>();
            Map<TopocentricFrame, TimeIntervalArray> gpEvents = eventsBySatellite.get(satellite.getName());
            for (TopocentricFrame tf : gpEvents.keySet()) {
                GeodeticPoint gp = tf.getPoint();
                TimeIntervalArray tia = gpEvents.get(tf);
                for (int i = 0; i < tia.numIntervals(); i++) {
                    double riseTime = tia.getRiseAndSetTimesList()[2*i];
                    double setTime = tia.getRiseAndSetTimesList()[2*i+1];
                    double incidenceAngle = getIncidenceAngle(gp,riseTime,setTime,satellite,groundTrack);
                    Observation obs = new Observation(gp,riseTime,setTime,1.0,incidenceAngle);
                    observations.add(obs);
                }
            }
            obsMap.put(satellite.getName(),observations);
        }
        return obsMap;
    }

    private double getIncidenceAngle(GeodeticPoint point, double riseTime, double setTime, Satellite satellite, Map<Double, GeodeticPoint> groundTrack) {
        double time = (riseTime + setTime) / 2;

        double closestDist = 100000000000000000.0;
        double closestTime = 100 * 24 * 3600; // 100 days
        GeodeticPoint closestPoint;
        for (Double sspTime : groundTrack.keySet()) {
            if (Math.abs(sspTime - time) < closestTime) {
                closestTime = Math.abs(sspTime - time);
                closestPoint = groundTrack.get(sspTime);
                double dist = Math.sqrt(Math.pow(LLAtoECI(closestPoint)[0] - LLAtoECI(point)[0], 2) + Math.pow(LLAtoECI(closestPoint)[1] - LLAtoECI(point)[1], 2) + Math.pow(LLAtoECI(closestPoint)[2] - LLAtoECI(point)[2], 2));
                if (dist < closestDist) {
                    closestDist = dist;
                }
            }
        }
        return Math.atan2(closestDist,(satellite.getOrbit().getA()-6370000)/1000);
    }

    private double[] LLAtoECI(GeodeticPoint point) {
        double re = 6370;
        double x = re * Math.cos(point.getLatitude()) * Math.cos(point.getLongitude());
        double y = re * Math.cos(point.getLatitude()) * Math.sin(point.getLongitude());
        double z = re * Math.sin(point.getLatitude());
        double[] result = {x,y,z};
        return result;
    }

//    private Map<Double, GeodeticPoint> getGroundTrack(Orbit orbit) {
//        TimeScale utc = TimeScalesFactory.getUTC();
//
//        ArrayList<Instrument> payload = new ArrayList<>();
//        Satellite sat1 = new Satellite(orbit.toString(), orbit,  payload);
//        Properties propertiesPropagator = new Properties();
//        PropagatorFactory pf = new PropagatorFactory(PropagatorType.J2,propertiesPropagator);
//
//
//        Collection<Analysis<?>> analyses = new ArrayList<>();
//        double analysisTimeStep = 10;
//        GroundTrackAnalysis gta = new GroundTrackAnalysis(startDate, endDate, analysisTimeStep, sat1, earthShape, pf);
//        analyses.add(gta);
//        Scenario scen = new Scenario.Builder(startDate, endDate, utc).
//                analysis(analyses).name(orbit.toString()).propagatorFactory(pf).build();
//        try {
//            scen.call();
//        } catch (Exception ex) {
//            throw new IllegalStateException("Ground track scenario failed to complete.");
//        }
//        Map<Double, GeodeticPoint> sspMap = new HashMap<>();
//        List<Record<String>> hist = (List<Record<String>>) gta.getHistory();
//        for (int i = 0; i < hist.size(); i++) {
//            String rawString = hist.get(i).getValue();
//            AbsoluteDate date = hist.get(i).getDate();
//            String[] splitString = rawString.split(",");
//            double latitude = Double.parseDouble(splitString[0]);
//            double longitude = Double.parseDouble(splitString[1]);
//            GeodeticPoint ssp = new GeodeticPoint(Math.toRadians(latitude),Math.toRadians(longitude),0);
//            double elapsedTime = date.durationFrom(startDate);
//            sspMap.put(elapsedTime,ssp);
//        }
//        return sspMap;
//    }
    private Map<Double, GeodeticPoint> getGroundTrack(Orbit orbit) {
        long start = System.nanoTime();
        Properties propertiesPropagator = new Properties();
        Map<Double, GeodeticPoint> sspMap = new HashMap<>();
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.J2,propertiesPropagator);
        Propagator prop=pf.createPropagator(orbit, 0);
        int i = 0;
        AbsoluteDate lastTime = startDate;
        while(i < endDate.durationFrom(startDate)) {
            AbsoluteDate newTime = startDate.shiftedBy(i);
            SpacecraftState currentState = prop.propagate(lastTime,newTime);
            GeodeticPoint pt = earthShape.transform(
                    currentState.getPVCoordinates().getPosition(),
                    currentState.getFrame(),
                    currentState.getDate());
            double elapsedTime = newTime.durationFrom(startDate);
            lastTime = newTime;
            i = i+10;
            sspMap.put(elapsedTime,pt);
        }
        long end = System.nanoTime();
        System.out.printf("getGroundTrack took %.4f sec\n", (end - start) / Math.pow(10, 9));
        return sspMap;
    }
    private void computeImagerAccesses() throws OrekitException{
        TimeScale utc = TimeScalesFactory.getUTC();

        //define the scenario parameters
        //must use IERS_2003 and EME2000 frames to be consistent with STK
        Frame inertialFrame = FramesFactory.getEME2000();

        PropagatorFactory pf = new PropagatorFactory(PropagatorType.J2, new Properties());
        //define coverage params
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
        CoverageDefinition covDef;
        if(fastCov) {
            covDef = new CoverageDefinition("Whole Earth", 10.0, earthShape, EQUAL_AREA);
        } else {
            covDef = new CoverageDefinition("ATLASPoints", covPoints, earthShape);
        }
        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        Constellation constellation = new Constellation("Constellation", satellites);
        covDef.assignConstellation(constellation);
        covDefs.add(covDef);

        ArrayList<EventAnalysis> eventAnalyses = new ArrayList<>();
        FieldOfViewEventAnalysis fovea = new FieldOfViewEventAnalysis(startDate, endDate, inertialFrame,covDefs,pf,true, true,30.0);
        eventAnalyses.add(fovea);

        Scenario scene = new Scenario.Builder(startDate, endDate, utc).eventAnalysis(eventAnalyses).covDefs(covDefs).name("CoverageByConstellation").propagatorFactory(pf).build();
        long start = System.nanoTime();
        try {
            scene.call();
        } catch (Exception e) {
            e.printStackTrace();
        }
        long end = System.nanoTime();
        //System.out.printf("imageraccesses took %.4f sec\n", (end - start) / Math.pow(10, 9));

        GroundEventAnalyzer gea = new GroundEventAnalyzer(fovea.getEvents(covDef));
        //System.out.printf("coverageByConstellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
        imagerEvents = gea.getEvents();
        double[] latBounds = new double[]{FastMath.toRadians(-85), FastMath.toRadians(85)};
        double[] lonBounds = new double[]{FastMath.toRadians(-180), FastMath.toRadians(180)};
        System.out.println("Maximum revisit time, FOR: "+getMaxRevisitTime(imagerEvents,latBounds,lonBounds)/3600);
        eventsBySatellite = new HashMap<>();
        HashMap<Satellite, HashMap<TopocentricFrame, TimeIntervalArray>> events = fovea.getAllEvents(covDef);
        for (Satellite satellite : events.keySet()) {
            eventsBySatellite.put(satellite.getName(),events.get(satellite));
        }
    }

    public double getMaxRevisitTime(Map<TopocentricFrame, TimeIntervalArray> accesses, double[] latBounds, double[] lonBounds){
        // Method to compute average revisit time from accesses

        GroundEventAnalyzer eventAnalyzer = new GroundEventAnalyzer(accesses);

        DescriptiveStatistics stat;

        if(latBounds.length == 0 && lonBounds.length == 0){
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, this.propertiesPropagator);

        }else{
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, latBounds, lonBounds, this.propertiesPropagator);
        }

        //double max = stat.getElement((int) Math.round(0.95*stat.getValues().length));
        double max = stat.getMax();
        return max;
    }

    public double getPercentCoverage(Map<TopocentricFrame, TimeIntervalArray> accesses, double[] latBounds, double[] lonBounds){
        // Method to compute average revisit time from accesses

        GroundEventAnalyzer eventAnalyzer = new GroundEventAnalyzer(accesses);

        DescriptiveStatistics stat;

        if(latBounds.length == 0 && lonBounds.length == 0){
            stat = eventAnalyzer.getStatistics(AnalysisMetric.PERCENT_COVERAGE, true, this.propertiesPropagator);

        }else{
            stat = eventAnalyzer.getStatistics(AnalysisMetric.PERCENT_COVERAGE, true, latBounds, lonBounds, this.propertiesPropagator);
        }

        double perc_cov = stat.getMean();
        //System.out.println(String.format("Mean revisit time %s", mean));
        return perc_cov;
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
}
