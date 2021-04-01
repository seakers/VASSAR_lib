/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar.coverage;

import org.hipparchus.stat.descriptive.DescriptiveStatistics;
import org.hipparchus.util.FastMath;
import org.orekit.bodies.BodyShape;
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
import seakers.orekit.event.ReflectionEventAnalysis;
import seakers.orekit.object.CoverageDefinition;
import seakers.orekit.object.Instrument;
import seakers.orekit.object.fieldofview.NadirSimpleConicalFOV;
import seakers.orekit.object.fieldofview.OffNadirRectangularFOV;
import seakers.orekit.propagation.PropagatorFactory;
import seakers.orekit.propagation.PropagatorType;
import seakers.orekit.scenario.Scenario;
import seakers.orekit.util.OrekitConfig;

import java.io.File;
import java.util.*;

import static seakers.orekit.object.CoverageDefinition.GridStyle.EQUAL_AREA;
import static seakers.orekit.util.Orbits.LTAN2RAAN;

/**
 *
 * @author Prachi
 */
public class ReflectometerCoverageAnalysis {

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

    public ReflectometerCoverageAnalysis(int numThreads, int coverageGridGranularity) throws OrekitException{
        this(numThreads, coverageGridGranularity, true, true);
    }

    public ReflectometerCoverageAnalysis(int numThreads, int coverageGridGranularity, boolean saveAccessData, boolean binaryEncoding) throws OrekitException {
        this(numThreads, coverageGridGranularity, saveAccessData, binaryEncoding, System.getProperty("user.dir"));
    }

    public ReflectometerCoverageAnalysis(int numThreads, int coverageGridGranularity, boolean saveAccessData, boolean binaryEncoding, String cwd) throws OrekitException{

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
        this.endDate = startDate.shiftedBy(1 * 24 * 60 * 60); // 7 days in seconds

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
            //System.out.println("Corresponding data file found");
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
        return this.computeAccesses(fieldOfView, inclination, altitude, numSats, numPlanes, 0.0,0.0,"");
    }

