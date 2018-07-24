/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

import org.moeaframework.core.Solution;
import seak.architecture.pattern.ArchitecturalDecision;
import seak.architecture.pattern.Assigning;
import seak.architecture.pattern.Combining;
import seak.architecture.Architecture;

import java.util.ArrayList;

/**
 * This class creates a solution for the problem consisting of an assigning
 * pattern of instruments to orbits and a combining pattern for the number of
 * satellites per orbit. Assigning instruments from the left hand side to orbits
 * on the right hand side
 *
 * @author nozomi
 */
public class InstrumentAssignmentArchitecture extends Architecture {

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
    public InstrumentAssignmentArchitecture(int[] alternativesForNumberOfSatellites,
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
    private InstrumentAssignmentArchitecture(Solution solution) {
        super(solution);
        this.alternativesForNumberOfSatellites = ((InstrumentAssignmentArchitecture) solution).alternativesForNumberOfSatellites;
    }

    public void setAlreadyEvaluated(boolean alreadyEvaluated) {
        this.alreadyEvaluated = alreadyEvaluated;
    }

    public boolean getAlreadyEvaluated() {
        return this.alreadyEvaluated;
    }

    @Override
    public Solution copy() {
        return new InstrumentAssignmentArchitecture(this);
    }
}
