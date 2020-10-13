/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.operators.permutation;

import java.util.ArrayList;
import java.util.HashMap;
import org.moeaframework.core.PRNG;
import org.moeaframework.core.Solution;
import org.moeaframework.core.Variable;
import org.moeaframework.core.Variation;
import org.moeaframework.core.variable.Permutation;

/**
 * "In uniform order-based crossover, two parents (say P1 and P2) are randomly
 * selected and a random binary template is generated. Some of the genes for
 * offspring C1 are filled by taking the genes from parent P1 where there is a
 * one in the template. At this point we have C1 partially filled, but it has
 * some “gaps”. The genes of parent P1 in the positions corresponding to zeros
 * in the template are taken and sorted in the same order as they appear in
 * parent P2. The sorted list is used to fill the gaps in C1. Offspring C2 is
 * created using a similar process."
 *
 * Description obtained from Book "Search Methodologies" Chapter 4 "Genetic
 * Algorithms" by Kumara Sastry, David E. Goldberg, Graham Kendall.
 * 10.1007/978-1-4614-6940-7_4
 *
 * @author nozomihitomi
 */
public class UniformOrderCrossover implements Variation {

    /**
     * The probability of applying this operator.
     */
    private final double probability;

    /**
     * Constructs a UniformOrderBasedCrossover operator with the specified
     * probability.
     *
     * @param probability the probability of applying this operator
     */
    public UniformOrderCrossover(double probability) {
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
     * Creates a binary template of the same length as the permutation. values
     * of the permutation where the binary vector is equal to 1 are copied
     * straight over. The remaining values are filled in using an ordered list
     * of the remaining values as ordered by
     *
     * @param p1
     * @param p2
     */
    private void evolve(Permutation p1, Permutation p2) {
        int[] child1 = new int[p1.size()];
        int[] child2 = new int[p2.size()];

        ArrayList<Integer> indices = new ArrayList<>(p1.size());
        ArrayList<Integer> p1MissingVals = new ArrayList<>(p1.size());
        ArrayList<Integer> p2MissingVals = new ArrayList<>(p1.size());
        //map to store <value, index> for each permutation
        HashMap<Integer, Integer> p1Map = new HashMap<>();
        HashMap<Integer, Integer> p2Map = new HashMap<>();
        for (int i = 0; i < p1.size(); i++) {
            if (PRNG.nextBoolean()) {
                child1[i] = p1.get(i);
                child2[i] = p2.get(i);
            } else {
                indices.add(i);
                p1MissingVals.add(p1.get(i));
                p2MissingVals.add(p2.get(i));
            }
            p1Map.put(p1.get(i),i);
            p2Map.put(p2.get(i),i);
        }
        
        //Create lists storing the ordered values to insert
        ArrayList<Integer> p1List = new ArrayList<>(p1.size());
        ArrayList<Integer> p2List = new ArrayList<>(p1.size());
        for(int i = 0; i < indices.size(); i++){
            p1List.add(p2Map.get(p1MissingVals.get(i)));
            p2List.add(p1Map.get(p2MissingVals.get(i)));
        }

        //fill in the rest of child1 and child2
        for (int i = 0; i < indices.size(); i++) {
            child1[indices.get(i)] = p1List.get(i);
            child2[indices.get(i)] = p2List.get(i);
        }

        //copy children permutation over
        p1.fromArray(child1);
        p2.fromArray(child2);
    }

}
