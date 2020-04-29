

// APOLLO
import com.apollographql.apollo.ApolloCall;
import com.apollographql.apollo.ApolloClient;
import com.apollographql.apollo.api.Response;
import com.apollographql.apollo.exception.ApolloException;
import com.apollographql.apollo.fetcher.ApolloResponseFetchers;
import com.apollographql.apollo.cache.normalized.NormalizedCacheFactory;
import com.apollographql.apollo.subscription.WebSocketSubscriptionTransport;


// QUERIES
import com.example.MyQuery;
import okhttp3.OkHttpClient;



public class DatabaseAPI {

    private File           logFile;
    private BufferedWriter writer;
    private ApolloClient   apollo;
    private OkHttpClient   http;

    private String apollo_url;
    private String filepath;
    private int    group_id;
    private int    problem_id;
    
    public DatabaseAPI(String filename, int group_id, int problem_id) throws Exception{
        this.apollo_url = "http://graphql:8080/v1/graphql";
        this.filepath   = "/app/logs/" + filename;

        this.logFile = new File(this.filepath);
        this.write   = new BufferedWriter(new FileWriter(this.filepath, true));

        this.group_id   = group_id;
        this.problem_id = problem_id;

        if(!this.logFile.createNewFile()){
            this.logFile.delete();
            this.logFile.createNewFile();
        }

        this.http         = new OkHttpClient.Builder().build();
        this.apolloClient = new ApolloClient.builder().serverUrl(this.apollo_url).okHttpClient(this.http).build();
    }

    public writeToLog(String to_write){
        this.writer.write(to_write);
    }

    public void close() {
        this.writer.close();
    }




    // loadOrderedDeffacts(r, missionAnalysisXls, "Walker", "Walker-revisit-time-facts","DATABASE::Revisit-time-of");
    // loadOrderedDeffacts(r, missionAnalysisXls, "Power", "orbit-information-facts", "DATABASE::Orbit");
    // loadOrderedDeffacts(r, missionAnalysisXls, "Launch Vehicles", "DATABASE::launch-vehicle-information-facts", "DATABASE::Launch-vehicle");
    public void loadOrderedDeffacts(Rete r, Workbook xls, String sheet, String name, String template) {
        try {
            // 1. Query all the orbits for a problem\

            // 2. For each orbit, create an ArrayList containing all the orbit_attribute names starting with (id)
                // Add this to context

            // 3. For each orbit, create an ArrayList containing all the orbit_attribute_values (in the same order as the orbit attributes)
                // Add these to the facts then add the facts to the context


            


            PebbleEngine engine = new PebbleEngine.Builder().extension(new JessExtension()).build();
            StringWriter writer = new StringWriter();

            Map<String, Object> context = new HashMap<>();
            context.put("name", name);
            context.put("template", template);

            ArrayList<ArrayList<String>> facts = new ArrayList<>();
            Sheet meas = xls.getSheet(sheet);
            int numFacts = meas.getRows();
            int numSlots = meas.getColumns();

            for (int i = 1; i < numFacts; i++) {     // FOR EACH: row
                Cell[] row = meas.getRow(i);
                ArrayList<String> slots = new ArrayList<>();
                for (int j = 0; j < numSlots; j++) { // FOR EACH: col
                    String slot_value = row[j].getContents();
                    slots.add(slot_value);
                }
                facts.add(slots);
            }
            context.put("facts", facts);

            ArrayList<String> slotNames = new ArrayList<>();
            Cell[] slotNameCells = meas.getRow(0);
            for (int i = 0; i < numSlots; i++) {
                slotNames.add(slotNameCells[i].getContents());
            }
            context.put("slotNames", slotNames);

            context.put("startingNof", params.nof);

            engine.getTemplate(params.resourcesPath + "/templates/orderedDeffacts.clp").evaluate(writer, context);
            params.nof += (numFacts - 1);
            r.eval(writer.toString());
        }
        catch (Exception e) {
            System.out.println("EXC in loadOrderedDeffacts " + e.getMessage());
        }
    }
    
    


