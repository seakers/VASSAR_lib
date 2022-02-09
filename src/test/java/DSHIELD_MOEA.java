import org.apache.commons.codec.Charsets;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.entity.UrlEncodedFormEntity;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.Header;
import org.apache.hc.core5.http.HttpEntity;
import org.apache.hc.core5.http.NameValuePair;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.message.BasicNameValuePair;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.moeaframework.Executor;
import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.Solution;
import seakers.vassar.HeteroArchProblem;
import seakers.vassar.RadarArchProblem;
import seakers.vassar.utils.ParameterStringBuilder;
import seakers.vassar.utils.PythonInterface;

import java.io.DataOutputStream;
import java.io.File;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class DSHIELD_MOEA {
    public static void main(String[] args){
        try{
            Properties properties = new Properties();
            properties.setProperty("populationSize","10");
            properties.setProperty("maxEvaluations","10");
            NondominatedPopulation result = new Executor().withProblemClass(RadarArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).withProperties(properties).run();

            //NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).distributeOnAllCores().run();
            int count = 1;
            for (Solution sol : result) {
                System.out.println("Variables for solution " + count + ":");
                System.out.println("Number of radar satellites: " + sol.getVariable(0));
                System.out.println("Altitude of radar satellites: " + sol.getVariable(1));
                System.out.println("Inclination of radar satellites: " + sol.getVariable(2));
                System.out.println("Number of cubesat planes: " + sol.getVariable(3));
                System.out.println("Cubesats per plane: " + sol.getVariable(4));
                System.out.println("Altitude of cubesats: " + sol.getVariable(5));
                System.out.println("Inclination of cubesats: " + sol.getVariable(6));
                count++;
            }
            PopulationIO.writeObjectives(new File("objectives.txt"), result);
            System.out.println(result.toString());
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}
