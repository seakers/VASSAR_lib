package rbsa.eoss;

import org.apache.commons.lang3.StringUtils;
import org.hipparchus.util.FastMath;
import org.orekit.utils.Constants;
import seak.orekit.object.OrbitWizard;

import java.util.Objects;

/**
 *
 * @author Ana-Dani
 */
public class Orbit {

    private String type;
    private String altitude;
    private String inclination;
    private String eccentricity;
    private String semimajor_axis;
    private String raan;
    private String arg_perigee;
    private String mean_anomaly;
    private String nplanes;
    private String num_sats_per_plane;
    private String mission_arch;

    private double altitudeNum; // [m]
    private double inclinationNum; // [deg]

    public Orbit(String orb, int np, int nsat) {
        String[] tokens = orb.split("-");
        type = tokens[0];
        altitude = tokens[1];
        inclination = tokens[2];
        raan = tokens[3];
        nplanes = String.valueOf(np);
        num_sats_per_plane = String.valueOf(nsat);
        mission_arch = "single_arch";
        eccentricity = "0.0";
        this.saveOrbitalParamInNumbers(altitude, inclination);
    }

    public Orbit(String orb) {
        String[] tokens = orb.split("-");
        type = tokens[0];
        altitude = tokens[1];
        inclination = tokens[2];
        raan = tokens[3];
        nplanes = "1";
        num_sats_per_plane = "1";
        mission_arch = "single_arch";
        eccentricity = "0.0";
        this.saveOrbitalParamInNumbers(altitude, inclination);
    }

    public Orbit(String t, String a, String i, String ra) {
        type = t;
        altitude = a;
        inclination = i;
        raan = ra;
        nplanes = "1";
        mission_arch = "single_arch";
        eccentricity = "0.0";
        this.saveOrbitalParamInNumbers(altitude, inclination);
    }

    public void saveOrbitalParamInNumbers(String altitude, String inclination){
//    "LEO-600-polar-NA","SSO-600-SSO-AM"

        if(inclination != null && StringUtils.isNumeric(altitude)){
            this.altitudeNum = Double.parseDouble(altitude) * 1000;  // [m]

        }

        if(inclination != null && StringUtils.isNumeric(inclination)){
            this.inclinationNum = Double.parseDouble(inclination); // [deg]

        }else{
            switch (inclination){
                case "polar":
                    this.inclinationNum = 90;
                    break;

                case "SSO":
                    // Calculate the inclination
                    double semimajoraxis = Constants.WGS84_EARTH_EQUATORIAL_RADIUS + altitudeNum;
                    this.inclinationNum = FastMath.toDegrees(OrbitWizard.SSOinc(semimajoraxis, 0.0)); // [deg]

                default:
                    break;
            }
        }
    }

    public String getAltitude() {
        return altitude;
    }

    public double getAltitudeNum(){
        return altitudeNum;
    }

    public String getArg_perigee() {
        return arg_perigee;
    }

    public String getInclination() {
        return inclination;
    }

    public double getInclinationNum(){
        return inclinationNum;
    }

    public String getEccentricity() {
        return eccentricity;
    }

    public String getMean_anomaly() {
        return mean_anomaly;
    }

    public String getRaan() {
        return raan;
    }

    public String getSemimajor_axis() {
        return semimajor_axis;
    }

    public String getType() {
        return type;
    }

    public void setAltitude(String altitude) {
        this.altitude = altitude;
        saveOrbitalParamInNumbers(this.altitude, null);
    }

    public void setAltitudeNum(double altitude){
        this.altitudeNum = altitude;
    }

    public void setArg_perigee(String arg_perigee) {
        this.arg_perigee = arg_perigee;
    }

    public void setEccentricity(String eccentricity) {
        this.eccentricity = eccentricity;
    }

    public void setInclination(String inclination) {
        this.inclination = inclination;
        saveOrbitalParamInNumbers(null, this.inclination);
    }

    public void setInclinationNum(double inclination){
        this.inclinationNum = inclination;
    }

    public void setMean_anomaly(String mean_anomaly) {
        this.mean_anomaly = mean_anomaly;
    }

    public void setRaan(String raan) {
        this.raan = raan;
    }

    public void setSemimajor_axis(String semimajor_axis) {
        this.semimajor_axis = semimajor_axis;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public String toString() {
        return type + "-" + altitude + "-" + inclination + "-" + raan;
    }
    public String toJessSlots() {
        return " (num-of-planes# " + nplanes + ")" +
            " (num-of-sats-per-plane# "  + num_sats_per_plane + ")"  + 
            " (mission-architecture " + mission_arch + ") " +     
            " (orbit-type " + type + ")"  + 
            " (orbit-altitude# "  + altitude + ")"  + 
            " (orbit-eccentricity "  + eccentricity + ")"  + 
            " (orbit-RAAN " + raan + ")"  + 
            " (orbit-inclination " + inclination + ")"  + 
            " (orbit-string " + this.toString() + ")";

    }

    public String getMission_arch() {
        return mission_arch;
    }

    public void setMission_arch(String mission_arch) {
        this.mission_arch = mission_arch;
    }

    public String getNplanes() {
        return nplanes;
    }

    public void setNplanes(String nplanes) {
        this.nplanes = nplanes;
    }

    public String getNum_sats_per_plane() {
        return num_sats_per_plane;
    }

    public void setNum_sats_per_plane(String num_sats_per_plane) {
        this.num_sats_per_plane = num_sats_per_plane;
    }

}
