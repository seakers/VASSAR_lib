package rbsa.eoss.problems.DecadalSurvey;

import rbsa.eoss.architecture.AbstractArchitecture;

import java.util.*;

public class Architecture extends AbstractArchitecture{

    private Params params;
    private int[] instrumentPartitioning;
    private int[] orbitAssignment;
    private int numSatellites;

    public Architecture(int[] instrumentPartitioning, int[] orbitAssignment, int numSatellites, Params params) {
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

    public Architecture(List<Set<String>> instrumentPartitioning, Map<Set<String>, String> orbitAssignment, int numSatellites, Params params) {
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
                throw new IllegalArgumentException("orbitAssignment does not contain a set: " + Arrays.asList(sat));
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
        for(int p:instrumentPartitioning){
            if(p == -1){
                // Instrument not assigned to any set
                return false;
            }
            temp.add(p);
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
    public String toString(){
        return Arrays.toString(this.instrumentPartitioning) + " | " + Arrays.toString(this.orbitAssignment);
    }
}
