package rbsa.eoss.local.test;

import org.moeaframework.algorithm.EpsilonMOEA;
import org.moeaframework.core.*;
import org.moeaframework.core.comparator.ChainedComparator;
import org.moeaframework.core.comparator.ParetoObjectiveComparator;
import org.moeaframework.core.operator.*;
import org.moeaframework.core.operator.binary.BitFlip;
import org.moeaframework.util.TypedProperties;
import rbsa.eoss.evaluation.AbstractArchitectureEvaluator;
import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
import rbsa.eoss.local.test.search.InstrumentedSearch;
import rbsa.eoss.local.test.search.problems.Assigning.AssigningProblem;
import rbsa.eoss.problems.Assigning.ClimateCentricParams;
import seak.architecture.operators.IntegerUM;

import java.io.File;
import java.util.concurrent.*;

public class RunGA {
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        System.out.println("Starting GA for binary input data");

        ExecutorService pool = Executors.newFixedThreadPool(1);
        CompletionService<Algorithm> ecs = new ExecutorCompletionService<>(pool);

        //parameters and operators for seak.vassar_server.search
        TypedProperties properties = new TypedProperties();
        //seak.vassar_server.search paramaters set here
        int popSize = 200;
        int maxEvals = 3000;
        properties.setInt("maxEvaluations", maxEvals);
        properties.setInt("populationSize", popSize);
        double crossoverProbability = 1.0;
        properties.setDouble("crossoverProbability", crossoverProbability);
        double mutationProbability = 1. / 60.;
        properties.setDouble("mutationProbability", mutationProbability);
        Variation singlecross;
        Variation bitFlip;
        Variation intergerMutation;
        Initialization initialization;

        //setup for epsilon MOEA
        double[] epsilonDouble = new double[]{0.001, 1};

        //setup for saving results
        properties.setBoolean("saveQuality", true);
        properties.setBoolean("saveCredits", true);
        properties.setBoolean("saveSelection", true);

        //initialize problem
        String path = "./" + File.separator + "problems" + File.separator + "ClimateCentric";
        ClimateCentricParams params = new ClimateCentricParams(path, "FUZZY-ATTRIBUTES",
                    "test", "normal", "search_heuristic_rules_smap_127");
        AbstractArchitectureEvaluator evaluator = new rbsa.eoss.problems.Assigning.ArchitectureEvaluator(params);
        ArchitectureEvaluationManager AEM = new ArchitectureEvaluationManager(params, evaluator);
        AEM.init(1);

        Problem assignmentProblem = new AssigningProblem(new int[]{1}, "ClimateCentric", AEM, params);

        initialization = new RandomInitialization(assignmentProblem, popSize);

        //initialize population structure for algorithm
        Population population = new Population();
        EpsilonBoxDominanceArchive archive = new EpsilonBoxDominanceArchive(epsilonDouble);
        ChainedComparator comp = new ChainedComparator(new ParetoObjectiveComparator());
        TournamentSelection selection = new TournamentSelection(2, comp);

        singlecross = new OnePointCrossover(crossoverProbability);
        bitFlip = new BitFlip(mutationProbability);
        intergerMutation = new IntegerUM(mutationProbability);
        CompoundVariation var = new CompoundVariation(singlecross, bitFlip, intergerMutation);


        Algorithm eMOEA = new EpsilonMOEA(assignmentProblem, population, archive, selection, var, initialization);
        ecs.submit(new InstrumentedSearch(eMOEA, properties, path + File.separator + "result", "emoea"));


        try {
            Algorithm alg = ecs.take().get();
        } catch (InterruptedException | ExecutionException ex) {
            ex.printStackTrace();
        }

        pool.shutdown();
        System.out.println("DONE");
    }
}
