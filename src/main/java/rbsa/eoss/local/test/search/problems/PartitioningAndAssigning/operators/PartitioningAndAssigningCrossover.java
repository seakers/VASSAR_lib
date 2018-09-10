package rbsa.eoss.local.test.search.problems.PartitioningAndAssigning.operators;

import org.moeaframework.core.Solution;
import org.moeaframework.core.Variation;
import rbsa.eoss.local.BaseParams;
import rbsa.eoss.local.test.search.problems.PartitioningAndAssigning.PartitioningAndAssigningArchitecture;
import seak.architecture.Architecture;
import seak.architecture.util.IntegerVariable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Random;

public class PartitioningAndAssigningCrossover implements Variation {

    protected double probability;
    protected BaseParams params;
    protected String option = "antoni"; // antoni, prachi

    public PartitioningAndAssigningCrossover(double probability, BaseParams params, String option){
        this.probability = probability;
        this.params = params;
        this.option = option;
    }

    public PartitioningAndAssigningCrossover(double probability, BaseParams params){
        this.probability = probability;
        this.params = params;
    }

    @Override
    public Solution[] evolve(Solution[] parents){

        Solution[] out = new Solution[2];

        Architecture arch1 = (PartitioningAndAssigningArchitecture) parents[0];
        Architecture arch2 = (PartitioningAndAssigningArchitecture) parents[1];
        int[] intVars1 = getIntVariables(arch1);
        int[] intVars2 = getIntVariables(arch2);
        int[] partitioning1 = Arrays.copyOfRange(intVars1, 0, params.getNumInstr());
        int[] partitioning2 = Arrays.copyOfRange(intVars2, 0, params.getNumInstr());
        int[] assigning1 = Arrays.copyOfRange(intVars1, params.getNumInstr(), 2 * params.getNumInstr()+1);
        int[] assigning2 = Arrays.copyOfRange(intVars2, params.getNumInstr(), 2 * params.getNumInstr()+1);

        Architecture newArch1 = new PartitioningAndAssigningArchitecture(params.getNumInstr(), params.getNumOrbits(), 2);
        Architecture newArch2 = new PartitioningAndAssigningArchitecture(params.getNumInstr(), params.getNumOrbits(), 2);
        int[] newPartitioning1 = new int[partitioning1.length];
        int[] newPartitioning2 = new int[partitioning2.length];
        int[] newAssigning1 = new int[assigning1.length];
        int[] newAssigning2 = new int[assigning2.length];

        Random random = new Random();
        int split = random.nextInt(partitioning1.length); // Single-point crossover

        if(option == "antoni"){
            int[] orbitAssigned1 = new int[partitioning1.length];
            for(int i = 0; i < partitioning1.length; i++){
                int sat = partitioning1[i];
                int orb = assigning1[sat];
                orbitAssigned1[i] = orb;
            }

            int[] orbitAssigned2 = new int[partitioning2.length];
            for(int i = 0; i < partitioning2.length; i++){
                int sat = partitioning2[i];
                int orb = assigning2[sat];
                orbitAssigned2[i] = orb;
            }

            ArrayList<int[]> orbitAssignedSwapped = swapSubarrays(orbitAssigned1, orbitAssigned2, split);

            int[] orbitAssignmentInfo1 = orbitAssignedSwapped.get(0);
            int[] orbitAssignmentInfo2 = orbitAssignedSwapped.get(1);

            ArrayList<int[]> temp1 = extractPartitioningAndAssigning(orbitAssignmentInfo1);
            ArrayList<int[]> temp2 = extractPartitioningAndAssigning(orbitAssignmentInfo2);

            newPartitioning1 = temp1.get(0);
            newAssigning1 = temp1.get(1);
            newPartitioning2 = temp2.get(0);
            newAssigning2 = temp2.get(1);

        }else if(option == "prachi"){
            throw new UnsupportedOperationException();
        }

        int[] newIntVars1 = new int[partitioning1.length + assigning1.length];
        int[] newIntVars2 = new int[partitioning1.length + assigning1.length];
        for(int i = 0; i < newPartitioning1.length;i ++){
            newIntVars1[i] = newPartitioning1[i];
            newIntVars2[i] = newPartitioning2[i];
        }
        for(int i = 0; i < newAssigning1.length;i ++){
            newIntVars1[i + newPartitioning1.length] = newAssigning1[i];
            newIntVars2[i + newPartitioning1.length] = newAssigning2[i];
        }
        setIntVariables(newArch1, newIntVars1);
        setIntVariables(newArch2, newIntVars2);

        out[0] = newArch1;
        out[1] = newArch2;
        return out;
    }

    private ArrayList<int[]> extractPartitioningAndAssigning(int[] assignedOrbit){
        int[] partitioning = new int[assignedOrbit.length];
        int[] assigning = new int[assignedOrbit.length];

        for(int i = 0; i < assignedOrbit.length; i++){
            partitioning[i] = -1;
            assigning[i] = -1;
        }

        int satIndex = 0;
        HashMap<Integer, Integer> orbit2SatIndex = new HashMap<>();
        HashMap<Integer, Integer> satIndex2Orbit = new HashMap<>();

        for(int i = 0; i < assignedOrbit.length; i++){
            int orb = assignedOrbit[i];

            if(!orbit2SatIndex.containsKey(orb)){
                orbit2SatIndex.put(orb, satIndex);
                satIndex2Orbit.put(satIndex, orb);
                satIndex++;
            }

            partitioning[i] = orbit2SatIndex.get(orb);
        }

        for(int index: satIndex2Orbit.keySet()){
            assigning[index] = satIndex2Orbit.get(index);
        }

        ArrayList<int[]> out = new ArrayList<>();
        out.add(partitioning);
        out.add(assigning);
        return out;
    }

    private ArrayList<int[]> swapSubarrays(int[] arr1, int[] arr2, int split){
        int[] out1 = new int[arr1.length];
        int[] out2 = new int[arr2.length];
        for(int i = 0; i < arr1.length; i++){
            if(i < split){
                out1[i] = arr1[i];
                out2[i] = arr2[i];
            }else{
                out2[i] = arr1[i];
                out1[i] = arr2[i];
            }
        }
        ArrayList<int[]> out = new ArrayList<>();
        out.add(out1);
        out.add(out2);
        return out;
    }

    private int[] getIntVariables(Architecture arch){
        int[] out = new int[arch.getNumberOfVariables()];
        for(int i = 0; i < out.length; i++){
            out[i] = ((IntegerVariable) arch.getVariable(i)).getValue();
        }
        return out;
    }

    private void setIntVariables(Architecture arch, int[] values){
        int[] out = new int[arch.getNumberOfVariables()];
        for(int i = 0; i < out.length; i++){
            ((IntegerVariable) arch.getVariable(i)).setValue(values[i]);
        }
    }

    @Override
    public int getArity(){ return 2; }
}
