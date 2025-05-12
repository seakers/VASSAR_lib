package seakers.vassar;
import java.io.File;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.eclipse.paho.client.mqttv3.*;
import seakers.vassar.Result;
import seakers.vassar.problems.Assigning.ArchitectureEvaluator;
import seakers.vassar.problems.Assigning.AssigningParams;
import seakers.vassar.problems.Assigning.ClimateCentricParams;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class VASSAREvaluator {

    // MQTT Broker details
    private static final String BROKER_ADDRESS = "tcp://localhost:1883"; // Replace with your broker address
    private static final String CLIENT_ID = "VASSAR_Evaluator";
    private static final String RESULT_TOPIC_PREFIX = "evaluators/VASSAR/results";

    // Implemented function
    private static final String FUNCTION_NAME = "ScienceModel";

    // MQTT client
    private MqttClient client;

    // Executor service for handling requests asynchronously
    private ExecutorService executorService = Executors.newFixedThreadPool(10);

    // Gson instance for JSON parsing
    private static final Gson gson = new Gson();

    public static void main(String[] args) {
        VASSAREvaluator evaluator = new VASSAREvaluator();
        evaluator.start();
    }

    public void start() {
        try {
            client = new MqttClient(BROKER_ADDRESS, CLIENT_ID);
            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(true);

            client.setCallback(new MqttCallbackExtended() {
                @Override
                public void connectionLost(Throwable cause) {
                    System.err.println("Connection lost: " + cause.getMessage());
                }

                @Override
                public void messageArrived(String topic, MqttMessage message) {
                    processMessage(topic, message);
                }

                @Override
                public void deliveryComplete(IMqttDeliveryToken token) {
                    // Not used
                }

                @Override
                public void connectComplete(boolean reconnect, String serverURI) {
                    System.out.println("Connected to MQTT Broker!");
                    subscribeToTopics();
                }
            });

            client.connect(options);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void subscribeToTopics() {
        try {
            String topic = "evaluators/VASSAR/" + FUNCTION_NAME;
            client.subscribe(topic);
            System.out.println("Subscribed to topic: " + topic);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    private void processMessage(String topic, MqttMessage message) {
        executorService.submit(() -> {
            try {
                String payload = new String(message.getPayload());
                System.out.println("Received message on topic " + topic + ": " + payload);

                JsonObject data = JsonParser.parseString(payload).getAsJsonObject();

                // Extract the function name from the topic
                String[] topicParts = topic.split("/");
                if (topicParts.length >= 3) {
                    String functionName = topicParts[2];
                    if (FUNCTION_NAME.equals(functionName)) {
                        // Process the request
                        processRequest(functionName, data);
                    } else {
                        System.err.println("Unknown function: " + functionName);
                    }
                } else {
                    System.err.println("Invalid topic format: " + topic);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private void processRequest(String functionName, JsonObject data) {
        try {
            // Check if the message contains the necessary fields
            if (data.has("workflow_id") && data.has("result_topic")) {
                String workflowId = data.get("workflow_id").getAsString();
                String publishMetricsTopic = data.get("result_topic").getAsString();
                System.out.println("Processing request for workflow ID: " + workflowId);
                System.out.println("Function to execute: " + functionName);
                JsonObject architecture = data.getAsJsonObject("architecture");
                // Extract the dependencies
                JsonObject dependencies = data.getAsJsonObject("dependencies");

                // Execute the requested function
                JsonObject resultData = executeFunction(functionName, dependencies, architecture);

                // Prepare the result message
                JsonObject result = new JsonObject();
                result.addProperty("evaluator", "VASSAR");
                result.addProperty("workflow_id", workflowId);
                result.addProperty("function", functionName);
                result.add("results", resultData);

                // Determine the result topic
                String resultTopic = RESULT_TOPIC_PREFIX + "/" + functionName;

                // Publish the result
                MqttMessage message = new MqttMessage(gson.toJson(result).getBytes());
                client.publish(resultTopic, message);
                System.out.println("Published result to topic " + resultTopic + ": " + result.toString());
                client.publish(publishMetricsTopic, message);
                System.out.println("Published result to topic " + publishMetricsTopic + ": " + result.toString());
            } else {
                System.err.println("Missing required fields in the message.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JsonObject executeFunction(String functionName, JsonObject dependencies, JsonObject architecture) throws Exception {
        if (!FUNCTION_NAME.equals(functionName)) {
            throw new IllegalArgumentException("Function " + functionName + " is not implemented.");
        }

        System.out.println("Executing function: " + functionName);

        HashMap<String, JsonObject> dependencyResults = new HashMap<>();

        // For each dependency, send HTTP request and get the result
//        if (dependencies != null && dependencies.has(functionName)) {
//            JsonObject functionDependencies = dependencies.getAsJsonObject(functionName);
//            JsonObject deps = functionDependencies.getAsJsonObject("dependencies");
//            for (String dependencyName : deps.keySet()) {
//                // Get the URL for the dependency
//                String dependencyUrl = deps.get(dependencyName).getAsString();
//                System.out.println("Requesting dependency " + dependencyName + " from " + dependencyUrl);
//
//                // Build the request payload
//                JsonObject requestPayload = new JsonObject();
//                requestPayload.add("architecture", architecture);
//                requestPayload.addProperty("workflow_id", architecture.has("workflow_id") ? architecture.get("workflow_id").getAsString() : "0");
//                requestPayload.addProperty("function", dependencyName);
//
//                try {
//                     //Send the request to the dependency via HTTP POST
//                    JsonObject dependencyResult = sendHttpPost(dependencyUrl, requestPayload);
//                    dependencyResults.put(dependencyName, dependencyResult);
//                    System.out.println("Received result for dependency " + dependencyName + ": " + dependencyResult.toString());
//                } catch (Exception e) {
//                    System.err.println("Error requesting dependency " + dependencyName + ": " + e.getMessage());
//                    e.printStackTrace();
//                    throw e;
//                }
//            }
//        }
        JsonObject result_dep = new JsonObject();
        dependencyResults.put("results", result_dep);
        // All dependencies have been resolved, execute the main function
        JsonObject result = executeScienceModel(architecture, dependencyResults);


        System.out.println("Function " + functionName + " execution completed.");
        return result;
    }

    private JsonObject sendHttpPost(String urlString, JsonObject payload) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setDoOutput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");

        String input = gson.toJson(payload);

        OutputStream os = conn.getOutputStream();
        os.write(input.getBytes());
        os.flush();

        if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
            throw new RuntimeException("Failed : HTTP error0code : " + conn.getResponseCode());
        }

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));

        String output;
        StringBuilder responseStrBuilder = new StringBuilder();
        while ((output = br.readLine()) != null) {
            responseStrBuilder.append(output);
        }

        conn.disconnect();

        return JsonParser.parseString(responseStrBuilder.toString()).getAsJsonObject();
    }
    public static void saveObjectToFile(Object object, String filePath) {
        try (FileOutputStream fileOut = new FileOutputStream(filePath);
             ObjectOutputStream out = new ObjectOutputStream(fileOut)) {
            out.writeObject(object);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Load an object from a file
    public static Object loadObjectFromFile(String filePath) {
        try (FileInputStream fileIn = new FileInputStream(filePath);
             ObjectInputStream in = new ObjectInputStream(fileIn)) {
            return in.readObject();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private JsonObject executeScienceModel(JsonObject architectureJson, HashMap<String, JsonObject> dependencyResults) {
        JsonObject result = new JsonObject();
        try {
            String paramsFile = "params.ser";
            // Getting params
            String resourcesPath = new File(System.getProperty("user.dir")).getParent() + File.separator + "VASSAR_resources";
            //String resourcesPath = new File("C:\\Users\\dfornos\\OneDrive - Texas A&M University\\Desktop\\VASSAR_3D_Chess_Augmentation\\VASSAR_resources").getAbsolutePath();
            AssigningParams params;
//            if (new File(paramsFile).exists()) {
//                params = (AssigningParams) loadObjectFromFile(paramsFile);
//            } else {
//                params = new ClimateCentricParams(resourcesPath, "CRISP-ATTRIBUTES",
//                        "test", "normal");
//                saveObjectToFile(params, paramsFile);
//            }

            params = new ClimateCentricParams(resourcesPath, "CRISP-ATTRIBUTES",
                    "test", "normal");
            //saveObjectToFile(params, paramsFile);


            // Convert JsonObject to JSONObject for compatibility
            org.json.JSONObject arch = new org.json.JSONObject(architectureJson.toString());

            // Extract dependency data as needed
            // For example, you might need revisit time from a dependency
            double harmonicMeanRevisitTime = 1.0; // Default value
//            for (JsonObject value : dependencyResults.values()) {
//                if (value.has("results")) {
//                    JsonObject resultsObject = value.getAsJsonObject("results");
//                    if (resultsObject.has("HarmonicMeanRevisitTime")) {
//                        harmonicMeanRevisitTime = resultsObject.get("HarmonicMeanRevisitTime").getAsDouble();
//                        System.out.println("Harmonic Mean Revisit Time: " + harmonicMeanRevisitTime);
//                    }
//                }
//            }
            //JSONObject results = dependencyResults.getJSONObject("results");

            // Initialize the evaluator
            ArchitectureEvaluator evaluator = new ArchitectureEvaluator();
            //JSONObject payload = transformArchitecture(arch);
// Iterate over the space segment and gather all satellites
            JSONArray spaceSegment = arch.getJSONArray("spaceSegment");
            JSONArray allSatellites = new JSONArray();

            for (int i = 0; i < spaceSegment.length(); i++) {
                JSONObject constellation = spaceSegment.getJSONObject(i);
                if (constellation.has("satellites")) {
                    JSONArray satellites = constellation.getJSONArray("satellites");
                    for (int j = 0; j < satellites.length(); j++) {
                        allSatellites.put(satellites.getJSONObject(j));
                    }
                }
            }
            JSONObject constellation = spaceSegment.getJSONObject(0);
            constellation.put("satellites", new JSONArray(allSatellites.toString()));
            // Evaluate the architecture
            Result evalResult = evaluator.evaluatePerformanceFromJSON(constellation, harmonicMeanRevisitTime, params);

            // Prepare the result
            result.addProperty("ScienceScore", evalResult.getScience());
            //result.addProperty("cost", evalResult.getCost());
            // Include other metrics from evalResult as needed

            System.out.println("Science Score: " + evalResult.getScience());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    private JSONObject transformArchitecture(JSONObject arch){
        JSONArray spaceSegment = arch.getJSONArray("spaceSegment");
        JSONObject satellite = spaceSegment.getJSONObject(0).getJSONArray("satellites").getJSONObject(0);

        // Create a new JSONObject with the desired structure.
        JSONObject newSatellite = new JSONObject();
        newSatellite.put("@type", satellite.getString("@type"));
        newSatellite.put("@id", satellite.getString("@id"));
        newSatellite.put("name", satellite.getString("name"));
        newSatellite.put("acronym", satellite.getString("acronym"));
        newSatellite.put("mass", JSONObject.NULL);
        newSatellite.put("dryMass", JSONObject.NULL);
        newSatellite.put("volume", JSONObject.NULL);
        newSatellite.put("power", JSONObject.NULL);
        newSatellite.put("commBand", satellite.getJSONArray("commBand"));
        newSatellite.put("techReadinessLevel", satellite.getInt("techReadinessLevel"));
        newSatellite.put("isGroundCommand", satellite.getBoolean("isGroundCommand"));
        newSatellite.put("isSpare", satellite.getBoolean("isSpare"));
        newSatellite.put("propellantType", satellite.getString("propellantType"));
        newSatellite.put("stabilizationType", satellite.getString("stabilizationType"));

        // Copy the payload array and modify it as needed.
        JSONArray newPayloadArray = new JSONArray();
        JSONArray payloadArray = satellite.getJSONArray("payload");

        for (int i = 0; i < payloadArray.length(); i++) {
            JSONObject payload = payloadArray.getJSONObject(i);
            JSONObject newPayload = new JSONObject();
            newPayload.put("scanTechnique", payload.getString("scanTechnique"));
            newPayload.put("numberOfDetectorsRowsAlongTrack", JSONObject.NULL);
            newPayload.put("numberOfDetectorsColsCrossTrack", JSONObject.NULL);
            newPayload.put("Fnum", JSONObject.NULL);
            newPayload.put("focalLength", JSONObject.NULL);
            newPayload.put("apertureDia", JSONObject.NULL);
            newPayload.put("operatingWavelength", JSONObject.NULL);
            newPayload.put("bandwidth", JSONObject.NULL);
            newPayload.put("opticsSysEff", JSONObject.NULL);
            newPayload.put("quantumEff", JSONObject.NULL);
            newPayload.put("numOfReadOutE", JSONObject.NULL);
            newPayload.put("targetBlackBodyTemp", payload.getDouble("targetBlackBodyTemp"));
            newPayload.put("temperatureRange", payload.getJSONArray("tempRange"));
            newPayload.put("detectorWidth", JSONObject.NULL);
            newPayload.put("maxDetectorExposureTime", JSONObject.NULL);
            newPayload.put("snrThreshold", JSONObject.NULL);
            newPayload.put("name", payload.getString("name"));
            newPayload.put("acronym", payload.getString("acronym"));
            newPayload.put("mass", payload.getDouble("mass"));
            newPayload.put("dimensions", payload.getJSONArray("dimensions"));
            newPayload.put("volume", payload.getDouble("volume"));
            newPayload.put("power", payload.getDouble("power"));
            newPayload.put("peakPower", payload.getDouble("power"));
            newPayload.put("resolution", payload.getDouble("resolution"));

            // Add the orientation object with nullified fields.
            JSONObject orientation = payload.getJSONObject("orientation");
            JSONObject newOrientation = new JSONObject();
            //newOrientation.put("convention", orientation.getString("convention"));
            newOrientation.put("sideLookAngle", JSONObject.NULL);
            newOrientation.put("@type", orientation.getString("@type"));
            newPayload.put("orientation", newOrientation);

            // Add the fieldOfView object with some nullified fields.
            JSONObject fieldOfView = payload.getJSONObject("fieldOfView");
            JSONObject newFieldOfView = new JSONObject();
            newFieldOfView.put("sensorGeometry", fieldOfView.getString("sensorGeometry"));
            newFieldOfView.put("fullConeAngle", JSONObject.NULL);
            newFieldOfView.put("alongTrackFieldOfView", JSONObject.NULL);
            newFieldOfView.put("crossTrackFieldOfView", fieldOfView.getDouble("crossTrackFieldOfView"));
            newFieldOfView.put("fieldOfRegard", fieldOfView.getDouble("fieldOfRegard"));
            newFieldOfView.put("@type", fieldOfView.getString("@type"));
            newPayload.put("fieldOfView", newFieldOfView);

            newPayload.put("dataRate", payload.getDouble("dataRate"));
            newPayload.put("bitsPerPixel", JSONObject.NULL);
            newPayload.put("techReadinessLevel", JSONObject.NULL);
            newPayload.put("mountType", payload.getString("mountType"));
            newPayload.put("@type", payload.getString("@type"));

            newPayloadArray.put(newPayload);
        }

        newSatellite.put("payload", newPayloadArray);

        // Add the orbit object with modified fields.
        JSONObject orbit = satellite.getJSONObject("orbit");
        JSONObject newOrbit = new JSONObject();
        newOrbit.put("@type", orbit.getString("@type"));
        newOrbit.put("orbitType", "KEPLERIAN");
        newOrbit.put("semimajorAxis", orbit.getDouble("semimajorAxis"));
        newOrbit.put("inclination", orbit.getDouble("inclination"));
        newOrbit.put("eccentricity", orbit.getDouble("eccentricity"));
        newOrbit.put("periapsisArgument", orbit.getDouble("periapsisArgument"));
        newOrbit.put("rightAscensionAscendingNode", orbit.getDouble("rightAscensionAscendingNode"));
        newOrbit.put("trueAnomaly", orbit.getDouble("trueAnomaly"));
        newOrbit.put("epoch", orbit.getString("epoch"));

        newSatellite.put("orbit", newOrbit);
        return  newSatellite;
        // Print or use the new JSON object.
    }

}
