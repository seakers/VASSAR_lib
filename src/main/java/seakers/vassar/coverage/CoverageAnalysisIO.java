package seakers.vassar.coverage;

import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.apache.commons.math3.util.FastMath;
import org.hipparchus.stat.descriptive.DescriptiveStatistics;
import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.bodies.OneAxisEllipsoid;
import org.orekit.errors.OrekitException;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.coverage.analysis.AnalysisMetric;
import seakers.orekit.coverage.analysis.GroundEventAnalyzer;
import seakers.orekit.object.CoveragePoint;
import seakers.vassar.RawSafety;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Class that computes coverage metrics for each satellite in the constellation
 * @author Prachi
 */

public class CoverageAnalysisIO {

    private boolean binaryEncoding;
    private TimeScale timeScale;

    private static HashMap<String, ReentrantLock> fileLocks;

    static {
        fileLocks = new HashMap<>();
    }

    private static void lockFile(String filename) {
        if (fileLocks.containsKey(filename)) {
            fileLocks.get(filename).lock();
        }
        else {
            fileLocks.put(filename, new ReentrantLock());
            fileLocks.get(filename).lock();
        }
    }

    private static void unlockFile(String filename) {
        fileLocks.get(filename).unlock();
    }

    public CoverageAnalysisIO(boolean binaryEncoding, TimeScale timeScale){
        this.binaryEncoding = binaryEncoding;
        this.timeScale = timeScale;
    }

    public void setBinaryEncoding(boolean binaryEncoding){
        this.binaryEncoding = binaryEncoding;
    }

    public void writeAccessData(AccessDataDefinition definition, Map<TopocentricFrame, TimeIntervalArray> fovEvents){
        if(this.binaryEncoding){
            this.writeAccessDataBinary(definition, fovEvents);

        }else{
            this.writeAccessDataCSV(definition, fovEvents);
        }
    }

    public Map<TopocentricFrame, TimeIntervalArray> readAccessData(AccessDataDefinition definition){
        if(this.binaryEncoding){
            return this.readAccessDataBinary(definition);
        }else{
            return this.readAccessDataCSV(definition);
        }
    }

