package seakers.vassar.coverage;

import org.hipparchus.stat.descriptive.DescriptiveStatistics;
import org.orekit.frames.TopocentricFrame;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.coverage.analysis.AnalysisMetric;
import seakers.orekit.coverage.analysis.GroundEventAnalyzer;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class CoverageRetriever {

    public String coverageDB;
    public CoverageAnalysisIO coverageAnalysisIO;
    public int coverageGridGranularity;
    public Properties propertiesPropagator;

    public CoverageRetriever(String coverageDB, int covGranularity){
        this.coverageDB = coverageDB;
        this.coverageGridGranularity = covGranularity;
        TimeScale utc = TimeScalesFactory.getUTC();
        this.coverageAnalysisIO = new CoverageAnalysisIO(true, utc, coverageDB);
        this.propertiesPropagator = new Properties();
    }

    public Map<TopocentricFrame, TimeIntervalArray> getAccesses(double fieldOfView, double inclination, double altitude, int numSats, int numPlanes, String raanLabel) throws IOException, ClassNotFoundException {
        CoverageAnalysisIO.AccessDataDefinition definition = new CoverageAnalysisIO.AccessDataDefinition(fieldOfView, inclination, altitude, numSats, numPlanes, this.coverageGridGranularity, raanLabel);

        String filename = this.coverageAnalysisIO.getAccessDataFilename(definition);
        File access_file = this.coverageAnalysisIO.getAccessDataFile(filename);
        if (access_file.exists()) {
            Map<TopocentricFrame, TimeIntervalArray> cov_data = this.coverageAnalysisIO.readAccessData(definition);
//            System.out.println("--> ACCESES FILE: " + access_file.getAbsolutePath() + " " + cov_data.keySet().size());
            return cov_data;
        }
        else{
            System.out.println("--> ERROR COVERAGE FILE DNE FOR: " + altitude + " " + fieldOfView);
            return new HashMap<>();
        }
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

}
