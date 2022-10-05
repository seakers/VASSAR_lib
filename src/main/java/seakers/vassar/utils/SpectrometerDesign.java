package seakers.vassar.utils;

public class SpectrometerDesign {
    private double mass;
    private double power;
    private double dataRate;

    private double spectralResolution;

    private double spatialResolution;
    private double spectralRange;
    private double swath;

    public SpectrometerDesign(double alt, int numSpec, double lowerSpec, double upperSpec, double focalLength, double FOV, double aperture) {
        spectralRange = upperSpec - lowerSpec; // nm
        spectralResolution = spectralRange/numSpec; // nm
        double pixelSize = 6E-6; // m
        double orbitalVelocity = Math.sqrt(398600 / (6378 + alt)); // km/s
        double groundVelocity = orbitalVelocity * 6378 / (6378 + alt); // km/s
        double groundPixelSize = pixelSize * alt / focalLength; // km
        double imagingRate = groundVelocity / groundPixelSize;
        System.out.println("imagingRate: "+imagingRate);
        int bitsPerPixel = 12;
        double IFOV = pixelSize / focalLength;
        spatialResolution = IFOV * alt * 1000;
        double diffractionLimitedResolution = 1.22 * alt * 1000 * 2500e-9 / aperture;
        if (diffractionLimitedResolution > spatialResolution) {
            spatialResolution = diffractionLimitedResolution;
        }
        double numSpatialPixels = Math.ceil(Math.toRadians(FOV)/IFOV);
        swath = spatialResolution * numSpatialPixels / 1000;
        power = numSpec * numSpatialPixels * 2e-7;
        dataRate = numSpec * numSpatialPixels * bitsPerPixel * imagingRate / 1e6; // Mbps
        System.out.println("Datarate: "+dataRate);
        double lensMass = focalLength * 10;
        double sensorMass = 1.509 + 1e-6 * numSpatialPixels * numSpec;
        //mass = 161.5 - 0.021 * groundPixelSize * 1000;
        mass = lensMass + sensorMass;
    }

    public double getMass() {
        return mass;
    }

    public double getPower() {
        return power;
    }

    public double getDataRate() {
        return dataRate;
    }

    public double getSpectralResolution() { return spectralResolution; }
    public double getSpatialResolution() { return spatialResolution; }
    public double getSpectralRange() { return spectralRange; }
    public double getSwath() { return swath; }
}
