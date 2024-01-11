import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.XGrantsProblemFixedAgility;
import seakers.vassar.moea.XGrantsProgressListener;
import seakers.vassar.utils.SpectrometerDesign;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class SpectrometerAnalysis {
    public static String convertToCSV(String[] data) {
        return Stream.of(data)
                .collect(Collectors.joining(","));
    }
    public static void main(String[] args) throws FileNotFoundException {
        Double[] altitudes = {400.0,500.0,600.0,700.0,800.0};
        int numVNIRSpec = 150;
        int numSWIRSpec = 300;
        boolean tir = true;
        Double[] focalLengths = {0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1.0, 2.0};
        Double[] fovs = {0.1, 0.2, 0.5, 1.0, 2.0, 5.0};
        Double[] apertures = {0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1.0, 2.0};
        Double[] vnirPixelSizes = {1e-6,2e-6,5e-6,10e-6,20e-6};
        Double[] swirPixelSizes = {5e-6,10e-6,20e-6,50e-6};
        double agility = 1.0;
        List<String[]> specLines = new ArrayList<>();
        specLines.add(new String[]
                {"altitude","mass","vnir_snr","spatial_res"});
        for (Double alt : altitudes) {
            for (Double focalLength : focalLengths) {
                for (Double FOV: fovs) {
                    for (Double aperture : apertures) {
                        for (Double pixelSizeVNIR : vnirPixelSizes) {
                            for (Double pixelSizeSWIR : swirPixelSizes) {
                                SpectrometerDesign sd = new SpectrometerDesign(alt,numVNIRSpec,numSWIRSpec,tir,focalLength,FOV,aperture,pixelSizeVNIR,pixelSizeSWIR,agility);
                                if (alt >= 700 && sd.getSpatialResolution() <= 10 && sd.getVNIRSNR() >= 600 && sd.getSWIRSNR() > 250 && sd.getSwath() > 10 && sd.getMass() < 100) {
                                    System.out.println(alt);
                                    System.out.println(sd.getSpatialResolution());
                                    System.out.println(sd.getMass());
                                    System.out.println(focalLength);
                                    System.out.println(aperture);
                                    System.out.println(sd.getSpectralResolution());
                                    System.out.println("Eureka!");
                                }
                                specLines.add(new String[]
                                        {Double.toString(alt),Double.toString(sd.getMass()),Double.toString(sd.getVNIRSNR()),Double.toString(sd.getSpatialResolution())});
                            }
                        }
                    }
                }
            }
        }
        File csvOutputFile = new File("spectrometers.csv");
        try (PrintWriter pw = new PrintWriter(csvOutputFile)) {
                specLines.stream()
                .map(SpectrometerAnalysis::convertToCSV)
                .forEach(pw::println);
                }
        SpectrometerDesign sd = new SpectrometerDesign(850, 313, 324, true, 0.58, 2.1, 1.01, 10.7e-6, 18.6e-6, 0.07);
        System.out.println(sd.getSpatialResolution());
        System.out.println(sd.getMass());
        System.out.println("DONE");
        System.exit(0);
    }
}