    public Map<TopocentricFrame, TimeIntervalArray> readAccessDataCSV(AccessDataDefinition definition) {

        String filename = getAccessDataFilename(definition);

        CoverageAnalysisIO.lockFile(filename);

        File file = getAccessDataFile(filename);


        Map<TopocentricFrame, TimeIntervalArray> out = new HashMap<>();
            
        String line;
        List<SimpleDateFormat> startTime = new ArrayList<>();
        List<AbsoluteDate> stopTime = new ArrayList<>();
        List<Double> riseTime = new ArrayList<>();
        List<Double> setTime = new ArrayList<>();
        
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {

            // Skip first line
            br.readLine();

            while ((line = br.readLine()) != null) {

                String[] entry = line.split(","); // use comma as separator
                int columns = entry.length; //get the number of columns in a row

                double lat = Double.parseDouble(entry[0]);
                double lon = Double.parseDouble(entry[1]);

                GeodeticPoint geoPoint = new GeodeticPoint(lat, lon, 0.0);
                
                //using a default body frame since we are simulating earth
                //must use IERS_2003 and EME2000 frames to be consistent with STK
                Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);
                BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                        Constants.WGS84_EARTH_FLATTENING, earthFrame);
                
                TopocentricFrame topos = new TopocentricFrame(earthShape, geoPoint, String.valueOf(definition.hashCode()));
                AbsoluteDate head = new AbsoluteDate(entry[2], timeScale);
                AbsoluteDate tail = new AbsoluteDate(entry[3], timeScale);

                TimeIntervalArray timeInterval = new TimeIntervalArray(head, tail);
                
                for (int i = 0; i < columns; i = i + 2) {
                    timeInterval.addRiseTime(Double.parseDouble(entry[i + 4]));
                    timeInterval.addSetTime(Double.parseDouble(entry[i + 5]));
                }
                
                out.put(topos, timeInterval);
            }
        }
        catch (IOException | OrekitException e) {
            e.printStackTrace();
        }
        finally {
            CoverageAnalysisIO.unlockFile(filename);
        }
        return out;
    } 
    
    public void writeAccessDataCSV(AccessDataDefinition definition, Map<TopocentricFrame, TimeIntervalArray> fovEvents){

        String filename = getAccessDataFilename(definition);

        CoverageAnalysisIO.lockFile(filename);

        File file = getAccessDataFile(filename);

        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {

            StringJoiner sj = new StringJoiner(",");

            sj.add("Latitude [deg]");
            sj.add("Longitude [deg]");
            sj.add("Start Time [UTC]");
            sj.add("Stop Time [UTC]");
            sj.add("Rise Time [s]");
            sj.add("Set Time [s]");
            bw.append(sj.toString());
            bw.newLine();
            bw.flush();

            GroundEventAnalyzer fovEventAnalyzer = new GroundEventAnalyzer(fovEvents);
            Iterator<CoveragePoint> iterator = fovEventAnalyzer.getCoveragePoints().iterator();

            String datarow = nextEntry(iterator, fovEventAnalyzer);
            while (datarow != null) {
                bw.append(datarow);
                bw.newLine();
                datarow = nextEntry(iterator, fovEventAnalyzer);
            }
            bw.flush();

        } catch (FileNotFoundException exc) {
            System.out.println("Exc in finding the file: " + exc.getMessage());
            exc.printStackTrace();

        } catch (IOException exc) {
            System.out.println("Exc in writing access data in csv: " + exc.getMessage());
            exc.printStackTrace();
        }
        finally {
            CoverageAnalysisIO.unlockFile(filename);
        }
    }

    private String nextEntry(Iterator<CoveragePoint> coveragePointsIterator, GroundEventAnalyzer fovEventAnalyzer) {

        if (coveragePointsIterator.hasNext()) {
            CoveragePoint point = coveragePointsIterator.next();
            Properties prop = new Properties();

            DescriptiveStatistics accesses = fovEventAnalyzer.getStatistics(AnalysisMetric.DURATION, true, point, prop);
            DescriptiveStatistics gaps = fovEventAnalyzer.getStatistics(AnalysisMetric.DURATION, false, point, prop);
            DescriptiveStatistics riseSetTimes = fovEventAnalyzer.getStatistics(AnalysisMetric.LIST_RISE_SET_TIMES, true, point, prop);
            int riseSetTimesSize = (int) riseSetTimes.getN();

            String[] entry = new String[4 + riseSetTimesSize];
            entry[0] = String.valueOf(FastMath.toDegrees(point.getPoint().getLatitude()));
            entry[1] = String.valueOf(FastMath.toDegrees(point.getPoint().getLongitude()));

            entry[2] = String.valueOf(fovEventAnalyzer.getStartDate()); // Start date
            entry[3] = String.valueOf(fovEventAnalyzer.getEndDate()); // End date

            if (riseSetTimesSize == 0) {
                return String.join(",", entry);

            } else {
                for (int i = 0; i < riseSetTimesSize; i++) {
                    entry[i + 4] = String.valueOf(riseSetTimes.getElement(i));
                }
            }

            return String.join(",", entry);

        } else {

            return null;
        }
    }

    public String getAccessDataFilename(AccessDataDefinition definition) {
        StringBuilder filename = new StringBuilder();
        filename.append(String.valueOf(definition.hashCode()));

        if(!this.binaryEncoding){
            filename.append(".csv");
        }

        return filename.toString();
    }

    public File getAccessDataFile(String filename) {

        return new File(
                System.getProperty("orekit.coveragedatabase"),
                filename
                );
    }

    public Map<TopocentricFrame, TimeIntervalArray> readAccessDataBinary(AccessDataDefinition definition) {

        String filename = getAccessDataFilename(definition);

        CoverageAnalysisIO.lockFile(filename);

        File file = getAccessDataFile(filename);

        Map<TopocentricFrame, TimeIntervalArray> out = new HashMap<>();

        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file))) {
            out = RawSafety.castHashMap(ois.readObject());

        } catch (FileNotFoundException exc) {
            System.out.println("Exc in finding the file: " + exc.getMessage());
            exc.printStackTrace();

        } catch (IOException exc) {
            System.out.println("Exc in reading binary access data: " + filename + "\n"+ exc.getMessage());
            exc.printStackTrace();

        } catch (ClassNotFoundException exc) {
            exc.printStackTrace();
        }
        finally {
            CoverageAnalysisIO.unlockFile(filename);
        }

        return out;
    }

    public void writeAccessDataBinary(AccessDataDefinition definition, Map<TopocentricFrame, TimeIntervalArray> accesses) {

        String filename = getAccessDataFilename(definition);

        CoverageAnalysisIO.lockFile(filename);

        File file = getAccessDataFile(filename);

        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file))) {

            oos.writeObject(accesses);

        } catch (FileNotFoundException exc) {
            System.out.println("Exc in finding the file: " + exc.getMessage());
            exc.printStackTrace();

        } catch (IOException exc) {
            System.out.println("Exc in writing binary access data: " + exc.getMessage());
            exc.printStackTrace();
        }
        finally {
            CoverageAnalysisIO.unlockFile(filename);
        }
    }

    public static class AccessDataDefinition {

        private double fieldOfView;
        private double inclination;
        private double altitude;
        private double trueAnom;
        private int numSats;
        private int numPlanes;
        private int granularity;
        private String raan;

        public AccessDataDefinition(double fieldOfView, double inclination, double altitude, int numSats, int numPlanes, int granularity, String raanLabel){
            this.fieldOfView = fieldOfView;
            this.inclination = inclination;
            this.altitude = altitude;
            this.numSats = numSats;
            this.numPlanes = numPlanes;
            this.granularity = granularity;
            this.trueAnom = 0;
            if(raanLabel == null){
                this.raan = "NA";
            }else{
                this.raan = raanLabel;
            }
        }

        public AccessDataDefinition(double fieldOfView, double inclination, double altitude, int numSats, int numPlanes, int granularity, String raanLabel, double trueAnom){
            this.fieldOfView = fieldOfView;
            this.inclination = inclination;
            this.altitude = altitude;
            this.numSats = numSats;
            this.numPlanes = numPlanes;
            this.granularity = granularity;
            this.trueAnom = trueAnom;
            if(raanLabel == null){
                this.raan = "NA";
            }else{
                this.raan = raanLabel;
            }
        }

        @Override
        public int hashCode() {

            // Round inclination and altitude values to the first decimal
            double inclinationRoundOff = Math.round(inclination * 10.0) / 10.0;
            double altitudeRoundOff = Math.round(altitude * 10.0) / 10.0;

            return new HashCodeBuilder(17, 37).
                    append(fieldOfView).
                    append(inclinationRoundOff).
                    append(altitudeRoundOff).
                    append(numSats).
                    append(numPlanes).
                    append(granularity).
                    append(raan).
                    append(trueAnom).
                    toHashCode();
        }
    }
}