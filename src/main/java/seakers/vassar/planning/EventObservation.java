package seakers.vassar.planning;

import org.orekit.bodies.GeodeticPoint;

public class EventObservation {
    private GeodeticPoint location;
    private double obsTime;
    private double value;

    public EventObservation(GeodeticPoint location, double obsTime, double value) {
        this.location = location;
        this.obsTime = obsTime;
        this.value = 0;
    }

    public GeodeticPoint getLocation() { return location; }
    public double getObsTime() { return obsTime; }

    public double getValue() { return value; }
}
