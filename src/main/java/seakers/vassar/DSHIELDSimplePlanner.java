package seakers.vassar;

import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.bodies.OneAxisEllipsoid;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.orbits.Orbit;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;
import seakers.orekit.analysis.Analysis;
import seakers.orekit.analysis.Record;
import seakers.orekit.analysis.ephemeris.GroundTrackAnalysis;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.object.Instrument;
import seakers.orekit.object.Satellite;
import seakers.orekit.propagation.PropagatorFactory;
import seakers.orekit.propagation.PropagatorType;
import seakers.orekit.scenario.Scenario;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.problems.OrbitInstrumentObject;

import java.util.*;

public class DSHIELDSimplePlanner {
    private double reward;

    public DSHIELDSimplePlanner (List<Map<TopocentricFrame, TimeIntervalArray>> gpAccessList, Map<GeodeticPoint,Double> covPointRewards, ArrayList<Orbit> orbits, AbsoluteDate startDate, double duration) {
        double sum = 0.0;
        int i = 0;
        for (Map<TopocentricFrame, TimeIntervalArray> gpAccess : gpAccessList) {
            Map<TopocentricFrame, TimeIntervalArray> sortedGPAccesses = sortAccesses(gpAccess);
            Orbit orbit = orbits.get(i);
            Collection<Record<String>> groundTrack = getGroundTrack(orbit, duration, startDate);
            SMDPPlanner smdpPlanner = new SMDPPlanner(sortedGPAccesses,covPointRewards,groundTrack,startDate,orbit.getA()-6371000);
            ArrayList<Observation> smdpOutput = smdpPlanner.getResults();
            double satSum = 0.0;
            for (Observation obs : smdpOutput) {
                satSum = satSum + obs.getObservationReward();
            }
            sum = sum + satSum;
            i = i + 1;
        }
        this.reward = sum;
    }

    public double getReward() {
        return reward;
    }

    public static Collection<Record<String>> getGroundTrack(Orbit orbit, double duration, AbsoluteDate startDate) {
        OrekitConfig.init(1);
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate endDate = startDate.shiftedBy(duration*86400);

        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2003, true);

        BodyShape earthShape = new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING, earthFrame);
        ArrayList<Instrument> payload = new ArrayList<>();
        Satellite sat1 = new Satellite(orbit.toString(), orbit,  payload);
        Properties propertiesPropagator = new Properties();
        PropagatorFactory pf = new PropagatorFactory(PropagatorType.J2,propertiesPropagator);


        Collection<Analysis<?>> analyses = new ArrayList<>();
        double analysisTimeStep = 1;
        GroundTrackAnalysis gta = new GroundTrackAnalysis(startDate, endDate, analysisTimeStep, sat1, earthShape, pf);
        analyses.add(gta);
        Scenario scen = new Scenario.Builder(startDate, endDate, utc).
                analysis(analyses).name(orbit.toString()).propagatorFactory(pf).build();
        try {
            scen.call();
        } catch (Exception ex) {
            throw new IllegalStateException("Ground track scenario failed to complete.");
        }
        OrekitConfig.end();
        return gta.getHistory();
    }

    public static Map<TopocentricFrame, TimeIntervalArray> sortAccesses(Map<TopocentricFrame, TimeIntervalArray> gpAccesses) {
        Map<TopocentricFrame, TimeIntervalArray> sortedMap = new LinkedHashMap<>();
        gpAccesses.values().removeIf(TimeIntervalArray::isEmpty);
        while(!gpAccesses.isEmpty()) {
            TopocentricFrame bestTF = null;
            TimeIntervalArray bestTIA = null;
            double earliestTime = 1*3600*24;
            for (TopocentricFrame tf : gpAccesses.keySet()) {
                TimeIntervalArray tia = gpAccesses.get(tf);
                double[] tia_raslist = tia.getRiseAndSetTimesList();
                if(tia_raslist[0] < earliestTime) {
                    earliestTime = tia_raslist[0];
                    bestTF = tf;
                    bestTIA = tia;
                }
            }
            if(bestTF == null) {
                break;
            }
            sortedMap.put(bestTF,bestTIA);
            gpAccesses.remove(bestTF);
        }
        return sortedMap;
    }

}
