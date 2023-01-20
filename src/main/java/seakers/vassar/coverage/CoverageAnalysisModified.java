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
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;
import seakers.orekit.constellations.Walker;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.coverage.analysis.AnalysisMetric;
import seakers.orekit.coverage.analysis.GroundEventAnalyzer;
import seakers.orekit.event.EventAnalysis;
import seakers.orekit.event.EventAnalysisEnum;
import seakers.orekit.event.EventAnalysisFactory;
import seakers.orekit.event.FieldOfViewEventAnalysis;
import seakers.orekit.examples.CoverageExample;
import seakers.orekit.object.CoverageDefinition;
import seakers.orekit.object.Instrument;
import seakers.orekit.object.fieldofview.NadirSimpleConicalFOV;
import seakers.orekit.object.fieldofview.OffNadirRectangularFOV;
import seakers.orekit.propagation.PropagatorFactory;
import seakers.orekit.propagation.PropagatorType;
import seakers.orekit.scenario.Scenario;
import seakers.orekit.util.OrekitConfig;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import static seakers.orekit.object.CoverageDefinition.GridStyle.EQUAL_AREA;
import static seakers.orekit.util.Orbits.LTAN2RAAN;

@SuppressWarnings({"rawtypes","unchecked"})
public class CoverageAnalysisModified {

    private int numThreads;
    private int coverageGridGranularity;
    private String cwd; //current working directory
    private Properties propertiesPropagator;
    private CoverageDefinition.GridStyle gridStyle;
    private boolean binaryEncoding;
    private CoverageAnalysisIO coverageAnalysisIO;
    private boolean saveAccessData;
    private AbsoluteDate startDate;
    private AbsoluteDate endDate;

    public CoverageAnalysisModified(int numThreads, int coverageGridGranularity) throws OrekitException{
        this(numThreads, coverageGridGranularity, true, true);
    }

    public CoverageAnalysisModified(int numThreads, int coverageGridGranularity, boolean saveAccessData, boolean binaryEncoding) throws OrekitException {
        this(numThreads, coverageGridGranularity, saveAccessData, binaryEncoding, System.getProperty("user.dir"));
    }

    public CoverageAnalysisModified(int numThreads, int coverageGridGranularity, boolean saveAccessData, boolean binaryEncoding, String cwd) throws OrekitException{

        this.cwd = cwd;

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
        double simDays = 1.0;
        this.endDate = startDate.shiftedBy(simDays*86400); // 7 days in seconds

        this.numThreads = numThreads;
        this.coverageGridGranularity = coverageGridGranularity;
        this.gridStyle = EQUAL_AREA;
        this.saveAccessData = saveAccessData;
        this.binaryEncoding = binaryEncoding;
        this.coverageAnalysisIO = new CoverageAnalysisIO(this.binaryEncoding, utc);

        reset();
    }

    public void setStartDate(int year, int month, int day, int hour, int minute, double second) throws OrekitException{
        TimeScale utc = TimeScalesFactory.getUTC();
        this.startDate = new AbsoluteDate(year, month, day, hour, minute, second, utc);
    }

    public void setDuration(double durationInSeconds) throws OrekitException{

        this.endDate = this.startDate.shiftedBy(durationInSeconds);

        if(this.endDate.compareTo(this.startDate) < 1){
            throw new IllegalStateException("The end date cannot be set before the start date");
        }
    }

