/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture;

import seakers.architecture.pattern.ArchitecturalDecision;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Objects;
import org.moeaframework.core.Solution;
import org.moeaframework.core.Variable;

/**
 * The architecture is defined by the types of decisions and the values of those
 * decisions
 *
 * @author nozomihitomi
 */
public class Architecture extends Solution {

    private static final long serialVersionUID = -2195550924166538032L;
    
    private final HashMap<String, Integer> indices;
    
    private final HashMap<String, ArchitecturalDecision> decisions;
    
    public Architecture(int numberOfDecisions, int numberOfObjectives, int numberOfConstraints, ArrayList<ArchitecturalDecision> decisions) {
        super(numberOfDecisions, numberOfObjectives, numberOfConstraints);
        
        this.indices = new HashMap<>();
        this.decisions = new HashMap<>();
        
        int varIndex = 0;
        for (ArchitecturalDecision decision : decisions) {
            String tag = decision.getTag();
            if(indices.put(tag, varIndex) != null){
                throw new IllegalArgumentException(String.format("Decision %s already exists",tag));
            }
            this.decisions.put(tag, decision);
            ArrayList<Variable> vars = decision.getVariables();
            for(int j=0; j<vars.size(); j++){
                setVariable(j + varIndex, vars.get(j));
            }
            varIndex += vars.size();
        }
        
        Collections.unmodifiableMap(this.indices);
        Collections.unmodifiableMap(this.decisions);
    }

    public Architecture(int numberOfObjectives, int numberOfConstraints, ArrayList<ArchitecturalDecision> decisions) {
        this(countVariables(decisions), numberOfObjectives, numberOfConstraints, decisions);
    }
    
    protected Architecture(Solution solution){
        super(solution);
        if(!(solution instanceof Architecture)){
            throw new ClassCastException("Solution is not an instance of Architecture");
        }
        Architecture arch = (Architecture) solution;
        this.indices = arch.indices;
        this.decisions = arch.decisions;
    }
    
    private static int countVariables(Collection<ArchitecturalDecision> decisions){
        int count = 0;
        for(ArchitecturalDecision dec : decisions){
            count += dec.getNumberOfVariables();
        }
        return count;
    }
    
    /**
     * Checks all the constraint values of the architecture.
     * @return true if the architecture is feasible
     */
    public boolean isFeasible() {
        for (int i = 0; i < getNumberOfConstraints(); i++) {
            if (getConstraint(i) > 0) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Gets the decision variable index where the selected architectural decision begins
     * @param tag
     * @return 
     */
    public int getDecisionIndex(String tag){
        return indices.get(tag);
    }
    
    /**
     * Gets the decision variable
     * @param tag
     * @return 
     */
    public ArchitecturalDecision getDecision(String tag){
        return decisions.get(tag);
    }
    
    /**
     * Gets the number of architectural decisions
     * @return the number of architectural decisions
     */
    public int getNumberOfDecisions(){
        return decisions.size();
    }

    /**
     * Returns the values of each decision
     *
     * @return a string with the values of each decision
     */
    @Override
    public String toString() {
        String out = "";
        for (int i = 0; i < getNumberOfVariables() - 1; i++) {
            out += getVariable(i).toString() + ",";
        }
        out += getVariable(getNumberOfVariables()-1).toString();
        return out;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        for (int i = 0; i < getNumberOfVariables(); i++) {
            hash = 67 * hash + Objects.hashCode(this.getVariable(i));
        }
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final Architecture other = (Architecture) obj;
        for (int i = 0; i < getNumberOfVariables(); i++) {
            if (!this.getVariable(i).equals(other.getVariable(i))) {
                return false;
            }
        }
        return true;
    }

}
