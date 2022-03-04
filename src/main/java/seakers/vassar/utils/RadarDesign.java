package seakers.vassar.utils;

public class RadarDesign {
    private double antennaMass;
    private double electronicsMass;
    private double avgPower;
    private double maxPower;
    private double dataRate;

    public RadarDesign(double dAz, double dEl, double pixelResAt, double numLooks) {
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
        double antennaMaterialMass = depth * area * 0.1514;
        antennaMass = feedMass + antennaMaterialMass;
        maxPower = 1000;
        electronicsMass = 21.253 * Math.log(maxPower) - 50.093;

        // dataRate
        double swath = 25;
        double pixelResAcrossKm = pixelResAt * 0.001;
        int bitsPerPixel = 8;
        double pixelResAcrossSAR = pixelResAcrossKm * Math.sqrt(numLooks);
        double numX = swath/pixelResAcrossSAR;
        double rb_bps = numX * bitsPerPixel;
        dataRate = rb_bps/1e6;

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
