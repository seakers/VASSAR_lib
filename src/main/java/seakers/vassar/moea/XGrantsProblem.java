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
import org.moeaframework.core.variable.BinaryVariable;
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
import seakers.vassar.utils.SpectrometerDesign;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import static java.lang.Double.NaN;

public class XGrantsProblem extends AbstractProblem {
    public XGrantsProblem() {
        super(11,2,0);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // number of radar satellites
        solution.setVariable(1, EncodingUtils.newInt(1,5)); // number of planes
        solution.setVariable(2, new RealVariable(380.0,1000.0)); // altitude of radar satellites
        solution.setVariable(3, new RealVariable(70.0,90.0)); // inclination of radar satellites
        solution.setVariable(4, EncodingUtils.newInt(3,1000)); // num spectral pixels in VNIR
        solution.setVariable(5, EncodingUtils.newInt(3,1000)); // num spectral pixels in SWIR
        solution.setVariable(6, EncodingUtils.newInt(0,1)); // SWIR presence
        solution.setVariable(7, EncodingUtils.newInt(0,1)); // TIR presence
        solution.setVariable(8, new RealVariable(0.01,10)); // focal length (m)
        solution.setVariable(9, new RealVariable(0.01,10)); // FOV (deg)
        solution.setVariable(10, new RealVariable(0.01, 10)); // aperture (m)
        return solution;
    }

    public void evaluate(Solution solution) {
        int numSatsPerPlane = EncodingUtils.getInt(solution.getVariable(0));
        int numPlanes = EncodingUtils.getInt(solution.getVariable(1));
        double alt = Math.floor(EncodingUtils.getReal(solution.getVariable(2)) * 100) / 100;
        double inc = Math.floor(EncodingUtils.getReal(solution.getVariable(3)) * 100) / 100;
        int numVNIRSpec = EncodingUtils.getInt(solution.getVariable(4));
        int numSWIRSpec = EncodingUtils.getInt(solution.getVariable(5));
        boolean swir = EncodingUtils.getInt(solution.getVariable(6)) == 1;
        boolean tir = EncodingUtils.getInt(solution.getVariable(7)) == 1;
        double focalLength = EncodingUtils.getReal(solution.getVariable(8));
        double FOV = EncodingUtils.getReal(solution.getVariable(9));
        double aperture = EncodingUtils.getReal(solution.getVariable(10));
        double[] f = new double[numberOfObjectives];

        SpectrometerDesign sd = new SpectrometerDesign(alt,numVNIRSpec,numSWIRSpec,swir,tir,focalLength,FOV,aperture);

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
                }
                OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"CustomInstrument"},orbitName);
                satellites.add(radarOnlySatellite);
            }
        }
        SimpleArchitecture architecture = new SimpleArchitecture(satellites);
        architecture.setRepeatCycle(0);
        architecture.setName(inc+", "+alt+", " );
        String[] orbList = new String[orbitList.size()];
        System.out.println("Spectrometer mass (kg): "+sd.getMass());
        System.out.println("Spectrometer power (W): "+sd.getPower());
        System.out.println("Data rate (Mbps): "+sd.getDataRate());
        for (int i = 0; i < orbitList.size(); i++)
            orbList[i] = orbitList.get(i);
        try {
            SimpleParams params = new SimpleParams(orbList, "XGrants", path, "CRISP-ATTRIBUTES", "test", "normal", sd);
            DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator();
            ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
            evaluationManager.init(1);
            Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
            evaluationManager.clear();
            f[0] = result.getCost();
            f[1] = -result.getScience();
        } catch (Exception e) {
            e.printStackTrace();
        }
        solution.setObjectives(f);
    }
}
