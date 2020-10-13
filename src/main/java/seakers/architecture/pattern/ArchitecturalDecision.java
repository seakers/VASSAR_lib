/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package seakers.architecture.pattern;

import java.util.ArrayList;
import org.moeaframework.core.Variable;

/**
 * Architectural decisions must be be one of the 6 architectural decision
 * patterns. It is a single discrete variable or a set of discrete valued
 * variables.
 *
 * @author Nozomi
 */
public interface ArchitecturalDecision{
    
    /**
     * Gets the architectural decision pattern for this decision
     * @return 
     */
    public DecisionPattern getPattern();
    
    /**
     * Each architectural decision will have a tag that provides some identification or other information
     * @return 
     */
    public String getTag();
    
    /**
     * Gets the variables that correspond to this architectural decision
     * @return The ordered list of variables that correspond to this architectural decision
     */
    public ArrayList<Variable> getVariables();
    
    /**
     * Gets the number variables that this decision pattern needs
     * @return the number variables that this decision pattern needs
     */
    public int getNumberOfVariables();
}
