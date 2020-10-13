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
 * This pattern assumes there are two different sets of entities, and an
 * architecture fragment is defined by assigning each entity from one set to any
 * subset of entities from the other set.
 *
 * @author nozomihitomi
 */
public class Assigning implements ArchitecturalDecision, Serializable{

    private static final long serialVersionUID = -537105464191766990L;

    /**
     * The number of elements to assign (left hand side)
     */
    private final int mNodes;

    /**
     * The number of elements that get elements assigned (right hand side)
     */
    private final int nNodes;

    private final String tag;

    /**
     * This constructor creates an assignment matrix with m items assigned to n
     * items
     *
     * @param mNodes the number of elements that are being assigned
     * @param nNodes the number of elements that will have things assigned to
     * it.
     * @param tag the tag of the decision
     */
    public Assigning(int mNodes, int nNodes, String tag) {
        this.mNodes = mNodes;
        this.nNodes = nNodes;
        this.tag = tag;
    }

    @Override
    public DecisionPattern getPattern() {
        return DecisionPattern.ASSINGING;
    }

    /**
     * Assigns element i from the left side to element j on the right side.
     * Elements numbered starting with 0.
     *
     * @param i element in the left hand side
     * @param j element in the right hand side
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return the value of the assignment matrix in cell i,j before the change.
     * True = assigned. False = not assigned.
     */
    public static boolean connect(int i, int j, Architecture arch, String tag) {
        Assigning dec = (Assigning) arch.getDecision(tag);
        if(i >= dec.getNumberOfLHS()){
            throw new IllegalArgumentException(String.format("Cannot access LHS index greater than %d for decision %s", dec.getNumberOfLHS(), tag));
        }
        if(j >= dec.getNumberOfRHS()){
            throw new IllegalArgumentException(String.format("Cannot access RHS index greater than %d for decision %s", dec.getNumberOfRHS(), tag));
        }
        int index = arch.getDecisionIndex(tag);
        BinaryVariable var = ((BinaryVariable) arch.getVariable(i * dec.getNumberOfRHS() + j + index));
        boolean out = var.get(0);
        var.set(0, true);
        return out;
    }

    /**
     * Removes the connection between element i from the left side to element j
     * on the right side. Elements numbered starting with 0.
     *
     * @param i element in the left hand side
     * @param j element in the right hand side
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return the value of the assignment matrix in cell i,j before the change.
     * True = assigned. False = not assigned.
     */
    public static boolean disconnect(int i, int j, Architecture arch, String tag) {
        Assigning dec = (Assigning) arch.getDecision(tag);
        if(i >= dec.getNumberOfLHS()){
            throw new IllegalArgumentException(String.format("Cannot access LHS index greater than %d for decision %s", dec.getNumberOfLHS(), tag));
        }
        if(j >= dec.getNumberOfRHS()){
            throw new IllegalArgumentException(String.format("Cannot access RHS index greater than %d for decision %s", dec.getNumberOfRHS(), tag));
        }
        int index = arch.getDecisionIndex(tag);
        BinaryVariable var = ((BinaryVariable) arch.getVariable(i * dec.getNumberOfRHS() + j + index));
        boolean out = var.get(0);
        var.set(0, false);
        return out;
    }

    /**
     * Checks if element i from the left hand side and element j from the right
     * hand side are assigned. If assigned, returns true. Else false.
     *
     * @param i element in the left hand side
     * @param j element in the right hand side
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return if element i from the left hand side and element j from the right
     * hand side are assigned.
     */
    public static boolean isConnected(int i, int j, Architecture arch, String tag) {
        Assigning dec = (Assigning) arch.getDecision(tag);
        if(i >= dec.getNumberOfLHS()){
            throw new IllegalArgumentException(String.format("Cannot access LHS index greater than %d for decision %s", dec.getNumberOfLHS(), tag));
        }
        if(j >= dec.getNumberOfRHS()){
            throw new IllegalArgumentException(String.format("Cannot access RHS index greater than %d for decision %s", dec.getNumberOfRHS(), tag));
        }
        int index = arch.getDecisionIndex(tag);
        BinaryVariable var = ((BinaryVariable) arch.getVariable(i * dec.getNumberOfRHS() + j + index));
        return var.get(0);
    }

    /**
     * Returns the number of elements on the right hand side of the assigning
     * pattern
     *
     * @return elements on the left hand side of the assigning pattern
     */
    public int getNumberOfLHS() {
        return mNodes;
    }

    /**
     * Returns the number of elements on the right hand side of the assigning
     * pattern
     *
     * @return the number of elements on the right hand side of the assigning
     * pattern
     */
    public int getNumberOfRHS() {
        return nNodes;
    }

    @Override
    public String getTag() {
        return tag;
    }
    
    /**
     * In this implementation, binary variables are created and all are set to false
     * @return a list of Binary variables set to false
     */
    @Override
    public ArrayList<Variable> getVariables() {
        ArrayList<Variable> out = new ArrayList<>(getNumberOfVariables());
        for (int i = 0; i < getNumberOfVariables(); i++) {
            out.add(new BinaryVariable(1));
        }
        return out;
    }

    @Override
    public String toString() {
        return "Assigning{" + "LHSnodes=" + mNodes + ", RHSnodes=" + nNodes + ", tag=" + tag + '}';
    }

    @Override
    public int getNumberOfVariables() {
        return mNodes * nNodes;
    }

}
