package rbsa.eoss;

/**
 *
 * @author Marc
 */

import rbsa.eoss.local.Params;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Stack;

public class ResultCollection implements java.io.Serializable {
    private String stamp;
    private String filePath;
    private String name;
    private Stack<Result> results;
    private HashMap<String,String> conf;
    private ArrayList<Result> front;

    public ResultCollection(Stack<Result> results) {
        Params params = Params.getInstance();
        SimpleDateFormat dateFormat = new SimpleDateFormat( "yyyy-MM-dd_HH-mm-ss" );
        stamp = dateFormat.format( new Date() );
        name = params.getName();
        conf = new HashMap<>();
        conf.put("Requirements", params.requirementSatisfactionXls);
        conf.put("Capabilities", params.capabilityRulesXls);
        
        filePath = params.pathSaveResults + "/" + stamp + "_" + name + ".rs";
        filePath = filePath.replaceAll("\\\\", "\\\\\\\\");
        this.results = results;
        front = computeParetoFront(results);
    }

    private ArrayList<Result> computeParetoFront(Stack<Result> stack) {
        ArrayList<Result> thefront = new ArrayList<>();
        for (int i = 0;i<stack.size();i++) {
            Result r1 = stack.get(i);
            boolean dominated = false;
            for (int j = 0;j<stack.size();j++) {
                if(r1.dominates(stack.get(j))==-1) {
                    dominated = true;
                    break;//dominated
                }
            }
            if(!dominated) {
                thefront.add(r1);
            }
        }
        return thefront;
    }

    public String getStamp() {
        return stamp;
    }

    public String getFilePath() {
        return filePath;
    }

    public String getName() {
        return name;
    }

    public void setName(String inputFile) {
        this.name = inputFile;
    }

    public Stack<Result> getResults() {
        return results;
    }

    public ArrayList<Architecture> getPopulation() {
        ArrayList<Architecture> pop = new ArrayList<>();
        for (Result res: front)
            pop.add(res.getArch());
        return pop;
    }

    public ArrayList<Result> getFront() {
        return front;
    }
}

