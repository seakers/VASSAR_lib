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
 * There is a set of entities that can be seen as the nodes in a graph and an
 * architecture fragment is defined by the set of edges in the graph, i.e. the
 * way of connecting those nodes.
 *
 * @author nozomihitomi
 */
public class Connecting implements ArchitecturalDecision, Serializable {

    private static final long serialVersionUID = -193099801348840331L;

    /**
     * flag for if the graph is directed
     */
    private final boolean isDirected;
    
    /**
     * The number of nodes in the graph
     */
    private final int nNodes;
    
    private final String tag;

    /**
     * This constructor creates a graph with no connected edges.
     *
     * @param nNodes the number of nodes to include in the graph
     * @param isDirected flag to determine if graph is directed
     * @param tag the tag of the decision
     */
    public Connecting(int nNodes, boolean isDirected, String tag) {
        this.isDirected = isDirected;
        this.nNodes = nNodes;
        this.tag = tag;
    }

    /**
     * Connects nodes i and j. If directed, this will only establish a directed
     * edge from i to j. If undirected an undirected edge will be created
     * between i and j. Node count starts with 0.
     *
     * @param i index of node i
     * @param j index of node j
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return the value of the adjacency matrix in cell i,j before the change.
     * True = connected. False = not connected.
     */
    public static boolean connect(int i, int j, Architecture arch, String tag) {
        Connecting dec = (Connecting) arch.getDecision(tag);
        if(i >= dec.getNumberOfNodes()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfNodes(), tag));
        }
        if(j >= dec.getNumberOfNodes()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfNodes(), tag));
        }
        int index = arch.getDecisionIndex(tag);
        
        BinaryVariable var = ((BinaryVariable) arch.getVariable(i * dec.getNumberOfNodes()+ j + index));
        boolean out = var.get(0);
        var.set(0, true);
        
        if(!dec.isDirected()){
            ((BinaryVariable) arch.getVariable(j * dec.getNumberOfNodes()+ i + index)).set(0, true);
        }
        return out;
    }

    /**
     * Removes the connection between element i from the left side to element j
     * on the right side. Elements numbered starting with 0. If directed, this
     * will only disconnect a directed edge from i to j. If undirected all edges
     * between i and j will be disconnected .Node count starts with 0.
     *
     * @param i index of node i
     * @param j index of node j
     * @param arch the architecture
     * @param tag the tag of the decision to change
     * @return the value of the adjacency matrix in cell i,j before the change.
     * True = connected. False = not connected.
     */
    public static boolean disconnect(int i, int j, Architecture arch, String tag) {
        Connecting dec = (Connecting) arch.getDecision(tag);
        if(i >= dec.getNumberOfNodes()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfNodes(), tag));
        }
        if(j >= dec.getNumberOfNodes()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfNodes(), tag));
        }
        int index = arch.getDecisionIndex(tag);
        
        BinaryVariable var = ((BinaryVariable) arch.getVariable(i * dec.getNumberOfNodes()+ j + index));
        boolean out = var.get(0);
        var.set(0, false);
        
        if(!dec.isDirected()){
            ((BinaryVariable) arch.getVariable(j * dec.getNumberOfNodes()+ i + index)).set(0, false);
        }
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
        Connecting dec = (Connecting) arch.getDecision(tag);
        if(i >= dec.getNumberOfNodes()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfNodes(), tag));
        }
        if(j >= dec.getNumberOfNodes()){
            throw new IllegalArgumentException(String.format("Cannot access index greater than %d for decision %s", dec.getNumberOfNodes(), tag));
        }
        
        int index = arch.getDecisionIndex(tag);
        return ((BinaryVariable) arch.getVariable(i * dec.getNumberOfNodes()+ j + index)).get(0);
    }

    /**
     * Gets the number of nodes in the graph
     *
     * @return the number of nodes in the graph
     */
    public int getNumberOfNodes() {
        return nNodes;
    }

    /**
     * Checks if the graph is directed
     * @return true if the graph is directed. Else false.
     */
    public boolean isDirected() {
        return isDirected;
    }
    

    @Override
    public DecisionPattern getPattern() {
        return DecisionPattern.CONNECTING;
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
    public int getNumberOfVariables() {
        return nNodes * nNodes;
    }

}
