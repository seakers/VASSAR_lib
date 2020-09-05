package seakers.vassar.problems.Scheduling;

import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.architecture.AbstractArchitectureGenerator;
import seakers.vassar.BaseParams;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class ArchitectureGenerator extends AbstractArchitectureGenerator {

    private SchedulingParams params;
    private int numMiss;
    private Random rnd;

    public ArchitectureGenerator(int numMiss) {
        this.numMiss = numMiss;
        this.rnd = new Random();
    }

    public ArchitectureGenerator getNewInstance(BaseParams params){
        return new ArchitectureGenerator(5);
    }

    protected ArrayList<AbstractArchitecture> getManualArchitectures() {
        ArrayList<AbstractArchitecture> man_archs = new ArrayList<>();
        return man_archs;
    }

    public ArrayList<AbstractArchitecture> generateRandomPopulation(int numArchs) {
        ArrayList<AbstractArchitecture> popu = new ArrayList<>(numArchs);
        try {
            for (int i = 0; i < numArchs; i++) {
                int[] x = new int[numMiss];
                for (int j = 0; j < numMiss; j++) {
                    x[j]=rnd.nextInt();
                }
                AbstractArchitecture arch = new Architecture(x);
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
