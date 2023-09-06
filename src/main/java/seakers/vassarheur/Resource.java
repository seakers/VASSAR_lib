/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassarheur;

import jess.*;
import seakers.vassarheur.utils.MatlabFunctions;
import seakers.vassarheur.ModelParser;


public class Resource {

    private BaseParams params;
    private Rete r;
    private QueryBuilder qb;
    private MatlabFunctions m;
    
    public Resource(BaseParams params) {
        this.params = params;
        this.params.init();
        this.r = new Rete();
        this.qb = new QueryBuilder(this.r);
        this.m = new MatlabFunctions(this);
        this.r.addUserfunction(this.m);

        JessInitializer.getInstance().initializeJess(this.params, this.r, this.qb, this.m);

        // PARSE RULES
        try{
            ModelParser mParser = new ModelParser(this.r);
            mParser.saveVocabulary();
        }
        catch (Exception ex){
            ex.printStackTrace();
        }

    }

    public void cleanRete(){
        try {
            this.r.clear();
            JessInitializer.getInstance().initializeJess(this.params, this.r, this.qb, this.m);
        }
        catch (JessException e) {
            System.out.println(e.getMessage() + " " + e.getClass() + " ");
            e.printStackTrace();
        }
    }

    public BaseParams getParams(){ return params; }
    
    public Rete getRete() {
        return r;
    }

    public QueryBuilder getQueryBuilder() {
        return qb;
    }

    public MatlabFunctions getM() {
        return m;
    }
    
}
