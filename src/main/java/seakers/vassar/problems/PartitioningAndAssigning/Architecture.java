package seakers.vassar.problems.PartitioningAndAssigning;

import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.BaseParams;

import java.util.*;

public class Architecture extends AbstractArchitecture{

    private BaseParams params;
    private int[] instrumentPartitioning;
    private int[] orbitAssignment;
    private int numSatellites;

    public Architecture(int[] intArray, int numSatellites, BaseParams params) {
        super();

        for(int i = 0; i < params.getNumInstr() * 2; i++){
            if(i < params.getNumInstr()){
                this.instrumentPartitioning[i] = intArray[i];
            }
            else{
                this.orbitAssignment[i - params.getNumInstr()] = intArray[i];
            }
        }

        this.params = params;
        this.numSatellites = numSatellites;

        if(!isFeasibleAssignment()){
            throw new IllegalArgumentException("Infeasible architecture defined: \n" +
                    Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment));
        }
    }

    public Architecture(int[] instrumentPartitioning, int[] orbitAssignment, int numSatellites, BaseParams params) {
        super();
        this.instrumentPartitioning = instrumentPartitioning;
        this.orbitAssignment = orbitAssignment;
        this.params = params;
        this.numSatellites = numSatellites;

        if(!isFeasibleAssignment()){
            throw new IllegalArgumentException("Infeasible architecture defined: \n" +
                    Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment));
        }
    }

    public Architecture(List<Set<String>> instrumentPartitioning, Map<Set<String>, String> orbitAssignment, int numSatellites, BaseParams params) {
        super();

        String[] instrList = params.getInstrumentList();

        this.instrumentPartitioning = new int[params.getNumInstr()];
        this.orbitAssignment = new int[params.getNumInstr()];

        // Initialize entries of both arrays
        for(int i = 0; i < params.getNumInstr(); i++){
            this.instrumentPartitioning[i] = -1;
            this.orbitAssignment[i] = -1;
        }

        int satIndex = 0;
        for(Set<String> sat:instrumentPartitioning){

            String orb;
            if(orbitAssignment.keySet().contains(sat)){
                orb = orbitAssignment.get(sat);
            }else{
                throw new IllegalArgumentException("orbitAssignment does not contain the set: " + Arrays.asList(sat));
            }

            for(int j = 0; j < params.getNumInstr(); j++){
                if(sat.contains(instrList[j])){
                    this.instrumentPartitioning[j] = satIndex;
                }
            }

            this.orbitAssignment[satIndex] = params.getOrbitIndexes().get(orb);
            satIndex += 1;
        }

        this.numSatellites = numSatellites;

        if(!isFeasibleAssignment()){
            throw new IllegalArgumentException("Infeasible architecture defined: " +
                    Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment));
        }
    }

    @Override
    public boolean isFeasibleAssignment() {
        Set<Integer> temp = new HashSet<>();
        for(int p: instrumentPartitioning){
            if(p == -1){
                // Instrument not assigned to any set
                return false;
            }
            temp.add(p);
        }

        int numOrbitUsed = 0;
        for(int o: orbitAssignment){
            if(o!=-1){
                numOrbitUsed++;
            }
        }
        if(numOrbitUsed != temp.size()){
            // Number of orbits assigned does not match the number of satellites
            return false;
        }

        for(int p:temp){
            if(orbitAssignment[p] == -1){
                // Set not assigned to any orbit
                return false;
            }
        }
        return true;
    }

    public int getNumSatellites() {
        return numSatellites;
    }

    public int[] getInstrumentPartitioning(){
        return this.instrumentPartitioning;
    }

    public int[] getOrbitAssignment(){ return this.orbitAssignment; }

    @Override
    public String ppString(){
        return Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment);
    }

    public String toString(String delimiter){
        StringJoiner sj = new StringJoiner(delimiter);
        for(int i:this.instrumentPartitioning){
            sj.add(""+i);
        }
        for(int i:this.orbitAssignment){
            sj.add(""+i);
        }
        return sj.toString();
    }
}
