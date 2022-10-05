/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar.coverage;

import org.hipparchus.geometry.euclidean.threed.Vector3D;
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
import seakers.orekit.object.CoveragePoint;
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
import static java.lang.Double.parseDouble;
import static seakers.orekit.object.CoverageDefinition.GridStyle.EQUAL_AREA;
import static seakers.orekit.util.Orbits.LTAN2RAAN;
/**
 *
 * @author Prachi
 */
public class CoverageAnalysis {

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

    public CoverageAnalysis(int numThreads, int coverageGridGranularity) throws OrekitException{
        this(numThreads, coverageGridGranularity, true, true);
    }

    public CoverageAnalysis(int numThreads, int coverageGridGranularity, boolean saveAccessData, boolean binaryEncoding) throws OrekitException {
        this(numThreads, coverageGridGranularity, saveAccessData, binaryEncoding, System.getProperty("user.dir"));
    }

    public CoverageAnalysis(int numThreads, int coverageGridGranularity, boolean saveAccessData, boolean binaryEncoding, String cwd) throws OrekitException{

        //setup logger
//        Level level = Level.ALL;
//        Logger.getGlobal().setLevel(level);
//        ConsoleHandler handler = new ConsoleHandler();
//        handler.setLevel(level);
//        Logger.getGlobal().addHandler(handler);
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
        this.endDate = startDate.shiftedBy(7 * 24 * 60 * 60); // 7 days in seconds

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
        return this.computeAccesses(fieldOfView, inclination, altitude, numSats, numPlanes, 0.0,0.0);
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
//                raan = getRAANForGivenLTANOfSSO(hour, minute, second, altitude, inclination);
                TimeScale utc = TimeScalesFactory.getUTC();
                int day = startDate.getComponents(utc).getDate().getDay();
                int month = startDate.getComponents(utc).getDate().getMonth();
                int year = startDate.getComponents(utc).getDate().getYear();
                raan = FastMath.toDegrees( LTAN2RAAN(altitude, hour, day, month, year) );
            }
        }

        return this.computeAccesses(fieldOfView, FastMath.toDegrees(inclination), altitude, numSats, numPlanes, raan, 0.0);
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
    private Map<TopocentricFrame, TimeIntervalArray> computeAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom) throws OrekitException{
        //initializes the look up tables for planteary position (required!)
        //OrekitConfig.init(4);
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
        NadirSimpleConicalFOV fov = new NadirSimpleConicalFOV(FastMath.toRadians(fieldOfView), earthShape);
        ArrayList<Instrument> payload = new ArrayList<>();
        Instrument view1 = new Instrument("view1", fov, 100, 100);
        payload.add(view1);
        //number of total satellites
        int t = numSatsPerPlane*numPlanes;

        //number of planes
        int p = numPlanes;

        //number of phases
        int f = 0;

        //Create a walker constellation
        Walker walker = new Walker("walker1", payload, a, FastMath.toRadians(i), t, p, f, inertialFrame, startDate, mu, FastMath.toRadians(raan), FastMath.toRadians(trueAnom));

        //define coverage params
        //this is coverage with 20 granularity and equal area grid style
        CoverageDefinition coverageDefinition = new CoverageDefinition("covdef", this.coverageGridGranularity, earthShape, this.gridStyle);
        coverageDefinition.assignConstellation(walker);

        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        covDefs.add(coverageDefinition);

        //set the type of propagation
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.J2, new Properties());

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
        try {
//            System.out.println(String.format("Running Scenario %s", scen));
//            System.out.println(String.format("Number of points:     %d", covDef1.getNumberOfPoints()));
//            System.out.println(String.format("Number of satellites: %d", walker.getSatellites().size()));
            //run the scenario
            scen.call();
        } catch (Exception ex) {
            Logger.getLogger(CoverageExample.class.getName()).log(Level.SEVERE, null, ex);
            throw new IllegalStateException("scenario failed to complete.");
        }

        return fovEvent.getEvents(coverageDefinition);

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

        }else{
            stat = eventAnalyzer.getStatistics(AnalysisMetric.PERCENT_COVERAGE, true, latBounds, lonBounds, this.propertiesPropagator);
        }

        double perc_cov = stat.getMean();
        //System.out.println(String.format("Mean revisit time %s", mean));
        return perc_cov;
    }

    public double getRevisitTime(Map<TopocentricFrame, TimeIntervalArray> accesses, double[] latBounds, double[] lonBounds){
        // Method to compute average revisit time from accesses

        GroundEventAnalyzer eventAnalyzer = new GroundEventAnalyzer(accesses);

        DescriptiveStatistics stat;

        if(latBounds.length == 0 && lonBounds.length == 0){
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, this.propertiesPropagator);

        }else{
            stat = eventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, latBounds, lonBounds, this.propertiesPropagator);
        }

        double mean = stat.getMean();
        //System.out.println(String.format("Mean revisit time %s", mean));
        return mean;
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

    /**
     * Computes a rough estimate of RAAN for a given LTAN
     * @param altitude [m]
     * @param inclination [deg]
     * @return
     * @throws OrekitException
     */
    public double getRAANForGivenLTANOfSSO(int hour, int minute, double second, double altitude, double inclination) throws OrekitException{
        TimeScale utc = TimeScalesFactory.getUTC();
        double mu = Constants.WGS84_EARTH_MU; // gravitation coefficient

        //must use IERS_2003 and EME2000 frames to be consistent with STK
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
        Frame inertialFrame = FramesFactory.getEME2000();

        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);

        double minAngle = 10000;
        double optRaan = -1;

        DateTimeComponents startDateTimeComponents = this.startDate.getComponents(utc);

        DateComponents startDateComponents = startDateTimeComponents.getDate();
        TimeComponents startTimeComponents = new TimeComponents(hour, minute, second); // Set the desired LTAN

        AbsoluteDate tempStartDate = new AbsoluteDate(startDateComponents, startTimeComponents, utc);
        AbsoluteDate tempEndDate = this.startDate;

        // If the start date is not before the end date
        while(tempStartDate.compareTo(tempEndDate) > -1){

            // Shift 1 day
            tempStartDate = tempStartDate.shiftedBy( - 24 * 60 * 60);
        }

        for(double raan = 0; raan < 360; raan += 0.1){

            Orbit SSO = new KeplerianOrbit(Constants.WGS84_EARTH_EQUATORIAL_RADIUS + altitude, 0.0001, FastMath.toRadians(inclination),0.0,
                    FastMath.toRadians(raan), 0.0, PositionAngle.MEAN, inertialFrame, tempStartDate, mu);

            GeodeticPoint p = new GeodeticPoint(0, 0, 0);
            CoveragePoint point=new CoveragePoint(earthShape, p, "");

            Vector3D pt1 = SSO.getPVCoordinates().getPosition();
            Vector3D pt2 = point.getPVCoordinates(tempStartDate, inertialFrame).getPosition();
            double angle=Vector3D.angle(pt1, pt2);

            if(angle < minAngle){
                minAngle = angle;

                if(FastMath.toDegrees(angle) < 0.5){
                    Properties propertiesPropagator = new Properties();
                    propertiesPropagator.setProperty("orekit.propagator.mass", "6");
                    propertiesPropagator.setProperty("orekit.propagator.atmdrag", "true");

                    propertiesPropagator.setProperty("orekit.propagator.dragarea", "0.075");
                    propertiesPropagator.setProperty("orekit.propagator.dragcoeff", "2.2");
                    propertiesPropagator.setProperty("orekit.propagator.thirdbody.sun", "true");
                    propertiesPropagator.setProperty("orekit.propagator.thirdbody.moon", "true");
                    propertiesPropagator.setProperty("orekit.propagator.solarpressure", "true");
                    propertiesPropagator.setProperty("orekit.propagator.solararea", "0.058");

                    PropagatorFactory pf=new PropagatorFactory(PropagatorType.NUMERICAL,propertiesPropagator);
                    Propagator prop=pf.createPropagator(SSO, 0);
                    SpacecraftState s=prop.propagate(tempStartDate, tempEndDate);
                    KeplerianOrbit orbit=(KeplerianOrbit)s.getOrbit();
                    optRaan = orbit.getRightAscensionOfAscendingNode();
                }
            }
        }

