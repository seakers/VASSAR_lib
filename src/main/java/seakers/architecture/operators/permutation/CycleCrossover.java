/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.operators.permutation;

import java.util.HashMap;
import java.util.HashSet;
import org.moeaframework.core.PRNG;
import org.moeaframework.core.Solution;
import org.moeaframework.core.Variable;
import org.moeaframework.core.Variation;
import org.moeaframework.core.variable.Permutation;

/**
 *
 *
 * @author nozomihitomi
 */
public class CycleCrossover implements Variation {

    /**
     * The probability of applying this operator.
     */
    private final double probability;

    /**
     * Constructs a CycleCrssover operator with the specified probability.
     *
     * @param probability the probability of applying this operator
     */
    public CycleCrossover(double probability) {
        super();
        this.probability = probability;
    }

    @Override
    public int getArity() {
        return 2;
    }

    @Override
    public Solution[] evolve(Solution[] parents) {
        Solution result1 = parents[0].copy();
        Solution result2 = parents[1].copy();

        if (PRNG.nextDouble() <= probability) {
            for (int i = 0; i < result1.getNumberOfVariables(); i++) {
                Variable variable1 = result1.getVariable(i);
                Variable variable2 = result2.getVariable(i);

                if (PRNG.nextBoolean() && (variable1 instanceof Permutation)
                        && (variable2 instanceof Permutation)) {
                    evolve((Permutation) variable1, (Permutation) variable2);
                }
            }
        }

        return new Solution[]{result1, result2};
    }

    /**
     * Starts with the first index of parent 1, identifies which values to copy
     * over to child using 1 cycle. Remaining values are taken from parent 2
     *
     * @param p1
     * @param p2
     */
    private void evolve(Permutation p1, Permutation p2) {
        int[] child1 = new int[p1.size()];
        int[] child2 = new int[p2.size()];

        //map to store <value, index> for each permutation
        HashMap<Integer, Integer> p1Map = new HashMap<>();
        HashMap<Integer, Integer> p2Map = new HashMap<>();
        for (int i = 0; i < p1.size(); i++) {
            p1Map.put(p1.get(i), i);
            p2Map.put(p2.get(i), i);
        }

        final int p1CycleStart = p1.get(0);

        //Find where cycle indices occur
        HashSet<Integer> indices = new HashSet<>();
        int current = p1CycleStart;
        do {
            final int ind = p1Map.get(current);
            indices.add(ind);
            current = p2Map.get(ind);
        } while (current != p1CycleStart);

        //copy over the values in the indices where the cycle occurs. Swap all other values between parents
         for (int i = 0; i < p1.size(); i++) {
            if (indices.contains(i)) {
                child1[i] = p1.get(i);
                child2[i] = p2.get(i);
            } else {
                child1[i] = p2.get(i);
                child2[i] = p1.get(i);
            }
        }
        
        //copy children permutation over
        p1.fromArray(child1);
        p2.fromArray(child2);
    }

}
