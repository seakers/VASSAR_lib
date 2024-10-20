/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar;

import jess.*;
import seakers.vassar.utils.MatlabFunctions;

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
