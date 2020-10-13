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
import seakers.architecture.util.IntegerVariable;

/**
 * This pattern is typically used for scheduling items in order from first to
 * last. The length of the decision vector is the number of items N to order and
 * the value for each decision ranges from [0,N-1] with no repeated numbers
 * allowed
 *
 * @author nozomihitomi
 */
public class Permuting implements ArchitecturalDecision, Serializable {    
    
    private static final long serialVersionUID = -750345955372264068L;

    /**
     * The number of elements in the permutation
     */
    private final int nElements;
    
    private final String tag;
    
    /**
     * This constructor creates an ordered permutation from 0 to n-1
     *
     * @param numElements the number of elements to include in the permutation
     * @param tag the tag of the decision
     */
    public Permuting(int numElements, String tag) {
        this.nElements = numElements;
        this.tag = tag;
    }

    /**
     * Swaps the {@code i}th and {@code j}th elements in this permutation.
     *
     * @param i the first index
     * @param j the second index
     * @param arch
     * @param tag
     * @throws ArrayIndexOutOfBoundsException if {@code i} or {@code j} is out
     * or range @{code [0, size()-1]}
     */
    public static void swap(int i, int j, Architecture arch, String tag) {
        Permuting dec = (Permuting) arch.getDecision(tag);
        if(i >= dec.getNumberOfVariables() || j>= dec.getNumberOfVariables()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfVariables(), tag));
        }
        
        int startIndex = arch.getDecisionIndex(tag);
        Variable tmp1 = arch.getVariable(i+startIndex);
        Variable tmp2 = arch.getVariable(j+startIndex);
        arch.setVariable(i+startIndex, tmp2);
        arch.setVariable(j+startIndex, tmp1);
    }

    @Override
    public DecisionPattern getPattern() {
        return DecisionPattern.PERMUTING;
    }

    @Override
    public String getTag() {
        return tag;
    }

    @Override
    public ArrayList<Variable> getVariables() {
        ArrayList<Variable> out = new ArrayList<>(nElements);
        for (int i = 0; i < nElements; i++) {
            out.add(new IntegerVariable(i, 0, nElements-1));
        }
        return out;
    }

    @Override
    public int getNumberOfVariables() {
        return nElements;
    }

}
