/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar.search.problems.Assigning;

import org.moeaframework.core.Solution;
import org.moeaframework.problem.AbstractProblem;
import seakers.architecture.problem.SystemArchitectureProblem;
import seakers.vassar.BaseParams;
import seakers.vassar.Result;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.problems.Assigning.Architecture;
import seakers.vassar.problems.Assigning.AssigningParams;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;


/**
 * An assigning problem to optimize the allocation of n instruments to m orbits.
 * Also can choose the number of satellites per orbital plane. Objectives are
 * cost and scientific benefit
 *
 * @author nozomihitomi
 */
public class AssigningProblem extends AbstractProblem implements SystemArchitectureProblem {

    private final int[] alternativesForNumberOfSatellites;

    private final String problem;

    private final double dcThreshold = 0.5;

    private final double massThreshold = 3000.0; //[kg]

    private final double packingEffThreshold = 0.4; //[kg]

    private int nfe;

    private ArchitectureEvaluationManager evaluationManager;

    private BaseParams params;

    private boolean saveEvaluatedSolutions;

    private Map<Integer, double[]> hashedArch;

    /**
     * @param alternativesForNumberOfSatellites
     */
    public AssigningProblem(int[] alternativesForNumberOfSatellites, String problem, ArchitectureEvaluationManager evaluationManager, BaseParams params) {
        //2 decisions for Choosing and Assigning Patterns
        super(1 + params.getNumInstr()*params.getNumOrbits(), 2);
        this.problem = problem;
        this.evaluationManager = evaluationManager;
        this.alternativesForNumberOfSatellites = alternativesForNumberOfSatellites;
        this.params = params;
        this.nfe = 0;
        this.saveEvaluatedSolutions = false;
        this.hashedArch = new HashMap<>();
    }

    @Override
    public void evaluate(Solution sltn) {
        AssigningArchitecture arch = (AssigningArchitecture) sltn;
        evaluateArch(arch);
        this.nfe++;
        System.out.println(this.nfe + ": " + String.format("Arch %s Science = %10f; Cost = %10f",
                arch.toString(), -arch.getObjective(0), arch.getObjective(1)));
    }

    private void evaluateArch(AssigningArchitecture arch) {
        if (!arch.getAlreadyEvaluated()) {

            if(hashedArch.containsKey(arch.hashCode())){
                double[] objectives = hashedArch.get(arch.hashCode());
                arch.setObjective(0, objectives[0]); //negative because MOEAFramework assumes minimization problems
                arch.setObjective(1, objectives[1]); //normalize cost to maximum value
                arch.setAlreadyEvaluated(true);

            }else{
                StringBuilder bitStringBuilder = new StringBuilder(this.getNumberOfVariables());
                for (int i = 1; i < this.getNumberOfVariables(); ++i) {
                    bitStringBuilder.append(arch.getVariable(i).toString());
                }

                AbstractArchitecture arch_old;
                if (problem.equalsIgnoreCase("SMAP") || problem.equalsIgnoreCase("SMAP_JPL1")
                        || problem.equalsIgnoreCase("SMAP_JPL2")
                        || problem.equalsIgnoreCase("ClimateCentric") || problem.equalsIgnoreCase("DSHIELD")) {
                    // Generate a new architecture
                    arch_old = new Architecture(bitStringBuilder.toString(), 4, (AssigningParams)params);
                }
                else {
                    throw new IllegalArgumentException("Unrecorgnizable problem type: " + problem);
                }

                try {
                    Result result = this.evaluationManager.evaluateArchitectureAsync(arch_old, "Slow").get();
                    arch.setObjective(0, -result.getCoverage()); //negative because MOEAFramework assumes minimization problems
                    arch.setObjective(1, result.getCost()); //normalize cost to maximum value
                    arch.setAlreadyEvaluated(true);

                    if(this.saveEvaluatedSolutions){
                        double[] objectives = new double[2];
                        objectives[0] = -result.getScience();
                        objectives[1] = result.getCost();
                        hashedArch.put(arch.hashCode(), objectives);
                    }
                }
                catch (InterruptedException | ExecutionException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public AssigningProblem setSaveEvaluatedSolutions(){
        this.saveEvaluatedSolutions = true;
        return this;
    }

    public void clearHashedArch(){
        this.hashedArch = new HashMap<>();
    }

    @Override
    public Solution newSolution() {
        return new AssigningArchitecture(alternativesForNumberOfSatellites, params.getNumInstr(), params.getNumOrbits(), 2);
    }

    public void resetEvaluationManager(){
        this.evaluationManager.init();
    }
}
