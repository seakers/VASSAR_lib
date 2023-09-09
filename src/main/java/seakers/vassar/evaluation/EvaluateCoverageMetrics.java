package seakers.vassar.evaluation;

import org.orekit.frames.TopocentricFrame;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.coverage.CoverageAnalysis;
import seakers.vassar.spacecraft.Orbit;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class EvaluateCoverageMetrics {


    public static void main(String[] args) {
        String proc_num = args[0];
        ArrayList<String> orbitList = new ArrayList<>();
        String all_args = proc_num;
        for(int x = 1; x < args.length; x++){
            orbitList.add(args[x]);
            all_args += " " + args[x];
        }
        System.out.println("--> ALL ARGS: " + all_args);


        // Actual Values
//        double[] fovs = {1.0, 2.0, 5.0, 10.0, 35.0, 50.0};
        double[] fovs = {9.0, 13.0, 20.0, 55.0};


        // Testing Values
//        double[] fovs = {2.0};


        // Initialize Orekit
        String orekitResourcesPath = "/home/ec2-user/vassar/giga/VASSAR_resources/orekit";
        String coverageDatabase = orekitResourcesPath + File.separator + "CoverageDatabase_" + proc_num;
        EvaluateCoverageMetrics.createDir(coverageDatabase);

        OrekitConfig.init(1, orekitResourcesPath);
        System.setProperty("orekit.coveragedatabase", coverageDatabase);


        int coverageGranularity = 20;
        for(int x = 0; x < orbitList.size(); x++){
            for(int y = 0; y < fovs.length; y++) {
                double fieldOfView = fovs[y]; // [deg]
                String orbit_name = orbitList.get(x);
                Orbit orb = new Orbit(orbit_name, 1, 1);
                double inclination = orb.getInclinationNum(); // [deg]
                double altitude = orb.getAltitudeNum(); // [m]
                String raanLabel = orb.getRaan();
                int numSats = 1;
                int numPlanes = 1;
                System.out.println("--> RUNNING COVERAGE ANALYSIS");
                CoverageAnalysis coverageAnalysis = new CoverageAnalysis(1, coverageGranularity, true, true, orekitResourcesPath);
                try{
                    Map<TopocentricFrame, TimeIntervalArray> accesses = coverageAnalysis.getAccesses(fieldOfView, inclination, altitude, numSats, numPlanes, raanLabel);
                }
                catch (Exception ex){
                    ex.printStackTrace();
                }
            }
        }

        System.exit(0);
    }


    public static void createDir(String path_str){
        Path path = Paths.get(path_str);
        try {
            if (!Files.exists(path)) {
                Files.createDirectories(path);
                System.out.println("Directory created successfully");
            } else {
                System.out.println("Directory already exists");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }





}
