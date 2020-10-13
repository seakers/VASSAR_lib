/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.operators;

import org.moeaframework.core.PRNG;
import org.moeaframework.core.Solution;
import org.moeaframework.core.Variable;
import org.moeaframework.core.Variation;
import seakers.architecture.util.IntegerVariable;

/**
 * This operator is a uniform mutation over a set of integer valued variables
 *
 * @author nozomihitomi
 */
public class IntegerUM implements Variation {

    /**
     * Probability to apply mutation
     */
    private final double probability;

    /**
     * Creates a new uniform mutation
     *
     * @param probability probability to apply mutation
     */
    public IntegerUM(double probability) {
        this.probability = probability;
    }

    @Override
    public int getArity() {
        return 1;
    }

    @Override
    public Solution[] evolve(Solution[] parents) {
        Solution result = parents[0].copy();

        for (int i = 0; i < result.getNumberOfVariables(); i++) {
            Variable variable = result.getVariable(i);

            if ((PRNG.nextDouble() <= probability)
                    && (variable instanceof IntegerVariable)) {
                evolve((IntegerVariable) variable);
            }
        }

        return new Solution[]{result};
    }

    /**
     * Mutates the specified variable using uniform mutation.
     *
     * @param variable the variable to be mutated
     */
    public static void evolve(IntegerVariable variable) {
        variable.setValue(PRNG.nextInt(variable.getLowerBound(), variable
                .getUpperBound()));
    }

}
