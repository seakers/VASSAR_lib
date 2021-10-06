package seakers.vassar.problems.Evaluating;

import jess.Rete;
import seakers.vassar.BaseParams;
import seakers.vassar.ResourcePool;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.MatlabFunctions;

import java.util.HashSet;
import java.util.Map;

public class ArchitectureEvaluator extends AbstractArchitectureEvaluator {

    public ArchitectureEvaluator(){
        super();
    }

    public ArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        super(resourcePool, arch, type);
    }

    public ArchitectureEvaluator getNewInstance() {
        return new ArchitectureEvaluator(super.resourcePool, super.arch, super.type);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        return new ArchitectureEvaluator(resourcePool, arch, type);
    }

    protected void assertMissions(BaseParams params, Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {
        Architecture arch = (Architecture) inputArch;
        try {
            this.orbitsUsed = new HashSet<>();
            String orbitName = arch.getOrbit();
            String instrumentList[] = arch.getInstrumentList();
            Map<String, Object> facts = arch.getMissionFacts();
            Orbit orb = new Orbit(orbitName, 1, 1);
            this.orbitsUsed.add(orb);
            String payload = "";
            String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";
            for (int i = 0; i < instrumentList.length; i++) {
                payload+=" " + instrumentList[i];
            }
            String factList = "";
            for (Map.Entry<String, Object> entry : facts.entrySet()) {
                factList+=" ("+entry.getKey()+" "+entry.getValue().toString()+")";
            }
            if (!facts.containsKey("lifetime")) {
                factList+="(lifetime 5)";
            }
            if (!facts.containsKey("launch-date")) {
                factList+="(launch-date 2015)";
            }
            call += "(instruments " + payload + ") "+factList+" (select-orbit no) " + orb.toJessSlots() + ""
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
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }
}
