package seakers.vassar;

import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.core.variable.RealVariable;
import org.moeaframework.problem.AbstractProblem;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;

import java.util.ArrayList;

public class HeteroArchProblem extends AbstractProblem {
    public HeteroArchProblem() {
        super(7,4,1);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // number of radar satellites
        solution.setVariable(1, new RealVariable(450.0,550.0)); // altitude of radar satellites
        solution.setVariable(2, new RealVariable(45.0,90.0)); // inclination of radar satellites
        solution.setVariable(3, EncodingUtils.newInt(1,5)); // number of cubesat planes
        solution.setVariable(4, EncodingUtils.newInt(1,5)); // cubesats per plane
        solution.setVariable(5, new RealVariable(400.0,800.0)); // altitude of cubesat constellation
        solution.setVariable(6, new RealVariable(5.0,175.0)); // inclination of cubesat constellation
        return solution;
    }

    public void evaluate(Solution solution) {
        int numRadarSats = EncodingUtils.getInt(solution.getVariable(0));
        double altRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(1)) * 100) / 100;
        double incRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(2)) * 100) / 100;
        int numCubePlanes = EncodingUtils.getInt(solution.getVariable(3));
        int numSatsPerPlane = EncodingUtils.getInt(solution.getVariable(4));
        double altCubeSats = Math.floor(EncodingUtils.getReal(solution.getVariable(5)) * 100) / 100;
        double incCubeSats = Math.floor(EncodingUtils.getReal(solution.getVariable(6)) * 100) / 100;
        double[] f = new double[numberOfObjectives];
        double[] c = new double[numberOfConstraints];

        String path = "/home/ben/Documents/VASSAR/VASSAR_resources";
        ArrayList<String> orbitList = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
        int r = 1;
        for(int m = 0; m < r; m++) {
            for(int n = 0; n < numRadarSats; n++) {
                int pu = 360 / (r* numRadarSats);
                int delAnom = pu * r; //in plane spacing between satellites
                int delRAAN = pu * numRadarSats; //node spacing
                int RAAN = delRAAN * m;
                int g = 1;
                int phasing = pu * g;
                int anom = (n * delAnom + phasing * m);
                String orbitName = "LEO-"+altRadarSats+"-"+incRadarSats+"-"+RAAN+"-"+anom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                }
                OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"L-band_SAR","P-band_SAR"},orbitName);
                satellites.add(radarOnlySatellite);
            }
        }
        for(int m = 0; m < numCubePlanes; m++) {
            for(int n = 0; n < numSatsPerPlane; n++) {
                int pu = 360 / (numCubePlanes * numSatsPerPlane);
                int delAnom = pu * numCubePlanes; //in plane spacing between satellites
                int delRAAN = pu * numSatsPerPlane; //node spacing
                int RAAN = delRAAN * m;
                int g = 1;
                int phasing = pu * g;
                int anom = (n * delAnom + phasing * m);
                String orbitName = "LEO-"+altCubeSats+"-"+incCubeSats+"-"+RAAN+"-"+anom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                }
                OrbitInstrumentObject cubesat = new OrbitInstrumentObject(new String[]{"L-band_Reflectometer","P-band_Reflectometer","FMPL-2"},orbitName);
                satellites.add(cubesat);
            }
        }
        SimpleArchitecture architecture = new SimpleArchitecture(satellites);
        architecture.setRepeatCycle(0);
        architecture.setName(incCubeSats+", repeat cycle of "+0+" days, "+ numCubePlanes +" planes, "+ numSatsPerPlane +" satellites per plane, full satellites");
        String[] orbList = new String[orbitList.size()];
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
            f[1] = architecture.getPlannerReward();
            f[2] = architecture.getAllMaxRevisit();
            c[0] = architecture.getAllCoverage()-1.0;
            f[3] = -1*architecture.getOverlap();
            solution.setObjectives(f);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
