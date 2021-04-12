package seakers.vassar.utils;

import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDArchitectureEvaluator;
import seakers.vassar.evaluation.DSHIELDArchitectureSizer;
import seakers.vassar.problems.Assigning.Architecture;
import seakers.vassar.problems.Assigning.AssigningParams;
import seakers.vassar.problems.Assigning.DSHIELDParams;
import seakers.vassar.spacecraft.SpacecraftDescription;

import java.util.ArrayList;
import java.util.HashMap;

public class VassarPy {
    String[][] payloads;
    String[] orbits;
    AssigningParams params;
    Architecture arch;
    String resourcesPath;
    String[][] factList;

    public VassarPy(String problemName, String[][] payloads, String[] orbits, String resourcesPath, String[][] factList){
        this.payloads = payloads;
        this.orbits = orbits;
        this.params = new DSHIELDParams(orbits, problemName, resourcesPath, "CRISP-ATTRIBUTES","test", "normal");
        this.arch = new Architecture( mapPayloads(payloads, orbits), 1, params);
        this.resourcesPath = resourcesPath;
        this.factList = factList;

    }

    public VassarPy(String problemName, String[][] payloads, String[] orbits, String resourcesPath){
        this.payloads = payloads;
        this.orbits = orbits;
        this.params = new DSHIELDParams(orbits, problemName, resourcesPath, "CRISP-ATTRIBUTES","test", "normal");
        this.arch = new Architecture( mapPayloads(payloads, orbits), 1, params);
        this.resourcesPath = resourcesPath;
        this.factList = null;
    }

    private HashMap<String, String[]> mapPayloads(String[][] payloads, String[] orbits){
        HashMap<String,String[]> map = new HashMap<>();

        for(int i = 0; i < orbits.length; i++){
            map.put(orbits[i], payloads[i]);
        }

        return map;
    }

    public ArrayList<SpacecraftDescription> archDesign(){
        DSHIELDArchitectureSizer evaluator = new DSHIELDArchitectureSizer(this.factList);
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);

        Result result = evaluationManager.evaluateArchitectureSync(arch, "Slow");

        evaluationManager.clear();
        System.out.println("Architecture design DONE");
        System.out.println("cost: "+result.getCost());

        return result.getDesigns();
    }

    public Result archEval(){
        DSHIELDArchitectureEvaluator evaluator = new DSHIELDArchitectureEvaluator(this.factList);
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);

        Result result = evaluationManager.evaluateArchitectureSync(arch, "Slow");

        evaluationManager.clear();
        System.out.println("Architecture evaluation DONE");
        System.out.println("science: " + result.getScience() + ", cost:" + result.getCost());

        return result;
    }

}
