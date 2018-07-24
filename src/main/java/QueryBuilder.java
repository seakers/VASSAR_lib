package rbsa.eoss;

import jess.*;
import java.util.ArrayList;
import java.util.HashMap;

public class QueryBuilder {
    
    private Rete r;
    private HashMap<String, HashMap> precomputedQueries;

    public QueryBuilder(Rete r) {
        this.r = r;
        this.precomputedQueries = new HashMap<>();
    }

    public void addPrecomputedQuery(String key, HashMap hm) {
        this.precomputedQueries.put(key, hm);
    }
    
    public ArrayList<Fact> makeQuery(String template) {
        ArrayList<Fact> facts = new ArrayList<>();
        
        String call = "(defquery temp-query ?f <- (" + template + "))";
        
        try {
            r.eval(call);
            QueryResult q_result = r.runQueryStar("temp-query", new ValueVector());
            
            while(q_result.next())
                facts.add((Fact) q_result.getObject("f"));
            
            r.removeDefrule("temp-query");
            
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
        
        return facts;
    }
}
