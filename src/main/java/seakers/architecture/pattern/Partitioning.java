/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.pattern;

import java.io.Serializable;
import java.util.ArrayList;
import org.moeaframework.core.Variable;
import seakers.architecture.util.IntegerVariable;

/**
 * This pattern is used when creating subsets from a set of entities. The union
 * of all subsets is equivalent to the set and the intersection of all subsets
 * is the empty set
 *
 * @author nozomihitomi
 */
public class Partitioning implements ArchitecturalDecision, Serializable {

    private static final long serialVersionUID = 6906299973248340513L;
    
    /**
     * The number of elements in the permutation
     */
    private final int nElements;
    
    private final String tag;
    
    /**
     * This constructor creates a partition consisting of n elements
     *
     * @param numElements the number of elements to include in the partition
     * @param tag the tag of the decision
     */
    public Partitioning(int numElements, String tag) {
        this.nElements = numElements;
        this.tag = tag;
    }

    @Override
    public DecisionPattern getPattern() {
        return DecisionPattern.PARTITIONING;
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
