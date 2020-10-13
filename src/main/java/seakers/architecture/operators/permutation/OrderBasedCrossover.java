/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.operators.permutation;

import java.util.ArrayList;
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
public class OrderBasedCrossover implements Variation {

    /**
     * The probability of applying this operator.
     */
    private final double probability;

    /**
     * Constructs a OrderBasedCrossover operator with the specified
     * probability.
     *
     * @param probability the probability of applying this operator
     */
    public OrderBasedCrossover(double probability) {
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
        //select 2 cross points
        int crossoverPoint1 = PRNG.nextInt(p1.size() - 1);
        int crossoverPoint2 = PRNG.nextInt(p1.size() - 1);
        if (crossoverPoint1 > crossoverPoint2) {
            int temp = crossoverPoint1;
            crossoverPoint1 = crossoverPoint2;
            crossoverPoint2 = temp;
        }

        int[] child1 = new int[p1.size()];
        int[] child2 = new int[p2.size()];

        ArrayList<Integer> indices = new ArrayList<>(p1.size());
        HashSet<Integer> p1MissingVals = new HashSet<>(p1.size());
        HashSet<Integer> p2MissingVals = new HashSet<>(p1.size());
        //map to store <value, index> for each permutation
        HashMap<Integer, Integer> p1Map = new HashMap<>();
        HashMap<Integer, Integer> p2Map = new HashMap<>();
        for (int i = 0; i < p1.size(); i++) {
            if (i > crossoverPoint1 && i <= crossoverPoint2) {
                child1[i] = p1.get(i);
                child2[i] = p2.get(i);
            } else {
                indices.add(i);
                p2MissingVals.add(p2.get(i));
            }
            p1Map.put(p1.get(i), i);
            p2Map.put(p2.get(i), i);
        }
        
        //fill in the rest of child1 starting from the second cross point
        int ind = crossoverPoint2 + 1;
        int counter = 0;
        while(!p1MissingVals.isEmpty()){
            if(ind == p1Map.size()){
                ind = 0;
            }
            if(!p1MissingVals.contains(p2Map.get(ind))){
                child1[indices.get(counter)] = p2Map.get(ind);
                p1MissingVals.remove(p2Map.get(ind));
                counter++;
            }
        }
        
        //fill in the rest of child2 starting from the second cross point
        ind = crossoverPoint2 + 1;
        counter = 0;
        while(!p2MissingVals.isEmpty()){
            if(ind == p2Map.size()){
                ind = 0;
            }
            if(!p2MissingVals.contains(p1Map.get(ind))){
                child2[indices.get(counter)] = p1Map.get(ind);
                p2MissingVals.remove(p1Map.get(ind));
                counter++;
            }
        }

        //copy children permutation over
        p1.fromArray(child1);
        p2.fromArray(child2);
    }

}
