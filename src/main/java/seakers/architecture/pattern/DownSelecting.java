/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.pattern;

import seakers.architecture.Architecture;
import java.io.Serializable;
import java.util.ArrayList;
import org.moeaframework.core.Variable;
import org.moeaframework.core.variable.BinaryVariable;

/**
 * This is the downselecting architectural pattern where the decision is to
 * select a subset from a set of entities. For each entity a decision is made to
 * select it or not. The decision can be represented as a binary vector.
 *
 * @author nozomihitomi
 */
public class DownSelecting implements ArchitecturalDecision, Serializable {

    private static final long serialVersionUID = 1082536400479697102L;
    
    private final String tag;
    
    private final int numberOfEntities;

    /**
     * Creates a new downselecting decision where all entities are set to "not
     * selected". 
     *
     * @param numberOfEntities the number of entities available to choose from
     * @param tag the tag of the decision
     */
    public DownSelecting(int numberOfEntities, String tag) {
        this.numberOfEntities = numberOfEntities;
        this.tag = tag;
    }
    
    /**
     * Method to set the value of a downselecting decision
     * @param index index of the decision
     * @param value true or false
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return
     */
    public static boolean set(int index, boolean value, Architecture arch, String tag){
        DownSelecting dec = (DownSelecting) arch.getDecision(tag);
        if(index >= dec.getNumberOfVariables()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfVariables(), tag));
        }
        
        int i = arch.getDecisionIndex(tag);
        BinaryVariable var = ((BinaryVariable) arch.getVariable(i + index));
        boolean out = var.get(0);
        var.set(0, value);
        return out;
    }
    
     /**
     * Method to get the value of a downselecting decision
     * @param index index of the decision
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return
     */
    public static boolean getValue(int index, Architecture arch, String tag){
        DownSelecting dec = (DownSelecting) arch.getDecision(tag);
        if(index >= dec.getNumberOfVariables()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfVariables(), tag));
        }
        
        int i = arch.getDecisionIndex(tag);
        BinaryVariable var = ((BinaryVariable) arch.getVariable(i + index));
        return var.get(0);
    }    

    @Override
    public DecisionPattern getPattern() {
        return DecisionPattern.DOWNSELECTING;
    }

    @Override
    public String getTag() {
        return this.tag;
    }

    @Override
    public ArrayList<Variable> getVariables() {
        ArrayList<Variable> out = new ArrayList<>(numberOfEntities);
        for (int i = 0; i < numberOfEntities; i++) {
            out.add(new BinaryVariable(1));
        }
        return out;
    }

    @Override
    public int getNumberOfVariables() {
        return numberOfEntities;
    }

}
