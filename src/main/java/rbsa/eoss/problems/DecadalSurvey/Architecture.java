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

        String[] instrList = params.getInstrumentList();

        this.instrumentPartitioning = new int[params.getNumInstr()];
        this.orbitAssignment = new int[params.getNumInstr()];

        // Initialize entries in the orbit assignment
        for(int i = 0; i < params.getNumInstr(); i++){
            this.orbitAssignment[i] = -1;
        }

        int satIndex = 0;
        for(Set<String> sat:instrumentPartitioning){
            String orb = orbitAssignment.get(sat);
            for(int j = 0; j < params.getNumInstr(); j++){
                if(sat.contains(instrList[j])){
                    this.instrumentPartitioning[j] = satIndex;
                }
            }
            this.orbitAssignment[satIndex] = params.getOrbitIndexes().get(orb);
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
