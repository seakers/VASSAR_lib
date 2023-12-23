package seakers.vassar.utils;

public class SpectrometerDesign {
    private double mass;
    private double power;
    private double dataRate;

    private double spectralResolution;

    private double spatialResolution;
    private double spectralRange;

    private double vnirSNR;
    private double swirSNR;

    private double agility;

    private boolean tir;
    private double swath;

    private double focalLength;
    private double aperture;

    public SpectrometerDesign(double alt, int numVNIRSpec, int numSWIRSpec, boolean tir, double focalLength, double FOV, double aperture, double vnirPixelSize, double swirPixelSize, double agility) {
        double vnirSpectralResolution = (1000.0-380.0)/numVNIRSpec;
        double maxWavelength = 2500e-9;
        double swirSpectralResolution = 0;
        this.agility = agility;
        if(numSWIRSpec > 0) {
            spectralRange = 2501.0-379.0;
            swirSpectralResolution = (2500.0-1000.0)/numSWIRSpec;
            spectralResolution = Math.max(vnirSpectralResolution,swirSpectralResolution);
        } else {
            spectralRange = 1001.0-379.0;
            numSWIRSpec = 0;
            spectralResolution = vnirSpectralResolution;
            maxWavelength = 1000e-9;
        }
         // nm
        double orbitalVelocity = Math.sqrt(398600 / (6378 + alt)); // km/s
        double groundVelocity = orbitalVelocity * 6378 / (6378 + alt); // km/s
        int bitsPerPixel = 16;
        double pixelSize = Math.max(vnirPixelSize,swirPixelSize);
        double IFOV = pixelSize / focalLength;
        double gsd = IFOV * alt * 1000;
        double diffractionLimitedResolution = 1.22 * alt * 1000 * maxWavelength / aperture;
        spatialResolution = Math.max(diffractionLimitedResolution, gsd);
        double imagingRate = groundVelocity*1000 / gsd;
        double numSpatialPixels = Math.floor(Math.toRadians(FOV)/IFOV);
        swath = gsd * numSpatialPixels / 1000;
        power = 2.69e-5*(numVNIRSpec+numSWIRSpec)*numSpatialPixels + 1.14; // Watts, based on regression
        dataRate = (numVNIRSpec+numSWIRSpec) * numSpatialPixels * bitsPerPixel * imagingRate / 1e6; // Mbps
        //System.out.println("Datarate: "+dataRate);
        double lensMass = Math.exp(4.365*focalLength+2.009*aperture - 2.447);
        double vnirSensorMass = 0.363 + 0.0014e-3 * numSpatialPixels * numVNIRSpec;
        double swirSensorMass = 0.618 + 0.0226e-3 * numSpatialPixels * numSWIRSpec;
        double tirSensorMass = 0.0;
        if(tir) {
            tirSensorMass = 10.5;
            power = power + 200;
        }
        this.tir = tir;

        // Calculate SNR
        double vnirL = 0.1; // approximate, at 600 nm
        double swirL = 0.02; // approximate, at 1600 nm
        double vnirLambda = 600e-9;
        double swirLambda = 1600e-9;
        double c = 3e8;
        double h = 6.63e-34;
        double eff = 0.8;
        double vnirSignal = vnirLambda*vnirL*Math.PI*Math.pow(aperture,2)*Math.pow(vnirPixelSize,2)*(1/imagingRate)*eff*vnirSpectralResolution/(4*h*c*Math.pow(focalLength,2));
        double swirSignal = swirLambda*swirL*Math.PI*Math.pow(aperture,2)*Math.pow(swirPixelSize,2)*(1/imagingRate)*eff*swirSpectralResolution/(4*h*c*Math.pow(focalLength,2));
        double vnirNoise = Math.sqrt(Math.pow(Math.sqrt(vnirSignal),2)+10000);
        double swirNoise = Math.sqrt(Math.pow(Math.sqrt(swirSignal),2)+10000);
        vnirSNR = vnirSignal/vnirNoise;
        swirSNR = swirSignal/swirNoise;
        //System.out.println("VNIR SNR: "+vnirSNR);
        //System.out.println("SWIR SNR: "+swirSNR);
        mass = lensMass + vnirSensorMass + swirSensorMass + tirSensorMass;
        this.focalLength = focalLength;
        this.aperture = aperture;
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

    public double getMaxDim() {
        return Math.max(focalLength,aperture);
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
    public double getVNIRSNR() { return vnirSNR; }
    public double getSWIRSNR() { return swirSNR; }

    public double getAgility() { return agility; }
}