    public void setEndDate(int year, int month, int day, int hour, int minute, double second) throws OrekitException{
        TimeScale utc = TimeScalesFactory.getUTC();
        this.endDate = new AbsoluteDate(year, month, day, hour, minute, second, utc);

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

    public void setCoverageGridGranularity(int granularity){
        this.coverageGridGranularity = granularity;
        this.reset();
    }

    public Map<TopocentricFrame, TimeIntervalArray> getAccesses(double fieldOfView, double inclination, double altitude, int numSats, int numPlanes, String raanLabel) throws OrekitException {

        CoverageAnalysisIO.AccessDataDefinition definition = new CoverageAnalysisIO.AccessDataDefinition(fieldOfView, inclination, altitude, numSats, numPlanes, this.coverageGridGranularity, raanLabel);

        String filename = this.coverageAnalysisIO.getAccessDataFilename(definition);
        if (this.coverageAnalysisIO.getAccessDataFile(filename).exists()) {
            // The access data exists
            return this.coverageAnalysisIO.readAccessData(definition);
        }
        else {
            // Newly compute the accesses
            Map<TopocentricFrame, TimeIntervalArray> fovEvents = this.computeAccesses(fieldOfView, inclination, altitude, numSats, numPlanes, raanLabel);

            if (this.saveAccessData) {
                this.coverageAnalysisIO.writeAccessData(definition, fovEvents);
            }

            return fovEvents;
        }
    }

    private Map<TopocentricFrame, TimeIntervalArray> computeAccesses(double fieldOfView, double inclination, double altitude, int numSats, int numPlanes) throws OrekitException{
        return this.computeAccesses(fieldOfView, inclination, altitude, numSats, numPlanes, 0.0,0.0,"radar");
    }

    private Map<TopocentricFrame, TimeIntervalArray> computeAccesses(double fieldOfView, double inclination, double altitude, int numSats, int numPlanes, String raanLabel) throws OrekitException{

        double raan = 0.0;

        if(raanLabel != null){
            int hour = 0;
            boolean skip = false;

            switch (raanLabel){
                case "DD":
                    hour = 6;
                    break;
                case "AM":
                    hour = 10;
                    break;
                case "noon":
                    hour = 12;
                    break;
                case "PM":
                    hour = 14;
                    break;
                default:
                    skip = true;
            }

            if(!skip){
                TimeScale utc = TimeScalesFactory.getUTC();
                int day = startDate.getComponents(utc).getDate().getDay();
                int month = startDate.getComponents(utc).getDate().getMonth();
                int year = startDate.getComponents(utc).getDate().getYear();
                raan = FastMath.toDegrees( LTAN2RAAN(altitude, hour, day, month, year) );
            }
        }

        return this.computeAccesses(fieldOfView, FastMath.toDegrees(inclination), altitude, numSats, numPlanes, raan, 0.0, "radar");
    }

    private Map<TopocentricFrame, TimeIntervalArray> computeAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom, String instrumentType) throws OrekitException{
        //initializes the look up tables for planteary position (required!)

        //define the start and end date of the simulation
        TimeScale utc = TimeScalesFactory.getUTC();

        //define the scenario parameters
        double mu = Constants.WGS84_EARTH_MU; // gravitation coefficient
        //must use IERS_2003 and EME2000 frames to be consistent with STK
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        Frame inertialFrame = FramesFactory.getEME2000();
        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);

        //Enter satellite orbital parameters
        double a = Constants.WGS84_EARTH_EQUATORIAL_RADIUS + altitude;
        double i = inclination;

