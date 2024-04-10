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

public class XGrantsProblemPlanner extends AbstractProblem {
    public XGrantsProblemPlanner() {
        super(10,2,0);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // number of satellites
        solution.setVariable(1, EncodingUtils.newInt(1,5)); // number of planes
        solution.setVariable(2, EncodingUtils.newInt(1,10)); // altitude of satellites (between 400 and 900 km)
        solution.setVariable(3, new RealVariable(0.0,110.0)); // inclination of satellites
        solution.setVariable(4, EncodingUtils.newInt(3,1000)); // num spectral pixels in VNIR
        solution.setVariable(5, new RealVariable(0.01,2.0)); // focal length (m)
        solution.setVariable(6, new RealVariable(0.1,10)); // FOV (deg)
        solution.setVariable(7, new RealVariable(0.01, 2.0)); // aperture (m)
        solution.setVariable(8, new RealVariable(1e-6,20e-6)); // VNIR pixel size (m)
        solution.setVariable(9, new RealVariable(0.01,10.0)); // agility (deg/s)
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
        double inc = EncodingUtils.getReal(solution.getVariable(3));
        int numVNIRSpec = EncodingUtils.getInt(solution.getVariable(4));
        double focalLength = EncodingUtils.getReal(solution.getVariable(5));
        double FOV = EncodingUtils.getReal(solution.getVariable(6));
        double aperture = EncodingUtils.getReal(solution.getVariable(7));
        double pixelSizeVNIR = EncodingUtils.getReal(solution.getVariable(8));
        double agility = EncodingUtils.getReal(solution.getVariable(9));
        double[] f = new double[numberOfObjectives];

        SpectrometerDesign sd = new SpectrometerDesign(alt,numVNIRSpec,focalLength,FOV,aperture,pixelSizeVNIR,agility);

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
        CloseableHttpClient client = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://localhost:5000");
        List<NameValuePair> constellationParams = new ArrayList<NameValuePair>();
        DecimalFormat df = new DecimalFormat("0", DecimalFormatSymbols.getInstance(Locale.ENGLISH));
        df.setMaximumFractionDigits(340);
        constellationParams.add(new BasicNameValuePair("n_s", df.format(numSatsPerPlane)));
        constellationParams.add(new BasicNameValuePair("n_p", df.format(numPlanes)));
        constellationParams.add(new BasicNameValuePair("alt",df.format(alt)));
        constellationParams.add(new BasicNameValuePair("inc",df.format(inc)));
        constellationParams.add(new BasicNameValuePair("fov",df.format(FOV)));
        constellationParams.add(new BasicNameValuePair("agility",df.format(agility)));
        constellationParams.add(new BasicNameValuePair("spectral_pixels",df.format(numVNIRSpec)));
        constellationParams.add(new BasicNameValuePair("focal_length",df.format(focalLength)));
        constellationParams.add(new BasicNameValuePair("aperture",df.format(aperture)));
        constellationParams.add(new BasicNameValuePair("pixel_size",df.format(pixelSizeVNIR)));
        try {
            httpPost.setEntity(new UrlEncodedFormEntity(constellationParams));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        JSONObject radarResult = new JSONObject();
        CloseableHttpResponse response = null;
        try {
            response = client.execute(httpPost);
            HttpEntity entity = response.getEntity();
            String jsonString = EntityUtils.toString(entity, StandardCharsets.UTF_8);
            JSONParser parser = new JSONParser();
            System.out.println(jsonString);
            radarResult = (JSONObject) parser.parse(jsonString);
            f[1] = ((Number) radarResult.get("reward")).doubleValue();
            f[1] = f[1]*-1.0;
            client.close();
        } catch (IOException | ParseException | org.json.simple.parser.ParseException e) {
            e.printStackTrace();
        }
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
            solution.setAttribute("hsr",sd.getSpatialResolution());
            solution.setAttribute("swath",sd.getSwath());
            solution.setAttribute("vnirSNR",sd.getVNIRSNR());
            solution.setAttribute("spectralResolution",sd.getSpectralResolution());
        } catch (Exception e) {
            e.printStackTrace();
        }
        solution.setObjectives(f);
    }
}