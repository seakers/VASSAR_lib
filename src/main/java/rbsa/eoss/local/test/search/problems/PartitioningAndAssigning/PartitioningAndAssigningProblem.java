/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss.local.test.search.problems.PartitioningAndAssigning;

import org.moeaframework.core.Solution;
import org.moeaframework.problem.AbstractProblem;
import rbsa.eoss.Result;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
import rbsa.eoss.local.BaseParams;
import seak.architecture.problem.SystemArchitectureProblem;
import seak.architecture.util.IntegerVariable;

import java.util.HashSet;
import java.util.Set;


/**
 * An assigning problem to optimize the allocation of n instruments to m orbits.
 * Also can choose the number of satellites per orbital plane. Objectives are
 * cost and scientific benefit
 *
 * @author nozomihitomi
 */
public class PartitioningAndAssigningProblem extends AbstractProblem implements SystemArchitectureProblem {

    private final String problem;

    private final ArchitectureEvaluationManager evaluationManager;

    private final BaseParams params;

    private final double dcThreshold = 0.5;

    private final double massThreshold = 3000.0; //[kg]

    private final double packingEffThreshold = 0.4; //[kg]

    public PartitioningAndAssigningProblem(String problem, ArchitectureEvaluationManager evaluationManager, BaseParams params) {
        //2 decisions for Choosing and Assigning Patterns
        super(2 * params.getNumInstr(), 2);
        this.problem = problem;
        this.evaluationManager = evaluationManager;
        this.params = params;
    }

    @Override
    public void evaluate(Solution sltn) {
        PartitioningAndAssigningArchitecture arch = (PartitioningAndAssigningArchitecture) sltn;
        evaluateArch(arch);
        //System.out.println(String.format("Arch %s Science = %10f; Cost = %10f",
        //        arch.toString(), arch.getObjective(0), arch.getObjective(1)));
    }

    private void evaluateArch(PartitioningAndAssigningArchitecture arch) {
        if (!arch.getAlreadyEvaluated()) {

            int numPartitioningVariables = params.getNumInstr();
            int numAssignmentVariables = params.getNumInstr();

            int[] instrumentPartitioning = new int[numPartitioningVariables];
            int[] orbitAssignment = new int[numAssignmentVariables];

            for(int i = 0; i < numPartitioningVariables; i++){
                instrumentPartitioning[i] = ((IntegerVariable)arch.getVariable(i)).getValue();
            }

            for(int i = 0; i < numAssignmentVariables; i++){
                orbitAssignment[i] = ((IntegerVariable) arch.getVariable(numPartitioningVariables + i)).getValue();
            }

            // Check constraint
            double constraint = 1.0;
            if(!isFeasible(instrumentPartitioning, orbitAssignment)){
                constraint = 0.0;
            }
            arch.setConstraint(0, constraint);

            AbstractArchitecture arch_old;
            if (problem.equalsIgnoreCase("Decadal2017Aerosols")) {
                // Generate a new architecture
                arch_old = new rbsa.eoss.problems.PartitioningAndAssigning.Architecture(instrumentPartitioning, orbitAssignment,
                        1, params);

            }else{
                throw new IllegalArgumentException("Unrecorgnizable problem type: " + problem);
            }

            Result result = this.evaluationManager.evaluateArchitectureSync(arch_old, "Slow");
            arch.setObjective(0, -result.getScience()); //negative because MOEAFramework assumes minimization problems

            double cost = result.getCost();
            arch.setObjective(1, cost); //normalize cost to maximum value
            arch.setAlreadyEvaluated(true);
        }
    }

    @Override
    public Solution newSolution() {
        return new PartitioningAndAssigningArchitecture(params.getNumInstr(), params.getNumOrbits(), 2);
    }

    private boolean isFeasible(int[] instrumentPartitioning, int[] orbitAssignment){

        // Check if the number of satellites matches the number of orbit assignments
        Set<Integer> satIndices = new HashSet<>();
        for(int i = 0; i < instrumentPartitioning.length; i++){
            satIndices.add(instrumentPartitioning[i]);
        }

        for(int i = 0; i < orbitAssignment.length; i++){
            if(orbitAssignment[i] >= 0){
                continue;

            }else{
                if(satIndices.size() != i){
                    return false;
                }
            }
        }

        // Check if the index of the new satellite is +1 of the largest index
        int max = 0;
        for(int i = 0; i < instrumentPartitioning.length; i++){
            if(instrumentPartitioning[i] > max){
                if(instrumentPartitioning[i] == max + 1){
                    max = instrumentPartitioning[i];
                }else{
                    return false;
                }
            }
        }

        return true;
    }
}
