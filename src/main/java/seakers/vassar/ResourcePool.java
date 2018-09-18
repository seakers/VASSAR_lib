/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar;

import seakers.vassar.local.BaseParams;

import java.util.Stack;

public class ResourcePool 
{
    BaseParams params;
    private Stack<Resource> pool;
    
    public ResourcePool(BaseParams params, int numCPU) {
        this.params = params;
        pool = new Stack<>();
        
        for (int i = 0; i < numCPU; i++) {
            Resource res = new Resource(params);
            
            pool.push( res );
            System.out.println("Resource " + i + " initialized.");
        }
    }
    
    public synchronized void freeResource(Resource res) {
        if(!pool.contains(res))
            pool.push(res);
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
