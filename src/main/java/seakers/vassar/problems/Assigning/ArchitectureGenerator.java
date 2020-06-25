package seakers.vassar.problems.Assigning;

import seakers.vassar.architecture.AbstractArchitecture;
import seakers.vassar.architecture.AbstractArchitectureGenerator;
import seakers.vassar.BaseParams;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

public class ArchitectureGenerator extends AbstractArchitectureGenerator {

    protected AssigningParams params;
    protected Random rnd;

    public ArchitectureGenerator(AssigningParams params) {
        this.params = params;
        this.rnd = new Random();
    }

    public ArchitectureGenerator getNewInstance(BaseParams params){
        return new ArchitectureGenerator((AssigningParams) params);
    }

    @Override
    protected ArrayList<AbstractArchitecture> getManualArchitectures() {
        ArrayList<AbstractArchitecture> man_archs = new ArrayList<>();
        man_archs.add(new Architecture("000000000000000000000000000000000000000000000000000000000000",1, params));
        //N = 1 in random orbit (12)
        for (int i = 0; i < params.getNumInstr(); i++) {
            StringBuilder str = new StringBuilder("000000000000000000000000000000000000000000000000000000000000");
            int orb = rnd.nextInt(params.getNumOrbits());
            str.setCharAt(params.getNumInstr()*orb + i, '1');
            man_archs.add(new Architecture(str.toString(),1,params));
        }
        //N = 2 in random orbit (66)
        for (int i = 0; i < params.getNumInstr() - 1; i++) {
            for (int j = i+1; j< params.getNumInstr(); j++) {
                StringBuilder str = new StringBuilder("000000000000000000000000000000000000000000000000000000000000");
                int orb = rnd.nextInt(params.getNumOrbits());
                str.setCharAt(params.getNumInstr()*orb + i, '1');
                str.setCharAt(params.getNumInstr()*orb + j, '1');
                man_archs.add(new Architecture(str.toString(),1,params));
            }
        }

        //One copy of each instrument in the same orbit
        man_archs.add(new Architecture("000000000000111111111111000000000000000000000000000000000000",1,params));

        //Two copies of each instrument in the same orbits
        man_archs.add(new Architecture("111111111111111111111111000000000000000000000000000000000000",1,params));

        //Reference rbsa.eoss.architecture #1
        HashMap<String,String[]> map = new HashMap<>();
        String[] payl_polar = {""};map.put("LEO-600-polar-NA",payl_polar);
        String[] payl_AM = {"HYSP_TIR"};map.put("SSO-600-SSO-AM",payl_AM);
        String[] payl_600DD = {""};map.put("SSO-600-SSO-DD",payl_600DD);
        String[] payl_PM = {"GACM_VIS","GACM_SWIR"};map.put("SSO-800-SSO-PM",payl_PM);
        String[] payl_800DD = {""};map.put("SSO-800-SSO-DD",payl_800DD);
        man_archs.add(new Architecture(map, 1,params));

        //Reference rbsa.eoss.architecture #2
        HashMap<String,String[]> map2 = new HashMap<>();
        String[] payl2_polar = {""};map2.put("LEO-600-polar-NA",payl2_polar);
        String[] payl2_AM = {"HYSP_TIR"};map2.put("SSO-600-SSO-AM",payl2_AM);
        String[] payl2_600DD = {""};map2.put("SSO-600-SSO-DD",payl2_600DD);
        String[] payl2_PM = {"GACM_VIS","GACM_SWIR","POSTEPS_IRS"};map2.put("SSO-800-SSO-PM",payl2_PM);
        String[] payl2_800DD = {"DESD_SAR"};map2.put("SSO-800-SSO-DD",payl2_800DD);
        man_archs.add(new Architecture(map2, 1,params));

        //Reference rbsa.eoss.architecture #3
        HashMap<String,String[]> map3 = new HashMap<>();
        String[] payl3_polar = {"CLAR_ERB"};map3.put("LEO-600-polar-NA",payl3_polar);
        String[] payl3_AM = {"HYSP_TIR","POSTEPS_IRS"};map3.put("SSO-600-SSO-AM",payl3_AM);
        String[] payl3_600DD = {""};map3.put("SSO-600-SSO-DD",payl3_600DD);
        String[] payl3_PM = {"GACM_VIS","GACM_SWIR","POSTEPS_IRS"};map3.put("SSO-800-SSO-PM",payl3_PM);
        String[] payl3_800DD = {"DESD_SAR"};map3.put("SSO-800-SSO-DD",payl3_800DD);
        man_archs.add(new Architecture(map3, 1,params));

        //Reference rbsa.eoss.architecture #4
        HashMap<String,String[]> map4 = new HashMap<>();
        String[] payl4_polar = {"CLAR_ERB","CNES_KaRIN"};map4.put("LEO-600-polar-NA",payl4_polar);
        String[] payl4_AM = {"HYSP_TIR","POSTEPS_IRS"};map4.put("SSO-600-SSO-AM",payl4_AM);
        String[] payl4_600DD = {"DESD_LID"};map4.put("SSO-600-SSO-DD",payl4_600DD);
        String[] payl4_PM = {"GACM_VIS","GACM_SWIR","POSTEPS_IRS"};map4.put("SSO-800-SSO-PM",payl4_PM);
        String[] payl4_800DD = {"DESD_SAR"};map4.put("SSO-800-SSO-DD",payl4_800DD);
        man_archs.add(new Architecture(map4, 1,params));

        //Reference rbsa.eoss.architecture #5
        HashMap<String,String[]> map5 = new HashMap<>();
        String[] payl5_polar = {"CLAR_ERB","CNES_KaRIN","ACE_POL","ACE_ORCA"};map5.put("LEO-600-polar-NA",payl5_polar);
        String[] payl5_AM = {"HYSP_TIR","POSTEPS_IRS","ACE_LID"};map5.put("SSO-600-SSO-AM",payl5_AM);
        String[] payl5_600DD = {"DESD_LID"};map5.put("SSO-600-SSO-DD",payl5_600DD);
        String[] payl5_PM = {"GACM_VIS","GACM_SWIR","POSTEPS_IRS"};map5.put("SSO-800-SSO-PM",payl5_PM);
        String[] payl5_800DD = {"DESD_SAR"};map5.put("SSO-800-SSO-DD",payl5_800DD);
        man_archs.add(new Architecture(map5, 1,params));
        return man_archs;
    }

