import org.moeaframework.Executor;
import org.moeaframework.algorithm.NSGAII;
import org.moeaframework.core.*;
import org.moeaframework.core.comparator.ChainedComparator;
import org.moeaframework.core.comparator.CrowdingComparator;
import org.moeaframework.core.comparator.ParetoDominanceComparator;
import org.moeaframework.core.operator.GAVariation;
import org.moeaframework.core.operator.real.PM;
import org.moeaframework.core.operator.real.SBX;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.core.operator.InjectedInitialization;
import org.moeaframework.core.operator.TournamentSelection;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.MOEAFixedInsAltProgressListener;
import seakers.vassar.moea.RadarFixedInsAltProblem;

import java.io.File;
import java.util.Properties;

public class DSHIELD_RadarFixedInsAlt_MOEA {
    public static void main(String[] args){
        try{
            OrekitConfig.init(4);
            Properties properties = new Properties();
            properties.setProperty("populationSize","48");
            properties.setProperty("maxEvaluations","10000");
//            Instrumenter instrumenter = new Instrumenter()
//                    .withProblem("NSGA-II")
//                    .withFrequency(48)
//                    .attachElapsedTimeCollector()
//                    .attachHypervolumeCollector();
            RadarFixedInsAltProblem rfiap = new RadarFixedInsAltProblem();
            InjectedInitialization initialization = new InjectedInitialization(
                    rfiap,
                    100);

            TournamentSelection selection = new TournamentSelection(2,
                    new ChainedComparator(
                            new ParetoDominanceComparator(),
                            new CrowdingComparator()));

            Variation variation = new GAVariation(
                    new SBX(1.0, 25.0),
                    new PM(1.0 / rfiap.getNumberOfVariables(), 30.0));

            Algorithm algorithm = new NSGAII(
                    rfiap,
                    new NondominatedSortingPopulation(),
                    null, // no archive
                    selection,
                    variation,
                    initialization);
            MOEAFixedInsAltProgressListener progressListener = new MOEAFixedInsAltProgressListener();
            NondominatedPopulation result = new Executor().withProblemClass(RadarFixedInsAltProblem.class).withAlgorithm(algorithm.).withProperties(properties).distributeOn(4).withProgressListener(progressListener).run();
//            Accumulator accumulator = instrumenter.getLastAccumulator();
//
//            for (int i=0; i<accumulator.size("NFE"); i++) {
//                System.out.println(accumulator.get("NFE", i) + "\t" +
//                        accumulator.get("Elapsed Time", i) + "\t" +
//                        accumulator.get("Hypervolume", i));
//            }
            //NondominatedPopulation result = new Executor().withProblemClass(HeteroArchProblem.class).withAlgorithm("NSGA-II").withMaxEvaluations(1).distributeOnAllCores().run();
            int count = 1;
            for (Solution sol : result) {
                System.out.println("Variables for solution " + count + ":");
                System.out.println("Number of radar satellites per plane: " + EncodingUtils.getInt(sol.getVariable(0)));
                System.out.println("Number of radar satellite planes: " + EncodingUtils.getInt(sol.getVariable(1)));
                System.out.println("Inclination of radar satellites: " + sol.getVariable(2));
                count++;
            }
            PopulationIO.writeObjectives(new File("./src/test/output/radar_fixedinsalt/objectives.txt"), result);
            OrekitConfig.end();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }
}
