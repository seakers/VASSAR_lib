package seakers.vassar.planning;

import org.orekit.bodies.GeodeticPoint;
import org.orekit.time.AbsoluteDate;
import seakers.orekit.coverage.access.TimeIntervalArray;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class EqualSimulator {
    public Map<String, ArrayList<Observation>> observationEvents;
    public Map<String, ArrayList<SatelliteAction>> currentPlans;
    public Map<String, ArrayList<SatelliteAction>> actionsTaken;
    public Map<String, ArrayList<SatelliteAction>> naiveActionsTaken;
    public Map<String, Map<GeodeticPoint, Double>> localRewardGrids;
    public Map<String, Double> rewardDownlinked;
    public Map<String, Double> naiveRewardDownlinked;
    public Map<GeodeticPoint,Double> globalRewardGrid;
    public Map<GeodeticPoint,Double> naiveGlobalRewardGrid;
    public Map<GeodeticPoint,Double> centralRewardGrid;
    public Map<String, Map<String,String>> crosslinkInfo;
    public ArrayList<Map<GeodeticPoint,GeophysicalEvent>> naiveGlobalRewardGridUpdates;
    public Map<String, SatelliteState> currentStates;
    public double chlReward;
    boolean debug;
    public AbsoluteDate startDate;
    public AbsoluteDate endDate;
    public double endTime;
    private Map<String, Double> results;
    public Map<String,Map<GeodeticPoint,ArrayList<TimeIntervalArray>>> gpAccesses;

    public EqualSimulator(Map<String,String> settings, AbsoluteDate startDate, AbsoluteDate endDate, Map<GeodeticPoint,Double> inputRewardGrid, Map<String, ArrayList<Observation>> observations) {
        long start = System.nanoTime();
        observationEvents = observations;
        initializeRewardGrid(inputRewardGrid);
        debug = true;
        this.startDate = startDate;
        this.endDate = endDate;
        endTime = endDate.durationFrom(startDate);
        results = new HashMap<>();
        localRewardGrids = new HashMap<>();
        actionsTaken = new HashMap<>();
        naiveActionsTaken = new HashMap<>();
        currentPlans = new HashMap<>();
        currentStates = new HashMap<>();
        rewardDownlinked = new HashMap<>();
        naiveRewardDownlinked = new HashMap<>();
        gpAccesses = new HashMap<>();
        naiveGlobalRewardGridUpdates = new ArrayList<>();
        ArrayList<String> satList = new ArrayList<>(observationEvents.keySet());
        for (String sat : satList) {
            Map<GeodeticPoint,ArrayList<TimeIntervalArray>> gpAccessesPerSat = new HashMap<>();
            for (GeodeticPoint gp : globalRewardGrid.keySet()) {
                ArrayList<TimeIntervalArray> tias = new ArrayList<>();
                gpAccessesPerSat.put(gp,tias);
            }
            gpAccesses.put(sat,gpAccessesPerSat);
        }
        // Create initial plans
        for (String sat : satList) {
            localRewardGrids.put(sat,globalRewardGrid);
            actionsTaken.put(sat,new ArrayList<>());
            SatelliteState satelliteState = new SatelliteState(0,0, new ArrayList<>(),70.0,0.0,0.0,0.0);
            currentStates.put(sat,satelliteState);
            long planStart = System.nanoTime();
            makePlan(sat,settings);
            //System.out.println("Plan for "+sat+": "+currentPlans.get(sat));
            long planEnd = System.nanoTime();
            System.out.printf("Took %.4f sec\n", (planEnd - planStart) / Math.pow(10, 9));
            rewardDownlinked.put(sat,0.0);
            System.out.println("Done with initial plan for "+sat);
        }
        double currentTime = 0.0;

        for (String sat : satList) {
            NaivePlanExecutor planExec = new NaivePlanExecutor(currentStates.get(sat),currentTime,endTime,currentPlans.get(sat), sat, settings);
            naiveActionsTaken.put(sat,planExec.getActionsTaken());
        }
        System.out.println("Done!");
        computeStatistics("Non-reactive",naiveActionsTaken);
        long end = System.nanoTime();
        System.out.printf("Took %.4f sec\n", (end - start) / Math.pow(10, 9));
    }

    public void computeStatistics(String flag, Map<String, ArrayList<SatelliteAction>> takenActions) {
        for (String sat : takenActions.keySet()) {
            Map<GeodeticPoint,ArrayList<TimeIntervalArray>> gpAccessesPerSat = gpAccesses.get(sat);
            for (SatelliteAction sa : takenActions.get(sat)) {
                switch (sa.getActionType()) {
                    case "charge":
                        break;
                    case "imaging":
                        GeodeticPoint gp = sa.getLocation();
                        ArrayList<GeodeticPoint> nearbyGPs = getPointsInFOV(gp,new ArrayList<>(globalRewardGrid.keySet()));
                        for (GeodeticPoint nearbyGP : nearbyGPs) {
                            TimeIntervalArray tia = new TimeIntervalArray(startDate,endDate);
                            tia.addRiseTime(sa.gettStart());
                            if(sa.gettEnd() > endDate.durationFrom(startDate)) {
                                tia.addSetTime(endDate.durationFrom(startDate));
                            } else {
                                tia.addSetTime(sa.gettEnd());
                            }
                            ArrayList<TimeIntervalArray> tias = gpAccessesPerSat.get(nearbyGP);
                            tias.add(tia);
                            gpAccessesPerSat.put(nearbyGP,tias);
                        }
                        break;
                    case "downlink":
                        break;
                }
            }
            for (GeodeticPoint gp : gpAccessesPerSat.keySet()) {
                ArrayList<TimeIntervalArray> tias = gpAccessesPerSat.get(gp);
                ArrayList<TimeIntervalArray> newtias = new ArrayList<>();
                if (!tias.isEmpty()) {
                    newtias.add(tias.get(0));
                    for (int i = 1; i < tias.size(); i++) {
                        if (tias.get(i).getRiseSetTimes().get(0).getTime() > tias.get(i - 1).getRiseSetTimes().get(1).getTime() + 30 * 60) {
                            newtias.add(tias.get(i));
                        }
                    }
                }
                gpAccessesPerSat.put(gp,newtias);
            }
            gpAccesses.put(sat,gpAccessesPerSat);
        }
    }

    public void initializeRewardGrid(Map<GeodeticPoint,Double> inputGrid) {
            globalRewardGrid = inputGrid;
            globalRewardGrid.replaceAll((g, v) -> 1.0);
            naiveGlobalRewardGrid = new HashMap<>(globalRewardGrid);
            centralRewardGrid = new HashMap<>(globalRewardGrid);
    }

    public void makePlan(String sat, Map<String,String> settings) {
        if (settings.get("planner").equals("greedy_coverage")) {
            GreedyCoveragePlanner greedyCoveragePlanner = new GreedyCoveragePlanner(observationEvents.get(sat), localRewardGrids.get(sat), currentStates.get(sat), settings);
            currentPlans.put(sat, greedyCoveragePlanner.getResults());
        } else {
            System.out.println("Error in makePlan");
        }
    }

    public Map<String, Double> getResults() { return results; }

    public Map<String,Map<GeodeticPoint,ArrayList<TimeIntervalArray>>> getPlannerAccesses() {
        return gpAccesses;
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
}