    @Override
    public ArrayList<AbstractArchitecture> generateRandomPopulation(int numArchs) {
        ArrayList<AbstractArchitecture> popu = new ArrayList<>(numArchs);
        try {
            for (int i = 0; i < numArchs; i++) {
                boolean[][] x = new boolean[params.getNumOrbits()][params.getNumInstr()];
                for (int j = 0; j < params.getNumOrbits(); j++) {
                    for(int k = 0; k < params.getNumInstr(); k++){
                        x[j][k] = rnd.nextBoolean();
                    }
                }
                AbstractArchitecture arch = new Architecture(x, params.getNumSatellites()[rnd.nextInt(params.getNumSatellites().length)], params);
                popu.add(arch);
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return popu;
    }

    @Override
    public ArrayList<AbstractArchitecture> generateBiasedRandomPopulation(int numArchs, double bias) {
        int genomeLength = params.getNumInstr() * params.getNumOrbits();
        ArrayList<AbstractArchitecture> popu = new ArrayList<>(numArchs);
        for (int i = 0; i < numArchs; i++) {
            boolean[][] x = new boolean[params.getNumOrbits()][params.getNumInstr()];
            for (int j = 0; j < params.getNumOrbits(); j++) {
                for(int k = 0; k < params.getNumInstr(); k++){
                    x[j][k] = rnd.nextDouble() < bias;
                }
            }
            AbstractArchitecture arch = new Architecture(x, params.getNumSatellites()[rnd.nextInt(params.getNumSatellites().length)], params);
            popu.add(arch);
        }
        return popu;
    }

    public AbstractArchitecture getMaxArch() { // SMAP 2 SSO orbits, 2 sats per orbit
        Architecture arch = new Architecture("111111111111111111111111000000000000000000000000000000000000",1,params);
        return arch; //{"SMAP_RAD","SMAP_MWR","CMIS","VIIRS","BIOMASS"};{"600polar","600AM","600DD","800AM","800PM"};
    }

    public AbstractArchitecture getMinArch() {
        boolean[][] mat = new boolean[params.getNumOrbits()][params.getNumInstr()];
        for (int i = 0; i < params.getNumOrbits(); i++) {
            for (int j = 0; j < params.getNumInstr(); j++) {
                mat[i][j] = false;
            }
        }
        return new Architecture(mat, 1,params);
    }
}
