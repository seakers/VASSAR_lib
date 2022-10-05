package seakers.vassar.utils;

import java.util.HashMap;

import static java.lang.Math.*;
import static java.lang.Math.pow;

public class AntennaDesign {
    // Design Parameters
    private String antennaType = "nil";
    private double L = -1.0;
    private double W = -1.0;
    private double Ltx = -1.0;
    private double Dtx = -1.0;
    private double F = -1.0;
    private double H = -1.0;
    private double massA_DL = -1.0;
    private double massA = -1.0;
    private double massE = -1.0;
    private double commsMass = -1.0;
    private double costA = 1e10;
    private double costE = 1e10;
    private double costComms = 1e10;
    private double commsPower = 0.0;
    private double Ptx = 0.0;
    private double Gtx = 0.0;

    // Constants
    String[] GS = {"NEN", "TDRSS", "MOBILE"};

    double[] EbN0_min = {10.6, 10.6, 14.0, 18.3};

    String[] bands_NEN = {"UHF", "Sband", "Xband", "Kaband"};
    double[][] BW_NEN = {{137.825e6,137.175e6}, {2.29e9,2.2e9}, {8.175e9,8.025e9}, {27e9,25.5e9}};
    double[] f_NEN_DL = {1.44e8, 2.30e9, 8.10e9, 2.60e10};
    double[] G_NEN_DL = {18, 50, 56.8, 70.5};
    double[] T_gs_NEN_DL = {200, 165, 170, 225};
    double[] f_NEN_UL = {1.39e8, 2.07e9};

    String[] bands_TDRSS = {"Sband", "Kuband", "Kaband"};
    double[][] BW_TDRSS = {{2.29e9,2.2e9}, {15.1365e9,14.8e9}, {27e9,25.5e9}};
    double[] frequencies_TDRSS_return = {2.2875e9, 15.0034e9, 26e9};
    double[] GainToNoise_TDRSS_return = {9.5, 18.4, 19.1};
    double[] Rb_TDRSS_return = {6e6, 0.8*300e6, 0.8*300e6};
    double[] frequencies_TDRS_forward = {2.0718e9, 13.775e9, 23e9};
    double[] EIRP_TDRSS_forward = {43.6, 46.5, 56.2};

    public void designAntenna(double alt, double drymass, double payload_datarate, double Ptx, double Gtx, String band) throws Exception{ // TODO shannon limit?
        int[] indices = bandIndex(band);
        int band_type = indices[0];
        int band_i = indices[1];
        double dataPerDay = payload_datarate * 1e6 * 24 * 3600 * 0.1;
        double Rb_DL = dataPerDay/(20*15*60); // Contact Time/Access Time <- ~10-15 min per contact, ~2 contacts per day

        double f_DL = 0.0;
        double G_GS = 0.0;
        double Tgs = 0.0;

        if(band_type == 0) {
            f_DL = f_NEN_DL[band_i];
            G_GS = G_NEN_DL[band_i];
            Tgs = T_gs_NEN_DL[band_i];
        }
        else if(band_type == 1) {
            throw new Exception("Communication not yet supported");
        }

        double lambda = 3e8 / f_DL;
        double R = calcRange(alt, 15.0);
        double k = 1.38e-23;
        double f_DL_GHz = f_DL / 1e9;
        double EbN0min = calcEbN0min(Rb_DL, BW_NEN[band_i][0] - BW_NEN[band_i][1]);
        EbN0min = 12.6;
        double EbN0 = lin2dB(Ptx*Gtx) + G_GS + 2*lin2dB(lambda/(4*PI*R)) - lin2dB(k*Tgs*Rb_DL);

        boolean linkBudgetClosed = false;
        if(EbN0 > EbN0min) {
            this.Ptx = Ptx;
            this.Gtx = Gtx;
            Gtx = lin2dB(Gtx);

            if (band_type == 0) {
                double NChannels = (BW_NEN[band_i][0] - BW_NEN[band_i][1]) / 32e6;
                if (Gtx < 3 && band.equals("UHF")) {
                    lambda = 3e8 / f_DL;
                    if (Gtx < 1.0 / 76.0) {
                        Ltx = 0.1 * lambda;
                    } else if (2.15 > Gtx && Gtx > 1.76) {
                        Ltx = 0.5 * lambda;
                    } else if (5.2 > Gtx && Gtx > 2.15) {
                        Ltx = (5.0 / 4.0) * lambda;
                    }
                    antennaType = "Dipole";
                    massA_DL = 0.05;
                    linkBudgetClosed = true;
                } else if (Gtx < 9 && (band.equals("UHF") || band.equals("Sband") )){
                    double er = 10.2;
                    double[] antennaDim = dimPatchAntenna(er, f_DL_GHz);
                    massA_DL = patchMass(antennaDim[0]*100, antennaDim[1]*100);
                    W = antennaDim[0];
                    L = antennaDim[1];
                    antennaType = "Patch";
                    linkBudgetClosed = true;
                } else {
                    double[] antennaDim = gain2Diameter(Gtx, f_DL_GHz, 0.5);
                    Dtx = antennaDim[0];
                    if (0.3 < Dtx && Dtx < 4.5) {
                        antennaType = "Parabolic";
                        linkBudgetClosed = true;
                    } else if (Dtx < 0.3) {
                        Dtx = 0.3;
                        antennaType = "Parabolic";
                        linkBudgetClosed = true;
                    }
                    massA_DL = parabolicMass(Dtx);
                    F = 0.5 * Dtx;
                    H = pow(Dtx, 2) / (16 * F);
                }

                if (linkBudgetClosed) {
                    massA = massA_DL;
                    massE = massCommElectronics(Ptx, drymass, band_i) * 2.0 + 0.01 * drymass;
                    commsMass = massA + massE;

                    costA = costAntenna(massA, antennaType);
                    costE = costElectronics(massE, NChannels);
                    costComms = costA + costE;

                    commsPower = commsPower(Ptx);
                } else {
                    costComms = 1e10;
                }
            } else {
                if (Gtx < 3) {
                    lambda = 3e8 / f_DL;
                }
            }
        }
    }

