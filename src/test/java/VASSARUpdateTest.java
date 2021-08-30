import org.moeaframework.core.*;
import org.moeaframework.util.TypedProperties;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.Result;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.problems.Evaluating.Architecture;
import seakers.vassar.problems.Evaluating.ArchitectureEvaluator;
import seakers.vassar.problems.Evaluating.CommonParams;
import seakers.vassar.spacecraft.SpacecraftDescription;

import java.util.ArrayList;
import java.util.concurrent.*;

public class VASSARUpdateTest {
    private static String resourcesPath = "../VASSAR_resources";
    private CommonParams params;
    private ArrayList<SpacecraftDescription> designs;

    public static void main(String[] args){
        System.out.println("Evaluating architecture");

        String path = "../VASSAR_resources";
        String[] orbitList = {"SSO-680-SSO-DD"};
        String orbit = "SSO-680-SSO-DD";
        String[] instrumentList = {"SMAP_MWR","SMAP_RAD"};

        CommonParams params = new CommonParams(orbitList,"Designer", path, "CRISP-ATTRIBUTES", "test", "normal");
        params.setInstrumentList(instrumentList);
        ArchitectureEvaluator evaluator = new ArchitectureEvaluator();
        ArchitectureEvaluationManager evaluationManager = new ArchitectureEvaluationManager(params, evaluator);
        evaluationManager.init(1);
        OrekitConfig.init(1, params.orekitResourcesPath);
        Architecture arch = new Architecture(instrumentList,orbit);

        Result result = evaluationManager.evaluateArchitectureSync(arch, "Slow");

        evaluationManager.clear();
        System.out.println("Architecture evaluation DONE");
        System.out.println("science: " + result.getScience() + ", cost:" + result.getCost());

        OrekitConfig.end();

        System.out.println("DONE");
    }
}