        //define instruments and payload
        //NadirSimpleConicalFOV fov = new NadirSimpleConicalFOV(FastMath.toRadians(fieldOfView), earthShape);
        ArrayList<Instrument> payload = new ArrayList<>();
        if(instrumentType.equals("radar")) {
            OffNadirRectangularFOV fov = new OffNadirRectangularFOV(FastMath.toRadians(45), FastMath.toRadians(15),FastMath.toRadians(15),0,earthShape);
            OffNadirRectangularFOV fov_opposite = new OffNadirRectangularFOV(FastMath.toRadians(-45), FastMath.toRadians(15),FastMath.toRadians(15),0,earthShape);
            Instrument view1 = new Instrument("view1", fov, 100, 100);
            Instrument view2 = new Instrument("view2", fov_opposite, 100, 100);
            payload.add(view1);
            payload.add(view2);
        } else if(instrumentType.equals("radiometer")) {
            NadirSimpleConicalFOV fov = new NadirSimpleConicalFOV(FastMath.toRadians(fieldOfView),earthShape);
            Instrument view = new Instrument("view", fov,100,100);
            payload.add(view);
        } else if(instrumentType.equals("reflectometer")) {
            OffNadirRectangularFOV firstQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(10),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            OffNadirRectangularFOV secondQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(20),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            OffNadirRectangularFOV thirdQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(-10),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            OffNadirRectangularFOV fourthQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(-20),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            Instrument view1 = new Instrument("view1", firstQuadrant,100,100);
            Instrument view2 = new Instrument("view2", secondQuadrant,100,100);
            Instrument view3 = new Instrument("view3", thirdQuadrant,100,100);
            Instrument view4 = new Instrument("view4", fourthQuadrant,100,100);
            payload.add(view1);
            payload.add(view2);
            payload.add(view3);
            payload.add(view4);
        }

        //number of total satellites
        int t = numSatsPerPlane*numPlanes;

        //number of planes
        int p = numPlanes;

        //number of phases
        int f = 0;

        //Create a walker constellation
        Walker walker = new Walker("walker1", payload, a, FastMath.toRadians(i), t, p, f, inertialFrame, startDate, mu, FastMath.toRadians(raan), FastMath.toRadians(trueAnom));

        ArrayList<GeodeticPoint> covPoints = getCovPoints("simulationpoints");

        //create a coverage definition
        CoverageDefinition covDef1 = new CoverageDefinition("covdef", this.coverageGridGranularity, earthShape, this.gridStyle);
        //CoverageDefinition covDef1 = new CoverageDefinition("covdef1", covPoints, earthShape);

        //assign the walker constellation to the coverage definition
        covDef1.assignConstellation(walker);

        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        covDefs.add(covDef1);

