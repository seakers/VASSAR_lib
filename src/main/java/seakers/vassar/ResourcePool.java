/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar;

import jess.JessException;
import seakers.vassar.problems.Assigning.GigaAssigningParams;

import java.util.Stack;

public class ResourcePool 
{
    private Stack<Resource> pool;
    
    public ResourcePool(BaseParams params, int numCPU) {
        pool = new Stack<>();
        
        for (int i = 0; i < numCPU; i++) {

            long startTime = System.nanoTime();
            BaseParams resource_params = params.copy();
            resource_params.setOrekitCoverageDatabase(i);
            Resource res = new Resource(resource_params);
            long endTime = System.nanoTime();
            // Calculate and print the time taken in milliseconds
            long timeElapsed = (endTime - startTime) / 1000000000;
            System.out.println("Execution time in seconds: " + timeElapsed);


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
