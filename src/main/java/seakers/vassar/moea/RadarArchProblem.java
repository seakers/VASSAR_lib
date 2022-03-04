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

public class RadarArchProblem extends AbstractProblem {
    public RadarArchProblem() {
        super(4,4,1);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // number of radar satellites
        solution.setVariable(1, new RealVariable(450.0,550.0)); // altitude of radar satellites
        solution.setVariable(2, new RealVariable(45.0,90.0)); // inclination of radar satellites
        solution.setVariable(3, EncodingUtils.newInt(0,47)); // radar design
        solution.setConstraint(0, 0.0);
        return solution;
    }

    public void evaluate(Solution solution) {
        int numRadarSats = EncodingUtils.getInt(solution.getVariable(0));
        double altRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(1)) * 100) / 100;
        double incRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(2)) * 100) / 100;
        int radarIndex = EncodingUtils.getInt(solution.getVariable(3));
        double[] f = new double[numberOfObjectives];
        double[] c = new double[numberOfConstraints];

        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/radardesigns.csv"))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }
        List<String> radar_design = records.get(radarIndex);
        RadarDesign rd = new RadarDesign(Double.parseDouble(radar_design.get(0)),Double.parseDouble(radar_design.get(1)),-Double.parseDouble(radar_design.get(5)),-Double.parseDouble(radar_design.get(6)));
        f[2] = Double.parseDouble(radar_design.get(4)); // snez
        f[3] = Double.parseDouble(radar_design.get(5)); // num looks
        String path = "../VASSAR_resources";
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
                OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"CustomLSAR","CustomLANT"},orbitName);
                satellites.add(radarOnlySatellite);
            }
        }
        SimpleArchitecture architecture = new SimpleArchitecture(satellites);
        architecture.setRepeatCycle(0);
        architecture.setName(incRadarSats+", "+altRadarSats+", " );
        String[] orbList = new String[orbitList.size()];
        System.out.println("Antenna mass (kg): "+rd.getAntennaMass());
        System.out.println("Electronics mass (kg): "+rd.getElectronicsMass());
        for (int i =0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        try{
            SimpleParams params = new SimpleParams(orbList, "Designer", path, "CRISP-ATTRIBUTES","test", "normal", rd.getAntennaMass(), rd.getElectronicsMass(), rd.getDataRate());
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