        //set the type of propagation
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.KEPLERIAN, new Properties());

        //can set the properties of the analyses
        Properties propertiesEventAnalysis = new Properties();
        propertiesEventAnalysis.setProperty("fov.saveAccess", "false");

        //set the coverage event analyses
        EventAnalysisFactory eaf = new EventAnalysisFactory(startDate, endDate, inertialFrame, pf);
        ArrayList<EventAnalysis> eventanalyses = new ArrayList<>();
        FieldOfViewEventAnalysis fovEvent = (FieldOfViewEventAnalysis) eaf.createGroundPointAnalysis(EventAnalysisEnum.FOV, covDefs, propertiesEventAnalysis);
        eventanalyses.add(fovEvent);

        //build the scenario
        Scenario scen = new Scenario.Builder(startDate, endDate, utc).
                eventAnalysis(eventanalyses).covDefs(covDefs).
                name("SMAP").properties(propertiesEventAnalysis).
                propagatorFactory(pf).build();
        long start = System.nanoTime();
        try {
            //System.out.println(String.format("Running Scenario %s", scen));
            //System.out.println(String.format("Number of points:     %d", covDef1.getNumberOfPoints()));
            //System.out.println(String.format("Number of satellites: %d", walker.getSatellites().size()));

            //run the scenario
            scen.call();
        } catch (Exception ex) {
            Logger.getLogger(CoverageExample.class.getName()).log(Level.SEVERE, null, ex);
            throw new IllegalStateException("scenario failed to complete.");
        }
        long end = System.nanoTime();
        //System.out.printf("Took %.4f sec\n", (end - start) / Math.pow(10, 9));
        return fovEvent.getEvents(covDef1);

    }

    /**
     * Computes the accesses for satellites sharing the same field of view
     * @param fieldOfView [deg]
     * @param inclination [deg]
     * @param altitude [m]
     * @param numSatsPerPlane [int]
     * @param numPlanes [int]
     * @param raan [deg]
     * @throws OrekitException [exception]
     */
    private Map<TopocentricFrame, TimeIntervalArray> computePlannerAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom, String instrumentType) throws OrekitException{
        //initializes the look up tables for planteary position (required!)

        //define the start and end date of the simulation
        TimeScale utc = TimeScalesFactory.getUTC();

        //define the scenario parameters
        double mu = Constants.WGS84_EARTH_MU; // gravitation coefficient
        //must use IERS_2003 and EME2000 frames to be consistent with STK
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        Frame inertialFrame = FramesFactory.getEME2000();
        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);

        //Enter satellite orbital parameters
        double a = Constants.WGS84_EARTH_EQUATORIAL_RADIUS + altitude;
        double i = inclination;

        //define instruments and payload
        //NadirSimpleConicalFOV fov = new NadirSimpleConicalFOV(FastMath.toRadians(fieldOfView), earthShape);
        ArrayList<Instrument> payload = new ArrayList<>();
        if(instrumentType.equals("radar")) {
            OffNadirRectangularFOV fov = new OffNadirRectangularFOV(FastMath.toRadians(45), FastMath.toRadians(15),FastMath.toRadians(15),0,earthShape);
            OffNadirRectangularFOV fov_opposite = new OffNadirRectangularFOV(FastMath.toRadians(-45), FastMath.toRadians(15),FastMath.toRadians(15),0,earthShape);
            Instrument view1 = new Instrument("view1", fov, 100, 100);
            Instrument view2 = new Instrument("view2", fov_opposite, 100, 100);
            payload.add(view1);
            payload.add(view2);
        } else if(instrumentType.equals("radiometer")) {
            NadirSimpleConicalFOV fov = new NadirSimpleConicalFOV(FastMath.toRadians(fieldOfView),earthShape);
            Instrument view = new Instrument("view", fov,100,100);
            payload.add(view);
        } else if(instrumentType.equals("reflectometer")) {
            OffNadirRectangularFOV firstQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(10),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            OffNadirRectangularFOV secondQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(20),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            OffNadirRectangularFOV thirdQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(-10),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            OffNadirRectangularFOV fourthQuadrant = new OffNadirRectangularFOV(FastMath.toRadians(-20),FastMath.toRadians(2.86),FastMath.toRadians(2.86),0,earthShape);
            Instrument view1 = new Instrument("view1", firstQuadrant,100,100);
            Instrument view2 = new Instrument("view2", secondQuadrant,100,100);
            Instrument view3 = new Instrument("view3", thirdQuadrant,100,100);
            Instrument view4 = new Instrument("view4", fourthQuadrant,100,100);
            payload.add(view1);
            payload.add(view2);
            payload.add(view3);
            payload.add(view4);
        }

        //number of total satellites
        int t = numSatsPerPlane*numPlanes;

        //number of planes
        int p = numPlanes;

        //number of phases
        int f = 0;

        //Create a walker constellation
        Walker walker = new Walker("walker1", payload, a, FastMath.toRadians(i), t, p, f, inertialFrame, startDate, mu, FastMath.toRadians(raan), FastMath.toRadians(trueAnom));

        // Uncomment for coverage grid of land points between -75 and 75 latitude, 5 degree granularity
        /*
        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("D:\\Documents\\VASSAR\\VASSAR_lib\\src\\test\\java\\LandLatLong75.csv"))) { 
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }

        ArrayList<GeodeticPoint> landPoints = new ArrayList<>();
        for(int idx = 0; idx < records.size(); idx++) {
            double lat = Double.parseDouble(records.get(idx).get(0));
            double lon = Double.parseDouble(records.get(idx).get(1));
            lon = lon - 180.0;
            lat = Math.toRadians(lat);
            lon = Math.toRadians(lon);
            GeodeticPoint landPoint = new GeodeticPoint(lat,lon,0.0);
            if(Math.abs(lat) <= Math.toRadians(75.0)) {
                landPoints.add(landPoint);
            }
        }
        */
