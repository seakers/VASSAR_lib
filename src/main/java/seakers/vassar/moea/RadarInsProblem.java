package seakers.vassar.moea;

import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.ParseException;
import org.apache.http.util.EntityUtils;
import org.apache.http.message.BasicNameValuePair;
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

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import static java.lang.Double.NaN;

public class RadarInsProblem extends AbstractProblem {
    public RadarInsProblem() {
        super(7,4,2);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives(),getNumberOfConstraints());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // number of radar satellites
        solution.setVariable(1, new RealVariable(450.0,550.0)); // altitude of radar satellites
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
        int numRadarSats = EncodingUtils.getInt(solution.getVariable(0));
        double altRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(1)) * 100) / 100;
        double incRadarSats = Math.floor(EncodingUtils.getReal(solution.getVariable(2)) * 100) / 100;
        double dAz = Math.floor(EncodingUtils.getReal(solution.getVariable(3)) * 100) / 100;
        double dEl = Math.floor(EncodingUtils.getReal(solution.getVariable(4)) * 100) / 100;
        double chirpBW = EncodingUtils.getReal(solution.getVariable(5));
        double pulseWidth = EncodingUtils.getReal(solution.getVariable(6));
        double[] f = new double[numberOfObjectives];
        double[] c = new double[numberOfConstraints];

        CloseableHttpClient client = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost("http://localhost:5000");

        RadarDesign rd = new RadarDesign(dAz,dEl);

        List<NameValuePair> instrumentParams = new ArrayList<NameValuePair>();
        DecimalFormat df = new DecimalFormat("0", DecimalFormatSymbols.getInstance(Locale.ENGLISH));
        df.setMaximumFractionDigits(340);
        instrumentParams.add(new BasicNameValuePair("height", df.format(dAz)));
        instrumentParams.add(new BasicNameValuePair("width", df.format(dEl)));
        instrumentParams.add(new BasicNameValuePair("pulseWidth",df.format(pulseWidth*1e-6)));
        instrumentParams.add(new BasicNameValuePair("chirpBW",df.format(chirpBW)));
        try {
            httpPost.setEntity(new UrlEncodedFormEntity(instrumentParams));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        JSONObject radarResult = new JSONObject();
        CloseableHttpResponse response = null;
        try {
            response = client.execute(httpPost);
            HttpEntity entity = response.getEntity();
            String jsonString = EntityUtils.toString(entity, StandardCharsets.UTF_8);
            if(jsonString.equals("radar design not valid")) {
                System.out.println("radar design not valid");
                f[2] = NaN;
                f[3] = NaN;
                c[1] = 1.0;
            } else {
                JSONParser parser = new JSONParser();
                radarResult = (JSONObject) parser.parse(jsonString);
                f[2] = (double) radarResult.get("NESZ [dB]");
                double atRes = (double) radarResult.get("ground pixel along-track resolution [m]");
                double ctRes = (double) radarResult.get("ground pixel cross-track resolution [m]");
                f[3] = -1e6/(atRes * ctRes);
                c[1] = 0.0;
            }
            client.close();
        } catch (IOException | ParseException | org.json.simple.parser.ParseException e) {
            e.printStackTrace();
        }

//        File xlsFile = new File("../VASSAR_resources/problems/Designer/xls/Instrument Capability Definition.xls");
//        try {
//            //Creating input stream
//            FileInputStream inputStream = new FileInputStream(xlsFile);
//
//            //Creating workbook from input stream
//            Workbook workbook = WorkbookFactory.create(inputStream);
//
//            //Reading first sheet of excel file
//            Sheet sheet = workbook.getSheetAt(1);
//
//            //Getting the count of existing records
//            int rowCount = sheet.getLastRowNum();
//
//            Row lElecRow = sheet.getRow(22); // CustomLSAR
//            Cell lElecMass = lElecRow.getCell(26);
//            Row lAntRow = sheet.getRow(24); // CustomLANT
//            Cell lAntMass = lAntRow.getCell(26);
//            lElecMass.setCellValue("mass# "+Math.floor(rd.getElectronicsMass() * 100) / 100);
//            lAntMass.setCellValue("mass# "+Math.floor(rd.getAntennaMass() * 100) / 100);
//
//            //Close input stream
//            inputStream.close();
//
//            //Crating output stream and writing the updated workbook
//            FileOutputStream os = new FileOutputStream(xlsFile);
//            workbook.write(os);
//
//            //Close the workbook and output stream
//            workbook.close();
//            os.close();
//
//            System.out.println("Excel file has been updated successfully.");
//
//        } catch (EncryptedDocumentException | IOException e) {
//            System.err.println("Exception while updating an existing excel file.");
//            e.printStackTrace();
//        }


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
            SimpleParams params = new SimpleParams(orbList, "Designer", path, "CRISP-ATTRIBUTES","test", "normal", rd.getAntennaMass(), rd.getElectronicsMass());
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
