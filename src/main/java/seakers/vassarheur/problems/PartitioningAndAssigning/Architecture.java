package seakers.vassarheur.problems.PartitioningAndAssigning;

import seakers.vassarheur.architecture.AbstractArchitecture;
import seakers.vassarheur.BaseParams;

import java.util.*;
import java.util.regex.Pattern;

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

        //if(!isFeasibleAssignment()){
            //throw new IllegalArgumentException("Infeasible architecture defined: \n" +
                    //Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment));
        //}
    }

    public Architecture(String valString, int numSatellites, BaseParams params) {
        super();
        int[] instrumentPartitions = getInstrumentPartitionsFromString(valString);
        int[] orbitAssignments = getOrbitAssignmentsFromString(valString, params);

        this.instrumentPartitioning = instrumentPartitions;
        this.orbitAssignment = orbitAssignments;
        this.params = params;
        this.numSatellites = numSatellites;

    }

    public Architecture(int[] instrumentPartitioning, int[] orbitAssignment, int numSatellites, BaseParams params) {
        super();
        this.instrumentPartitioning = instrumentPartitioning;
        this.orbitAssignment = orbitAssignment;
        this.params = params;
        this.numSatellites = numSatellites;

        //if(!isFeasibleAssignment()){
            //throw new IllegalArgumentException("Infeasible architecture defined: \n" +
                    //Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment));
        //}
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

        //if(!isFeasibleAssignment()){
            //throw new IllegalArgumentException("Infeasible architecture defined: " +
                    //Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment));
        //}
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
        sj.add("|");
        for(int i:this.orbitAssignment){
            sj.add(""+i);
        }
        return sj.toString();
    }

    private int[] getInstrumentPartitionsFromString(String archString) {
        String[] partitionStrings = archString.split(Pattern.quote("|"),2);
        ArrayList<Integer> instrumentPartitioningArrayList = new ArrayList<>();
        String instrumentPartitionString = partitionStrings[0];
        for (int i = 0; i < instrumentPartitionString.length(); i++) {
            String val = instrumentPartitionString.substring(i,i+1);
            if (!val.equalsIgnoreCase(" ")) {
                instrumentPartitioningArrayList.add(Integer.parseInt(val));
            }
        }
        return instrumentPartitioningArrayList.stream().mapToInt(i->i).toArray();
    }

    private int[] getOrbitAssignmentsFromString(String archString, BaseParams params) {
        String[] partitionStrings = archString.split(Pattern.quote("|"),2);
        int[] orbitAssignment = new int[params.getNumInstr()];
        Arrays.fill(orbitAssignment, -1);
        String orbitAssignmentString = partitionStrings[1];
        int index = 0;
        for (int i = 0; i < orbitAssignmentString.length(); i++) {
            String val = orbitAssignmentString.substring(i,i+1);
            if (!val.equalsIgnoreCase(" ")) {
                if (val.equalsIgnoreCase("-")) {
                    break;
                } else {
                    orbitAssignment[index] = Integer.parseInt(val);
                    index += 1;
                }
            }
        }
        return orbitAssignment;
    }
}