//        Logger.getGlobal().finest(String.format("ANGLE Diff=%.4f", minAngle));
//        Logger.getGlobal().finest(String.format("RAAN=%.4f", optRaan));

        return optRaan;
    }

    public Map<TopocentricFrame, TimeIntervalArray> getAccesses(double fieldOfView, double inclination, double altitude, int numSatsPerPlane, int numPlanes, double raan, double trueAnom) throws OrekitException {
        String raanLabel = Double.toString(raan);
        CoverageAnalysisIO.AccessDataDefinition definition = new CoverageAnalysisIO.AccessDataDefinition(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, this.coverageGridGranularity, raanLabel, trueAnom);

        String filename = this.coverageAnalysisIO.getAccessDataFilename(definition);
        if (this.coverageAnalysisIO.getAccessDataFile(filename).exists()) {
            // The access data exists
            //System.out.println("Corresponding data file found");
            return this.coverageAnalysisIO.readAccessData(definition);
        }
        else {
            // Newly compute the accesses
            Map<TopocentricFrame, TimeIntervalArray> fovEvents = this.computeAccesses(fieldOfView, inclination, altitude, numSatsPerPlane, numPlanes, raan,trueAnom);

            if (this.saveAccessData) {
                this.coverageAnalysisIO.writeAccessData(definition, fovEvents);
            }

            return fovEvents;
        }
    }
}
