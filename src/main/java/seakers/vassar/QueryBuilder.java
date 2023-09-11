package seakers.vassar;

import jess.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Comparator;
import java.util.regex.Matcher;

public class QueryBuilder {
    
    private Rete r;
    private HashMap<String, HashMap<String, Fact>> precomputedQueries;

    public QueryBuilder(Rete r) {
        this.r = r;
        this.precomputedQueries = new HashMap<>();
    }

    public void addPrecomputedQuery(String key, HashMap<String, Fact> hm) {
        this.precomputedQueries.put(key, hm);
    }
    
    public ArrayList<Fact> makeQuery(String template) {
        ArrayList<Fact> facts = new ArrayList<>();
        
        String call = "(defquery TempArchitecture-query ?f <- (" + template + "))";
        
        try {
            r.eval(call);
            QueryResult q_result = r.runQueryStar("TempArchitecture-query", new ValueVector());
            
            while(q_result.next())
                facts.add((Fact) q_result.getObject("f"));
            
            r.removeDefrule("TempArchitecture-query");
            
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
        
        return facts;
    }

    public ArrayList<Fact> saveQuery(String fileName, String template){
        if(!DebugWriter.debug){
            return null;
        }

        ArrayList<Fact> facts = new ArrayList<>();

        String call = "(defquery TempArchitecture-query ?f <- (" + template + "))";

        try {
            r.eval(call);
            QueryResult q_result = r.runQueryStar("TempArchitecture-query", new ValueVector());

            while(q_result.next())
                facts.add((Fact) q_result.getObject("f"));

            r.removeDefrule("TempArchitecture-query");

        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }

        if(DebugWriter.debug){
            String debug = "empty query";
            if(!facts.isEmpty()){
                debug = "";
                int counter = 1;

                // Sort facts based on an attribute value
                Collections.sort(facts, this.getFactComparator());

                for(Fact fct: facts){
                    debug += "\n--------------- " + template + " - " + counter + " ---------------\n";


                    debug += this.transformFactString(fct.toStringWithParens());
                    counter++;
                }
            }
            DebugWriter.writeDebug(debug, fileName);
        }

        return facts;
    }

    public Comparator<Fact> getFactComparator() {
        Rete engine = this.r;
        return new Comparator<Fact>() {
            @Override
            public int compare(Fact o1, Fact o2) {
                Deftemplate f1 = o1.getDeftemplate();
                String[] slot_names = f1.getSlotNames();
                String true_slot = "";
                boolean slot_found = false;
                for(String slot_name: slot_names) {


                    // Comparison on Name attribute
                    if (slot_name.equals("Name")) {
                        true_slot = slot_name;
                        slot_found = true;
                    } else if (slot_name.equals("Parameter")) {
                        true_slot = slot_name;
                        slot_found = true;
                    }

                    // Evaluate and return
                    if (slot_found) {
                        try {
                            String v1 = o1.getSlotValue(true_slot).stringValue(engine.getGlobalContext());
                            String v2 = o2.getSlotValue(true_slot).stringValue(engine.getGlobalContext());
                            return v1.compareTo(v2);
                        } catch (JessException e) {
                            e.printStackTrace();
                            return 0;
                        }
                    }
                }
                return 0;
            }
        };
    }

    public String transformFactString(String fact){
        String trans = "";
        String clipped = fact.substring(1, fact.length()-1);

        Matcher m = java.util.regex.Pattern.compile("\\((.*?)\\)").matcher(clipped);
        while(m.find()) {
            trans += (m.group() + "\n");
        }

        return trans;
    }
}
