package seakers.vassar.planning;

import org.orekit.bodies.GeodeticPoint;
import org.orekit.data.DataProvidersManager;
import org.orekit.data.DirectoryCrawler;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.util.OrekitConfig;

import java.io.File;
import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class EqualSimulator {
    private String filepath;
    public Map<String, Map<String, TimeIntervalArray>> crosslinkEvents;
    public Map<String, TimeIntervalArray> downlinkEvents;
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

    private AbsoluteDate startDate;
    private AbsoluteDate endDate;
    public double chlReward;
    boolean debug;
    public double endTime;
    private Map<String, Double> results;
    public Map<String,Map<GeodeticPoint,ArrayList<TimeIntervalArray>>> gpAccesses;

    public EqualSimulator(Map<String,String> settings, String filepath, AbsoluteDate startDate, AbsoluteDate endDate, Map<GeodeticPoint,Double> inputRewardGrid, Map<String, ArrayList<Observation>> observations) {
        long start = System.nanoTime();
        this.filepath = filepath;
        observationEvents = observations;
        initializeRewardGrid(inputRewardGrid);
        debug = true;
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
        ArrayList<String> satList = new ArrayList<>(downlinkEvents.keySet());
        for (String sat : downlinkEvents.keySet()) {
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
            SatelliteState satelliteState = new SatelliteState(0,0, new ArrayList<>(),70.0,0.0,0.0,0.0, new ArrayList<>(),new ArrayList<>(),new ArrayList<>());
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
            updateNaiveGlobalRewardGrid(planExec.getRewardGridUpdates());
            naiveActionsTaken.put(sat,planExec.getActionsTaken());
        }
        System.out.println("Done!");
        computeStatistics("Non-reactive",naiveActionsTaken);
        long end = System.nanoTime();
        System.out.printf("Took %.4f sec\n", (end - start) / Math.pow(10, 9));
    }

    public void computeStatistics(String flag, Map<String, ArrayList<SatelliteAction>> takenActions) {
        for (String sat : downlinkEvents.keySet()) {
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
                            tia.addSetTime(sa.gettEnd());
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
    public void updateNaiveGlobalRewardGrid(Map<GeodeticPoint,GeophysicalEvent> updates) {
        for(GeodeticPoint gp : updates.keySet()) {
            naiveGlobalRewardGrid.put(gp,chlReward);
        }
        naiveGlobalRewardGridUpdates.add(updates);
    }

    public void initializeRewardGrid(Map<GeodeticPoint,Double> inputGrid) {
            globalRewardGrid = inputGrid;
            globalRewardGrid.replaceAll((g, v) -> 1.0);
            naiveGlobalRewardGrid = new HashMap<>(globalRewardGrid);
            centralRewardGrid = new HashMap<>(globalRewardGrid);
    }

    public void makePlan(String sat, Map<String,String> settings) {
        switch (settings.get("planner")) {
            case "ruleBased":
                RuleBasedPlanner ruleBasedPlanner = new RuleBasedPlanner(observationEvents.get(sat), downlinkEvents.get(sat), localRewardGrids.get(sat), currentStates.get(sat), crosslinkInfo.get(sat), settings);
                currentPlans.put(sat, ruleBasedPlanner.getResults());
                break;
            case "ruleBased_coverage":
                RuleBasedCoveragePlanner ruleBasedCoveragePlanner = new RuleBasedCoveragePlanner(observationEvents.get(sat), downlinkEvents.get(sat), localRewardGrids.get(sat), currentStates.get(sat), crosslinkInfo.get(sat), settings);
                currentPlans.put(sat, ruleBasedCoveragePlanner.getResults());
                break;
            case "greedy_coverage":
                GreedyCoveragePlanner greedyCoveragePlanner = new GreedyCoveragePlanner(observationEvents.get(sat), downlinkEvents.get(sat), localRewardGrids.get(sat), currentStates.get(sat), crosslinkInfo.get(sat), settings);
                currentPlans.put(sat, greedyCoveragePlanner.getResults());
                break;
            case "mcts":
                MCTSPlanner mctsPlanner = new MCTSPlanner(observationEvents.get(sat), downlinkEvents.get(sat), localRewardGrids.get(sat), currentStates.get(sat), crosslinkInfo.get(sat), settings);
                currentPlans.put(sat, mctsPlanner.getResults());
                break;
            case "dumbMcts":
                DumbMCTSPlanner dumbMctsPlanner = new DumbMCTSPlanner(observationEvents.get(sat), downlinkEvents.get(sat), localRewardGrids.get(sat), currentStates.get(sat), crosslinkInfo.get(sat), settings);
                currentPlans.put(sat, dumbMctsPlanner.getResults());
                break;
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
