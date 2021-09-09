package seakers.vassarheur.problems.Assigning;

import jess.*;
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

    public ArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type) {
        super(resourcePool, arch, type, 0.5, 3000.0, 0.4);
    }

    public ArchitectureEvaluator(ResourcePool resourcePool, AbstractArchitecture arch, String type, double dcThreshold, double massThreshold, double packingEffThreshold) {
        super(resourcePool, arch, type, dcThreshold, massThreshold, packingEffThreshold);
    }

    public ArchitectureEvaluator getNewInstance(){
        return new ArchitectureEvaluator(super.resourcePool, super.arch, super.type, super.dcThreshold, super.massThreshold, super.packingEffThreshold);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type){
        return new ArchitectureEvaluator(resourcePool, arch, type, 0.5, 3000.0, 0.4);
    }

    public ArchitectureEvaluator getNewInstance(ResourcePool resourcePool, AbstractArchitecture arch, String type, double dcThreshold, double massThreshold, double packingEffThreshold){
        return new ArchitectureEvaluator(resourcePool, arch, type, dcThreshold, massThreshold, packingEffThreshold);
    }

    protected void assertMissions(BaseParams params, Rete r, AbstractArchitecture inputArch, MatlabFunctions m) {

        Architecture arch = (Architecture) inputArch;

        boolean[][] mat = arch.getBitMatrix();
        try {
            this.orbitsUsed = new HashSet<>();

            for (int i = 0; i < params.getNumOrbits(); i++) {
                int ninstrs = m.sumRowBool(mat, i);
                if (ninstrs > 0) {
                    String orbitName = params.getOrbitList()[i];

                    Orbit orb = new Orbit(orbitName, 1, arch.getNumSatellites());
                    this.orbitsUsed.add(orb);

                    String payload = "";
                    String call = "(assert (MANIFEST::Satellite (Name " + orbitName + ") ";
                    for (int j = 0; j < params.getNumInstr(); j++) {
                        if (mat[i][j]) {
                            payload += " " + params.getInstrumentList()[j];
                        }
                    }
                    call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                            + " (id sat" + i + ")"
                            + " (factHistory F" + params.nof + ")))";
                    params.nof++;

                    call += "(assert (SYNERGIES::cross-registered-instruments " +
                            " (instruments " + payload +
                            ") (degree-of-cross-registration spacecraft) " +
                            " (platform " + orbitName +  ") "
                            + "(factHistory F" + params.nof + ")))";
                    params.nof++;
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
