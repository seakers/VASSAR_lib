package seakers.vassar.planning;

import org.orekit.bodies.GeodeticPoint;

public class GeophysicalEvent {
    private GeodeticPoint location;
    private double startTime;
    private double endTime;

    private double value;

    public GeophysicalEvent(GeodeticPoint location, double startTime, double endTime, double value) {
        this.location = location;
        this.startTime = startTime;
        this.endTime = endTime;
        this.value = 0;
    }

    public GeodeticPoint getLocation() { return location; }
    public double getStartTime() { return startTime; }

    public double getEndTime() { return endTime; }

    public double getValue() { return value; }
}