    private double lin2dB(double x){
        return 10 * log10(x);
    }

    private double dB2lin(double x){
        return pow(10, x/10.0);
    }

    private double[] dimPatchAntenna(double er, double f_GHz){
        double f = f_GHz*1e9;
        double lambda_o = 3e8/f;
        double h = 0.1 * lambda_o;
        double W = 3e8/(2.0*f)*sqrt(2.0/(er+1.0));
        double ereff = (er + 1.0)/2.0 + (er-1)/(2.0*sqrt(1.0 + 12.0 * h/W));
        double dl = 0.824 * h * ((ereff + 0.3) * (W/h + 0.264))/((ereff-0.258) * (W/h + 0.8));
        double Leff = 3e8/(2.0*f*sqrt(ereff));
        double L = Leff - 2.0*dl;

        double[] design = {W, L};
        return design;
    }

    private double patchMass(double W, double L){
        double rho = 2700;
        double h = 0.1 * max(W,L);
        double volume = W*L*h;
        double volume_real = 0.5 * volume;
        return rho * volume_real;
    }

    private double[] gain2Diameter(double G_dB, double f_GHz, double eff){
        double c = 3e8;
        if(G_dB < 0) G_dB = 0.0;
        double G_lin = dB2lin(G_dB);
        double lambda = c/(f_GHz*1e9);
        double D = sqrt((G_lin * pow(lambda,2))/(pow(PI,2)*eff));
        double theta = 21.0/(f_GHz*D);

        if(theta > 180) theta = 180;

        double[] design = {D, theta};
        return design;
    }

    private double parabolicMass(double D){
        double rho;
        if(D <= 0.5){
            rho = 20;
        }
        else if(D <= 1){
            rho = 10;
        }
        else if(D <= 10){
            rho = 5;
        }
        else{
            rho = 5;
        }
        double f_N = 0.25;
        double h = 1/10.0;
        double alpha = 0.05;

        return rho * PI * pow((D/2),2) * (pow((1+4*pow(h,2)),1.5) - 1) / (6*pow(h,2)) * (1 + alpha);
    }

    private int[] bandIndex(String band){
        for(int i = 0; i < bands_NEN.length; i++){
            if(bands_NEN[i] == band){
                int[] indeces = {0, i};
                return indeces;
            }
        }

        for(int i = 0; i < bands_TDRSS.length; i++){
            if(bands_TDRSS[i] == band){
                int[] indeces = {1, i};
                return indeces;
            }
        }
        return null;
    }

    private double massCommElectronics(double Ptx, double drymass, int band){
        double m = 0;
        if(drymass < 30){
            if(band == 0) m = 0.1;
            else if(band == 1) m = 0.2;
            else if(band == 2) m = 0.3;
            else m = 0.3;
        }
        else{
            double powerTx = Ptx/0.1;
            double powerAmp = Ptx/0.7;

            double massTransmitter = powerTx*0.008 + 0.5;
            double massAmplifier = powerAmp*0.005 + 0.2;

            m = massTransmitter + massAmplifier;
        }
        return m;
    }

