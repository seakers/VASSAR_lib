package rbsa.eoss.architecture;

import rbsa.eoss.local.BaseParams;

import java.util.ArrayList;
import java.util.Random;

public abstract class AbstractArchitectureGenerator {

    protected static AbstractArchitectureGenerator instance = null;
    protected BaseParams params;
    protected Random rnd;

    public abstract AbstractArchitectureGenerator getInstance();

    protected AbstractArchitectureGenerator() {
        rnd = new Random();
    }

    public ArrayList<AbstractArchitecture> getInitialPopulation(int numArchs) {
        ArrayList<AbstractArchitecture> population = new ArrayList<>();
        population.addAll(getManualArchitectures());
        population.addAll(generateRandomPopulation(numArchs - population.size()));
        return population;
    }

    protected abstract ArrayList<AbstractArchitecture> getManualArchitectures();
    public abstract ArrayList<AbstractArchitecture> generateRandomPopulation(int numArchs);
    public abstract ArrayList<AbstractArchitecture> generateBiasedRandomPopulation(int numArchs, double bias);
    public abstract AbstractArchitecture getMaxArch();
    public abstract AbstractArchitecture getMinArch();
}