    private void loadMeasurementTemplate(Rete r, Workbook xls) { 
        try {
            writeToLogfile("loadMeasurementTemplate", true);
            HashMap<String, Integer> attribsToKeys = new HashMap<>();
            HashMap<Integer, String> keysToAttribs = new HashMap<>();
            HashMap<String, String> attribsToTypes = new HashMap<>();
            HashMap<String, EOAttribute> attribSet = new HashMap<>();
            params.parameterList = new ArrayList<>();

            Sheet meas = xls.getSheet("Measurement");

            PebbleEngine engine = new PebbleEngine.Builder().extension(new JessExtension()).build();
            StringWriter writer = new StringWriter();
            Map<String, Object> context = new HashMap<>();

            int numSlots = meas.getRows();
            ArrayList<SlotInfo> slots = new ArrayList<>();
            for (int i = 1; i < numSlots; i++) {             // FOR EACH: row

                Cell[] row      = meas.getRow(i);
                String slotType = row[0].getContents();
                String name     = row[1].getContents();
                String strId    = row[2].getContents(); int id          = Integer.parseInt(strId);
                String type     = row[3].getContents();
                                
                attribsToKeys.put(name, id);
                keysToAttribs.put(id, name);
                attribsToTypes.put(name, type);

                if (type.equalsIgnoreCase("NL") || type.equalsIgnoreCase("OL")) { // ACCEPTED VALUES
                    String strNumAtts = row[4].getContents();
                    int numVals = Integer.parseInt(strNumAtts);
                    Hashtable<String, Integer> acceptedValues = new Hashtable<>();
                    for (int j = 0; j < numVals; j++) {
                        acceptedValues.put(row[j+5].getContents(), j);
                    }
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attrib.acceptedValues = acceptedValues;
                    attribSet.put(name, attrib);
                    if (name.equalsIgnoreCase("Parameter")) {
                        params.parameterList.addAll(acceptedValues.keySet());
                    }
                } // NO ACCEPTED VALUES
                else {
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attribSet.put(name, attrib);
                }

                slots.add(new SlotInfo(slotType, name));
            }
            context.put("slots", slots);
            GlobalVariables.defineMeasurement(attribsToKeys, keysToAttribs, attribsToTypes, attribSet);

            engine.getTemplate(params.resourcesPath + "/templates/measurementTemplate.clp").evaluate(writer, context);
            r.eval(writer.toString());
        }
        catch (Exception e) {
            System.out.println("EXC in loadMeasurementTemplate " + e.getMessage());
        }
    }

    // Finished
    private void loadInstrumentTemplate(Rete r, Workbook xls) {
        try {
            HashMap<String, Integer> attribsToKeys = new HashMap<>();
            HashMap<Integer, String> keysToAttribs = new HashMap<>();
            HashMap<String, String> attribsToTypes = new HashMap<>();
            HashMap<String, EOAttribute> attribSet = new HashMap<>();

            Sheet meas = xls.getSheet("Instrument");
            String call = "(deftemplate CAPABILITIES::Manifested-instrument ";
            String call2 = "(deftemplate DATABASE::Instrument ";
            int numSlots = meas.getRows();
            for (int i = 1; i < numSlots; i++) {
                Cell[] row = meas.getRow(i);
                String slotType = row[0].getContents();
                String name = row[1].getContents();
                String strId = row[2].getContents();
                int id = Integer.parseInt(strId);
                String type = row[3].getContents();

                attribsToKeys.put(name, id);
                keysToAttribs.put(id, name);
                attribsToTypes.put(name, type);
                if (type.equalsIgnoreCase("NL") || type.equalsIgnoreCase("OL")) {
                    String strNumAtts = row[4].getContents();
                    int numVals = Integer.parseInt(strNumAtts);
                    Hashtable<String, Integer> acceptedValues = new Hashtable<>();
                    for (int j = 0; j < numVals; j++) {
                        acceptedValues.put(row[j+5].getContents(), j);
                    }
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attrib.acceptedValues = acceptedValues;
                    attribSet.put(name, attrib);
                }
                else {
                    EOAttribute attrib = AttributeBuilder.make(type, name, "N/A");
                    attribSet.put(name, attrib);
                }

                call = call.concat(" (" + slotType + " " + name + ") ");
                call2 = call2.concat(" (" + slotType + " " + name + ") ");
            }
            GlobalVariables.defineInstrument(attribsToKeys, keysToAttribs, attribsToTypes, attribSet);

            call = call.concat(")");
            call2 = call2.concat(")");
            r.eval(call);
            r.eval(call2);
        }
        catch (Exception e) {
            System.out.println( "EXC in loadInstrumentTemplate " + e.getMessage());
        }
    }

    // Finished for: mission, orbitl, launch vehicle pages on attributeset.xls
    private void loadSimpleTemplate(Rete r, Workbook xls, String sheet, String templateName) {
        try {
            Sheet meas = xls.getSheet(sheet);
            String call = "(deftemplate " + templateName + " ";
            int numSlots = meas.getRows();
            for (int i = 1; i < numSlots; i++) {
                Cell[] row = meas.getRow(i);
                String slotType = row[0].getContents();
                String name = row[1].getContents();
                call = call.concat(" (" + slotType + " " + name + ") ");
            }

            call = call.concat(")");
            r.eval(call);
        }
        catch (Exception e) {
            System.out.println("EXC in loadSimpleTemplate " + e.getMessage());
        }
    }


    // MyQuery query = MyQuery.builder().build();
    // ApolloCall<MyQuery.Data> queryData = apolloClient.query(query).responseFetcher(ApolloResponseFetchers.NETWORK_FIRST);
}