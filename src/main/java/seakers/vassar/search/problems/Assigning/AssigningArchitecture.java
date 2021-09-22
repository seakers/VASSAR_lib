/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar.search.problems.Assigning;

import org.moeaframework.core.Solution;
import seakers.architecture.Architecture;
import seakers.architecture.pattern.ArchitecturalDecision;
import seakers.architecture.pattern.Assigning;
import seakers.architecture.pattern.Combining;

import java.util.ArrayList;
import java.util.Objects;

/**
 * This class creates a solution for the problem consisting of an assigning
 * pattern of instruments to orbits and a combining pattern for the number of
 * satellites per orbit. Assigning instruments from the left hand side to orbits
 * on the right hand side
 *
 * @author nozomi
 */
public class AssigningArchitecture extends Architecture {

    private static final long serialVersionUID = 8776271523867355732L;

    /**
     * Tag used for the assigning decision
     */
    private static final String assignTag = "inst";

    /**
     * Tag used for the combining decision
     */
    private static final String combineTag = "nSat";

    /**
     * The available options of the number of satellites
     */
    private final int[] alternativesForNumberOfSatellites;

    private boolean alreadyEvaluated;

    //Constructors
    /**
     * Creates an empty architecture with a default number of satellites.
     * Default value is the first value in the array given as
     * alternativesForNumberOfSatellites
     *
     * @param numberOfInstruments
     * @param numberOfOrbits
     * @param alternativesForNumberOfSatellites
     * @param numberOfObjectives
     */
    public AssigningArchitecture(int[] alternativesForNumberOfSatellites,
                                 int numberOfInstruments, int numberOfOrbits, int numberOfObjectives) {
        super(numberOfObjectives, 0,
                createDecisions(alternativesForNumberOfSatellites, numberOfInstruments, numberOfOrbits));
        this.alternativesForNumberOfSatellites = alternativesForNumberOfSatellites;
        this.alreadyEvaluated = false;
    }

    private static ArrayList<ArchitecturalDecision> createDecisions(
            int[] altnertivesForNumberOfSatellites,
            int numberOfInstruments, int numberOfOrbits) {
        ArrayList<ArchitecturalDecision> out = new ArrayList<>();
        out.add(new Combining(new int[]{altnertivesForNumberOfSatellites.length}, combineTag));
        out.add(new Assigning(numberOfInstruments, numberOfOrbits, assignTag));
        return out;
    }

    /**
     * makes a copy solution from the input solution
     *
     * @param solution
     */
    private AssigningArchitecture(Solution solution) {
        super(solution);
        this.alternativesForNumberOfSatellites = ((AssigningArchitecture) solution).alternativesForNumberOfSatellites;
    }

    public void setAlreadyEvaluated(boolean alreadyEvaluated) {
        this.alreadyEvaluated = alreadyEvaluated;
    }

    public boolean getAlreadyEvaluated() {
        return this.alreadyEvaluated;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        for (int i = 0; i < getNumberOfVariables(); i++) {
            hash = 67 * hash + Objects.hashCode(this.getVariable(i));
        }
        return hash;
    }

    @Override
    public Solution copy() {
        return new AssigningArchitecture(this);
    }
}
