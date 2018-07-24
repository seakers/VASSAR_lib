/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

import jess.*;

public class Resource {
    
    private Rete r;
    private QueryBuilder qb;
    private MatlabFunctions m;
    
    public Resource() {
        r = new Rete();
        qb = new QueryBuilder(r);
        m = new MatlabFunctions(this);
        r.addUserfunction(m);
        
        JessInitializer.getInstance().initializeJess(r, qb, m);
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
