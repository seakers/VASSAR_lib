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
import seakers.vassar.utils.RadarDesign;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import static java.lang.Double.NaN;

public class RadarScienceProblem extends AbstractProblem {
    public RadarScienceProblem() {
        super(8,2,2);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // number of radar satellites
        solution.setVariable(7, EncodingUtils.newInt(1,4)); // number of planes
        solution.setVariable(1, new RealVariable(300.0,1000.0)); // altitude of radar satellites
        solution.setVariable(2, new RealVariable(45.0,90.0)); // inclination of radar satellites
        solution.setVariable(3, new RealVariable(0.1,15.0)); // dAz
        solution.setVariable(4, new RealVariable(0.1,15.0)); // dEl
        solution.setVariable(5, new RealVariable(1e6,80e6)); // chirpBW
        solution.setVariable(6, new RealVariable(1,1000)); // pulse width
        solution.setConstraint(0, 0.0);
        solution.setConstraint(1, 0.0);
        return solution;
    }

    public void evaluate(Solution solution) {
        int numSatsPerPlane = EncodingUtils.getInt(solution.getVariable(0));
        int numPlanes = EncodingUtils.getInt(solution.getVariable(7));
        double altRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(1)) * 100) / 100;
        double incRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(2)) * 100) / 100;
        double dAz = Math.floor(EncodingUtils.getReal(solution.getVariable(3)) * 100) / 100;
        double dEl = Math.floor(EncodingUtils.getReal(solution.getVariable(4)) * 100) / 100;
        double chirpBW = EncodingUtils.getReal(solution.getVariable(5));
        double pulseWidth = EncodingUtils.getReal(solution.getVariable(6));
        double[] f = new double[numberOfObjectives];
        double[] c = new double[numberOfConstraints];
        double snez = 0.0;
        double nlooks = 0.0;

        CloseableHttpClient client = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://localhost:5000");



        List<NameValuePair> instrumentParams = new ArrayList<NameValuePair>();
        DecimalFormat df = new DecimalFormat("0", DecimalFormatSymbols.getInstance(Locale.ENGLISH));
        df.setMaximumFractionDigits(340);
        instrumentParams.add(new BasicNameValuePair("height", df.format(dAz)));
        instrumentParams.add(new BasicNameValuePair("width", df.format(dEl)));
        instrumentParams.add(new BasicNameValuePair("pulseWidth",df.format(pulseWidth*1e-6)));
        instrumentParams.add(new BasicNameValuePair("chirpBW",df.format(chirpBW)));
        instrumentParams.add(new BasicNameValuePair("altitude",df.format(altRadarSats)));
        try {
            httpPost.setEntity(new UrlEncodedFormEntity(instrumentParams));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        JSONObject radarResult = new JSONObject();
        CloseableHttpResponse response = null;
        double atRes = 0.0;
        double ctRes = 0.0;
        try {
            response = client.execute(httpPost);
            HttpEntity entity = response.getEntity();
            String jsonString = EntityUtils.toString(entity, StandardCharsets.UTF_8);
            if(jsonString.equals("radar design not valid")) {
                System.out.println("radar design not valid");
                c[1] = 1.0;
            } else {
                JSONParser parser = new JSONParser();
                radarResult = (JSONObject) parser.parse(jsonString);
                snez = (double) radarResult.get("NESZ [dB]");
                atRes = (double) radarResult.get("ground pixel along-track resolution [m]");
                ctRes = (double) radarResult.get("ground pixel cross-track resolution [m]");
                nlooks = -1e6/(atRes * ctRes);
                c[1] = 0.0;
            }
            client.close();
        } catch (IOException | ParseException | org.json.simple.parser.ParseException e) {
            e.printStackTrace();
        }
        RadarDesign rd = new RadarDesign(dAz,dEl,atRes,ctRes,nlooks,altRadarSats);
        double[] smError = null;
        if(c[1] == 0.0) {
            CloseableHttpClient smClient = HttpClients.createDefault();
            HttpPost smHttpPost = new HttpPost("http://localhost:8080");
            List<NameValuePair> instrumentSpecs = new ArrayList<NameValuePair>();
            instrumentSpecs.add(new BasicNameValuePair("snez", df.format(snez)));
            instrumentSpecs.add(new BasicNameValuePair("nlooks", df.format(-nlooks)));
            try {
                smHttpPost.setEntity(new UrlEncodedFormEntity(instrumentSpecs));
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
            JSONObject smResult;
            CloseableHttpResponse smResponse;
            try {
                smResponse = smClient.execute(smHttpPost);
                HttpEntity entity = smResponse.getEntity();
                String jsonString = EntityUtils.toString(entity, StandardCharsets.UTF_8);
                JSONParser parser = new JSONParser();
                smResult = (JSONObject) parser.parse(jsonString);
                ArrayList<Double> smErrorList = new ArrayList<>();
                for (Object o : smResult.values()) {
                    smErrorList.add((double) o);
                }
                smError = smErrorList.stream().mapToDouble(Double::doubleValue).toArray();
                smClient.close();
            } catch (IOException | ParseException | org.json.simple.parser.ParseException e) {
                e.printStackTrace();
            }


            String path = "../VASSAR_resources";
            ArrayList<String> orbitList = new ArrayList<>();
            ArrayList<OrbitInstrumentObject> satellites = new ArrayList<>();
            int r = numPlanes;
            int s = numSatsPerPlane;
            for (int m = 0; m < r; m++) {
                for (int n = 0; n < s; n++) {
                    int pu = 360 / (r * s);
                    int delAnom = pu * r; //in plane spacing between satellites
                    int delRAAN = pu * s; //node spacing
                    int RAAN = delRAAN * m;
                    int g = 1;
                    int phasing = pu * g;
                    int anom = (n * delAnom + phasing * m);
                    String orbitName = "LEO-" + altRadarSats + "-" + incRadarSats + "-" + RAAN + "-" + anom;
                    if (!orbitList.contains(orbitName)) {
                        orbitList.add(orbitName);
                    }
                    OrbitInstrumentObject radarOnlySatellite = new OrbitInstrumentObject(new String[]{"CustomLSAR", "P-band_SAR"}, orbitName);
                    satellites.add(radarOnlySatellite);
                }
            }
            SimpleArchitecture architecture = new SimpleArchitecture(satellites);
            architecture.setRepeatCycle(0);
            architecture.setName(incRadarSats + ", " + altRadarSats + ", ");
            String[] orbList = new String[orbitList.size()];
            System.out.println("Antenna mass (kg): " + rd.getAntennaMass());
            System.out.println("Electronics mass (kg): " + rd.getElectronicsMass());
            System.out.println("Data rate (kbps): " + rd.getDataRate());
            for (int i = 0; i < orbitList.size(); i++)
                orbList[i] = orbitList.get(i);
            try {
                SimpleParams params = new SimpleParams(orbList, "Designer", path, "CRISP-ATTRIBUTES", "test", "normal", rd.getAntennaMass(), rd.getElectronicsMass(), rd.getDataRate());
                DSHIELDSimpleEvaluator evaluator = new DSHIELDSimpleEvaluator(smError);
                ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
                evaluationManager.init(1);
                Result result = evaluationManager.evaluateArchitectureSync(architecture, "Slow");
                evaluationManager.clear();
                architecture.setCoverage(result.getCoverage());
                f[0] = result.getCost();
                f[1] = architecture.getScienceReward();
                System.out.println(f[1]);
                c[0] = architecture.getAllCoverage() - 1.0;
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            f[0] = 0.0;
            f[1] = 0.0;
            c[0] = 1.0;
        }
        solution.setObjectives(f);
        solution.setConstraints(c);
    }
}
