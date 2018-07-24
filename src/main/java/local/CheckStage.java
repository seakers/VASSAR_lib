package rbsa.eoss.local;

import rbsa.eoss.Architecture;
import rbsa.eoss.ArchitectureEvaluator;
import rbsa.eoss.Result;
import rbsa.eoss.ResultCollection;

import java.io.*;

public class CheckStage {
    public static void main(String[] args) {

        String csvFile = "./results/stage2.csv";
        BufferedReader br = null;
        String line = "";
        String cvsSplitBy = ",";

        Params.initInstance(".", "FUZZY-ATTRIBUTES", "test","normal","search_heuristic_rules_smap_127");
        ArchitectureEvaluator AE = ArchitectureEvaluator.getInstance();
        AE.init(1);

        try {

            br = new BufferedReader(new FileReader(csvFile));
            while ((line = br.readLine()) != null) {
                // use comma as separator
                String[] arch = line.split(cvsSplitBy);
                Architecture architecture = new Architecture(arch[0].substring(1, 61), 1);
                Result res = AE.evaluateArchitecture(architecture, "Slow");
                System.out.println("next");
                System.out.println(Double.toString(res.getScience()).equals(arch[1]));
                System.out.println(Double.toString(res.getCost()).equals(arch[2]));
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (br != null) {
                try {
                    br.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        AE.clear();
    }
}
