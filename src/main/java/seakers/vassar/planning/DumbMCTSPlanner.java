package seakers.vassar.planning;

import org.orekit.bodies.GeodeticPoint;
import seakers.orekit.coverage.access.TimeIntervalArray;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class DumbMCTSPlanner {
    private ArrayList<SatelliteAction> results;
    private ArrayList<SatelliteState> V;
    private Map<Key,Integer> N;
    private Map<Key,Double> Q;
    private double c;
    private boolean downlinkEnabled;
    private boolean crosslinkEnabled;
    private ArrayList<Observation> sortedObservations;
    private TimeIntervalArray downlinks;
    private Map<String, TimeIntervalArray> crosslinks;
    private Map<String,String> priorityInfo;
    private double gamma;
    private int dSolveInit;
    private Map<GeodeticPoint,Double> rewardGrid;
    private int actionSpaceSize;
    private int nMaxSim;
    private Map<String,String> settings;

//    public MCTSPlanner(ArrayList<Observation> sortedObservations, TimeIntervalArray downlinks, Map<String,TimeIntervalArray> crosslinks, Map<GeodeticPoint,Double> rewardGrid, SatelliteState initialState, Map<String,String> priorityInfo) {
//        this.sortedObservations = sortedObservations;
//        this.downlinks = downlinks;
//        this.crosslinks = crosslinks;
//        this.rewardGrid = rewardGrid;
//        this.gamma = 0.999;
//        this.priorityInfo = priorityInfo;
//        this.dSolveInit = 10;
//        this.actionSpaceSize = 10;
//        this.nMaxSim = 50;
//        this.crosslinkEnabled = true;
//        this.downlinkEnabled = false;
//        this.c = 3;
//        this.Q = new HashMap<>();
//        this.N = new HashMap<>();
//        this.V = new ArrayList<>();
//        ArrayList<StateAction> stateActions = monteCarloTreeSearch(initialState);
//        ArrayList<SatelliteAction> observations = new ArrayList<>();
//        for (StateAction stateAction : stateActions) {
//            observations.add(stateAction.getA());
//        }
//        results = observations;
//    }

    public DumbMCTSPlanner(ArrayList<Observation> sortedObservations, TimeIntervalArray downlinks, Map<GeodeticPoint,Double> rewardGrid, SatelliteState initialState, Map<String,String> priorityInfo, Map<String, String> settings) {
        this.sortedObservations = sortedObservations;
        this.downlinks = downlinks;
        this.rewardGrid = rewardGrid;
        this.settings = settings;
        this.gamma = 0.995;
        this.priorityInfo = new HashMap<>(priorityInfo);
        this.dSolveInit = 10;
        this.actionSpaceSize = 5;
        this.nMaxSim = 50;
        this.crosslinkEnabled = Boolean.parseBoolean(settings.get("crosslinkEnabled"));
        this.downlinkEnabled = Boolean.parseBoolean(settings.get("downlinkEnabled"));
        this.c = 3;
        this.Q = new HashMap<>();
        this.N = new HashMap<>();
        this.V = new ArrayList<>();
        ArrayList<StateAction> stateActions = monteCarloTreeSearch(initialState);
        ArrayList<SatelliteAction> observations = new ArrayList<>();
        for (StateAction stateAction : stateActions) {
            observations.add(stateAction.getA());
        }
        results = observations;
    }

    public ArrayList<StateAction> monteCarloTreeSearch(SatelliteState initialState) {
        ArrayList<StateAction> resultList = new ArrayList<>();
        SatelliteState s = initialState;
        boolean moreActions = true;
        while(moreActions) {
            for (int n = 0; n < nMaxSim; n++) {
                simulate(s,dSolveInit);
            }
            double max = 0.0;
            SatelliteAction bestAction = null;
            for (Key sa : Q.keySet()) {
                if(sa.getS().equals(s)) {
                    double value = Q.get(sa);
                    if(value >= max) {
                        max = value;
                        bestAction = sa.getA();

                        //System.out.println(bestAction.getReward());
                    }
                }
            }
            if(bestAction==null) {
                break;
            }
            StateAction stateAction = new StateAction(s,bestAction);
            s = transitionFunction(s,bestAction);
            //System.out.println(s.getT());
            resultList.add(stateAction);
            moreActions = !getActionSpace(s).isEmpty();
            Q = new HashMap<>();
            N = new HashMap<>();
        }
        return resultList;
    }



    public double simulate(SatelliteState s, int d) {
        if(d == 0) {
            return 0;
        }
        if(!V.contains(s)) {
            ArrayList<SatelliteAction> actionSpace = getActionSpace(s);
            for (SatelliteAction a : actionSpace) {
                Key sa = new Key(s,a);
                N.put(sa,1);
                Q.put(sa,0.0);
            }
            V.add(s);
            return rollout(s,actionSpace,dSolveInit);
        }
        double max = 0.0;
        SatelliteAction bestAction = null;
        int nSum = 0;
        for(Key sa1 : N.keySet()) {
            if(sa1.getS().equals(s)) {
                nSum = nSum + N.get(sa1);
            }
        }
        for (Key sa : Q.keySet()) {
            if(sa.getS().equals(s)) {
                double value = Q.get(sa) + c*Math.sqrt(Math.log10(nSum)/N.get(sa));
                if(value > max) {
                    max = value;
                    bestAction = sa.getA();
                }
            }
        }
        Key key = new Key(s,bestAction);
        if(bestAction == null) {
            return 0;
        }
        SatelliteState newSatelliteState = transitionFunction(s,bestAction);
        double r = rewardFunction(s,bestAction);
        double q = r + Math.pow(gamma,bestAction.gettStart()-s.getT()) * simulate(newSatelliteState, d-1);
        N.put(key,N.get(key)+1);
        Q.put(key,Q.get(key)+(q-Q.get(key))/N.get(key));
        return q;
    }

    public double rollout(SatelliteState s, ArrayList<SatelliteAction> actionSpace, int d) {
        if(d == 0) {
            return 0;
        }
        SatelliteAction selectedAction = null;
        ArrayList<SatelliteAction> downlinkActions = new ArrayList<>();
        if(downlinkEnabled) {
            for (SatelliteAction a : actionSpace) {
                if(a.getActionType().equals("downlink")) {
                    downlinkActions.add(a);
                }
            }
        }
        if(downlinkActions.size()!=0) {
            Random random = new Random();
            selectedAction = downlinkActions.get(random.nextInt(downlinkActions.size()));
        }
        if(selectedAction==null) {
            ArrayList<SatelliteAction> observationActions = new ArrayList<>();
            for(SatelliteAction a : actionSpace) {
                if(a.getActionType().equals("imaging")){
                    observationActions.add(a);
                }
            }
            if(observationActions.isEmpty()) {
                return 0;
            }
            Random random = new Random();
            selectedAction = observationActions.get(random.nextInt(observationActions.size()));
        }
        double reward = rewardFunction(s,selectedAction);
        SatelliteState newSatelliteState = transitionFunction(s,selectedAction);
        return reward + Math.pow(gamma,selectedAction.gettStart()-s.getT())*rollout(newSatelliteState, getActionSpace(newSatelliteState),d-1);
    }

    public double rewardFunction(SatelliteState s, SatelliteAction a){
        double score = 0.0;
        switch (a.getActionType()) {
            case "imaging":
                score = 1.0;
                break;
            case "downlink":
                score = s.getStoredImageReward();
                break;
        }
        return score;
    }

    public SatelliteState transitionFunction(SatelliteState s, SatelliteAction a) {
        double t = a.gettEnd();
        double tPrevious = s.getT();
        ArrayList<SatelliteAction> history = new ArrayList<>(s.getHistory());
        history.add(a);
        double storedImageReward = s.getStoredImageReward();
        double batteryCharge = s.getBatteryCharge();
        double dataStored = s.getDataStored();
        double currentAngle = s.getCurrentAngle();
        switch (a.getActionType()) {
            case "charge":
                batteryCharge = batteryCharge + (a.gettEnd() - s.getT()) * Double.parseDouble(settings.get("chargePower")) / 3600; // Wh
                break;
            case "imaging":
                currentAngle = a.getAngle();
                batteryCharge = batteryCharge + (a.gettStart()-s.getT())*Double.parseDouble(settings.get("chargePower")) / 3600;
                batteryCharge = batteryCharge - (a.gettEnd()-a.gettStart())*Double.parseDouble(settings.get("cameraOnPower")) / 3600;
                storedImageReward = storedImageReward + a.getReward();
                break;
            // insert reward grid update here
            case "downlink":
                dataStored = dataStored - (a.gettEnd() - a.gettStart()) * Double.parseDouble(settings.get("downlinkSpeedMbps"));
                batteryCharge = batteryCharge + (a.gettStart()-s.getT())*Double.parseDouble(settings.get("chargePower")) / 3600;
                batteryCharge = batteryCharge - (a.gettEnd()-a.gettStart())*Double.parseDouble(settings.get("downlinkOnPower")) / 3600;
                if (dataStored < 0) {
                    dataStored = 0;
                }
                storedImageReward = 0.0;
                break;
        }
        return new SatelliteState(t,tPrevious,history,batteryCharge,dataStored,currentAngle,storedImageReward);
    }

    public ArrayList<SatelliteAction> getActionSpace(SatelliteState s) {
        double currentTime = s.getT();
        ArrayList<SatelliteAction> possibleActions = new ArrayList<>();
        ArrayList<Observation> currentObservations = new ArrayList<>();
        for (Observation obs : sortedObservations) {
            if(obs.getObservationStart() > currentTime && currentObservations.size() < actionSpaceSize) {
                SatelliteAction obsAction = new SatelliteAction(obs.getObservationStart(),obs.getObservationEnd(),obs.getObservationPoint(),"imaging",rewardGrid.get(obs.getObservationPoint()),obs.getObservationAngle());
                if(canSlew(s.getCurrentAngle(),obs.getObservationAngle(),currentTime,obs.getObservationStart())) {
                    possibleActions.add(obsAction);
                    currentObservations.add(obs);
                }
            }
        }
        ArrayList<SatelliteAction> downlinkActions = new ArrayList<>();
        if(downlinkEnabled) {
            for (int i = 0; i < downlinks.getRiseAndSetTimesList().length; i = i + 2) {
                if (downlinks.getRiseAndSetTimesList()[i] > currentTime && downlinkActions.size() < actionSpaceSize) {
                    SatelliteAction downlinkAction = new SatelliteAction(downlinks.getRiseAndSetTimesList()[i], downlinks.getRiseAndSetTimesList()[i+1], null, "downlink");
                    possibleActions.add(downlinkAction);
                    downlinkActions.add(downlinkAction);
                } else if (downlinks.getRiseAndSetTimesList()[i] < currentTime && downlinks.getRiseAndSetTimesList()[i + 1] > currentTime && downlinkActions.size() < actionSpaceSize) {
                    SatelliteAction downlinkAction = new SatelliteAction(currentTime, downlinks.getRiseAndSetTimesList()[i + 1], null, "downlink");
                    possibleActions.add(downlinkAction);
                    downlinkActions.add(downlinkAction);
                }
            }
        }
        possibleActions.sort(new SatelliteAction.TimeComparator());
        if(possibleActions.size() < actionSpaceSize) {
            return possibleActions;
        } else {
            return new ArrayList<>(possibleActions.subList(0, actionSpaceSize));
        }
    }

    public boolean canSlew(double angle1, double angle2, double time1, double time2){
        double slewTorque = 4*Math.abs(angle2-angle1)*0.05/Math.pow(Math.abs(time2-time1),2);
        double maxTorque = Double.parseDouble(settings.get("maxTorque"));
        return !(slewTorque > maxTorque);
    }
    
    public ArrayList<SatelliteAction> getResults() {
        return results;
    }
}

