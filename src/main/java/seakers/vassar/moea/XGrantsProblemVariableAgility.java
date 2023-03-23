package seakers.vassar.moea;

import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.core.variable.RealVariable;
import org.moeaframework.problem.AbstractProblem;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;
import seakers.vassar.utils.SpectrometerDesign;

import java.util.ArrayList;

public class XGrantsProblemVariableAgility extends AbstractProblem {
    public XGrantsProblemVariableAgility() {
        super(12,2,0);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, EncodingUtils.newInt(1,10)); // number of radar satellites
        solution.setVariable(1, EncodingUtils.newInt(1,10)); // number of planes
        solution.setVariable(2, EncodingUtils.newInt(1,10)); // altitude of radar satellites (between 400 and 900 km)
        solution.setVariable(3, EncodingUtils.newInt(3,1000)); // num spectral pixels in VNIR
        solution.setVariable(4, EncodingUtils.newInt(0,1000)); // num spectral pixels in SWIR
        solution.setVariable(5, EncodingUtils.newInt(0,1)); // TIR presence
        solution.setVariable(6, new RealVariable(0.01,2.0)); // focal length (m)
        solution.setVariable(7, new RealVariable(0.1,5)); // FOV (deg)
        solution.setVariable(8, new RealVariable(0.01, 2.0)); // aperture (m)
        solution.setVariable(9, new RealVariable(1e-6,20e-6)); // VNIR pixel size (m)
        solution.setVariable(10, new RealVariable(5e-6,50e-6)); // SWIR pixel size (m)
        solution.setVariable(11, new RealVariable(0.1,10.0)); // agility (deg/s)
        return solution;
    }

    public double getSSOInclination(double alt) {
        double RE = 6378;
        double a = RE + alt;
        double J2 = 1.08e-3;
        double mu = 398600.0;
        double rate = 2*Math.PI/365.25/86400;
        double n = Math.sqrt(mu/Math.pow(a,3));
        return Math.acos(-2*rate*Math.pow(a,2)/(3*J2*Math.pow(RE,2)*n));
    }

    public void evaluate(Solution solution) {
        int numSatsPerPlane = EncodingUtils.getInt(solution.getVariable(0));
        int numPlanes = EncodingUtils.getInt(solution.getVariable(1));
        int alt = EncodingUtils.getInt(solution.getVariable(2)) * 50 + 400;
        int numVNIRSpec = EncodingUtils.getInt(solution.getVariable(3));
        int numSWIRSpec = EncodingUtils.getInt(solution.getVariable(4));
        boolean tir = EncodingUtils.getInt(solution.getVariable(5)) == 1;
        double focalLength = EncodingUtils.getReal(solution.getVariable(6));
        double FOV = EncodingUtils.getReal(solution.getVariable(7));
        double aperture = EncodingUtils.getReal(solution.getVariable(8));
        double pixelSizeVNIR = EncodingUtils.getReal(solution.getVariable(9));
        double pixelSizeSWIR = EncodingUtils.getReal(solution.getVariable(10));
        double agility = EncodingUtils.getReal(solution.getVariable(11));
        double[] f = new double[numberOfObjectives];

        double inc = getSSOInclination(alt)*180/Math.PI;

        SpectrometerDesign sd = new SpectrometerDesign(alt,numVNIRSpec,numSWIRSpec,tir,focalLength,FOV,aperture,pixelSizeVNIR,pixelSizeSWIR,agility);

        String path = "../VASSAR_resources";
        ArrayList<String> orbitList = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
        int r = numPlanes;
        int s = numSatsPerPlane;
        for(int m = 0; m < r; m++) {
            for(int n = 0; n < s; n++) {
                int pu = 360 / (r*s);
                int delAnom = pu * r; //in plane spacing between satellites
                int delRAAN = pu * s; //node spacing
                int RAAN = delRAAN * m;
                int g = 1;
                int phasing = pu * g;
                int anom = (n * delAnom + phasing * m);
                String orbitName = "LEO-"+alt+"-"+inc+"-"+RAAN+"-"+anom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                } else {
                    System.out.println("Duplicate orbit name!");
                }
                OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"CustomInstrument"},orbitName);
                satellites.add(radarOnlySatellite);
            }
        }
        SimpleArchitecture architecture = new SimpleArchitecture(satellites);
        architecture.setRepeatCycle(0);
        architecture.setName(inc+", "+alt+", " );
        String[] orbList = new String[orbitList.size()];
        //System.out.println("Spectrometer mass (kg): "+sd.getMass());
        //System.out.println("Spectrometer power (W): "+sd.getPower());
        //System.out.println("Data rate (Mbps): "+sd.getDataRate());
        for (int i = 0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        try {
            SimpleParams params = new SimpleParams(orbList, "XGrants", path, "CRISP-ATTRIBUTES", "test", "fast", sd);
            DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
            ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
            evaluationManager.init(1);
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            evaluationManager.clear();
            f[0] = result.getCost();
            f[1] = -result.getScience();
            solution.setAttribute("hsr",sd.getSpatialResolution());
            solution.setAttribute("swath",sd.getSwath());
            solution.setAttribute("vnirSNR",sd.getVNIRSNR());
            solution.setAttribute("swirSNR",sd.getSWIRSNR());
            solution.setAttribute("spectralResolution",sd.getSpectralResolution());
            solution.setAttribute("overlap",result.getOverlap());
            solution.setAttribute("mrt",result.getMRT());
        } catch (Exception e) {
            e.printStackTrace();
        }
        solution.setObjectives(f);
    }
}
