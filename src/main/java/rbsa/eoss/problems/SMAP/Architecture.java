package rbsa.eoss.problems.SMAP;

import rbsa.eoss.architecture.AbstractArchitecture;

import java.util.*;

public class Architecture extends AbstractArchitecture{

    private Params params;
    private boolean[][] bitMatrix;
    private int numSatellites;

    public Architecture(String bitString, int numSatellites, Params params) {
        super();
        this.params = params;
        this.bitMatrix = booleanString2Matrix(bitString);
        this.numSatellites = numSatellites;
    }

    public Architecture(boolean[][] bitMatrix, int numSatellites, Params params) {
        super();
        this.params = params;
        this.bitMatrix = bitMatrix;
        this.numSatellites = numSatellites;
    }

    public Architecture(HashMap<String, String[]> mapping, int numSatellites, Params params) {
        super();
        this.params = params;
        bitMatrix = new boolean[params.getNumOrbits()][params.getNumInstr()];
        for (int o = 0; o < params.getNumOrbits(); o++) {
            for(int i = 0; i < params.getNumInstr(); i++) {
                bitMatrix[o][i] = false;
            }
        }

        for (int o = 0; o < params.getNumOrbits(); o++) {
            String orb = params.getOrbitList()[o];
            String[] payl = mapping.get(orb);
            if (payl == null)
                continue;
            ArrayList<String> thepayl = new ArrayList<>(Arrays.asList(payl));
            for(int i = 0; i < params.getNumInstr(); i++) {
                String instr = params.getInstrumentList()[i];
                if(thepayl.contains(instr))
                    bitMatrix[o][i] = true;
            }
        }
        this.numSatellites = numSatellites;
    }

    @Override
    public boolean isFeasibleAssignment() {
        return (sumAllInstruments(bitMatrix) <= params.MAX_TOTAL_INSTR);
    }

    public int getNumSatellites() {
        return numSatellites;
    }

    public boolean[][] getBitMatrix(){
        return this.bitMatrix;
    }

    // Utils
    private boolean[][] booleanString2Matrix(String bitString) {
        boolean[][] mat = new boolean[params.getNumOrbits()][params.getNumInstr()];
        for (int i = 0; i < params.getNumOrbits(); i++) {
            for (int j = 0; j < params.getNumInstr(); j++) {
                String b = bitString.substring(params.getNumInstr() *i + j,params.getNumInstr()*i + j + 1);
                if (b.equalsIgnoreCase("1")) {
                    mat[i][j] = true;
                }
                else if (b.equalsIgnoreCase("0")) {
                    mat[i][j] = false;
                }
                else {
                    System.out.println("Architecture: booleanString2Matrix string b is nor equal to 1 or 0!");
                }
            }
        }
        return mat;
    }

    private int sumAllInstruments(boolean[][] mat) {
        int x = 0;
        for (boolean[] row: mat) {
            for (boolean val: row) {
                if (val) {
                    x += 1;
                }
            }
        }
        return x;
    }
}
