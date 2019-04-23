/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar;

import jess.JessException;

import java.util.Stack;

public class ResourcePool 
{
    private Stack<Resource> pool;
    
    public ResourcePool(BaseParams params, int numCPU) {
        pool = new Stack<>();
        
        for (int i = 0; i < numCPU; i++) {
            Resource res = new Resource(params.copy());
            
            pool.push( res );
            System.out.println("Resource " + i + " initialized.");
        }
    }
    
    public synchronized void freeResource(Resource res) {
        if(!pool.contains(res)){
            try{
                res.getRete().eval("(reset)");

            } catch (JessException e){
                e.printStackTrace();
            }

            pool.push(res);
        }
    }
    
    public synchronized Resource getResource() {
        if(!pool.empty()) {
            return pool.pop();
        }
        else {
            System.out.println("getResource: No available resources");
            return null;
        }
    }
}
