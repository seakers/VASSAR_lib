/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

import java.util.Stack;

public class ResourcePool 
{
    private Stack<Resource> pool;
    
    public ResourcePool(int numCPU) {
        pool = new Stack<>();
        
        for (int i = 0; i < numCPU; i++) {
            Resource res = new Resource();
            
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