//        List<List<String>> records = new ArrayList<>();
//        try (BufferedReader br = new BufferedReader(new FileReader("D:\\Documents\\VASSAR\\IGBP.csv"))) { 
//            String line;
//            while ((line = br.readLine()) != null) {
//                String[] values = line.split(",");
//                records.add(Arrays.asList(values));
//            }
//        }
//        catch (Exception e) {
//            System.out.println(e);
//        }
//        ArrayList<GeodeticPoint> igbpPoints = new ArrayList<>();
//        double[] longitudes = linspace(-180.0,180.0,records.get(0).size());
//        double[] latitudes = linspace(-84.66,84.66,records.size());
//        double longDistCheck = 0.0;
//        double latDistCheck = 0.0;
//        for (int j = 0; j < records.get(0).size(); j++) {
//            for (int k = 0; k < records.size(); k++) {
//                // Check for IGBP biome types
//                // Change doubles in this if statement to change grid granularity
//                if (latDistCheck > 1.0 && longDistCheck > 1.0 && (records.get(k).get(j).equals("1") || records.get(k).get(j).equals("2") || records.get(k).get(j).equals("3") || records.get(k).get(j).equals("4") || records.get(k).get(j).equals("5") || records.get(k).get(j).equals("8") || records.get(k).get(j).equals("9"))) {
//                    GeodeticPoint point = new GeodeticPoint(Math.toRadians(latitudes[k]), Math.toRadians(longitudes[j]), 0.0);
//                    igbpPoints.add(point);
//                    latDistCheck = 0.0;
//                    longDistCheck = 0.0;
//                }
//                latDistCheck = latDistCheck+180.0/records.size();
//            }
//            latDistCheck = 0.0;
//            longDistCheck = longDistCheck+360.0/records.get(0).size();
//        }

        List<List<String>> plannerPointList = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/planner_points.csv"))) { 
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                plannerPointList.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }
        ArrayList<GeodeticPoint> plannerPoints = new ArrayList<>();
        for (int r = 0; r < plannerPointList.size(); r++) {
            GeodeticPoint gp = new GeodeticPoint(Double.parseDouble(plannerPointList.get(r).get(0)),Double.parseDouble(plannerPointList.get(r).get(1)),0.0);
            plannerPoints.add(gp);
        }
        ArrayList<GeodeticPoint> subset = new ArrayList(plannerPoints.subList(0,100));
        //create a coverage definition
        //CoverageDefinition covDef1 = new CoverageDefinition("covdef", this.coverageGridGranularity, earthShape, this.gridStyle);
        CoverageDefinition covDef1 = new CoverageDefinition("covdef1", plannerPoints, earthShape);

        //assign the walker constellation to the coverage definition
        covDef1.assignConstellation(walker);

        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        covDefs.add(covDef1);

        //set the type of propagation
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.KEPLERIAN, new Properties());

        //can set the properties of the analyses
        Properties propertiesEventAnalysis = new Properties();
        propertiesEventAnalysis.setProperty("fov.saveAccess", "false");

        //set the coverage event analyses
        EventAnalysisFactory eaf = new EventAnalysisFactory(startDate, endDate, inertialFrame, pf);
        ArrayList<EventAnalysis> eventanalyses = new ArrayList<>();
        FieldOfViewEventAnalysis fovEvent = (FieldOfViewEventAnalysis) eaf.createGroundPointAnalysis(EventAnalysisEnum.FOV, covDefs, propertiesEventAnalysis);
        eventanalyses.add(fovEvent);

        //build the scenario
        Scenario scen = new Scenario.Builder(startDate, endDate, utc).
                eventAnalysis(eventanalyses).covDefs(covDefs).
                name("SMAP").properties(propertiesEventAnalysis).
                propagatorFactory(pf).build();
        long start = System.nanoTime();
        try {
            //System.out.println(String.format("Running Scenario %s", scen));
            //System.out.println(String.format("Number of points:     %d", covDef1.getNumberOfPoints()));
            //System.out.println(String.format("Number of satellites: %d", walker.getSatellites().size()));

            //run the scenario
            scen.call();
        } catch (Exception ex) {
            Logger.getLogger(CoverageExample.class.getName()).log(Level.SEVERE, null, ex);
            throw new IllegalStateException("scenario failed to complete.");
        }
        long end = System.nanoTime();
        System.out.printf("Took %.4f sec\n", (end - start) / Math.pow(10, 9));
        return fovEvent.getEvents(covDef1);
    }

    public double getRevisitTime(Map<TopocentricFrame, TimeIntervalArray> accesses){
        return getRevisitTime(accesses,  new double[0], new double[0]);
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

    public double getRevisitTime(Map<TopocentricFrame, TimeIntervalArray> accesses, double[] latBounds, double[] lonBounds){
        // Method to compute average revisit time from accesses

        GroundEventAnalyzer eventAnalyzer = new GroundEventAnalyzer(accesses);

        DescriptiveStatistics stat;

        if(latBounds.length == 0 && lonBounds.length == 0){
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, this.propertiesPropagator);

        } else {
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, latBounds, lonBounds, this.propertiesPropagator);
        }
        return stat.getMean();
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
        return stat.getPercentile(100);
    }

    public Map<TopocentricFrame, TimeIntervalArray> getAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom, String instrumentType) throws OrekitException {
        String raanLabel = Double.toString(raan);
        CoverageAnalysisIO.AccessDataDefinition definition = new CoverageAnalysisIO.AccessDataDefinition(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, this.coverageGridGranularity, raanLabel, trueAnom);

        String filename = this.coverageAnalysisIO.getAccessDataFilename(definition);
        if (this.coverageAnalysisIO.getAccessDataFile(filename).exists()) {
            // The access data exists
            return this.coverageAnalysisIO.readAccessData(definition);
        }
        else {
            // Newly compute the accesses
            Map<TopocentricFrame, TimeIntervalArray> fovEvents = this.computeAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan,trueAnom, instrumentType);

            if (this.saveAccessData) {
                this.coverageAnalysisIO.writeAccessData(definition, fovEvents);
            }

            return fovEvents;
        }
    }
    public Map<TopocentricFrame, TimeIntervalArray> getPlannerAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom, String instrumentType) throws OrekitException {
        String raanLabel = Double.toString(raan);
        CoverageAnalysisIO.AccessDataDefinition definition = new CoverageAnalysisIO.AccessDataDefinition(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, this.coverageGridGranularity, raanLabel, trueAnom);

        String filename = this.coverageAnalysisIO.getAccessDataFilename(definition);
        if (this.coverageAnalysisIO.getAccessDataFile(filename).exists()) {
            // The access data exists
            return this.coverageAnalysisIO.readAccessData(definition);
        }
        else {
            // Newly compute the accesses
            Map<TopocentricFrame, TimeIntervalArray> fovEvents = this.computePlannerAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan,trueAnom, instrumentType);

            if (this.saveAccessData) {
                this.coverageAnalysisIO.writeAccessData(definition, fovEvents);
            }

            return fovEvents;
        }
    }

    public ArrayList<GeodeticPoint> getCovPoints(String pointType) {
        List<List<String>> records = new ArrayList<>();
        ArrayList<GeodeticPoint> covPoints = new ArrayList<>();
        switch(pointType) {
            case "igbp":
                try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/IGBP.csv"))) { 
                    String line;
                    while ((line = br.readLine()) != null) {
                        String[] values = line.split(",");
                        records.add(Arrays.asList(values));
                    }
                }
                catch (Exception e) {
                    System.out.println(e);
                }
                ArrayList<GeodeticPoint> igbpPoints = new ArrayList<>();
                double[] longitudes = linspace(-180.0,180.0,records.get(0).size());
                double[] latitudes = linspace(-84.66,84.66,records.size());
                double longDistCheck = 0.0;
                double latDistCheck = 0.0;
                for (int j = 0; j < records.get(0).size(); j++) {
                    for (int k = 0; k < records.size(); k++) {
                        // Check for IGBP biome types
                        // Change doubles in this if statement to change grid granularity
                        if (latDistCheck > 1.0 && longDistCheck > 1.0 && (records.get(k).get(j).equals("1") || records.get(k).get(j).equals("2") || records.get(k).get(j).equals("3") || records.get(k).get(j).equals("4") || records.get(k).get(j).equals("5") || records.get(k).get(j).equals("8") || records.get(k).get(j).equals("9"))) {
                            GeodeticPoint point = new GeodeticPoint(Math.toRadians(latitudes[k]), Math.toRadians(longitudes[j]), 0.0);
                            igbpPoints.add(point);
                            latDistCheck = 0.0;
                            longDistCheck = 0.0;
                        }
                        latDistCheck = latDistCheck+180.0/records.size();
                    }
                    latDistCheck = 0.0;
                    longDistCheck = longDistCheck+360.0/records.get(0).size();
                }
                covPoints = igbpPoints;
                break;
            case "land75_5":
                try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/LandLatLong75.csv"))) { 
                    String line;
                    while ((line = br.readLine()) != null) {
                        String[] values = line.split(",");
                        records.add(Arrays.asList(values));
                    }
                }
                catch (Exception e) {
                    System.out.println(e);
                }
                ArrayList<GeodeticPoint> landPoints = new ArrayList<>();
                for(int idx = 0; idx < records.size(); idx++) {
                    double lat = Double.parseDouble(records.get(idx).get(0));
                    double lon = Double.parseDouble(records.get(idx).get(1));
                    lon = lon - 180.0;
                    lat = Math.toRadians(lat);
                    lon = Math.toRadians(lon);
                    GeodeticPoint landPoint = new GeodeticPoint(lat,lon,0.0);
                    if(Math.abs(lat) <= Math.toRadians(75.0)) {
                        landPoints.add(landPoint);
                    }
                }
                covPoints = landPoints;
                break;
            case "simulationpoints":
                try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/20200101013000.csv"))) { 
                    String line;
                    while ((line = br.readLine()) != null) {
                        String[] values = line.split(",");
                        records.add(Arrays.asList(values));
                    }
                }
                catch (Exception e) {
                    System.out.println(e);
                }
                ArrayList<GeodeticPoint> simPoints = new ArrayList<>();
                double gridGranularity = 1.0;
                for (List<String> record : records) {
                    if (Objects.equals(record.get(1), "lat[deg]")) {
                        continue;
                    }
                    if(simPoints.size()==0) {
                        simPoints.add(new GeodeticPoint(Math.toRadians(Double.parseDouble(record.get(1))), Math.toRadians(Double.parseDouble(record.get(2))), 0.0));
                        continue;
                    }
                    GeodeticPoint newPoint = new GeodeticPoint(Math.toRadians(Double.parseDouble(record.get(1))), Math.toRadians(Double.parseDouble(record.get(2))), 0.0);
                    boolean tooClose = false;
                    for (int i = 0; i < simPoints.size();i++) {
                        double dist = Math.sqrt(Math.pow(simPoints.get(i).getLatitude()-newPoint.getLatitude(),2)+Math.pow(simPoints.get(i).getLongitude()-newPoint.getLongitude(),2));
                        if (dist < Math.toRadians(gridGranularity)) {
                            tooClose = true;
                            break;
                        }
                    }
                    if(!tooClose) {
                        simPoints.add(newPoint);
                    }
                }
                covPoints = simPoints;
                break;
            default:
                covPoints = null;
                break;
        }
        return covPoints;
    }

    public double[] linspace(double min, double max, int points) {
        double[] d = new double[points];
        for (int i = 0; i < points; i++){
            d[i] = min + i * (max - min) / (points - 1);
        }
        return d;
    }
}
