/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.orekit.event;

import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.hipparchus.geometry.euclidean.threed.Vector3D;
import org.hipparchus.ode.events.Action;
import org.orekit.bodies.CelestialBody;
import org.orekit.frames.Frame;
import org.orekit.frames.TopocentricFrame;
import org.orekit.orbits.KeplerianOrbit;
import org.orekit.orbits.PositionAngle;
import org.orekit.propagation.analytical.KeplerianPropagator;
import org.orekit.propagation.events.handlers.EventHandler;
import org.orekit.time.AbsoluteDate;
import seakers.orekit.coverage.access.TimeIntervalArray;
import seakers.orekit.event.detector.GroundBodyAngleDetector;
import seakers.orekit.object.CoverageDefinition;
import seakers.orekit.object.CoveragePoint;
import seakers.orekit.util.RawSafety;

/**
 * An analysis for recording when the angle between a direction centered at a
 * geodetic point and a celestial body are above a specified angle threshold
 *
 * @author nhitomi
 */
public class GroundBodyAngleEventAnalysis extends AbstractGroundEventAnalysis {

    /**
     * The maximum allowable angle from the sun to the desired direction.
     */
    private final double maxAngle;

    /**
     * The direction used to compute the maximum allowable angle from.
     */
    private final Vector3D direction;

    /**
     * The celestial body
     */
    private final CelestialBody body;

    public GroundBodyAngleEventAnalysis(AbsoluteDate startDate,
            AbsoluteDate endDate, Frame inertialFrame,
            Set<CoverageDefinition> covDefs, CelestialBody body,
            double maxAngle, Vector3D direction) {
        super(startDate, endDate, inertialFrame, covDefs);
        this.maxAngle = maxAngle;
        this.direction = direction;
        this.body = body;
    }

    @Override
    public EventAnalysis call() throws Exception {
        double stepSize = 86400. / 4.; //quarter of a day
        double threshold = 1E-3; //for root finding [s]
        for (CoverageDefinition cdef : getCoverageDefinitions()) {
            Logger.getGlobal().finest(String.format("Computing sun angles for %s...", cdef));
            HashMap<TopocentricFrame, TimeIntervalArray> illuminationTimes = new HashMap<>();
            File file = new File(
                    System.getProperty("orekit.coveragedatabase"),
                    "illumination"+cdef.getName());
            if (file.canRead()) {
                //System.out.println("Illumination found in database!!!");
                illuminationTimes = readAccesses(file);
                getEvents().put(cdef, illuminationTimes);
                continue;
            }
            KeplerianOrbit dummyOrbit
                    = new KeplerianOrbit(1, 0, Math.PI, 0, 0, 0,
                            PositionAngle.TRUE, getInertialFrame(), getStartDate(), 0);


            for (CoveragePoint point : cdef.getPoints()) {
                KeplerianPropagator kp = new KeplerianPropagator(dummyOrbit, 0);

                GroundBodyAngleDetector gsd
                        = new GroundBodyAngleDetector(kp.getInitialState(),
                                getStartDate(), getEndDate(), point, body,
                                maxAngle, direction, Action.CONTINUE, stepSize, threshold);
                kp.addEventDetector(gsd);
                kp.propagate(getStartDate(), getEndDate());
                illuminationTimes.put(point, gsd.getTimeIntervalArray());
            }
            getEvents().put(cdef, illuminationTimes);
            File writeFile = new File(
                    System.getProperty("orekit.coveragedatabase"),
                    "illumination"+cdef.getName());
            writeAccesses(writeFile, illuminationTimes);
        }

        return this;
    }

    private void writeAccesses(File file, HashMap<TopocentricFrame, TimeIntervalArray> accesses) {
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file))) {
            oos.writeObject(accesses);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(GroundBodyAngleEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(GroundBodyAngleEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private HashMap<TopocentricFrame, TimeIntervalArray> readAccesses(File file) {
        HashMap<TopocentricFrame, TimeIntervalArray> out = new HashMap<>();
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file))) {
            out = RawSafety.castHashMap(ois.readObject());
        } catch (FileNotFoundException ex) {
            Logger.getLogger(GroundBodyAngleEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(GroundBodyAngleEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(GroundBodyAngleEventAnalysis.class.getName()).log(Level.SEVERE, null, ex);
        }
        return out;
    }

    @Override
    public String getHeader() {
        StringBuilder sb = new StringBuilder();
        sb.append("Ground to Celestial Body Angle Event Analysis\n");
        sb.append("\tBody = ").append(body.getName()).append("\n");
        sb.append("\tCoverageDefinitions = {");
        for(CoverageDefinition cdef : getCoverageDefinitions()){
            sb.append("\t\t").append(cdef.toString()).append("\n");
        }
        sb.deleteCharAt(sb.length()-1); //removes last comma
        sb.append("\n\t}\n\n");
        
        return sb.toString();
    }

}
