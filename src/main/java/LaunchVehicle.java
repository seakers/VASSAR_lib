/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;
import java.util.HashMap;
import jess.ValueVector;
/**
 *
 * @author dani
 */
public class LaunchVehicle {
    private String id;
    private HashMap<String,ValueVector> payloadCoeffs;
    private double diameter;
    private double height;
    private double cost;

    public LaunchVehicle(String id, HashMap<String, ValueVector> payloadCoeffs, double diameter, double height, double cost) {
        this.id = id;
        this.payloadCoeffs = payloadCoeffs;
        this.diameter = diameter;
        this.height = height;
        this.cost = cost;
    }

    public ValueVector getPayloadCoeffsOrbit(String orb) {
        return payloadCoeffs.get(orb);
    }

    public double getDiameter() {
        return diameter;
    }

    public double getHeight() {
        return height;
    }

    public double getCost() {
        return cost;
    }
}
