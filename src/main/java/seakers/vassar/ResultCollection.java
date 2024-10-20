package seakers.vassar;

/**
 *
 * @author Marc
 */

import seakers.vassar.architecture.AbstractArchitecture;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Stack;

public class ResultCollection implements Serializable {
    private static final long serialVersionUID = 1L;

    private String stamp;
    private String filePath;
    private String name;
    private Stack<Result> results;
    private HashMap<String,String> conf;
    private ArrayList<Result> front;

    public ResultCollection(BaseParams params, Stack<Result> results) {
        SimpleDateFormat dateFormat = new SimpleDateFormat( "yyyy-MM-dd_HH-mm-ss" );
        stamp = dateFormat.format( new Date() );
        name = params.getName();
        conf = new HashMap<>();
        conf.put("Requirements", params.requirementSatisfactionXls);
        conf.put("Capabilities", params.capabilityRulesXls);
        
        filePath = params.pathSaveResults + "/" + stamp + "_" + name + ".rs";
        filePath = filePath.replaceAll("\\\\", "\\\\\\\\");
        this.results = results;
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

    public ArrayList<AbstractArchitecture> getPopulation() {
        ArrayList<AbstractArchitecture> pop = new ArrayList<>();
        for (Result res: front)
            pop.add(res.getArch());
        return pop;
    }

    public ArrayList<Result> getFront() {
        return front;
    }
}

