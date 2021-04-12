/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar.utils;

/**
 *
 * @author dani
 */
import jess.*;
import seakers.vassar.Interval;
import seakers.vassar.Resource;
import seakers.vassar.spacecraft.LaunchVehicle;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import static java.lang.Math.*;
import static org.moeaframework.util.Vector.dot;

public class MatlabFunctions implements Userfunction {
    private HashMap<String,Interval> valueInvHashmap;
    private HashMap<Interval,String> valueHashmap;
    private Value vvalueInvHashmap;
    private Value vvalueHashmap;
    private HashMap<Integer,Double> infFactors;
    private ValueVector instrumentList;
    private Resource res;
    private Method m;
    private HashMap<String, LaunchVehicle> lvDatabase;

    public HashMap<Integer, Double> getInfFactors() {
        return infFactors;
    }

    public MatlabFunctions(Resource res) {
        this.res = res;
        m = null;
        valueInvHashmap = new HashMap<>(5);
        valueInvHashmap.put("Full", new Interval("interval", 1.0, 1.0));
        valueInvHashmap.put("Most", new Interval("interval", 0.66, 1.0));
        //valueInvHashmap.put("Half",new Interval("interval",0.4,0.6));
        valueInvHashmap.put("Some", new Interval("interval", 0.33, 0.66));
        valueInvHashmap.put("Marginal", new Interval("interval", 0.0, 0.33));
        vvalueInvHashmap = new Value(valueInvHashmap);
        
        valueHashmap = new HashMap<>(5);
        valueHashmap.put(new Interval("interval", 1.0, 1.0), "Full");
        valueHashmap.put(new Interval("interval", 0.66, 1.0), "Most");
        //valueHashmap.put(new Interval("interval",0.4,0.6),"Half");
        valueHashmap.put(new Interval("interval", 0.33, 0.66), "Some");
        valueHashmap.put(new Interval("interval", 0.0, 0.33), "Marginal");
        vvalueHashmap = new Value(valueHashmap);

        lvDatabase = new HashMap<>();
        
        infFactors = new HashMap<>();
        initializeInflationFactors();
    }
    @Override
    public String getName()
    {
        return "MatlabFunctions";
    }
    
