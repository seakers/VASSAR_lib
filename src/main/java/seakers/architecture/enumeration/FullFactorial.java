/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.enumeration;

import seakers.architecture.pattern.ArchitecturalDecision;

import java.util.*;
//import org.paukov.combinatorics3.Generator;

/**
 * This class will conduct a full factorial enumeration of a given architectural
 * decision
 *
 * @author nozomihitomi
 */
public class FullFactorial implements Enumeration {

    private final ArchitecturalDecision template;

    /**
     * The constructor requires a template architectural decision parameterized
     * with the desired number of variables
     *
     * @param template
     */
    public FullFactorial(ArchitecturalDecision template) {
        this.template = template;
    }

    @Override
    public Collection<ArchitecturalDecision> enumerate() {
        ArrayList<ArchitecturalDecision> out = new ArrayList<>();
        switch (template.getPattern()) {
            case ASSINGING:
                break;
            case COMBINING:
                break;
            case CONNECTING:
                break;
            case DOWNSELECTING:
                break;
            case PARTITIONING:
                break;
            case PERMUTING:
                break;
            default:
                throw new IllegalArgumentException(String.format("Decision patter %s not supported", template.getPattern()));
        }

        return out;
    }

    /**
     * Creates a full factorial enumeration of combining decisions
     *
     * @param levels The number of options for each combining decision
     * @return a full factorial enumeration of collection of solutions
     */
    public static Collection<int[]> ffCombining(int[] levels) {
        int ssize = 1;    //number of experiments
        for (int lev : levels) {
            ssize *= lev;
        }
        int ncycles = ssize;

        int res[][] = new int[ssize][levels.length];

        for (int k = 0; k < levels.length; k++) {
            int nreps = ssize / ncycles;
            ncycles = ncycles / levels[k];
            int[] settingReps = new int[nreps * levels[k]];
            int index = 0;
            for (int j = 0; j < levels[k]; j++) {
                for (int i = 0; i < nreps; i++) {
                    settingReps[index] = j;
                    index++;
                }
            }

            index = 0;
            for (int j = 0; j < ncycles; j++) {
                for (int i = 0; i < settingReps.length; i++) {
                    res[index][k] = settingReps[i];
                    index++;
                }
            }
        }

        //convert matrix into collection of int arrays
        ArrayList<int[]> out = new ArrayList<>(ssize);
        for (int i = 1; i < ssize; i++) {
            out.add(res[i]);
        }
        return out;
    }

    /**
     * Creates a full factorial enumeration of down selecting decisions
     *
     * @param nElements The number of elements to down select from
     * @return a full factorial enumeration of collection of solutions
     */
    public static Collection<int[]> ffDownSelecting(int nElements) {
        int[] levels = new int[nElements];
        Arrays.fill(levels, 2);
        return ffCombining(levels);
    }

    /**
     * Creates a full factorial enumeration of assigning decisions
     *
     * @param nLHS The number of elements on the left hand side
     * @param nRHS The number of elements on the right hand side
     * @return a full factorial enumeration of collection of assignments
     */
    public static Collection<int[][]> ffAssigning(int nLHS, int nRHS) {
        int[] levels = new int[nLHS * nRHS];
        Arrays.fill(levels, 2);
        Collection<int[]> vectorRes = ffCombining(levels);

        ArrayList<int[][]> out = new ArrayList<>((int) Math.pow(2, nLHS * nRHS));
        for (int[] soln : vectorRes) {
            int[][] matrix = new int[nLHS][nRHS];
            int index = 0;
            for (int i = 0; i < nLHS; i++) {
                for (int j = 0; j < nRHS; j++) {
                    matrix[i][j] = soln[index];
                    index++;
                }
            }
        }
        return out;
    }

    /**
     * Conducts a full factorial enumeration of ordered partitions. Partitions
     * are returned as an array of integers where each integer value indicates
     * the partition number an element belongs to. The largest partition number
     * within an array is such that one minus the number is also a partition
     * number belonging to the array.
     *
     * @param nElements the number of elements to consider in partitioning
     * @return a full factorial enumeration of collection of partitions
     */
    public static Collection<int[]> ffOrderedPartitioning(int nElements) {
        //in implementation, we maintain the maximum partition number of the array in the 0th index
        Collection<int[]> prev = new ArrayList<>();
        prev.add(new int[]{0, 0});
        while (true) {
            ArrayList<int[]> curr = new ArrayList<>();
            for (int[] subPart : prev) {
                for (int partNum = 0; partNum <= subPart[0] + 1; partNum++) {
                    int[] extended = Arrays.copyOf(subPart, subPart.length + 1);
                    extended[subPart.length] = partNum;
                    extended[0] = Math.max(subPart[0], partNum);
                    curr.add(extended);
                }
            }
            if (curr.get(0).length == nElements + 1) {
                //find unique 
                HashSet<int[]> out = new HashSet<>();
                for (int[] partition : curr) {
                    //re
                    out.add(Arrays.copyOfRange(partition, 1, partition.length));
                }
                return out;
            }
            prev = curr;
        }
    }

