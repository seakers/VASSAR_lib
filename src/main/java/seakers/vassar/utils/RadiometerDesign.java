package seakers.vassar.utils;

public class RadiometerDesign {
    private double antennaMass;
    private double electronicsMass;
    private double avgPower;
    private double maxPower;
    private double dataRate;

    public RadiometerDesign(double dAz, double dEl, double pixelResAt, double altitude) {
        double maxDim = Math.max(dAz, dEl);
        double feedLength = 3.3/30 * maxDim;
        double feedThickness = 0.05;
        double feedWidth = feedLength / 3;
        double volume = feedLength * feedThickness * feedWidth;
        double density = 590;
        double feedMass = volume * density;
        double aperture = maxDim;
        double depth = aperture / (0.45*16);
        double area = Math.PI * Math.pow((aperture / 2), 2);
        double antennaDensity = 0.151;
        double antennaMaterialMass = antennaDensity * area * depth;
        antennaMass = feedMass + antennaMaterialMass;
        maxPower = 1000;
        electronicsMass = 25*Math.max(dAz,dEl);

        // dataRate
        if(pixelResAt == 0.0) {
            dataRate = 0.0;
        } else {
            int bitsPerPixel = 8;
            double re = 6378e3; // m
            double orbSpeed = Math.sqrt(3.986e14/(re+altitude*1e3));
            double gndSpeed = orbSpeed * (re/(re+altitude*1e3));
            double numX = 1;
            double rb_bps = numX * bitsPerPixel / (pixelResAt / gndSpeed);
            dataRate = rb_bps/1e6;
        }
    }

    public double getAntennaMass() {
        return antennaMass;
    }

    public double getElectronicsMass() {
        return electronicsMass;
    }

    public double getAvgPower() {
        return avgPower;
    }

    public double getDataRate() {
        return dataRate;
    }
}
