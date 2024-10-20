package seakers.vassar.architecture;

import seakers.vassar.BaseParams;

import java.util.ArrayList;

public abstract class AbstractArchitectureGenerator {

    public abstract AbstractArchitectureGenerator getNewInstance(BaseParams params);

    public ArrayList<AbstractArchitecture> getInitialPopulation(int numArchs) {
        ArrayList<AbstractArchitecture> population = new ArrayList<>();
        population.addAll(getManualArchitectures());
        population.addAll(generateRandomPopulation(numArchs - population.size()));
        return population;
    }

    protected abstract ArrayList<AbstractArchitecture> getManualArchitectures();
    public abstract ArrayList<AbstractArchitecture> generateRandomPopulation(int numArchs);
    public abstract ArrayList<AbstractArchitecture> generateBiasedRandomPopulation(int numArchs, double bias);
}
