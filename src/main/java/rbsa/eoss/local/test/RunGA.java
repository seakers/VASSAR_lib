package rbsa.eoss.local.test;

import org.moeaframework.algorithm.EpsilonMOEA;
import org.moeaframework.core.*;
import org.moeaframework.core.comparator.ChainedComparator;
import org.moeaframework.core.comparator.ParetoObjectiveComparator;
import org.moeaframework.core.operator.*;
import org.moeaframework.core.operator.binary.BitFlip;
import org.moeaframework.core.variable.BinaryVariable;
import org.moeaframework.util.TypedProperties;
import rbsa.eoss.evaluation.AbstractArchitectureEvaluator;
import rbsa.eoss.evaluation.ArchitectureEvaluationManager;
import rbsa.eoss.local.test.search.TimedSearch;
import rbsa.eoss.local.test.search.problems.Assigning.AssigningArchitecture;
import rbsa.eoss.local.test.search.problems.Assigning.AssigningProblem;
import rbsa.eoss.problems.Assigning.ClimateCentricParams;
import seak.architecture.operators.IntegerUM;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class RunGA {
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        System.out.println("Starting GA for binary input data");

        ExecutorService pool = Executors.newFixedThreadPool(4);
        CompletionService<Algorithm> ecs = new ExecutorCompletionService<>(pool);

        //parameters and operators for seak.vassar_server.search
        TypedProperties properties = new TypedProperties();
        //seak.vassar_server.search paramaters set here
        int popSize = 200;
        int maxEvals = 10000;
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
        ClimateCentricParams params = new ClimateCentricParams(path, "CRISP-ATTRIBUTES",
                    "test", "normal", "search_heuristic_rules_smap_127");
        AbstractArchitectureEvaluator evaluator = new rbsa.eoss.problems.Assigning.ArchitectureEvaluator(params);
        ArchitectureEvaluationManager AEM = new ArchitectureEvaluationManager(params, evaluator);
        AEM.init(4);

        Problem assignmentProblem = new AssigningProblem(new int[]{1}, "ClimateCentric", AEM, params);

        // Create a solution for each input arch in the dataset
        String csvFile = params.pathSaveResults + "/start_climate.csv";
        String line = "";
        String cvsSplitBy = ",";

        List<Solution> initial = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(csvFile))) {
            boolean header = true;
            while ((line = br.readLine()) != null) {
                if (header) {
                    header = false;
                    continue;
                }
                // use comma as separator
                String[] csvArch = line.split(cvsSplitBy);
                AssigningArchitecture arch = new AssigningArchitecture(new int[]{1},
                        params.getNumInstr(), params.getNumOrbits(), 2);
                for (int j = 1; j < arch.getNumberOfVariables(); ++j) {
                    BinaryVariable var = new BinaryVariable(1);
                    var.set(0, csvArch[j-1].equals("1"));
                    arch.setVariable(j, var);
                }
                int numBits = params.getNumInstr()*params.getNumOrbits();
                arch.setObjective(0, -Double.valueOf(csvArch[numBits]));
                arch.setObjective(1, Double.valueOf(csvArch[numBits+1]));
                arch.setAlreadyEvaluated(true);
                initial.add(arch);
            }
        }
        catch (IOException e) {
            e.printStackTrace();
        }

        initialization = new InjectedInitialization(assignmentProblem, popSize, initial);

        //initialize population structure for algorithm
        Population population = new Population();
        EpsilonBoxDominanceArchive archive = new EpsilonBoxDominanceArchive(epsilonDouble);
        ChainedComparator comp = new ChainedComparator(new ParetoObjectiveComparator());
        TournamentSelection selection = new TournamentSelection(2, comp);

        singlecross = new OnePointCrossover(crossoverProbability);
        bitFlip = new BitFlip(mutationProbability);
        intergerMutation = new IntegerUM(mutationProbability);
        CompoundVariation var = new CompoundVariation(singlecross, bitFlip, intergerMutation);

        for (int i = 0; i < 30; ++i) {
            Algorithm eMOEA = new EpsilonMOEA(assignmentProblem, population, archive, selection, var, initialization);
            ecs.submit(new TimedSearch(eMOEA, properties, path + File.separator + "results", "emoea_climate" + i));
        }

        for (int i = 0; i < 30; ++i) {
            try {
                Algorithm alg = ecs.take().get();
            } catch (InterruptedException | ExecutionException ex) {
                ex.printStackTrace();
            }
        }

        pool.shutdown();
        AEM.clear();
        System.out.println("DONE");
    }
}
