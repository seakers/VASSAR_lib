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
import seakers.vassar.utils.RadarDesign;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class RadarFixedInsAltProblem extends AbstractProblem {
    public RadarFixedInsAltProblem() {
        super(3,2,1);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // sats per plane
        solution.setVariable(1, EncodingUtils.newInt(1,4)); // num planes
        solution.setVariable(2, new RealVariable(45.0,90.0)); // inclination of radar satellites
        solution.setConstraint(0, 0.0);
        return solution;
    }

    public void evaluate(Solution solution) {
        int numSatsPerPlane = EncodingUtils.getInt(solution.getVariable(0));
        int numPlanes = EncodingUtils.getInt(solution.getVariable(1));
        double incRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(2)) * 100) / 100;
        double[] f = new double[numberOfObjectives];
        double[] c = new double[numberOfConstraints];

        String path = "../VASSAR_resources";
        ArrayList<String> orbitList = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
        int r = numPlanes;
        int s = numSatsPerPlane;
        for(int m = 0; m < r; m++) {
            for(int n = 0; n < s; n++) {
                int pu = 360 / (r* s);
                int delAnom = pu * r; //in plane spacing between satellites
                int delRAAN = pu * s; //node spacing
                int RAAN = delRAAN * m;
                int g = 1;
                int phasing = pu * g;
                int anom = (n * delAnom + phasing * m);
                String orbitName = "LEO-500-"+incRadarSats+"-"+RAAN+"-"+anom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                }
                OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"L-band_SAR","P-band_SAR"},orbitName);
                satellites.add(radarOnlySatellite);
            }
        }
        SimpleArchitecture architecture = new SimpleArchitecture(satellites);
        architecture.setRepeatCycle(0);
        architecture.setName(incRadarSats+", 500, " );
        String[] orbList = new String[orbitList.size()];
        //System.out.println("Antenna mass (kg): "+rd.getAntennaMass());
        //System.out.println("Electronics mass (kg): "+rd.getElectronicsMass());
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        try{
            SimpleParams params = new SimpleParams(orbList, "Designer", path, "CRISP-ATTRIBUTES","test", "normal");
            DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
            ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
            evaluationManager.init(1);
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            evaluationManager.clear();
            architecture.setCoverage(result.getCoverage());
            f[0] = result.getCost();
            f[1] = architecture.getAllMaxRevisit();
            c[0] = architecture.getAllCoverage()-1.0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        solution.setObjectives(f);
        solution.setConstraints(c);
    }
}
