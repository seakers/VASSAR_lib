package seakers.vassar.utils;

public class SpectrometerDesign {
    private double mass;
    private double power;
    private double dataRate;

    private double spectralResolution;

    private double spatialResolution;
    private double spectralRange;

    private boolean tir;
    private double swath;

    public SpectrometerDesign(double alt, int numVNIRSpec, int numSWIRSpec, boolean swir, boolean tir, double focalLength, double FOV, double aperture) {
        double vnirSpectralResolution = (1000.0-380.0)/numVNIRSpec;
        if(swir) {
            spectralRange = 2501.0-379.0;
            double swirSpectralResolution = (2500.0-1000.0)/numSWIRSpec;
            spectralResolution = Math.max(vnirSpectralResolution,swirSpectralResolution);
        } else {
            numSWIRSpec = 0;
            spectralResolution = vnirSpectralResolution;
        }
         // nm
        double pixelSize = 6E-6; // m
        double orbitalVelocity = Math.sqrt(398600 / (6378 + alt)); // km/s
        double groundVelocity = orbitalVelocity * 6378 / (6378 + alt); // km/s
        int bitsPerPixel = 12;
        double IFOV = pixelSize / focalLength;
        spatialResolution = IFOV * alt * 1000;
        double diffractionLimitedResolution = 1.22 * alt * 1000 * 2500e-9 / aperture;
        if (diffractionLimitedResolution > spatialResolution) {
            spatialResolution = diffractionLimitedResolution;
        }
        double imagingRate = groundVelocity*1000 / spatialResolution;
        double numSpatialPixels = Math.ceil(Math.toRadians(FOV)/IFOV);
        swath = spatialResolution * numSpatialPixels / 1000;
        power = (numVNIRSpec+numSWIRSpec) * numSpatialPixels * 2e-7; // based loosely on CCD power draw, refine using Teledyne website
        dataRate = (numVNIRSpec+numSWIRSpec) * numSpatialPixels * bitsPerPixel * imagingRate / 1e6; // Mbps
        System.out.println("Datarate: "+dataRate);
        double lensMass = focalLength * aperture * 10;
        double vnirSensorMass = 0.265 + 0.0026e-3 * numSpatialPixels * numVNIRSpec;
        double swirSensorMass = 0.618 + 0.0226e-3 * numSpatialPixels * numSWIRSpec;
        //mass = 161.5 - 0.021 * groundPixelSize * 1000;
        double tirSensorMass = 0.0;
        if(tir) {
            tirSensorMass = 10.5;
        }
        this.tir = tir;
        mass = lensMass + vnirSensorMass + swirSensorMass + tirSensorMass;
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
    public double getTir() {
        if(tir) {
            return 10.0;
        } else {
            return 0.1;
        }
    }
}
