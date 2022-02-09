package seakers.vassar;

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.entity.UrlEncodedFormEntity;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.HttpEntity;
import org.apache.hc.core5.http.NameValuePair;
import org.apache.hc.core5.http.ParseException;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.message.BasicNameValuePair;
import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.ss.usermodel.*;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.moeaframework.core.Solution;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.core.variable.RealVariable;
import org.moeaframework.problem.AbstractProblem;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDSimpleEvaluator;
import seakers.vassar.problems.OrbitInstrumentObject;
import seakers.vassar.problems.SimpleArchitecture;
import seakers.vassar.problems.SimpleParams;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class RadarArchProblem extends AbstractProblem {
    public RadarArchProblem() {
        super(7,5,1);
    }
    public Solution newSolution() {
        Solution solution = new Solution(getNumberOfVariables(),getNumberOfObjectives());
        solution.setVariable(0, EncodingUtils.newInt(1,5)); // number of radar satellites
        solution.setVariable(1, new RealVariable(450.0,550.0)); // altitude of radar satellites
        solution.setVariable(2, new RealVariable(45.0,90.0)); // inclination of radar satellites
        solution.setVariable(3, new RealVariable(1.0,20.0)); // dAz
        solution.setVariable(4, new RealVariable(1.0,20.0)); // dEl
        solution.setVariable(5, new RealVariable(1e5,1e6)); // chirpBW
        solution.setVariable(6, new RealVariable(1e-6,1e-5)); // pulse width
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
        instrumentParams.add(new BasicNameValuePair("height", Double.toString(dAz)));
        instrumentParams.add(new BasicNameValuePair("width", Double.toString(dEl)));
        instrumentParams.add(new BasicNameValuePair("pulseWidth",Double.toString(pulseWidth)));
        instrumentParams.add(new BasicNameValuePair("chirpBW",Double.toString(chirpBW)));
        httpPost.setEntity(new UrlEncodedFormEntity(instrumentParams));
        JSONObject radarResult = new JSONObject();
        CloseableHttpResponse response = null;
        try {
            response = client.execute(httpPost);
            HttpEntity entity = response.getEntity();
            String jsonString = EntityUtils.toString(entity, StandardCharsets.UTF_8);
            if(jsonString.equals("radar design not valid")) {
                System.out.println("radar design not valid");
            } else {
                JSONParser parser = new JSONParser();
                radarResult = (JSONObject) parser.parse(jsonString);
            }
            client.close();
        } catch (IOException | ParseException | org.json.simple.parser.ParseException e) {
            e.printStackTrace();
        }

        File xlsFile = new File("/home/ben/Documents/VASSAR_resources/problems/Designer/xls/Instrument Capability Definition.xls");
        try {
            //Creating input stream
            FileInputStream inputStream = new FileInputStream(xlsFile);

            //Creating workbook from input stream
            Workbook workbook = WorkbookFactory.create(inputStream);

            //Reading first sheet of excel file
            Sheet sheet = workbook.getSheetAt(1);
            System.out.println(sheet.getSheetName());

            //Getting the count of existing records
            int rowCount = sheet.getLastRowNum();

            Row lElecRow = sheet.getRow(22); // CustomLSAR
            Cell lElecMass = lElecRow.getCell(26);
            Row lAntRow = sheet.getRow(24); // CustomLANT
            Cell lAntMass = lAntRow.getCell(26);
            lElecMass.setCellValue("mass# "+Math.floor(rd.getElectronicsMass() * 100) / 100);
            lAntMass.setCellValue("mass# "+Math.floor(rd.getAntennaMass() * 100) / 100);

            //Close input stream
            inputStream.close();

            //Crating output stream and writing the updated workbook
            FileOutputStream os = new FileOutputStream(xlsFile);
            workbook.write(os);

            //Close the workbook and output stream
            workbook.close();
            os.close();

            System.out.println("Excel file has been updated successfully.");

        } catch (EncryptedDocumentException | IOException e) {
            System.err.println("Exception while updating an existing excel file.");
            e.printStackTrace();
        }


        String path = "/home/ben/Documents/VASSAR_resources";
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
            f[4] = Double.parseDouble((String) radarResult.get("NESZ [dB]"));
            solution.setObjectives(f);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
