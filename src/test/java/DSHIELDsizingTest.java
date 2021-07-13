import org.moeaframework.algorithm.EpsilonMOEA;
import org.moeaframework.core.*;
import org.moeaframework.core.comparator.ChainedComparator;
import org.moeaframework.core.comparator.ParetoObjectiveComparator;
import org.moeaframework.core.operator.CompoundVariation;
import org.moeaframework.core.operator.OnePointCrossover;
import org.moeaframework.core.operator.RandomInitialization;
import org.moeaframework.core.operator.TournamentSelection;
import org.moeaframework.core.operator.binary.BitFlip;
import org.moeaframework.util.TypedProperties;
import seakers.architecture.operators.IntegerUM;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.evaluation.ArchitectureEvaluationManager;
import seakers.vassar.evaluation.DSHIELDArchitectureEvaluator;
import seakers.vassar.problems.Assigning.DSHIELDParams;
import seakers.vassar.search.TimedSearch;
import seakers.vassar.search.problems.Assigning.AssigningProblem;
import seakers.vassar.spacecraft.SpacecraftDescription;

import java.util.ArrayList;
import java.util.concurrent.*;

public class DSHIELDsizingTest {
    private static String resourcesPath = "D:/Documents/VASSAR/VASSAR_resources";
    private DSHIELDParams params;
    private ArrayList<SpacecraftDescription> designs;

    public static void main(String[] args){
        System.out.println("Starting GA for binary input data");

        int numRuns = 1;
        int numCpus = 1;
        int startOn = 0;

        ExecutorService pool = Executors.newFixedThreadPool(numCpus);
        CompletionService<Algorithm> ecs = new ExecutorCompletionService<>(pool);

        //parameters and operators for seakers.vassar_server.search
        TypedProperties properties = new TypedProperties();
        //seakers.vassar_server.search paramaters set here
        int popSize = 500;
        int maxEvals = 10000;
        properties.setInt("maxEvaluations", maxEvals);
        properties.setInt("populationSize", popSize);
        double crossoverProbability = 1.0;
        properties.setDouble("crossoverProbability", crossoverProbability);
        double mutationProbability = 1. / 60.;
        properties.setDouble("mutationProbability", mutationProbability);
        Variation singlecross;
        Variation bitFlip;
        Variation integerMutation;
        Initialization initialization;

        //setup for epsilon MOEA
        double[] epsilonDouble = new double[]{0.001, 1};

        //setup for saving results
        properties.setBoolean("saveQuality", true);
        properties.setBoolean("saveCredits", true);
        properties.setBoolean("saveSelection", true);

        //initialize problem
        String path = "D:/Documents/VASSAR/VASSAR_resources";
        String[] numPlanes = new String[]{ "2","3","4" };
        String[] numSatsPerPlane = new String[]{"1","2"};
        String[] orbitAltitudes = new String[]{"350","500","600"};
        ArrayList<String> orbits = new ArrayList<String>();
        for (int i = 0; i < numPlanes.length; i++) {
            for (int j = 0; j < numSatsPerPlane.length; j++) {
                for (int k = 0; k < orbitAltitudes.length; k++) {
                    orbits.add("SSO-"+orbitAltitudes[k]+"-SSO-DD/"+numPlanes[i]+"-"+numSatsPerPlane[j]+"-1");
                }
            }
        }
        System.out.println(orbits.toString());
        String[] orbitList = new String[orbits.size()];
        orbits.toArray(orbitList);
        DSHIELDParams params = new DSHIELDParams(orbitList, "DSHIELD", path, "CRISP-ATTRIBUTES","test", "normal");
        DSHIELDArchitectureEvaluator evaluator = new DSHIELDArchitectureEvaluator();
        ArchitectureEvaluationManager AEM = new ArchitectureEvaluationManager(params, evaluator);
        AEM.init(numCpus);
        OrekitConfig.init(numCpus, params.orekitResourcesPath);

        for (int i = 0; i < numRuns; ++i) {

            Problem assignmentProblem = new AssigningProblem(new int[]{1}, "DSHIELD", AEM, params);

            initialization = new RandomInitialization(assignmentProblem, popSize);

            //initialize population structure for algorithm
            Population population = new Population();
            EpsilonBoxDominanceArchive archive = new EpsilonBoxDominanceArchive(epsilonDouble);
            ChainedComparator comp = new ChainedComparator(new ParetoObjectiveComparator());
            TournamentSelection selection = new TournamentSelection(2, comp);

            singlecross = new OnePointCrossover(crossoverProbability);
            bitFlip = new BitFlip(mutationProbability);
            integerMutation = new IntegerUM(mutationProbability);
            CompoundVariation var = new CompoundVariation(singlecross, bitFlip, integerMutation);

            Algorithm eMOEA = new EpsilonMOEA(assignmentProblem, population, archive, selection, var, initialization);
            ecs.submit(new TimedSearch(eMOEA, properties, params.pathSaveResults, "emoea_" + "ClimateCentric" + (i+startOn)));
        }

        for (int i = 0; i < numRuns; ++i) {
            try {
                Algorithm alg = ecs.take().get();
            } catch (InterruptedException | ExecutionException ex) {
                ex.printStackTrace();
            }
        }

        OrekitConfig.end();
        AEM.clear();
        pool.shutdown();

        System.out.println("DONE");
    }
}
