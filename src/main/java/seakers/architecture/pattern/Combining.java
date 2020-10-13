/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.pattern;

import seakers.architecture.Architecture;
import org.moeaframework.core.Variable;
import java.io.Serializable;
import java.util.ArrayList;
import static seakers.architecture.pattern.DecisionPattern.COMBINING;
import seakers.architecture.util.IntegerVariable;

/**
 *
 * @author nozomihitomi
 */
public class Combining implements ArchitecturalDecision, Serializable {
    
    private static final long serialVersionUID = 4142639957025157845L;
    
    /**
     * The list of the number of possible alternatives for each decision
     */
    private final int[] numAlternatives;
    
    private final String tag;

    /**
     * The number of alternatives available for each decision. Default solution
     * has 0 selected for all decisions
     *
     * @param numAlternatives number of alternatives available for each decision
     * @param tag the tag of the decision
     */
    public Combining(int[] numAlternatives, String tag) {
        this.numAlternatives = numAlternatives;
        //check that all values are positive
        for(int alt : numAlternatives){
            if(alt<=0){
                throw new IllegalArgumentException("The number of alternatives for any decision must be positive");
            }
        }
        this.tag = tag;
    }

    /**
     * Sets the value of the specified decision. The specified value of the
     * decision must not exceed the number of available values. The alternative
     * values are zero-indexed
     *
     * @param index the index of the decision
     * @param value the value to set the decision at the given index
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return true if the variable changed values as a result
     */
    public static boolean setValue(int index, int value, Architecture arch, String tag) {
        Combining dec = (Combining)arch.getDecision(tag);
        if(index >= dec.getNumberOfVariables()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfVariables(), tag));
        }
        int i = arch.getDecisionIndex(tag);
        if (value >= dec.getNumberOfAlternatives(index)) {
            throw new IllegalArgumentException(String.format("Cannot access value greater than %d. Tried accessesing %d.", dec.getNumberOfAlternatives(index), value));
        }
        if (value < 0){
            throw new IllegalArgumentException("Value must be greater than 0");
        }
        IntegerVariable var = (IntegerVariable)arch.getVariable(i + index);
        boolean out = var.getValue() == value;
        var.setValue(value);
        return out;
    }

    /**
     * Gets the value stored in the given index
     *
     * @param index the index of the decision of interest
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return the value stored in the given index
     */
    public static int getValue(int index, Architecture arch, String tag) {
        int i = arch.getDecisionIndex(tag);
        return ((IntegerVariable)arch.getVariable(i + index)).getValue();
    }

    /**
     * Returns the number of alternatives available for the specified decision
     *
     * @param index of the decision
     * @return the number of possible alternatives available for the specified
     * decision
     */
    public int getNumberOfAlternatives(int index) {
        return numAlternatives[index];
    }

    @Override
    public DecisionPattern getPattern() {
        return COMBINING;
    }

    @Override
    public String getTag() {
        return tag;
    }

    @Override
    public ArrayList<Variable> getVariables() {
        ArrayList<Variable> out = new ArrayList<>(numAlternatives.length);
        for (int i = 0; i < numAlternatives.length; i++) {
            out.add(new IntegerVariable(0, 0, numAlternatives[i] - 1));
        }
        return out;
    }

    @Override
    public int getNumberOfVariables() {
        return numAlternatives.length;
    }

}
