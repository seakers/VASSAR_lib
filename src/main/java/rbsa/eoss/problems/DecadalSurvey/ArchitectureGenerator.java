package rbsa.eoss.problems.DecadalSurvey;

import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.architecture.AbstractArchitectureGenerator;
import rbsa.eoss.local.BaseParams;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class ArchitectureGenerator extends AbstractArchitectureGenerator{

    private Params params;
    private Random rnd;

    private ArchitectureGenerator(Params params) {
        this.params = params;
        this.rnd = new Random();
    }

    public ArchitectureGenerator getNewInstance(BaseParams params){
        return new ArchitectureGenerator((Params) params);
    }

    protected ArrayList<AbstractArchitecture> getManualArchitectures() {
        ArrayList<AbstractArchitecture> man_archs = new ArrayList<>();
        return man_archs;
    }

    public ArrayList<AbstractArchitecture> generateRandomPopulation(int numArchs) {
        ArrayList<AbstractArchitecture> popu = new ArrayList<>(numArchs);
        try {
            for (int i = 0; i < numArchs; i++) {

                int[] instrumentPartitioning = new int[params.numInstr];
                int[] orbitAssignment = new int[params.numInstr];

                int numSats = rnd.nextInt(params.numInstr);
                for(int j = 0; j < params.numInstr; j++){
                    instrumentPartitioning[j] = rnd.nextInt(numSats);
                }

                HashMap<Integer, Integer> map = new HashMap<>();
                int satIndex = 0;
                for(int j = 0; j < params.numInstr; j++){
                    int satID = instrumentPartitioning[j];
                    if(map.keySet().contains(satID)){
                        instrumentPartitioning[j] = map.get(satID);
                    }else{
                        instrumentPartitioning[j] = satIndex;
                        map.put(satID, satIndex);
                        satIndex++;
                    }
                }

                for(int k = 0; k < params.numInstr; k++){
                    if(k < numSats){
                        orbitAssignment[k] = rnd.nextInt(params.numOrbits);
                    }else{
                        orbitAssignment[k] = -1;
                    }
                }

                AbstractArchitecture arch = new Architecture(instrumentPartitioning, orbitAssignment,
                        params.numSatellites[rnd.nextInt(params.numSatellites.length)],params);
                popu.add(arch);
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return popu;
    }

    public ArrayList<AbstractArchitecture> generateBiasedRandomPopulation(int numArchs, double bias) {
        throw new UnsupportedOperationException();
    }
}