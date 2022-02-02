package seakers.vassarheur.problems.PartitioningAndAssigning;

import jess.Rete;
import seakers.vassarheur.ResourcePool;
import seakers.vassarheur.architecture.AbstractArchitecture;
import seakers.vassarheur.evaluation.AbstractArchitectureEvaluator;
import seakers.vassarheur.BaseParams;
import seakers.vassarheur.spacecraft.Orbit;
import seakers.vassarheur.utils.MatlabFunctions;

import java.util.*;

/**
 *
 * @author Ana-Dani
 */

public class ArchitectureEvaluator extends AbstractArchitectureEvaluator {

    public ArchitectureEvaluator(){
        super();
    }

    public ArchitectureEvaluator(boolean considerFeasibility, double dcThreshold, double massThreshold, double packingEffThreshold) {
        super(considerFeasibility, dcThreshold, massThreshold, packingEffThreshold);
    }

    public ArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type, boolean considerFeasibility, double dcThreshold, double massThreshold, double packingEffThreshold) {
        super(resourcePool, arch, type, considerFeasibility, dcThreshold, massThreshold, packingEffThreshold);
    }

    public ArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type, boolean considerFeasibility) {
        super(resourcePool, arch, type, considerFeasibility, 0.5, 3000.0, 0.4);
    }

    public ArchitectureEvaluator getNewInstance(){
        return new ArchitectureEvaluator(super.resourcePool, super.arch, super.type, super.considerFeasibility, super.dcThreshold, super.massThreshold, super.packingEffThreshold);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type, boolean considerFeasibility){
        return new ArchitectureEvaluator(resourcePool, arch, type, considerFeasibility, 0.5, 3000.0, 0.4);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type, boolean considerFeasibility, double dcThreshold, double massThreshold, double packingEffThreshold){
        return new ArchitectureEvaluator(resourcePool, arch, type, considerFeasibility, dcThreshold, massThreshold, packingEffThreshold);
    }

    public void assertMissions(BaseParams params, Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {

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
            int satCount = 0;
            for (int index: satIndex2Orbit.keySet()) {
                int orbIndex = satIndex2Orbit.get(index);
                Set<Integer> instrumentSet = satIndex2InstrumentSet.get(index);

                String orbitName = params.getOrbitList()[orbIndex];
                Orbit orb = new Orbit(orbitName, 1, arch.getNumSatellites());
                orbitsUsed.add(orb);

                String payload = "";
                String call = "(assert (MANIFEST::Satellite (Name " + orbitName + ") ";

                for (int instrIndex: instrumentSet) {
                    payload += " " + params.getInstrumentList()[instrIndex];
                }

                call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                        + " (id sat" + satCount + ")"
                        + " (factHistory F" + params.nof + ")))";
                params.nof++;

                call += "(assert (SYNERGIES::cross-registered-instruments " +
                        " (instruments " + payload +
                        ") (degree-of-cross-registration spacecraft) " +
                        " (platform " + orbitName +  ") "
                        + "(factHistory F" + params.nof + ")))";
                params.nof++;
                r.eval(call);
                satCount++;
            }
        }
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }
}
