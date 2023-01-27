package seakers.vassar.planning;

import org.orekit.bodies.GeodeticPoint;

import java.util.ArrayList;

public class SatelliteState {
    private double t;
    private double tPrevious;
    private double batteryCharge;
    private double dataStored;
    private double currentAngle;
    private double storedImageReward;
    private ArrayList<SatelliteAction> actionHistory;
    private ArrayList<GeodeticPoint> images;
    private ArrayList<GeophysicalEvent> geophysicalEvents;
    private ArrayList<EventObservation> eventObservations;
    private ArrayList<String> crosslinkLog;
    private ArrayList<String> downlinkLog;
    public SatelliteState() {
        this.t = 0.0;
        this.tPrevious = 0.0;
        this.actionHistory = new ArrayList<>();
        this.batteryCharge = 30.0;
        this.dataStored = 0.0;
        this.currentAngle = 0.0;
        this.storedImageReward = 0.0;
    }
    public SatelliteState(double t, double tPrevious, ArrayList<GeodeticPoint> images) {
        this.t = t;
        this.tPrevious = tPrevious;
        this.images = images;
    }
    public SatelliteState(double t, double tPrevious, ArrayList<SatelliteAction> actionHistory, double batteryCharge, double dataStored, double currentAngle, double storedImageReward) {
        this.t = t;
        this.tPrevious = tPrevious;
        this.actionHistory = actionHistory;
        this.batteryCharge = batteryCharge;
        this.dataStored = dataStored;
        this.currentAngle = currentAngle;
        this.storedImageReward = storedImageReward;
    }
    public SatelliteState(double t, double tPrevious, ArrayList<SatelliteAction> actionHistory, double batteryCharge, double dataStored, double currentAngle, double storedImageReward, ArrayList<GeophysicalEvent> geophysicalEvents, ArrayList<String> crosslinkLog, ArrayList<String> downlinkLog) {
        this.t = t;
        this.tPrevious = tPrevious;
        this.actionHistory = actionHistory;
        this.batteryCharge = batteryCharge;
        this.dataStored = dataStored;
        this.currentAngle = currentAngle;
        this.storedImageReward = storedImageReward;
        this.geophysicalEvents = geophysicalEvents;
        this.crosslinkLog = crosslinkLog;
        this.downlinkLog = downlinkLog;
    }
    public SatelliteState(double t, double tPrevious, ArrayList<SatelliteAction> actionHistory, double batteryCharge, double dataStored, double currentAngle, double storedImageReward, ArrayList<GeophysicalEvent> geophysicalEvents, ArrayList<EventObservation> eventObservations, ArrayList<String> crosslinkLog, ArrayList<String> downlinkLog) {
        this.t = t;
        this.tPrevious = tPrevious;
        this.actionHistory = actionHistory;
        this.batteryCharge = batteryCharge;
        this.dataStored = dataStored;
        this.currentAngle = currentAngle;
        this.storedImageReward = storedImageReward;
        this.geophysicalEvents = geophysicalEvents;
        this.eventObservations = eventObservations;
        this.crosslinkLog = crosslinkLog;
        this.downlinkLog = downlinkLog;
    }
    public SatelliteState(SatelliteState another) {
        this.t = another.t;
        this.tPrevious = another.tPrevious;
        this.batteryCharge = another.batteryCharge;
        this.dataStored = another.dataStored;
        this.currentAngle = another.currentAngle;
        this.storedImageReward = another.storedImageReward;
        this.actionHistory = another.actionHistory;
        this.geophysicalEvents = another.geophysicalEvents;
        this.crosslinkLog = another.crosslinkLog;
        this.downlinkLog = another.downlinkLog;
    }

    public double getT() { return t; }
    public double gettPrevious() { return t; }
    public ArrayList<SatelliteAction> getHistory() { return actionHistory; }
    public ArrayList<GeodeticPoint> getImages() { return images; }
    public double getCurrentAngle() { return currentAngle; }
    public double getStoredImageReward() { return storedImageReward; }
    public double getDataStored() { return dataStored; }
    public double getBatteryCharge() { return batteryCharge; }
    public ArrayList<GeophysicalEvent> getGeophysicalEvents() { return geophysicalEvents; }
    public ArrayList<EventObservation> getEventObservations() { return eventObservations; }
    public ArrayList<String> getCrosslinkLog() { return crosslinkLog; }
    public ArrayList<String> getDownlinkLog() { return downlinkLog; }
}
