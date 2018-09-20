package seakers.vassar.problems.Assigning;

import jess.*;
import seakers.vassar.ResourcePool;
import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.evaluation.AbstractArchitectureEvaluator;
import seakers.vassar.local.BaseParams;
import seakers.vassar.spacecraft.Orbit;
import seakers.vassar.utils.MatlabFunctions;

import java.util.*;

/**
 *
 * @author Ana-Dani
 */

public class ArchitectureEvaluator extends AbstractArchitectureEvaluator {

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
        return new ArchitectureEvaluator(params, super.resourcePool, super.arch, super.type);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type){
        return new ArchitectureEvaluator(this.params, resourcePool, arch, type);
    }

    protected BaseParams getParams(){
        return this.params;
    }

    protected void assertMissions(Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {

        Architecture arch = (Architecture) inputArch;

        boolean[][] mat = arch.getBitMatrix();
        try {
            this.orbitsUsed = new HashSet<>();

            for (int i = 0; i < getParams().getNumOrbits(); i++) {
                int ninstrs = m.sumRowBool(mat, i);
                if (ninstrs > 0) {
                    String orbitName = getParams().getOrbitList()[i];

                    Orbit orb = new Orbit(orbitName, 1, arch.getNumSatellites());
                    this.orbitsUsed.add(orb);

                    String payload = "";
                    String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";
                    for (int j = 0; j < getParams().getNumInstr(); j++) {
                        if (mat[i][j]) {
                            payload += " " + getParams().getInstrumentList()[j];
                        }
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
        }
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }
}
