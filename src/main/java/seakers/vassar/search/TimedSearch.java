/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.vassar.search;


import org.moeaframework.algorithm.AbstractEvolutionaryAlgorithm;
import org.moeaframework.core.Algorithm;
import org.moeaframework.core.Population;
import org.moeaframework.core.Solution;
import org.moeaframework.util.TypedProperties;
import seakers.architecture.io.ResultIO;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.concurrent.Callable;

/**
 *
 * @author nozomihitomi
 */
public class TimedSearch implements Callable<Algorithm> {

    private final String savePath;
    private final String name;
    private final Algorithm alg;
    private final TypedProperties properties;

    public TimedSearch(Algorithm alg, TypedProperties properties, String savePath, String name) {
        this.alg = alg;
        this.properties = properties;
        this.savePath = savePath;
        this.name = name;
    }

    @Override
    public Algorithm call() throws IOException  {

        int populationSize = (int) properties.getDouble("populationSize", 600);
        int maxEvaluations = (int) properties.getDouble("maxEvaluations", 10000);

        // run the executor using the listener to collect results
        System.out.println("Starting " + alg.getClass().getSimpleName() + " on " + alg.getProblem().getName() + "(" + this.name + ") with pop size: " + populationSize);
        alg.step();


        ArrayList<Solution> allSolutions = new ArrayList<>();
        Population initPop = ((AbstractEvolutionaryAlgorithm) alg).getPopulation();
        for (int i = 0; i < initPop.size(); i++) {
            initPop.get(i).setAttribute("NFE", 0);
            allSolutions.add(initPop.get(i));
        }

        LocalDateTime currentTime = LocalDateTime.now();
        LocalDateTime endTime = currentTime.plus(2880, ChronoUnit.MINUTES);
        while (!alg.isTerminated() && (alg.getNumberOfEvaluations() < maxEvaluations) && LocalDateTime.now().isBefore(endTime)) {
            if (alg.getNumberOfEvaluations() % 500 == 0) {
                System.out.println("NFE: " + alg.getNumberOfEvaluations());
                System.out.print("Popsize: " + ((AbstractEvolutionaryAlgorithm) alg).getPopulation().size());
                System.out.println("  Archivesize: " + ((AbstractEvolutionaryAlgorithm) alg).getArchive().size());
            }
            alg.step();
            Population pop = ((AbstractEvolutionaryAlgorithm) alg).getPopulation();
            for(int i=1; i<3; i++){
                Solution s = pop.get(pop.size() - i);
                s.setAttribute("NFE", alg.getNumberOfEvaluations());
                allSolutions.add(s);
            }
        }

        alg.terminate();

        String filename = savePath + File.separator + alg.getClass().getSimpleName() + "_" + name;
        ResultIO.savePopulation(((AbstractEvolutionaryAlgorithm) alg).getPopulation(), filename);
        ResultIO.savePopulation(new Population(allSolutions), filename + "_all");
        ResultIO.saveObjectives(alg.getResult(), filename);

        return alg;
    }

}
