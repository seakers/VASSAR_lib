package seakers.vassar.problems.PartitioningAndAssigning;

import jess.Rete;
import seakers.vassar.ResourcePool;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.BaseParams;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.MatlabFunctions;

import java.util.*;

/**
 *
 * @author Ana-Dani
 */

public class ArchitectureEvaluator extends AbstractArchitectureEvaluator {

    public ArchitectureEvaluator(){
        super();
    }

    public ArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        super(resourcePool, arch, type);
    }

    public ArchitectureEvaluator getNewInstance(){
        return new ArchitectureEvaluator(super.resourcePool, super.arch, super.type);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type){
        return new ArchitectureEvaluator(resourcePool, arch, type);
    }

    protected void assertMissions(BaseParams params, Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {

        Architecture arch = (Architecture) inputArch;

        int[] instrumentPartitioning = arch.getInstrumentPartitioning();
        int[] orbitAssignment = arch.getOrbitAssignment();

        Map<Integer, Integer> satIndex2Orbit = new HashMap<>();
        Map<Integer, Set<Integer>> satIndex2InstrumentSet = new HashMap<>();

        for(int i = 0; i < instrumentPartitioning.length; i++){
            int satIndex = instrumentPartitioning[i];
            int orbit = orbitAssignment[satIndex];

            // Set orbit
            if(!satIndex2Orbit.containsKey(satIndex)){
                satIndex2Orbit.put(satIndex, orbit);
            }

            // Add new instrument set
            if(!satIndex2InstrumentSet.containsKey(satIndex)){
                satIndex2InstrumentSet.put(satIndex, new HashSet<>());
            }
            // Add an instrument
            Set<Integer> set = satIndex2InstrumentSet.get(satIndex);
            set.add(i);
        }

        try {
            this.orbitsUsed = new HashSet<>();
            for (int index: satIndex2Orbit.keySet()) {
                int orbIndex = satIndex2Orbit.get(index);
                Set<Integer> instrumentSet = satIndex2InstrumentSet.get(index);

                String orbitName = params.getOrbitList()[orbIndex];
                Orbit orb = new Orbit(orbitName, 1, arch.getNumSatellites());
                orbitsUsed.add(orb);

                String payload = "";
                String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";

                for (int instrIndex: instrumentSet) {
                    payload += " " + params.getInstrumentList()[instrIndex];
                }

                call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                        + "(factHistory F" + params.nof + ")))";
                params.nof++;

                call += "(assert (SYNERGIES::cross-registered-instruments " +
                        " (instruments " + payload +
                        ") (degree-of-cross-registration spacecraft) " +
                        " (platform " + orbitName +  " )"
                        + "(factHistory F" + params.nof + ")))";
                params.nof++;
                r.eval(call);
            }
        }
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }
}
