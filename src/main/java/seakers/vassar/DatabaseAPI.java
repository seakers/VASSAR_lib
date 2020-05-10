package seakers.vassar;

// I/O
import java.io.File;
import java.io.StringWriter;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.PrintWriter; 
import java.io.BufferedWriter;
import java.util.*;

// JSON
import org.json.simple.JSONArray; 
import org.json.simple.JSONObject; 
import com.google.gson.*;


// JETBRAINS ANNOTATIONS
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

// APOLLO
import okhttp3.OkHttpClient;
import com.apollographql.apollo.ApolloCall;
import com.apollographql.apollo.ApolloClient;
// import com.apollographql.apollo.ApolloCallback;
import com.apollographql.apollo.api.Response;
import com.apollographql.apollo.exception.ApolloException;
import com.apollographql.apollo.fetcher.ApolloResponseFetchers;
import com.apollographql.apollo.cache.normalized.NormalizedCacheFactory;
import com.apollographql.apollo.subscription.WebSocketSubscriptionTransport;


// RxJava2
import com.apollographql.apollo.rx2.Rx2Apollo;
import io.reactivex.Observable;

// QUERIES
import com.example.OrbitInformationQuery;
import com.example.LaunchVehicleInformationQuery;






public class DatabaseAPI {

    private ApolloClient   apollo;
    private OkHttpClient   http;
    private File           logFile;
    private BufferedWriter writer;
    private JSONObject     json;
    private FileWriter     jsonWriter;
    private String         apollo_url;
    private String         filepath;
    private int            group_id;
    private int            problem_id;
    
    public DatabaseAPI(int group_id, int problem_id) throws Exception{
        this.apollo_url = "http://graphql:8080/v1/graphql";
        this.filepath   = "/app/logs/jessInitDB.json";

        this.logFile = new File(this.filepath);
        this.writer  = new BufferedWriter(new FileWriter(this.filepath, true));
        if(!this.logFile.createNewFile()){
            this.logFile.delete();
            this.logFile.createNewFile();
        }

        this.json       = new JSONObject();
        this.jsonWriter = new FileWriter(this.filepath); 

        this.group_id   = group_id;
        this.problem_id = problem_id;

        this.http   = new OkHttpClient.Builder().build();
        this.apollo = ApolloClient.builder().serverUrl(this.apollo_url).okHttpClient(this.http).build();
    }

    public void close() throws Exception{
        this.writer.close();
    }

    public void writeJson() throws Exception{
        this.jsonWriter.write(this.json.toJSONString());
        this.jsonWriter.flush();
    }
    
    public JSONObject getJsonObject() throws Exception{
        return this.json;
    }


    // QUERIES
    private Response<OrbitInformationQuery.Data> orbitQuery(){
        OrbitInformationQuery orbitQuery = OrbitInformationQuery.builder()
                                                                .group_id(this.group_id)
                                                                .problem_id(this.problem_id)
                                                                .build();
        ApolloCall<OrbitInformationQuery.Data>           apolloCall  = this.apollo.query(orbitQuery);
        Observable<Response<OrbitInformationQuery.Data>> observable  = Rx2Apollo.from(apolloCall);
        return observable.blockingFirst();
    }

    private Response<LaunchVehicleInformationQuery.Data> launchVehicleQuery(){
        LaunchVehicleInformationQuery orbitQuery = LaunchVehicleInformationQuery.builder()
                                                                                .group_id(this.group_id)
                                                                                .problem_id(this.problem_id)
                                                                                .build();
        ApolloCall<LaunchVehicleInformationQuery.Data>           apolloCall  = this.apollo.query(orbitQuery);
        Observable<Response<LaunchVehicleInformationQuery.Data>> observable  = Rx2Apollo.from(apolloCall);
        return observable.blockingFirst();
    }



    public void loadOrbitFacts() {
        try {
            // QUERY
            Response<OrbitInformationQuery.Data> response = orbitQuery();

            // RETURN DATA
            ArrayList<String> attribute_names  = new ArrayList<>();
            ArrayList<ArrayList<String>> facts = new ArrayList<>();
            attribute_names.add("id");

            // PARSE QUERY
            for (OrbitInformationQuery.Orbit orbit : response.data().orbit()) {

                ArrayList<String> attribute_values = new ArrayList<>();
                attribute_values.add(orbit.name());

                for (OrbitInformationQuery.Attribute attribute : orbit.attributes()) {

                    attribute_values.add(attribute.value());
                    String attribute_name = attribute.Orbit_Attribute().name();
                    if (!attribute_names.contains(attribute_name)){
                        attribute_names.add(attribute_name);
                    }

                }

                facts.add(attribute_values);
            }

            JsonArray jsonArray_names  = new Gson().toJsonTree(attribute_names).getAsJsonArray();
            JsonArray jsonArray_values = new Gson().toJsonTree(facts).getAsJsonArray();
            
            this.json.put("orbit attribute names", jsonArray_names);
            this.json.put("orbit attribute values", jsonArray_values);
        }
        catch (Exception e) {
            System.out.println("EXC in loadOrderedDeffacts " + e.getMessage());
        }
    }

    public void loadLaunchVehicleFacts() {
        try {
            // QUERY
            Response<LaunchVehicleInformationQuery.Data> response = launchVehicleQuery();

            // RETURN DATA
            ArrayList<String> attribute_names  = new ArrayList<>();
            ArrayList<ArrayList<String>> facts = new ArrayList<>();
            attribute_names.add("id");

            // PARSE QUERY
            for (LaunchVehicleInformationQuery.Vehicle launch_vehicle : response.data().vehicle()) {

                ArrayList<String> attribute_values = new ArrayList<>();
                attribute_values.add(launch_vehicle.name());

                for (LaunchVehicleInformationQuery.Attribute attribute : launch_vehicle.attributes()) {

                    attribute_values.add(attribute.value());
                    String attribute_name = attribute.Launch_Vehicle_Attribute().name();
                    if (!attribute_names.contains(attribute_name)){
                        attribute_names.add(attribute_name);
                    }

                }

                facts.add(attribute_values);
            }

            JsonArray jsonArray_names  = new Gson().toJsonTree(attribute_names).getAsJsonArray();
            JsonArray jsonArray_values = new Gson().toJsonTree(facts).getAsJsonArray();
            
            this.json.put("launch vehicle attribute names", jsonArray_names);
            this.json.put("launch vehicle attribute values", jsonArray_values);
        }
        catch (Exception e) {
            System.out.println("EXC in loadOrderedDeffacts " + e.getMessage());
        }
    }


    
    

}