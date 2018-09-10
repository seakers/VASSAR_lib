/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss.local.test.search.problems.Assigning;

import org.moeaframework.core.Solution;
import org.moeaframework.problem.AbstractProblem;
import rbsa.eoss.Result;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
import rbsa.eoss.local.BaseParams;
import seak.architecture.problem.SystemArchitectureProblem;

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

    private final ArchitectureEvaluationManager evaluationManager;

    private final BaseParams params;

    private final double dcThreshold = 0.5;

    private final double massThreshold = 3000.0; //[kg]

    private final double packingEffThreshold = 0.4; //[kg]

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
    }

    @Override
    public void evaluate(Solution sltn) {
        AssigningArchitecture arch = (AssigningArchitecture) sltn;
        evaluateArch(arch);
        System.out.println(String.format("Arch %s Science = %10f; Cost = %10f",
                arch.toString(), arch.getObjective(0), arch.getObjective(1)));
    }

    private void evaluateArch(AssigningArchitecture arch) {
        if (!arch.getAlreadyEvaluated()) {
            String bitString = "";
            for (int i = 1; i < this.getNumberOfVariables(); ++i) {
                bitString += arch.getVariable(i).toString();
            }

            AbstractArchitecture arch_old;
            if (problem.equalsIgnoreCase("SMAP") || problem.equalsIgnoreCase("ClimateCentric")) {
                // Generate a new architecture
                arch_old = new rbsa.eoss.problems.Assigning.Architecture(bitString, 1, (rbsa.eoss.problems.Assigning.AssigningParams)params);

            }
            else {
                throw new IllegalArgumentException("Unrecorgnizable problem type: " + problem);
            }

            Result result = null;
            try {
                result = this.evaluationManager.evaluateArchitectureAsync(arch_old, "Slow").get();
            }
            catch (ExecutionException e) {
                System.out.println("Exception when evaluating an architecture");
                e.printStackTrace();
                this.evaluationManager.clear();
                System.exit(-1);
            }
            catch (InterruptedException e) {
                System.out.println("Execution got interrupted while evaluating an architecture");
                e.printStackTrace();
                this.evaluationManager.clear();
                System.exit(-1);
            }

            arch.setObjective(0, -result.getScience()); //negative because MOEAFramework assumes minimization problems

            double cost = result.getCost();
            arch.setObjective(1, cost); //normalize cost to maximum value
            arch.setAlreadyEvaluated(true);
        }
    }

    @Override
    public Solution newSolution() {
        return new AssigningArchitecture(alternativesForNumberOfSatellites, params.getNumInstr(), params.getNumOrbits(), 2);
    }

}
