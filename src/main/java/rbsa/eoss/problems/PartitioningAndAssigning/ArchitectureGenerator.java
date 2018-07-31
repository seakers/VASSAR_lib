package rbsa.eoss.problems.PartitioningAndAssigning;

import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.architecture.AbstractArchitectureGenerator;
import rbsa.eoss.local.BaseParams;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class ArchitectureGenerator extends AbstractArchitectureGenerator{

    private Decadal2017AerosolsParams params;
    private Random rnd;

    public ArchitectureGenerator(Decadal2017AerosolsParams params) {
        this.params = params;
        this.rnd = new Random();
    }

    public ArchitectureGenerator getNewInstance(BaseParams params){
        return new ArchitectureGenerator((Decadal2017AerosolsParams) params);
    }

    protected ArrayList<AbstractArchitecture> getManualArchitectures() {
        ArrayList<AbstractArchitecture> man_archs = new ArrayList<>();
        return man_archs;
    }

    public ArrayList<AbstractArchitecture> generateRandomPopulation(int numArchs) {
        ArrayList<AbstractArchitecture> popu = new ArrayList<>(numArchs);
        try {
            for (int i = 0; i < numArchs; i++) {

                int[] instrumentPartitioning = new int[params.getNumInstr()];
                int[] orbitAssignment = new int[params.getNumInstr()];

                // There must be at least one satellite
                int numSats = rnd.nextInt(params.getNumInstr()-1) + 1;

                for(int j = 0; j < params.getNumInstr(); j++){
                    instrumentPartitioning[j] = rnd.nextInt(numSats);
                }

                HashMap<Integer, Integer> map = new HashMap<>();
                int satIndex = 0;
                for(int j = 0; j < params.getNumInstr(); j++){
                    int satID = instrumentPartitioning[j];
                    if(map.keySet().contains(satID)){
                        instrumentPartitioning[j] = map.get(satID);
                    }else{
                        instrumentPartitioning[j] = satIndex;
                        map.put(satID, satIndex);
                        satIndex++;
                    }
                }

                ArrayList<Integer> orbitOptions = new ArrayList<>();
                for(int k = 0; k < params.getNumOrbits(); k++){
                    orbitOptions.add(k);
                }

                for(int k = 0; k < params.getNumInstr(); k++){
                    if(k < numSats){
                        int selectedInd = rnd.nextInt(orbitOptions.size());
                        int selectedOrb = orbitOptions.get(selectedInd);
                        orbitOptions.remove(selectedInd);
                        orbitAssignment[k] = selectedOrb;
                    }else{
                        orbitAssignment[k] = -1;
                    }
                }

                //AbstractArchitecture arch = new Architecture(instrumentPartitioning, orbitAssignment,
                //        params.getNumSatellites()[rnd.nextInt(params.getNumSatellites().length)],params);
                AbstractArchitecture arch = new Architecture(instrumentPartitioning, orbitAssignment,
                        1,params);

                popu.add(arch);
            }
        } catch (Exception e) {
            System.out.println("Error in generating a random population: " + e.getMessage());
            throw new IllegalStateException();
        }
        return popu;
    }

    public ArrayList<AbstractArchitecture> generateBiasedRandomPopulation(int numArchs, double bias) {
        throw new UnsupportedOperationException();
    }
}
