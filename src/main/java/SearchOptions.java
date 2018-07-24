package rbsa.eoss;
import java.util.ArrayList;

/**
 *
 * @author Ana-Dani
 */

public class SearchOptions {
    private int MAX_ITS;
    private double TOL;
    private double mutationRate;
    private int populationSize;
    private double improvementRate;
    private ArrayList<Architecture> initPopulation;
    
    public SearchOptions(int n, int MAX_ITS, double TOL, double mut, double improvementRate, ArrayList<Architecture> init_pop) {
        this.MAX_ITS = MAX_ITS;
        this.TOL = TOL;
        this.mutationRate = mut;
        this.improvementRate = improvementRate;
        populationSize = n;
        if (init_pop == null)
            initPopulation = ArchitectureGenerator.getInstance().generateRandomPopulation(n);
        else
            initPopulation = init_pop;
    }

    public ArrayList<Architecture> getInitPopulation() {
        return initPopulation;
    }

    public void setInitPopulation(ArrayList<Architecture> initPopulation) {
        this.initPopulation = initPopulation;
    }

    public double getImprovementRate() {
        return improvementRate;
    }

    public void setImprovementRate(double improvementRate) {
        this.improvementRate = improvementRate;
    }

    public int getPopulationSize() {
        return populationSize;
    }

    public void setPopulationSize(int populationSize) {
        this.populationSize = populationSize;
    }

    public double getMutationRate() {
        return mutationRate;
    }

    public int getMAX_ITS() {
        return MAX_ITS;
    }

    public void setMAX_ITS(int MAX_ITS) {
        this.MAX_ITS = MAX_ITS;
    }

    public double getTOL() {
        return TOL;
    }

    public void setTOL(double TOL) {
        this.TOL = TOL;
    }
    
    public Boolean checkTerminationCriteria(SearchPerformance sp) {
        Boolean converged = false;
        if (sp.nits >= MAX_ITS) {
            converged = true;
        }
        
        return converged;
    }
}
