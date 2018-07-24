/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

import org.moeaframework.core.Solution;
import org.moeaframework.problem.AbstractProblem;
import rbsa.eoss.local.Params;
import seak.architecture.problem.SystemArchitectureProblem;


/**
 * An assigning problem to optimize the allocation of n instruments to m orbits.
 * Also can choose the number of satellites per orbital plane. Objectives are
 * cost and scientific benefit
 *
 * @author nozomihitomi
 */
public class InstrumentAssignment extends AbstractProblem implements SystemArchitectureProblem {

    private final int[] alternativesForNumberOfSatellites;

    private final ArchitectureEvaluator eval;

    private final double dcThreshold = 0.5;

    private final double massThreshold = 3000.0; //[kg]

    private final double packingEffThreshold = 0.4; //[kg]

    /**
     * @param alternativesForNumberOfSatellites
     */
    public InstrumentAssignment(int[] alternativesForNumberOfSatellites, ArchitectureEvaluator archEval) {
        //2 decisions for Choosing and Assigning Patterns
        super(1 + Params.getInstance().numInstr*Params.getInstance().numOrbits, 2);
        this.eval = archEval;
        this.alternativesForNumberOfSatellites = alternativesForNumberOfSatellites;
    }

    @Override
    public void evaluate(Solution sltn) {
        InstrumentAssignmentArchitecture arch = (InstrumentAssignmentArchitecture) sltn;
        evaluateArch(arch);
        System.out.println(String.format("Arch %s Science = %10f; Cost = %10f",
                arch.toString(), arch.getObjective(0), arch.getObjective(1)));
    }

    private void evaluateArch(InstrumentAssignmentArchitecture arch) {
        if (!arch.getAlreadyEvaluated()) {
            String bitString = "";
            for(int i = 1; i < this.getNumberOfVariables(); ++i) {
                bitString += arch.getVariable(i).toString();
            }
            Architecture arch_old = new Architecture(bitString, 1);
            Result result = eval.evaluateArchitecture(arch_old, "Slow");
            arch.setObjective(0, -result.getScience()); //negative because MOEAFramework assumes minimization problems

            double cost = result.getCost();
            arch.setObjective(1, cost); //normalize cost to maximum value
            arch.setAlreadyEvaluated(true);
        }
    }

    @Override
    public Solution newSolution() {
        return new InstrumentAssignmentArchitecture(alternativesForNumberOfSatellites, Params.getInstance().numInstr, Params.getInstance().numOrbits, 2);
    }

}