    private Map<TopocentricFrame, TimeIntervalArray> computeAccesses(double fieldOfView, double inclination, double altitude, int numSats, int numPlanes, String raanLabel) throws OrekitException{

        double raan = 0.0;

        if(raanLabel != null){
            int hour = 0;
            int minute = 0;
            double second = 0.0;
            boolean skip = false;

            switch (raanLabel){
                case "DD":
                    hour = 6;
                    minute = 30;
                    break;
                case "AM":
                    hour = 10;
                    minute = 0;
                    break;
                case "noon":
                    hour = 12;
                    minute = 0;
                    break;
                case "PM":
                    hour = 14;
                    minute = 0;
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

        return this.computeAccesses(fieldOfView, FastMath.toDegrees(inclination), altitude, numSats, numPlanes, raan, 0.0, "");
    }

    /**
     * Computes the accesses for satellites sharing the same field of view
     * @param fieldOfView [deg]
     * @param inclination [deg]
     * @param altitude [m]
     * @param numSatsPerPlane
     * @param numPlanes
     * @param raan [deg]
     * @throws OrekitException
     */
    private Map<TopocentricFrame, TimeIntervalArray> computeAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom, String band) throws OrekitException{
        //initializes the look up tables for planteary position (required!)
        OrekitConfig.init(4);

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

        double aGPS = Constants.WGS84_EARTH_EQUATORIAL_RADIUS + 20180e3;
        double iGPS = FastMath.toRadians(55);

        double aMUOS = Constants.WGS84_EARTH_EQUATORIAL_RADIUS + 35786e3;
        double iMUOS = 0;

        //define instruments and payload
        //NadirSimpleConicalFOV fov = new NadirSimpleConicalFOV(FastMath.toRadians(fieldOfView), earthShape);
        OffNadirRectangularFOV fov = new OffNadirRectangularFOV(FastMath.toRadians(45), FastMath.toRadians(15),FastMath.toRadians(15),0,earthShape);
        OffNadirRectangularFOV fov_opposite = new OffNadirRectangularFOV(FastMath.toRadians(-45), FastMath.toRadians(15),FastMath.toRadians(15),0,earthShape);

        NadirSimpleConicalFOV gpsFOV = new NadirSimpleConicalFOV(FastMath.toRadians(42.6),earthShape);

        ArrayList<Instrument> payload = new ArrayList<>();
        Instrument view1 = new Instrument("view1", fov, 100, 100);
        Instrument view2 = new Instrument("view2", fov_opposite, 100, 100);
        payload.add(view1);
        payload.add(view2);

        ArrayList<Instrument> gpsPayload = new ArrayList<>();
        Instrument gpsAntenna = new Instrument("GPS", gpsFOV, 100,100);
        gpsPayload.add(gpsAntenna);
        Walker gpsWalker = new Walker("GPS Walker", gpsPayload, aGPS, iGPS, 24, 4, 0, inertialFrame, startDate, mu, 0, 0);
        Walker muos = new Walker("MUOS Walker", gpsPayload, aMUOS, iMUOS, 4, 4, 0, inertialFrame, startDate, mu, 0, 0);
        //number of total satellites
        int t = numSatsPerPlane*numPlanes;

        //number of planes
        int p = numPlanes;

        //number of phases
        int f = 0;

        //Create a walker constellation
        Walker walker = new Walker("walker1", payload, a, FastMath.toRadians(i), t, p, f, inertialFrame, startDate, mu, FastMath.toRadians(raan), FastMath.toRadians(trueAnom));
        
//        List<List<String>> records = new ArrayList<>();
//        try (BufferedReader br = new BufferedReader(new FileReader("D:\\Documents\\VASSAR\\VASSAR_lib\\src\\test\\java\\LandLatLong75.csv"))) { // CHANGE THIS FOR YOUR IMPLEMENTATION
//            String line;
//            while ((line = br.readLine()) != null) {
//                String[] values = line.split(",");
//                records.add(Arrays.asList(values));
//            }
//        }
//        catch (Exception e) {
//            System.out.println(e);
//        }
//
//        ArrayList<GeodeticPoint> landPoints = new ArrayList<>();
//        for(int idx = 0; idx < records.size(); idx++) {
//            double lat = parseDouble(records.get(idx).get(0));
//            double lon = parseDouble(records.get(idx).get(1));
//            lon = lon - 180.0;
//            lat = Math.toRadians(lat);
//            lon = Math.toRadians(lon);
//            GeodeticPoint landPoint = new GeodeticPoint(lat,lon,0.0);
//            if(Math.abs(lat) <= Math.toRadians(75.0)) {
//                landPoints.add(landPoint);
//            }
//        }
//        System.out.println(landPoints.size());
//
//        //create a coverage definition
//        CoverageDefinition covDef1 = new CoverageDefinition("covdef1", landPoints, earthShape);
        CoverageDefinition covDef1 = new CoverageDefinition("covdef1", this.coverageGridGranularity, earthShape, this.gridStyle);
        System.out.println(covDef1.getNumberOfPoints());
        //CoverageDefinition covDef2 = new CoverageDefinition("GPS", landPoints, earthShape);
        //assign the walker constellation to the coverage definition
        covDef1.assignConstellation(walker);
        //covDef2.assignConstellation(walker);
        //covDef2.assignConstellation(gpsWalker);
        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        covDefs.add(covDef1);
        //covDefs.add(covDef2);
        //set the type of propagation
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.KEPLERIAN, new Properties());

        //can set the properties of the analyses
        Properties propertiesEventAnalysis = new Properties();
        propertiesEventAnalysis.setProperty("fov.saveAccess", "false");

        //set the coverage event analyses
        EventAnalysisFactory eaf = new EventAnalysisFactory(startDate, endDate, inertialFrame, pf);
        ArrayList<EventAnalysis> eventanalyses = new ArrayList<>();
        Walker tx = null;
        if(band.equals("L-band")) {
            tx = gpsWalker;
        }
        if(band.equals("P-band")) {
            tx = muos;
        }
        ReflectionEventAnalysis reflEvent = (ReflectionEventAnalysis) eaf.createReflectionAnalysis(EventAnalysisEnum.REFLECTOR, walker, tx, covDefs, propertiesEventAnalysis);
        eventanalyses.add(reflEvent);

        //build the scenario
        Scenario scen = new Scenario.Builder(startDate, endDate, utc).
                eventAnalysis(eventanalyses).covDefs(covDefs).
                name("SMAP").properties(propertiesEventAnalysis).
                propagatorFactory(pf).build();
        try {
//            System.out.println(String.format("Running Scenario %s", scen));
//            System.out.println(String.format("Number of points:     %d", covDef1.getNumberOfPoints()));
//            System.out.println(String.format("Number of satellites: %d", walker.getSatellites().size()));
            //run the scenario
            scen.call();
        } catch (Exception ex) {
//            Logger.getLogger(CoverageExample.class.getName()).log(Level.SEVERE, null, ex);
            throw new IllegalStateException("scenario failed to complete.");
        }

        Map<TopocentricFrame, TimeIntervalArray> accesses = reflEvent.getEvents(covDef1);
        return accesses;

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
        return stat.getPercentile(95);
    }

    public Map<TopocentricFrame, TimeIntervalArray> getAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom, String band) throws OrekitException {
        String raanLabel = Double.toString(raan);
        CoverageAnalysisIO.AccessDataDefinition definition = new CoverageAnalysisIO.AccessDataDefinition(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, this.coverageGridGranularity, raanLabel, trueAnom);

        String filename = this.coverageAnalysisIO.getAccessDataFilename(definition);
        boolean override = false;
        if (this.coverageAnalysisIO.getAccessDataFile(filename).exists() && override) {
            // The access data exists
            return this.coverageAnalysisIO.readAccessData(definition);
        }
        else {
            // Newly compute the accesses
            Map<TopocentricFrame, TimeIntervalArray> fovEvents = this.computeAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan,trueAnom,band);

            if (this.saveAccessData) {
                this.coverageAnalysisIO.writeAccessData(definition, fovEvents);
            }

            return fovEvents;
        }
    }
}
