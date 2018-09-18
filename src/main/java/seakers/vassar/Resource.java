/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar;

import jess.*;
import seakers.vassar.local.BaseParams;
import seakers.vassar.utils.MatlabFunctions;

public class Resource {

    private BaseParams params;
    private Rete r;
    private QueryBuilder qb;
    private MatlabFunctions m;
    
    public Resource(BaseParams params) {
        this.params = params;
        r = new Rete();
        qb = new QueryBuilder(r);
        m = new MatlabFunctions(this);
        r.addUserfunction(m);
        
        JessInitializer.getInstance().initializeJess(params, r, qb, m);
    }
    
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
