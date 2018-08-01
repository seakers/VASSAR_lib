package rbsa.eoss.problems.PartitioningAndAssigning;

import jess.*;
import rbsa.eoss.*;
import rbsa.eoss.architecture.AbstractArchitecture;
import rbsa.eoss.evaluation.AbstractArchitectureEvaluator;
import rbsa.eoss.local.BaseParams;
import rbsa.eoss.spacecraft.Orbit;
import rbsa.eoss.utils.MatlabFunctions;

import java.util.*;

/**
 *
 * @author Ana-Dani
 */

public class ArchitectureEvaluator extends AbstractArchitectureEvaluator{

    protected BaseParams params;

    public ArchitectureEvaluator(BaseParams params){
        super();
        this.params = params;
    }

    public ArchitectureEvaluator(BaseParams params, ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        super(resourcePool, arch, type);
        this.params = params;
    }

    public ArchitectureEvaluator getNewInstance(BaseParams params){
        return new ArchitectureEvaluator((Decadal2017AerosolsParams) params, super.resourcePool, super.arch, super.type);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type){
        return new ArchitectureEvaluator(this.params, resourcePool, arch, type);
    }

    protected BaseParams getParams(){
        return this.params;
    }

    protected void assertMissions(Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {

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

                String orbitName = getParams().getOrbitList()[orbIndex];
                Orbit orb = new Orbit(orbitName, 1, arch.getNumSatellites());
                orbitsUsed.add(orb);

                String payload = "";
                String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";

                for (int instrIndex: instrumentSet) {
                    payload += " " + getParams().getInstrumentList()[instrIndex];
                }

                call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                        + "(factHistory F" + getParams().nof + ")))";
                getParams().nof++;

                call += "(assert (SYNERGIES::cross-registered-instruments " +
                        " (instruments " + payload +
                        ") (degree-of-cross-registration spacecraft) " +
                        " (platform " + orbitName +  " )"
                        + "(factHistory F" + getParams().nof + ")))";
                getParams().nof++;
                r.eval(call);
            }
        }
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }
}