    @Override
    public Value call(ValueVector vv, Context context) throws JessException {
        Class<?>[] partypes = new Class<?>[2];
        try {
            partypes[0] = vv.getClass();
            partypes[1] = context.getClass();
            
            m = this.getClass().getDeclaredMethod(vv.get(1).toString(), partypes);
            
            Value v = (Value)m.invoke(this, vv, context);
            
            return v;
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public Method getMethod() {
        return m;
    }

    public void setMethod( Method m ) {
        this.m = m;
    }

    public Resource getResource() {
        return res;
    }

    public void setResource(Resource res) {
        this.res = res;
    }
    
    private void initializeInflationFactors() {
        String factors = "0.097,0.088,0.08,0.075,0.078,0.08,0.081,0.084,0.082,"
                + "0.081,0.081,0.085,0.095,0.1,0.102,0.105,0.113,0.13,"
                + "0.14,0.138,0.14,0.151,0.154,0.155,0.156,0.156,0.158,"
                + "0.163,0.168,0.169,0.172,0.174,0.175,0.178,0.18,0.183,"
                + "0.188,0.194,0.202,0.213,0.225,0.235,0.243,0.258,0.286,"
                + "0.312,0.33,0.352,0.379,0.422,0.479,0.528,0.56,0.578,"
                + "0.603,0.625,0.636,0.66,0.687,0.72,0.759,0.791,0.815,"
                + "0.839,0.861,0.885,0.911,0.932,0.947,0.967,1,1.028,"
                + "1.045,1.069,1.097,1.134,1.171,1.171,1.216,1.208,1.226,"
                + "1.244,1.264,1.285,1.307,1.328,1.35,1.372,1.395,1.418";
        
        String[] tmp = factors.split(",");
        for( int i = 1930, j = 0; i<= 2019; i++, j++ )
            infFactors.put(i, Double.parseDouble(tmp[j]));
    }

    public String toJessList(String str) {
        //str = [a,b,c]; goal is to return (create$ a b c)
        String str2 = str.substring(1, str.length()-1);//get rid of []
        return " (create$ " + str2.replace(",", " ") + ")";
    }

    public String stringArraytoStringWithSpaces(String[] array) {
        String res = array[0];
        for (int i = 1; i < array.length; i++) {
            res += " " + array[i];
        }
        return res;
    }

    public String stringArraytoStringWith(String[] array, String ss) {
        String res = array[0];
        for (int i = 1; i < array.length; i++) {
            res += ss + array[i];
        }
        return res;
    }

    public int sumRowBool(boolean[][] mat, int row) {
        int x = 0;
        int ncols = mat[0].length;
        for (int i = 0; i < ncols; i++) {
            if (mat[row][i]) {
                x += 1;
            }
        }
        return x;
    }

    public ArrayList<String> jessList2ArrayList(ValueVector vv, Rete r) {
        ArrayList<String> al = new ArrayList<>();
        try {
            for (int i = 0; i < vv.size(); i++) {
                al.add(vv.get(i).stringValue(r.getGlobalContext()));
            }
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            al = null;
        }
        return al;
    }

    public Value getValueInvHashmap(Funcall vv, Context c) {
        return vvalueInvHashmap;
    }

    public Value getValueHashmap(Funcall vv, Context c) {
        return vvalueHashmap;
    }

    public void addLaunchVehicletoDB(String id, LaunchVehicle lv) {
        lvDatabase.put(id, lv);
    }

    public Value getLaunchVehicleCost(Funcall vv, Context c) {
        String id;
        try {
            id = vv.get(2).stringValue(c);
            double cost = lvDatabase.get(id).getCost();
            return new Value(cost, RU.FLOAT);

        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public Value getLaunchVehicleDimensions(Funcall vv, Context c) {
        String id;
        try {
            id = vv.get(2).stringValue(c);
            double h = lvDatabase.get(id).getHeight();
            double d = lvDatabase.get(id).getDiameter();
            ValueVector vv2 = new ValueVector(2);
            vv2.add(d);
            vv2.add(h);
            return new Value(vv2, RU.LIST);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public Value getLaunchVehiclePerformanceCoeffs(Funcall vv, Context c) {
        String id;
        String orb;
        try {
            id = vv.get(2).stringValue(c);
            orb = vv.get(3).stringValue(c);
            ValueVector coeffs = lvDatabase.get(id).getPayloadCoeffsOrbit(orb);
            return new Value( coeffs, RU.LIST );
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public Value designAvionics(Funcall vv, Context c) {
        double ddpd;
        int redundancy;
        double pmass;
        try {
            ddpd = vv.get(2).floatValue(c);
            redundancy = vv.get(3).intValue(c);
            pmass = vv.get(4).floatValue(c);

            // Estimate program memory, RAM, and frequency -- based on SMAD
            // tables, data downloaded per day, and margin of error (50%)

            double refMass = pmass * 0.0983;

            double mar = 50.0;

            double memory = ddpd / 300.0;

            double progm = 176742.4;
            double ram = 133324.8 + ddpd;
            double freq = 1648.5 + 0.25 * memory;

            progm = (1 + mar / 100.0) * progm;
            ram = (1 + mar / 100.0) * ram;
            freq = (1 + mar / 100.0) * freq;

            double[] x = {1, log(progm), log(ram), log(freq)};

            double[] cons1 = {-1.04807, 0.169433, 0.186482, -0.00983};
            double mass = exp(dot(cons1, x)) / 1.0;

            double[] cons2 = {3.540926, -0.01921, -0.00858, 0.072602};
            double l = exp(dot(cons2, x)) / 1.0;

            double[] cons3 = {2.763307, 0.091377, 0.053965, -0.02504};
            double w = exp(dot(cons3, x)) / 1.0;

            double[] cons4 = {-3.92369, 0.297605, 0.230538, -0.09338};
            double h = exp(dot(cons4, x)) / 1.0;

            double[] cons5 = {1.390067, 0.336528, 0.245416, -0.10272};
            double cost = exp(dot(cons5, x));

            double[] cons6 = {-5.81788, 0.173328, 0.143292, 0.194043};
            double avgPwr = exp(dot(cons6, x));

            double peakPwr = 2 * (avgPwr);

            double heatpower = peakPwr;

            double minTemp = -40.0;
            double maxTemp = 85.0;

            ValueVector vv2 = new ValueVector(10);
            vv2.add(mass * redundancy);
            vv2.add(l);
            vv2.add(w);
            vv2.add(h * redundancy);
            vv2.add(cost * redundancy);
            vv2.add(avgPwr * redundancy);
            vv2.add(peakPwr * redundancy);
            vv2.add(heatpower * redundancy);
            vv2.add(minTemp);
            vv2.add(maxTemp);
            //System.out.println("Avionics mass: "+mass);
            return new Value(vv2, RU.LIST);
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }
    public Value designEPS(Funcall vv, Context c) {
        String id;
        String orb;

        double ppa;
        double ppp;
        double pcoms;
        double pav;
        double padcs;
        double solarFrac;
        double worstAngle;
        double T;
        double lifetime;
        double drymass;
        double dod;

        try {
            String[] cellType = {"Multi", "Si", "GaAs", "DANI"};
//            String[] cellType = {"DANI"};
            String[] battType = {"NiH2", "NiCd","LiIon"};

            ppa = vv.get(2).floatValue(c);
            ppp = vv.get(3).floatValue(c);
            pcoms = vv.get(4).floatValue(c);
            pav = vv.get(5).floatValue(c);
            padcs = vv.get(6).floatValue(c);
            solarFrac = vv.get(7).floatValue(c);
            worstAngle = vv.get(8).floatValue(c);
            T = vv.get(9).floatValue(c);
            lifetime = vv.get(10).floatValue(c);
            drymass = vv.get(11).floatValue(c);
            dod = vv.get(12).floatValue(c);

            // Total power
            double ppow = ppp * 0.09/0.46;
            double ptherm = ppp * 0.10/0.46;
            double pstr = ppp * 0.01/0.46;
            double Pa = ppa + pcoms + pav + padcs + ppow + ptherm + pstr;
            double Pp = ppp + pcoms + pav + padcs + ppow + ptherm + pstr;
//            Pa = 1200;
//            Pp = Pa;

            // Calculate time in daylight and eclipse
            double Td = T * solarFrac;
            double Te = T - Td;

            // Calculate Solar Panel Power
            double Xe = 0.65;
            double Xd = 0.85;
            double Pe = 0.8 * Pa + 0.2 * Pp;
            double Pd = Pe;
            double Psa_min = (Pe*Te/Xe + Pd*Td/Xd)/Td;

            // Look for best combination of materials
            double Asa = 0.0;
            double Pbol = 0.0;
            double Meps = 0.0;
            double Msa = 0.0;
            double mbatt_min = 0.0;
            int Nbat_min = -1;
            double Mcpu_min = 0.0;
            double Mregconv_min = 0.0;
            double Mwiring_min =  0.0;

            double cost = 1e10;
            double costTemp = 0.0;

            for(int i = 0; i < cellType.length; i++){
                double Pbol_temp;
                double P_density_temp;
                double Msa_temp;
                double Asa_temp;
                double Ld;
                double Peol;

//                Pbol_temp = Pa;
                switch (cellType[i]){
                    case "Multi":
                        P_density_temp = 383 * 0.77 * cos(worstAngle * PI / 180);
                        Ld = pow( (1-0.005), lifetime);
                        Peol = P_density_temp * Ld;
                        Asa_temp = Psa_min / Peol;
                        Msa_temp = 2.8 * Asa_temp;
                        Pbol_temp = P_density_temp * Asa_temp;
                        break;
                    case "Si":
                        P_density_temp = 202 * 0.77 * cos(worstAngle * PI / 180);
                        Ld = pow( (1-0.00375), lifetime);
                        Peol = P_density_temp * Ld;
                        Asa_temp = Psa_min / Peol;
                        Msa_temp = 2.3 * Asa_temp;
                        Pbol_temp = P_density_temp * Asa_temp;
                        break;
                    case "GaAs":
                        P_density_temp = 253 * 0.77 * cos(worstAngle * PI / 180);
                        Ld = pow( (1-0.00275), lifetime);
                        Peol = P_density_temp * Ld;
                        Asa_temp = Psa_min / Peol;
                        Msa_temp = 2.7 * Asa_temp;
                        Pbol_temp = P_density_temp * Asa_temp;
                        break;
                    case "DANI":
                        P_density_temp = 300 * 0.77 * cos(worstAngle * PI / 180);
                        Ld = pow( (1-0.005), lifetime);
                        Peol = P_density_temp * Ld;
                        Asa_temp = Psa_min / Peol;
                        Pbol_temp = P_density_temp * Asa_temp;
                        Msa_temp = Pbol_temp/25;
                        break;
                    default:
                        continue;
                }


//                Pbol_temp = Pa;
                int j_min = -1;
                for(int j = 0; j < battType.length; j++){
                    double Cr;
                    double mbatt = 0.0;
                    double volume;
                    double dimbat;

                    for(int Nbat = 1; Nbat < 5; Nbat++) {
                        switch (battType[j]) {
                            case "NiH2":
                                Cr = Pe * Te / (Nbat * 3600 * dod * 0.70);
                                mbatt = Cr/60;
                                volume = mbatt/2956;
                                dimbat = pow(volume, 1.0/3.0);
                                break;
                            case "NiCd":
                                Cr = Pe * Te / (Nbat * 3600 * dod * 0.72);
                                mbatt = Cr/30;
                                volume = mbatt/2956;
                                dimbat = pow(volume, 1.0/3.0);
                                break;
                            case "LiIon":
                                Cr = Pe * Te / (Nbat * 3600 * dod * 0.98);
                                mbatt = Cr/125;
                                volume = (mbatt/458.3)*pow(.1,3);
                                dimbat = pow(volume, 1.0/3.0);
                                break;
                        }

                        double L = sqrt(Asa_temp);
                        double W = L;
                        double Mcpu;
                        double Mregconv;
                        double Mwiring;

                        if(drymass < 30.0){
                            Mcpu = 0.02 * Psa_min / 10;
                            Mregconv = 0.025 * Psa_min / 10;
                            Mwiring = (0.01 + 0.04) / 2 * drymass;
                        }
                        else{
                            Mcpu = 0.02 * Psa_min;
                            Mregconv = 0.025 * Psa_min;
                            Mwiring = (0.01 + 0.04) / 2 * drymass;
                        }

                        double Meps_temp = Msa_temp + (mbatt * Nbat) + Mcpu + Mregconv + Mwiring;
                        costTemp = 62.7 * Meps_temp + 112 * pow(Meps_temp, 0.763);

                        if(cost >= costTemp){
                            cost = costTemp;
                            j_min = j;

                            Meps = Meps_temp;
                            Pbol = Pbol_temp;
                            Asa = Asa_temp;
                            Msa = Msa_temp;
                            mbatt_min = mbatt;
                            Nbat_min = Nbat;
                            Mcpu_min = Mcpu;
                            Mregconv_min = Mregconv;
                            Mwiring_min =  Mwiring;
                        }
                    }
                }
            }

            if(false) {
                System.out.println("eps mass: " + Msa + " " + mbatt_min + " " + Nbat_min + " "
                + Mcpu_min + " " + Mregconv_min + " " + Mwiring_min);
                double totalMass = Msa+mbatt_min*Nbat_min+Mcpu_min+Mregconv_min+Mwiring_min;
                System.out.println("Total EPS Mass: "+ totalMass);
                System.out.println("eps power: " + " " + Psa_min + " " + Asa + " " + Pbol);
            }

            ValueVector vv2 = new ValueVector(4);
            vv2.add(Meps);
            vv2.add(Pbol);
            vv2.add(Asa);
            vv2.add(Msa);
            return new Value(vv2, RU.LIST);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public Value designComs(Funcall vv, Context c) {
        double bps;
        double drymass;
        double alt;

        try {
            bps = vv.get(2).floatValue(c);
            drymass = vv.get(3).floatValue(c);
            alt = vv.get(4).floatValue(c);

            ArrayList<ArrayList<ArrayList<AntennaDesign>>> nenAntennas = new ArrayList<>();
            String[] bands_NEN = {"UHF", "Sband", "Xband", "Kaband"};
//            String[] bands_NEN = {"Xband"};
            double[] receiverPower = new double[250];
            double[] antennaGain = new double[50];
            double costMin = 1e10;
            int band_min = -1;
            int i_min = -1;
            int j_min = -1;

            for(int band = 0; band < bands_NEN.length; band++) {
                ArrayList<ArrayList<AntennaDesign>> bandAntennas = new ArrayList<>();
                for (int i = 0; i < receiverPower.length; i++) {
                    if (i == 0) receiverPower[i] = 1;
                    else receiverPower[i] = receiverPower[i-1] + 1;

                    ArrayList<AntennaDesign> powerAntennas = new ArrayList<>();
                    for(int j = 0; j < antennaGain.length; j++) {
                        if (j == 0) antennaGain[j] = 1;
                        else antennaGain[j] = j+1;

                        AntennaDesign antenna = new AntennaDesign();
                        antenna.designAntenna(alt, drymass, bps, receiverPower[i], antennaGain[j], bands_NEN[band]);
                        powerAntennas.add(antenna);

                        if (antenna.getCost() < costMin) {
                            costMin = antenna.getCost();
                            band_min = band;
                            i_min = i;
                            j_min = j;
                        }
                    }

                    bandAntennas.add(powerAntennas);
                }
                nenAntennas.add(bandAntennas);
            }

            AntennaDesign bestAntenna = nenAntennas.get(band_min).get(i_min).get(j_min);
            double commsMass = bestAntenna.getMass();
            double commsPower = bestAntenna.getPower();
            //System.out.println("Gain: "+bestAntenna.getGain()+" Transmit Power: "+bestAntenna.getTransmitPower());

            if(false) {
                System.out.println("comms mass: " + commsMass);
                System.out.println("comms power: " + commsPower);
                System.out.println("antenna dims: " + Arrays.toString(bestAntenna.getDims()));
                System.out.println("antenna info: " + bestAntenna.getAntennaType() + " "
                        + bestAntenna.getMassA() + " " + bands_NEN[band_min] + " "
                        + receiverPower[i_min] + " " + antennaGain[j_min]);
            }


            ValueVector vv2 = new ValueVector(2);
            vv2.add(commsMass);
            vv2.add(commsPower);
            return new Value(vv2, RU.LIST);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public Value countSats(Funcall vv, Context c) {
        String orb1;
        String orb2;

        try {
            orb1 = vv.get(2).stringValue(c);
            orb2 = vv.get(3).stringValue(c);
            double npp = 0;
            double nsp = 0;
            double np2 = 0;
            double ns2 = 0;

            String[] orbit1 = orb1.split("-");
            String[] orbit2 = orb2.split("-");

            boolean sameOrbit = true;
            for(int i = 0; i < 4; i++){
                if(!orbit1[i].equals(orbit2[i])){
                    sameOrbit = false;
                    break;
                }
            }

            if(sameOrbit && !orb1.equals(orb2)){
                nsp = 1;
                np2 = 0;
                ns2 = 0;
            }
            else{
                np2 = 1;
                ns2 = 1;
            }

            ValueVector vv2 = new ValueVector(2);
            vv2.add(npp);
            vv2.add(nsp);
            vv2.add(np2);
            vv2.add(ns2);
            return new Value(vv2, RU.LIST);
        }
            catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }
}
