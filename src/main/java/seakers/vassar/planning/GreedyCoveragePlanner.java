package seakers.vassar.planning;

import org.orekit.bodies.GeodeticPoint;

import java.util.*;

public class GreedyCoveragePlanner {
    private ArrayList<SatelliteAction> results;
    private boolean resources;
    private ArrayList<Observation> sortedObservations;
    private Map<GeodeticPoint,Double> rewardGrid;
    private Map<String,String> settings;

    public GreedyCoveragePlanner(ArrayList<Observation> inputObservations, Map<GeodeticPoint,Double> rewardGrid, SatelliteState initialState, Map<String, String> settings) {
        this.sortedObservations = sortObservations(inputObservations);
        this.rewardGrid = rewardGrid;
        this.resources = Boolean.parseBoolean(settings.get("resources"));
        this.settings = settings;
        ArrayList<StateAction> stateActions = greedyPlan(initialState);
        ArrayList<SatelliteAction> observations = new ArrayList<>();
        for (StateAction stateAction : stateActions) {
            observations.add(stateAction.getA());
        }
        results = observations;
    }

    public ArrayList<Observation> sortObservations(ArrayList<Observation> observations) {
        observations.sort(new sortByRiseTime());
        return observations;
    }

    class sortByRiseTime implements Comparator<Observation>
    {
        // Used for sorting in ascending order of
        // roll number
        public int compare(Observation a, Observation b)
        {
            return (int) (a.getObservationStart() - b.getObservationStart());
        }
    }
    public ArrayList<StateAction> greedyPlan(SatelliteState initialState) {
        ArrayList<StateAction> resultList = new ArrayList<>();
        boolean moreActions = true;
        SatelliteState s = initialState;
        while(moreActions) {
            SatelliteAction bestAction = selectAction(s);
            if(bestAction==null) {
                break;
            }
            StateAction stateAction = new StateAction(s,bestAction);
            s = transitionFunction(s,bestAction);
            resultList.add(stateAction);
            moreActions = !getActionSpace(s).isEmpty();
        }
        return resultList;
    }

    ArrayList<GeodeticPoint> getPointsInFOV(GeodeticPoint location, ArrayList<GeodeticPoint> groundPoints) {
        ArrayList<GeodeticPoint> pointsInFOV = new ArrayList<>();
        for (GeodeticPoint gp : groundPoints) {
            double distance = Math.sqrt(Math.pow(location.getLatitude()-gp.getLatitude(),2)+Math.pow(location.getLongitude()-gp.getLongitude(),2)); // in radians latitude
            double radius = 577; // kilometers for 500 km orbit height, 30 deg half angle, NOT spherical trig TODO
            if(distance * 111.1 * 180 / Math.PI < radius) {
                pointsInFOV.add(gp);
            }
        }
        return pointsInFOV;
    }
    public SatelliteState transitionFunction(SatelliteState s, SatelliteAction a) {
        double t = a.gettEnd();
        double tPrevious = s.getT();
        //ArrayList<SatelliteAction> history = new ArrayList<>(s.getHistory());
        //history.add(a);
        double storedImageReward = s.getStoredImageReward();
        double batteryCharge = s.getBatteryCharge();
        double dataStored = s.getDataStored();
        double currentAngle = s.getCurrentAngle();
        switch (a.getActionType()) {
            case "charge":
                batteryCharge = batteryCharge + (a.gettEnd()-s.getT())*Double.parseDouble(settings.get("chargePower")) / 3600;
                break;
            case "imaging":
                currentAngle = a.getAngle();
                batteryCharge = batteryCharge + (a.gettStart()-s.getT())*Double.parseDouble(settings.get("chargePower")) / 3600;
                batteryCharge = batteryCharge - (a.gettEnd()-a.gettStart())*Double.parseDouble(settings.get("cameraOnPower")) / 3600;
                dataStored += 1.0; // 1 Mbps per picture
                break;
            case "downlink":
                dataStored = dataStored - (a.gettEnd() - a.gettStart()) * Double.parseDouble(settings.get("downlinkSpeedMbps"));
                batteryCharge = batteryCharge + (a.gettStart()-s.getT())*Double.parseDouble(settings.get("chargePower")) / 3600;
                batteryCharge = batteryCharge - (a.gettEnd()-a.gettStart())*Double.parseDouble(settings.get("downlinkOnPower")) / 3600;
                if (dataStored < 0) {
                    dataStored = 0;
                }
                break;
        }
        return new SatelliteState(t,tPrevious,new ArrayList<>(),batteryCharge,dataStored,currentAngle,storedImageReward);
    }

    public SatelliteAction selectAction(SatelliteState s) {
        ArrayList<SatelliteAction> possibleActions = getActionSpace(s);
        SatelliteAction bestAction = null;
        //System.out.println(s.getBatteryCharge());
        if(s.getBatteryCharge() < 15 && resources) {
            bestAction = new SatelliteAction(s.getT(),s.getT()+60.0,null,"charge");
            return bestAction;
        }
        outerloop:
        for (SatelliteAction a : possibleActions) {
            switch(a.getActionType()) {
                case("downlink"):
                    if(s.getDataStored() > 90 && resources) {
                        bestAction = a;
                        break outerloop;
                    }
                    if(!resources) {
                        bestAction = a;
                        break outerloop;
                    }
                    break;
                case("imaging"):
                    bestAction = a;
                    break outerloop;
            }

        }

        return bestAction;
    }

    public ArrayList<SatelliteAction> getActionSpace(SatelliteState s) {
        double currentTime = s.getT();
        ArrayList<SatelliteAction> possibleActions = new ArrayList<>();
        for (Observation obs : sortedObservations) {
            if(obs.getObservationStart() > currentTime) {
                SatelliteAction obsAction = new SatelliteAction(obs.getObservationStart(),obs.getObservationStart()+0.01,obs.getObservationPoint(),"imaging",rewardGrid.get(obs.getObservationPoint()),obs.getObservationAngle());
                if(canSlew(s.getCurrentAngle(),obs.getObservationAngle(),currentTime,obs.getObservationStart())) {
                    possibleActions.add(obsAction);
                    break;
                }
            }
        }
        possibleActions.sort(new SatelliteAction.TimeComparator());
        return possibleActions;
    }

    public boolean canSlew(double angle1, double angle2, double time1, double time2){
//        double slewTorque = 4*Math.abs(angle2-angle1)*0.05/Math.pow(Math.abs(time2-time1),2);
//        double maxTorque = Double.parseDouble(settings.get("maxTorque"));
        double maxSlewRate = Double.parseDouble(settings.get("maxSlewRate"));
        double slewRate = Math.abs(angle1-angle2)/Math.abs(time1-time2);
        return !(slewRate > maxSlewRate);
    }

    public ArrayList<SatelliteAction> getResults() {
        return results;
    }
}