    /**
     * Creates an iterator that iterates through all possible unordered
     * partitions of an integer set of elements.
     *
     * @param nElements the number of elements to consider in partitioning
     * @return an iterator of each possible partition
     */
//    public static Iterator<List<Integer>> ffUnorderedPartitioning(int nElements) {
//        return Generator.partition(nElements).iterator();
//    }

    /**
     * Conducts a full factorial enumeration of ordered partitions but doesn't
     * enumerate partitions that have more than a maximum allowable number of
     * elements per partition. Partitions are returned as an array of integers
     * where each integer value indicates the partition number an element
     * belongs to. The largest partition number within an array is such that one
     * minus the number is also a partition number belonging to the array.
     *
     * @param nElements the number of elements to consider in partitioning
     * @param maxElements the maximum number of elements per partition
     * @return a full factorial enumeration of collection of partitions
     */
    public static Collection<int[]> ffOrderedPartitioning(int nElements, int maxElements) {
        //in implementation, we maintain the maximum partition number of the array in the 0th index
        Collection<int[]> prev = new ArrayList<>();
        prev.add(new int[]{0, 0});
        while (true) {
            ArrayList<int[]> curr = new ArrayList<>();
            for (int[] subPart : prev) {
                for (int partNum = 0; partNum <= subPart[0] + 1; partNum++) {
                    int[] extended = Arrays.copyOf(subPart, subPart.length + 1);
                    extended[subPart.length] = partNum;
                    extended[0] = Math.max(subPart[0], partNum);
                    curr.add(extended);
                }
            }
            if (curr.get(0).length == nElements + 1) {
                ArrayList<int[]> out = new ArrayList<>(curr.size());
                for (int[] partition : curr) {
                    HashMap<Integer, Integer> map = new HashMap<>();
                    //count the number of elements in each partition
                    for (int partitionNumber : partition) {
                        if (!map.containsKey(partitionNumber)) {
                            map.put(partitionNumber, 0);
                        }
                        map.put(partitionNumber, map.get(partitionNumber) + 1);
                    }
                    for (int elementCount : map.values()) {
                        if (elementCount > maxElements) {
                            break;
                        }
                    }
                    //if partial partition meets constraint
                    out.add(Arrays.copyOfRange(partition, 1, partition.length));
                }
                return out;
            }
            prev = curr;
        }
    }

    /**
     * Conducts a full factorial enumeration of a permutation
     *
     * @param nElements the number of elements in the permutation
     * @return all permutations
     */
    public static Collection<int[]> ffPermuting(int nElements) {
        int[] array = new int[nElements];
        for (int i = 0; i < nElements; i++) {
            array[i] = i;
        }

        ArrayList<int[]> permutations = new ArrayList<>(factorial(array.length));

        permute(array, 0, array.length - 1, permutations);
        return permutations;
    }

    /**
     * Computes the factorial of a number.
     *
     * @param n the input to a factorial
     * @return the factorial of a number.
     */
    private static int factorial(int n) {
        int out = 1;
        for (int i = n; i > 1; i--) {
            out *= i;
        }
        return out;
    }

    /**
     * Recursive method to conduct a full factorial enumeration of permutations
     *
     * @param array the permutation
     * @param l left index
     * @param r right index
     * @param permutations container for completed permutations
     */
    private static void permute(int[] array, int l, int r, Collection<int[]> permutations) {
        if (l == r) {
            permutations.add(Arrays.copyOf(array, array.length));
        } else {
            for (int i = l; i <= r; i++) {
                swap(array, l, i);
                permute(array, l + 1, r, permutations);
                swap(array, l, i);
            }
        }
    }

    /**
     * Swaps the position of the elements in the array at index i and j.
     *
     * @param array array to perform swap
     * @param i index of first element to swap
     * @param j index of second element to swap
     * @return
     */
    private static void swap(int[] array, int i, int j) {
        int tmp = array[i];
        array[i] = array[j];
        array[j] = tmp;
    }
}