    private double costAntenna(double mass, String antennaType){
        if(antennaType.equals("Dipole")){
            return 5*mass;
        }
        else if(antennaType.equals("Patch")){
            return 5*mass;
        }
        else{
            if(0.75 <= mass && mass <= 87*1.25){
                double nrc = inflate(1015*pow(mass, 0.59), 1992, 2015);
                double rc = inflate(20+230*pow(mass,0.59), 1992, 2015);
                return nrc + rc;
            }
            else{
                return 1e10;
            }
        }
    }

    private double inflate(double x1, double y1, double y2){
        double[] factors = {0.097, 0.088, 0.08, 0.075, 0.078, 0.08, 0.081, 0.084, 0.082, 0.081, 0.081, 0.085, 0.095, 0.1, 0.102, 0.105, 0.113, 0.13, 0.14, 0.138, 0.14, 0.151, 0.154, 0.155, 0.156, 0.156, 0.158, 0.163, 0.168, 0.169, 0.172, 0.174, 0.175, 0.178, 0.18, 0.183, 0.188, 0.194, 0.202, 0.213, 0.225, 0.235, 0.243, 0.258, 0.286, 0.312, 0.33, 0.352, 0.379, 0.422, 0.479, 0.528, 0.56, 0.578, 0.603, 0.625, 0.636, 0.66, 0.687, 0.72, 0.759, 0.791, 0.815, 0.839, 0.861, 0.885, 0.911, 0.932, 0.947, 0.967, 1, 1.028, 1.045, 1.069, 1.097, 1.134, 1.171, 1.171, 1.216, 1.208, 1.226, 1.244, 1.264, 1.285, 1.307, 1.328, 1.35, 1.372, 1.395, 1.418};
        double[] years = {};
        double year = 1930;
        HashMap<Double, Double> factorMap = new HashMap<>(factors.length);
        for(int i = 0; i < factors.length; i++){
            factorMap.put(year+i, factors[i]);
        }

        double f1 = factorMap.get(y1);
        double f2 = factorMap.get(y2);
        return (x1/f1)*f2;
    }

    private double costElectronics(double mass, double NChannels){
        if(mass < 14*0.7){
            mass = 14*0.7;
        }
        else if(mass > 144 * 1.25){
            mass = 144 * 1.25;
        }

        if(14*0.7 <= mass && mass <= 144*1.25){
            return 917 * pow(mass, 0.7) + 179 * mass;
        }
        return 1e10;
    }

    private double commsPower(double Ptx) {
        double eff = 0.45 - 0.015 * (Ptx - 5);

        if(eff< 0.45){
            eff = 0.45;
        }

        double transceiver_power=Ptx*(1+1/eff);
        double antenna_power=0;
        double others_power=0;


        double PeakPowerComm = antenna_power+transceiver_power+others_power;
        double AvgPowerComm = 0+1+others_power;
        double OffPowerComm = others_power;

        double T_peak_comm = 0.15;
        double T_avg_comm  = 0.60;
        double T_off_comm  = 0.25;

//        return T_peak_comm * PeakPowerComm + T_avg_comm * AvgPowerComm + T_off_comm * OffPowerComm;
        return PeakPowerComm;
    }

    private double calcRange(double h_km, double epsmin){
        double RE              = 6378;
        double rho             = asin(RE/(RE+h_km))*180/PI;
        double etamax          = asin(sin(rho*PI/180)*cos(epsmin*PI/180))*180/PI;
        double lambdamax       = 90 - epsmin - etamax;
        double Dmax            = RE*sin(lambdamax*PI/180)/sin(etamax*PI/180);
        return 1000.*Dmax;
//        return 1000*sqrt( pow(RE + h_km,2) - pow(RE,2) );
    }

    private double calcEbN0min(double Rb,double B){
        double eta = Rb/B;
        double minLin = (pow(2,eta) - 1)/eta;
        double min = lin2dB(minLin);
        return min;
    }

    public double getCost(){ return costComms; }
    public double getMass(){ return commsMass; }
    public double getGain(){ return lin2dB(Gtx); }
    public double getTransmitPower(){ return Ptx; }
    public double getPower(){return commsPower;}
    public String getAntennaType(){return antennaType;}
    public double[] getDims(){
        if(antennaType.equals("Dipole")){
            double[] dims = {Ltx};
            return dims;
        }
        else if(antennaType.equals("Patch")){
            double[] dims = {L, W};
            return dims;
        }
        else if(antennaType.equals("Parabolic")){
            double[] dims = {Dtx};
            return dims;
        }
        else{
            double[] dims = {-1.0, -1.0, -1.0};
            return dims;
        }
    }
    public double getMassA(){return this.massA_DL;}
}
