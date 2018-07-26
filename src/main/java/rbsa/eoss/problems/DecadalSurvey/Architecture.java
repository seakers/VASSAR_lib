package rbsa.eoss.problems.DecadalSurvey;

import rbsa.eoss.architecture.AbstractArchitecture;
import java.util.List;
import java.util.Set;
import java.util.Map;

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
    }

    public Architecture(List<Set<String>> instrumentPartitioning, Map<Set<String>, String> orbitAssignment, int numSatellites, Params params) {
        super();

        String[] orbitList = params.orbitList;
        String[] instrList = params.instrumentList;

        this.instrumentPartitioning = new int[instrList.length];
        this.orbitAssignment = new int[instrList.length];

        // Initialize entries in the orbit assignment
        for(int i = 0; i < instrList.length; i++){
            this.orbitAssignment[i] = -1;
        }

        int satIndex = 0;
        for(Set<String> sat:instrumentPartitioning){
            String orb = orbitAssignment.get(sat);
            for(int j = 0; j < instrList.length; j++){
                if(sat.contains(instrList[j])){
                    this.instrumentPartitioning[j] = satIndex;
                }
            }
            for(int k = 0; k < orbitList.length; k++){
                if(orb == orbitList[k]){
                    this.orbitAssignment[satIndex] = k;
                }
            }
            satIndex += 1;
        }

        this.numSatellites = numSatellites;
    }

    @Override
    public boolean isFeasibleAssignment() {
        return true;
    }

    public int getNumSatellites() {
        return numSatellites;
    }

    public int[] getInstrumentPartitioning(){
        return this.instrumentPartitioning;
    }

    public int[] getOrbitAssignment(){ return this.orbitAssignment; }
}
