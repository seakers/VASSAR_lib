package seakers.vassar;

import org.moeaframework.algorithm.EpsilonMOEA;
import org.moeaframework.core.*;
import org.moeaframework.core.comparator.ChainedComparator;
import org.moeaframework.core.comparator.CrowdingComparator;
import org.moeaframework.core.comparator.ParetoDominanceComparator;
import org.moeaframework.core.operator.GAVariation;
import org.moeaframework.core.operator.InjectedInitialization;
import org.moeaframework.core.operator.RandomInitialization;
import org.moeaframework.core.operator.TournamentSelection;
import org.moeaframework.core.operator.real.PM;
import org.moeaframework.core.operator.real.SBX;
import org.moeaframework.core.variable.EncodingUtils;
import org.moeaframework.util.distributed.DistributedProblem;
import seakers.orekit.util.OrekitConfig;
import seakers.vassar.moea.XGrantsProblem;

import java.io.*;
import java.util.ArrayList;
import java.util.concurrent.Executors;


public class XGrants_restart {
    public static void main(String[] args){
        try{
            OrekitConfig.init(8);
            XGrantsProblem problem = new XGrantsProblem();
            Problem distributedProblem = new DistributedProblem(problem, Executors.newFixedThreadPool(8));
            ArrayList<Solution> initPop = new ArrayList<>();
            File tmpDir = new File("current_population.txt");
            boolean exists = tmpDir.exists();
            Initialization initialization;
            if(exists) {
                try {
                    FileInputStream f = new FileInputStream("current_population.txt");
                    ObjectInputStream i = new ObjectInputStream(f);
                    try {
                        while (true) {
                            Solution sol = (Solution) i.readObject();
                            initPop.add(sol);
                        }
                    } catch (Exception e) {
                        System.out.println(e);
                    }
                    i.close();
                    f.close();
                } catch (FileNotFoundException e) {
                    System.out.println("File not found");
                } catch (IOException e) {
                    System.out.println("Error initializing stream");
                }
                Solution[] array = initPop.toArray(new Solution[0]);
                initialization = new InjectedInitialization(
                        distributedProblem,
                        100,array);
                System.out.println("Injecting existing solution!");
            } else {
                initialization = new RandomInitialization(distributedProblem,50);
            }


            TournamentSelection selection = new TournamentSelection(2,
                    new ChainedComparator(
                            new ParetoDominanceComparator(),
                            new CrowdingComparator()));

            Variation variation = new GAVariation(
                    new SBX(1.0, 25.0),
                    new PM(1.0 / distributedProblem.getNumberOfVariables(), 25.0));
//            File stateFile = new File("last.state");
//            Checkpoints checkpoints = new Checkpoints(new NSGAII(
//                    distributedProblem,
//                    new NondominatedSortingPopulation(),
//                    null, // no archive
//                    selection,
//                    variation,
//                    initialization),stateFile,10);

            EpsilonMOEA algorithm = new EpsilonMOEA(
                    distributedProblem,
                    new NondominatedSortingPopulation(),
                    new EpsilonBoxDominanceArchive(0.05), // no archive
                    selection,
                    variation,
                    initialization);


            while (algorithm.getNumberOfEvaluations() < 10000) {
                algorithm.step();
                Population currentPop = algorithm.getResult();
                try {
                    FileOutputStream f = new FileOutputStream("./src/test/output/xgrants/0207_current_population.txt");
                    ObjectOutputStream o = new ObjectOutputStream(f);
                    for (Solution sol : currentPop) {
                        o.writeObject(sol);
                    }
                    o.close();
                    f.close();
                } catch (FileNotFoundException e) {
                    System.out.println("File not found");
                } catch (IOException e) {
                    System.out.println("Error initializing stream");
                }
                try{
                    PrintWriter out = new PrintWriter("./src/test/output/xgrants/0207_variables_"+algorithm.getNumberOfEvaluations()+".txt");
                    for (Solution sol : currentPop) {
                        String altitude = String.valueOf(EncodingUtils.getInt(sol.getVariable(2)) * 100 + 400);
                        String inclination = String.valueOf(EncodingUtils.getInt(sol.getVariable(2)) * 5 + 60);
                        out.println(EncodingUtils.getInt(sol.getVariable(0))+","+EncodingUtils.getInt(sol.getVariable(1))+","+altitude+","+inclination+","+EncodingUtils.getInt(sol.getVariable(4))+","+EncodingUtils.getInt(sol.getVariable(5))+","+EncodingUtils.getInt(sol.getVariable(6))+","+EncodingUtils.getInt(sol.getVariable(7))+","+EncodingUtils.getReal(sol.getVariable(8))+","+EncodingUtils.getReal(sol.getVariable(9))+","+EncodingUtils.getReal(sol.getVariable(10)));
                    }
                    out.close();
                } catch (FileNotFoundException e) {
                    System.out.println("File not found");
                }
                try {
                    PopulationIO.writeObjectives(new File("./src/test/output/xgrants/0207_objectives_"+algorithm.getNumberOfEvaluations()+".txt"), currentPop);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            OrekitConfig.end();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e);
        }
        System.out.println("DONE");
        System.exit(0);
    }

}
