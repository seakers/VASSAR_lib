package seakers.vassar.moea;

import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.ParseException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
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
import seakers.vassar.utils.RadiometerDesign;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import static java.lang.Double.NaN;

public class RadioSepProblem extends AbstractProblem {
    public RadioSepProblem() {
        super(4,4,0);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, new RealVariable(45.0,90.0)); // inclination of radiometer satellites
        solution.setVariable(1, EncodingUtils.newInt(1,4)); // number of planes
        solution.setVariable(2, EncodingUtils.newInt(1,4)); // sats per plane
        solution.setVariable(3, EncodingUtils.newInt(0,47)); // radar design
        return solution;
    }

    public void evaluate(Solution solution) {
        double incRadiometerSats = Math.floor(EncodingUtils.getReal(solution.getVariable(0)) * 100) / 100;
        int numPlanes = EncodingUtils.getInt(solution.getVariable(1));
        int satsPerPlane = EncodingUtils.getInt(solution.getVariable(2));
        int radiometerIndex = EncodingUtils.getInt(solution.getVariable(3));
        double[] f = new double[numberOfObjectives];

        List<List<String>> records = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("./src/test/resources/pareto_front_radiometers.csv"))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] values = line.split(",");
                records.add(Arrays.asList(values));
            }
        }
        catch (Exception e) {
            System.out.println(e);
        }
        List<String> radiometerDesign = records.get(radiometerIndex);
        f[2] = Double.parseDouble(radiometerDesign.get(4)); //sensitivity
        f[3] = Math.sqrt(Double.parseDouble(radiometerDesign.get(3)))/1000; //pixel area
        double atres = Double.parseDouble(radiometerDesign.get(5));
        double ctres = Double.parseDouble(radiometerDesign.get(6));
        double altitude = Double.parseDouble(radiometerDesign.get(2));
        RadiometerDesign rd = new RadiometerDesign(Double.parseDouble(radiometerDesign.get(0)),Double.parseDouble(radiometerDesign.get(1)),atres,altitude);
        double fov = ctres * 180 / Math.PI / altitude / 1e3;
        if (fov > 90) {
            fov = 90;
        }
        String path = "../VASSAR_resources";
        ArrayList<String> orbitList = new ArrayList<>();
        ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
        int r = numPlanes;
        int s = satsPerPlane;
        for(int m = 0; m < r; m++) {
            for(int n = 0; n < s; n++) {
                int pu = 360 / (r* s);
                int delAnom = pu * r; //in plane spacing between satellites
                int delRAAN = pu * s; //node spacing
                int RAAN = delRAAN * m;
                int g = 1;
                int phasing = pu * g;
                int anom = (n * delAnom + phasing * m);
                String orbitName = "LEO-"+altitude+"-"+incRadiometerSats+"-"+RAAN+"-"+anom;
                if(!orbitList.contains(orbitName)) {
                    orbitList.add(orbitName);
                }
                OrbitInstrumentObject radiometerOnlySatellite = new OrbitInstrumentObject(new String[]{"CustomRadiometer"},orbitName,fov);
                satellites.add(radiometerOnlySatellite);
            }
        }
        SimpleArchitecture architecture = new SimpleArchitecture(satellites);
        architecture.setRepeatCycle(0);
        architecture.setName(incRadiometerSats+", "+altitude+", " );
        String[] orbList = new String[orbitList.size()];
        System.out.println("Antenna mass (kg): "+rd.getAntennaMass());
        System.out.println("Electronics mass (kg): "+rd.getElectronicsMass());
        System.out.println("Data rate (kbps): "+rd.getDataRate());
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
        } catch (Exception e) {
            e.printStackTrace();
        }
        solution.setObjectives(f);
    }
}
