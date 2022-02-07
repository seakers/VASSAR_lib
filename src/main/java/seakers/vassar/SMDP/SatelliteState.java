package seakers.vassar.SMDP;

import org.orekit.bodies.GeodeticPoint;

import java.util.ArrayList;

public class SatelliteState {
    private double t;
    private double tPrevious;
    private double angle;
    private ArrayList<GeodeticPoint> images;
    public SatelliteState() {
        this.t = 0;
        this.tPrevious = 0;
        this.angle = 0.0;
        this.images = new ArrayList<>();
    }
    public SatelliteState (double t, double tPrevious, double angle, ArrayList<GeodeticPoint> images) {
        this.t = t;
        this.tPrevious = tPrevious;
        this.angle = angle;
        this.images = images;
    }
    public double getT() { return t; }
    public double gettPrevious() { return t; }
    public double getAngle() { return angle; }
    public ArrayList<GeodeticPoint> getImages() { return images; }
}
