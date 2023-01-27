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
import seakers.orekit.object.*;
import seakers.orekit.object.fieldofview.NadirSimpleConicalFOV;
import seakers.orekit.propagation.PropagatorFactory;
import seakers.orekit.propagation.PropagatorType;
import seakers.orekit.scenario.Scenario;

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
public class CoverageAnalysisPlannerOverlap {

    private int numThreads;
    private String cwd; //current working directory
    private Properties propertiesPropagator;
    private CoverageDefinition.GridStyle gridStyle;
    private boolean binaryEncoding;
    private CoverageAnalysisIO coverageAnalysisIO;
    private boolean saveAccessData;
    private AbsoluteDate startDate;
    private AbsoluteDate endDate;

    private Map<TopocentricFrame, TimeIntervalArray> imagerEvents;

    private HashMap<Satellite, HashMap<TopocentricFrame, TimeIntervalArray>> eventsBySatellite;

    public CoverageAnalysisPlannerOverlap(int numThreads) throws OrekitException{
        this(numThreads, true, true);
    }

    public CoverageAnalysisPlannerOverlap(int numThreads, boolean saveAccessData, boolean binaryEncoding) throws OrekitException {
        this(numThreads, saveAccessData, binaryEncoding, System.getProperty("user.dir"));
    }

    public CoverageAnalysisPlannerOverlap(int numThreads, boolean saveAccessData, boolean binaryEncoding, String cwd) throws OrekitException{

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
        this.endDate = startDate.shiftedBy(7 * 24 * 60 * 60); // 16 days in seconds

        this.numThreads = numThreads;
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

    public void reset(){

        //can set the properties/number of resources available
        //to the satellite but we don't need them right now
        //so we are just instantiating it
        this.propertiesPropagator = new Properties();
    }
    private void computeImagerAccesses(ArrayList<Satellite> satelliteList) throws OrekitException{
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
        CoverageDefinition covDef = new CoverageDefinition("covdef", covPoints, earthShape);
        //CoverageDefinition covDef = new CoverageDefinition("Whole Earth", granularity, earthShape, UNIFORM);
        HashSet<CoverageDefinition> covDefs = new HashSet<>();
        Constellation constellation = new Constellation("Constellation", satelliteList);
        covDef.assignConstellation(constellation);
        covDefs.add(covDef);

        ArrayList<EventAnalysis> eventAnalyses = new ArrayList<>();
        FieldOfViewEventAnalysis fovea = new FieldOfViewEventAnalysis(startDate, endDate, inertialFrame,covDefs,pf,true, true);
        eventAnalyses.add(fovea);

        Scenario scene = new Scenario.Builder(startDate, endDate, utc).eventAnalysis(eventAnalyses).covDefs(covDefs).name("CoverageByConstellation").propagatorFactory(pf).build();

        try {
            scene.call();
        } catch (Exception e) {
            e.printStackTrace();
        }

        GroundEventAnalyzer gea = new GroundEventAnalyzer(fovea.getEvents(covDef));
        long end = System.nanoTime();
        //System.out.printf("coverageByConstellation took %.4f sec\n", (end - start) / Math.pow(10, 9));
        imagerEvents = gea.getEvents();
        eventsBySatellite = fovea.getAllEvents(covDef);
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
}
