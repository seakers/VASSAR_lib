package seakers.vassar.problems.Assigning;

import jess.*;
import seakers.vassar.DebugWriter;
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

        boolean[][] mat = arch.getBitMatrix();
        try {
            ArrayList<String> lines = new ArrayList<>();
            this.orbitsUsed = new HashSet<>();

            for (int i = 0; i < params.getNumOrbits(); i++) {
                int ninstrs = m.sumRowBool(mat, i);
                if (ninstrs > 0) {
                    String orbitName = params.getOrbitList()[i];

                    Orbit orb = new Orbit(orbitName, 1, arch.getNumSatellites());
                    this.orbitsUsed.add(orb);

                    String payload = "";
                    String call = "(assert (MANIFEST::Mission (Name " + orbitName + ") ";
                    for (int j = 0; j < params.getNumInstr(); j++) {
                        if (mat[i][j]) {
                            payload += " " + params.getInstrumentList()[j];
                        }
                    }
                    if(payload.contains("SMAP_RAD") || payload.contains("SMAP_MWR")){
                        payload += " SMAP_ANT";
                    }
                    call += "(instruments " + payload + ") (lifetime 5) (launch-date 2015) (select-orbit no) " + orb.toJessSlots() + ""
                            + "(factHistory F" + params.nof + ")))";
                    params.nof++;

                    call += "(assert (SYNERGIES::cross-registered-instruments " +
                            " (instruments " + payload +
                            ") (degree-of-cross-registration spacecraft) " +
                            " (platform " + orbitName +  " )"
                            + "(factHistory F" + params.nof + ")))";
                    lines.add(call);
                    params.nof++;
                    r.eval(call);
//                    System.out.println("--> MISSION " + orb.toString() + ": " + payload);
                }
            }
            DebugWriter.writeDebug(lines, "design.txt");
        }
        catch (Exception e) {
            System.out.println("" + e.getClass() + " " + e.getMessage());
            e.printStackTrace();
        }
    }
}
