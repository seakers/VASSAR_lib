package rbsa.eoss.local.test.search.problems.PartitioningAndAssigning;

import org.moeaframework.core.Variable;
import seak.architecture.util.IntegerVariable;

import java.util.ArrayList;

/**
 * This class extends seak.architecture.pattern.Assigning, which defines the input space using
 * binary variables. Instead, this class defines the input space using categorical (Integer) variables.
 */

public class AssigningPatternCategorical extends seak.architecture.pattern.Assigning{

    protected int mNodes;
    protected int nNodes;

    public AssigningPatternCategorical(int mNodes, int nNodes, String tag){
        super(mNodes, nNodes, tag);
        this.mNodes = mNodes;
        this.nNodes = nNodes;
    }

    /**
     * In this implementation, categorical variables are created and all are set to -1 initially.
     * @return a list of Integer variables set to -1
     */
    @Override
    public ArrayList<Variable> getVariables() {
        ArrayList<Variable> out = new ArrayList<>(getNumberOfVariables());
        for (int i = 0; i < getNumberOfVariables(); i++) {
            out.add(new IntegerVariable(-1, -1, this.nNodes - 1));
        }
        return out;
    }

    @Override
    public int getNumberOfVariables() {
        return this.mNodes;
    }
}
