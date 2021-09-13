package seakers.vassar.problems.PartitioningAndAssigning;

import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.architecture.AbstractArchitectureGenerator;
import seakers.vassar.BaseParams;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class ArchitectureGenerator extends AbstractArchitectureGenerator{

    private PartitioningAndAssigningParams params;
    private Random rnd;

    public ArchitectureGenerator(PartitioningAndAssigningParams params) {
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
                int maxNumSats = rnd.nextInt(params.getNumInstr()) + 1;

                for(int j = 0; j < params.getNumInstr(); j++){
                    instrumentPartitioning[j] = rnd.nextInt(maxNumSats);
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

                int numSats = map.keySet().size();
                for(int k = 0; k < params.getNumInstr(); k++){
                    if(k < numSats){
                        orbitAssignment[k] = rnd.nextInt(params.getNumOrbits());;
                    }else{
                        orbitAssignment[k] = -1;
                    }
                }

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
