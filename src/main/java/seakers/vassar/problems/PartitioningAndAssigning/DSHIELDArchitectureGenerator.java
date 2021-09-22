package seakers.vassar.problems.PartitioningAndAssigning;

import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.problems.Assigning.Architecture;
import seakers.vassar.problems.Assigning.ArchitectureGenerator;
import seakers.vassar.problems.Assigning.AssigningParams;

import java.util.ArrayList;

public class DSHIELDArchitectureGenerator extends ArchitectureGenerator {
    public DSHIELDArchitectureGenerator(AssigningParams params) {
        super(params);
    }

    public ArrayList<AbstractArchitecture> generateArchitecture() {
        ArrayList<AbstractArchitecture> popu = new ArrayList<>(1);
        try {
            boolean[][] x = new boolean[params.getNumOrbits()][params.getNumInstr()];
            for (int j = 0; j < params.getNumOrbits(); j++) {
                for(int k = 0; k < params.getNumInstr(); k++){
                    x[j][k] = true;
                }
            }
            AbstractArchitecture arch = new Architecture(x, params.getNumSatellites()[rnd.nextInt(params.getNumSatellites().length)], params);
            popu.add(arch);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return popu;
    }
}
