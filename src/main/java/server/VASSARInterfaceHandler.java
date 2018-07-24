package rbsa.eoss.server;

/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */


import java.util.*;
import java.util.concurrent.*;

import io.lettuce.core.RedisClient;
import io.lettuce.core.pubsub.StatefulRedisPubSubConnection;
import io.lettuce.core.pubsub.api.sync.RedisPubSubCommands;
import jess.Fact;
import jess.JessException;
import jess.Value;
import jess.ValueVector;
import org.moeaframework.algorithm.EpsilonMOEA;
import org.moeaframework.core.*;
import org.moeaframework.core.comparator.ChainedComparator;
import org.moeaframework.core.comparator.ParetoObjectiveComparator;
import org.moeaframework.core.operator.*;
import org.moeaframework.core.operator.binary.BitFlip;
import org.moeaframework.core.variable.BinaryVariable;
import org.moeaframework.util.TypedProperties;
import rbsa.eoss.*;
import rbsa.eoss.javaInterface.*;
import rbsa.eoss.local.Params;
import seak.architecture.operators.IntegerUM;

public class VASSARInterfaceHandler implements VASSARInterface.Iface {

    private Params params;
    private ArchitectureEvaluator AE = null;

    public VASSARInterfaceHandler() {
        initJess();
    }

    public void ping() {
      System.out.println("ping()");
    }
  
    private void initJess() {
        // Set a path to the project folder
        String path = System.getProperty("user.dir");
        
        // Initialization
        String search_clps = "";
        params = Params.initInstance(path, "CRISP-ATTRIBUTES", "test","normal", search_clps);//FUZZY or CRISP
        AE = ArchitectureEvaluator.getInstance();
        AE.init(1);
    }

    @Override
    public BinaryInputArchitecture eval(List<Boolean> boolList) {
        // Input a new architecture design
        // There must be 5 orbits. Instrument name is represented by a capital letter, taken from {A,B,C,D,E,F,G,H,I,J,K,L}
        
        String bitString = "";
        for (Boolean b: boolList) {
            bitString += b ? "1" : "0";
        }

        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);

        // Evaluate the architecture
        Result result = AE.evaluateArchitecture(architecture,"Slow");
        
        // Save the score and the cost
        double cost = result.getCost();
        double science = result.getScience();
        List<Double> outputs = new ArrayList<>();
        outputs.add(science);
        outputs.add(cost);
        
        System.out.println("Performance Score: " + science + ", Cost: " + cost);
        return new BinaryInputArchitecture(0, boolList, outputs);
    }

    @Override
    public List<BinaryInputArchitecture> runLocalSearch(List<Boolean> boolList) {
        String bitString = "";
        for (Boolean b: boolList) {
            bitString += b ? "1" : "0";
        }

        ArrayList<String> samples = randomLocalChange(bitString, 4);

        List<BinaryInputArchitecture> out = new ArrayList<>();

        for (String sample: samples) {
            // Generate a new architecture
            Architecture architecture = new Architecture(sample, 1);

            // Evaluate the architecture
            Result result = AE.evaluateArchitecture(architecture,"Slow");

            // Save the score and the cost
            double cost = result.getCost();
            double science = result.getScience();
            List<Double> outputs = new ArrayList<>();
            outputs.add(science);
            outputs.add(cost);

            System.out.println("bitString: " + sample + ", Science: " + science + ", Cost: " + cost);

            BinaryInputArchitecture arch = new BinaryInputArchitecture(0, bitString2BoolArray(sample), outputs);
            out.add(arch);
        }

        return out;
    }

    private ArrayList<String> randomLocalChange(String bitString, int n) {
        Random rand = new Random();
        int numVars = params.orbitList.length * params.instrumentList.length;

        ArrayList<String> out = new ArrayList<>();

        for (int i = 0; i < n; i++) {
            int k = rand.nextInt(numVars);

            StringBuilder tempBitString = new StringBuilder(bitString);
            if (bitString.charAt(k) == '1') {
                tempBitString.setCharAt(k, '0');
            }
            else {
                tempBitString.setCharAt(k, '1');
            }
            out.add(tempBitString.toString());
        }
        return out;
    }

    private List<Boolean> bitString2BoolArray(String bitString){
        List<Boolean> out = new ArrayList<>();
        for (int i = 0; i < bitString.length(); i++) {
            out.add(bitString.charAt(i) == '1');
        }
        return out;
    }

    @Override
    public List<String> getCritique(List<Boolean> boolList) {
        String bitString = "";
        for(Boolean b: boolList){
            bitString += b ? "1" : "0";
        }
        
        System.out.println(bitString);

        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);

        // Initialize Critique Generator
        CritiqueGenerator critiquer = new CritiqueGenerator(architecture);

        return critiquer.getCritique();
    }

    @Override
    public ArrayList<String> getOrbitList() {
        ArrayList<String> orbitList = new ArrayList<>();
        for(String o: params.orbitList){
            orbitList.add(o);
        }
        return orbitList;
    }

    @Override
    public ArrayList<String> getInstrumentList() {
        ArrayList<String> instrumentList = new ArrayList<>();
        for (String i: params.instrumentList) {
            instrumentList.add(i);
        }
        return instrumentList;
    }

    @Override
    public ArrayList<String> getObjectiveList() {
        ArrayList<String> objectiveList = new ArrayList<>();
        params.objectiveDescriptions.forEach((k, v) -> {
            objectiveList.add(k);
        });
        return objectiveList;
    }

    @Override
    public ArrayList<String> getInstrumentsForObjective(String objective) {
        return new ArrayList<>(params.objectivesToInstruments.get(objective));
    }

    @Override
    public ArrayList<String> getInstrumentsForPanel(String panel) {
        return new ArrayList<>(params.panelsToInstruments.get(panel));
    }

    @Override
    public List<ObjectiveSatisfaction> getArchitectureScoreExplanation(List<Boolean> arch) {
        String bitString = "";
        for (Boolean b: arch) {
            bitString += b ? "1" : "0";
        }

        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);
        architecture.setEvalMode("DEBUG");

        // Evaluate the architecture
        Result result = null;
        // Save the explanations for each stakeholder score
        List<ObjectiveSatisfaction> explanations = new ArrayList<>();

        result = AE.evaluateArchitecture(architecture, "Slow");
        for (int i = 0; i < params.panelNames.size(); ++i) {
            explanations.add(new ObjectiveSatisfaction(params.panelNames.get(i),
                    result.getPanelScores().get(i), params.panelWeights.get(i)));
        }

        return explanations;
    }


    @Override
    public List<ObjectiveSatisfaction> getPanelScoreExplanation(List<Boolean> arch, String panel) {
        String bitString = "";
        for (Boolean b: arch) {
            bitString += b ? "1" : "0";
        }

        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);
        architecture.setEvalMode("DEBUG");

        // Evaluate the architecture
        Result result = null;
        // Save the explanations for each stakeholder score
        List<ObjectiveSatisfaction> explanations = new ArrayList<>();

        result = AE.evaluateArchitecture(architecture, "Slow");
        for (int i = 0; i < params.panelNames.size(); ++i) {
            if (params.panelNames.get(i).equals(panel)) {
                for (int j = 0; j < params.objNames.get(i).size(); ++j) {
                    explanations.add(new ObjectiveSatisfaction(params.objNames.get(i).get(j),
                            result.getObjectiveScores().get(i).get(j), params.objWeights.get(i).get(j)));
                }
            }
        }

        return explanations;
    }


    @Override
    public List<ObjectiveSatisfaction> getObjectiveScoreExplanation(List<Boolean> arch, String objective) {
        String bitString = "";
        for (Boolean b: arch) {
            bitString += b ? "1" : "0";
        }

        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);
        architecture.setEvalMode("DEBUG");

        // Evaluate the architecture
        Result result = null;
        // Save the explanations for each stakeholder score
        List<ObjectiveSatisfaction> explanations = new ArrayList<>();

        result = AE.evaluateArchitecture(architecture, "Slow");
        for (int i = 0; i < params.panelNames.size(); ++i) {
            for (int j = 0; j < params.objNames.get(i).size(); ++j) {
                if (params.objNames.get(i).get(j).equals(objective)) {
                    for (int k = 0; k < params.subobjectives.get(i).get(j).size(); ++k) {
                        explanations.add(new ObjectiveSatisfaction(params.subobjectives.get(i).get(j).get(k),
                                result.getSubobjectiveScores().get(i).get(j).get(k),
                                params.subobjWeights.get(i).get(j).get(k)));
                    }
                }
            }
        }

        return explanations;
    }

    @Override
    public void startGA(List<BinaryInputArchitecture> dataset, String username) {
        //PATH
        String path = ".";

        ExecutorService pool = Executors.newFixedThreadPool(1);
        CompletionService<Algorithm> ecs = new ExecutorCompletionService<>(pool);

        //parameters and operators for search
        TypedProperties properties = new TypedProperties();
        //search paramaters set here
        int popSize = dataset.size();
        int maxEvals = dataset.size() + 50;
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
        Params.initInstance(path, "CRISP-ATTRIBUTES", "test","normal","");
        ArchitectureEvaluator gaArchEval = ArchitectureEvaluator.getNewInstance();
        gaArchEval.init(1);
        Problem problem = new InstrumentAssignment(new int[]{1}, gaArchEval);

        // Create a solution for each input arch in the dataset
        List<Solution> initial = new ArrayList<>(dataset.size());
        for (int i = 0; i < dataset.size(); ++i) {
            InstrumentAssignmentArchitecture new_arch = new InstrumentAssignmentArchitecture(new int[]{1},
                    Params.getInstance().numInstr, Params.getInstance().numOrbits, 2);
            for (int j = 1; j < new_arch.getNumberOfVariables(); ++j) {
                BinaryVariable var = new BinaryVariable(1);
                var.set(0, dataset.get(i).inputs.get(j-1));
                new_arch.setVariable(j, var);
            }
            new_arch.setObjective(0, dataset.get(i).outputs.get(0));
            new_arch.setObjective(1, dataset.get(i).outputs.get(1));
            new_arch.setAlreadyEvaluated(true);
            initial.add(new_arch);
        }
        initialization = new InjectedInitialization(problem, popSize, initial);

        //initialize population structure for algorithm
        Population population = new Population();
        EpsilonBoxDominanceArchive archive = new EpsilonBoxDominanceArchive(epsilonDouble);
        ChainedComparator comp = new ChainedComparator(new ParetoObjectiveComparator());
        TournamentSelection selection = new TournamentSelection(2, comp);

        singlecross = new OnePointCrossover(crossoverProbability);
        bitFlip = new BitFlip(mutationProbability);
        intergerMutation = new IntegerUM(mutationProbability);
        CompoundVariation var = new CompoundVariation(singlecross, bitFlip, intergerMutation);

        // REDIS
        RedisClient redisClient = RedisClient.create("redis://localhost:6379/0");

        Algorithm eMOEA = new EpsilonMOEA(problem, population, archive, selection, var, initialization);
        ecs.submit(new InteractiveSearch(eMOEA, properties, username, redisClient));

        try {
            Algorithm alg = ecs.take().get();
        } catch (InterruptedException | ExecutionException ex) {
            ex.printStackTrace();
        }

        // Notify listeners of new architectures in username channel
        StatefulRedisPubSubConnection<String, String> pubsubConnection = redisClient.connectPubSub();
        RedisPubSubCommands<String, String> sync = pubsubConnection.sync();
        sync.publish(username, "ga_done");
        pubsubConnection.close();

        redisClient.shutdown();
        gaArchEval.clear();
        pool.shutdown();
        System.out.println("DONE");
    }

    @Override
    public List<SubscoreInformation> getArchScienceInformation(BinaryInputArchitecture arch) {
        List<SubscoreInformation> information = new ArrayList<>();

        String bitString = "";
        for (Boolean b: arch.inputs) {
            bitString += b ? "1" : "0";
        }
        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);
        architecture.setEvalMode("DEBUG");

        Result result = AE.evaluateArchitecture(architecture, "Slow");
        for (int i = 0; i < params.panelNames.size(); ++i) {
            List<SubscoreInformation> objectivesInformation = new ArrayList<>();
            for (int j = 0; j < params.objNames.get(i).size(); ++j) {
                List<SubscoreInformation> subobjectivesInformation = new ArrayList<>();
                for (int k = 0; k < params.subobjectives.get(i).get(j).size(); ++k) {
                    String subobjName = params.subobjectives.get(i).get(j).get(k);
                    subobjectivesInformation.add(new SubscoreInformation(
                            subobjName,
                            params.subobjDescriptions.get(subobjName),
                            result.getSubobjectiveScores().get(i).get(j).get(k),
                            params.subobjWeights.get(i).get(j).get(k),
                            null));
                }
                String objName = params.objNames.get(i).get(j);
                objectivesInformation.add(new SubscoreInformation(
                        objName,
                        params.objectiveDescriptions.get(objName),
                        result.getObjectiveScores().get(i).get(j),
                        params.objWeights.get(i).get(j),
                        subobjectivesInformation));
            }
            String panelName = params.panelNames.get(i);
            information.add(new SubscoreInformation(
                    panelName,
                    params.panelDescriptions.get(panelName),
                    result.getPanelScores().get(i),
                    params.panelWeights.get(i),
                    objectivesInformation));
        }

        return information;
    }

    @Override
    public List<MissionCostInformation> getArchCostInformation(BinaryInputArchitecture arch) {
        List<MissionCostInformation> information = new ArrayList<>();

        String bitString = "";
        for (Boolean b: arch.inputs) {
            bitString += b ? "1" : "0";
        }
        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);
        architecture.setEvalMode("DEBUG");

        Result result = AE.evaluateArchitecture(architecture, "Slow");

        // Auxiliary arrays
        String[] massBudgetSlots = { "adapter-mass", "propulsion-mass#", "structure-mass#", "avionics-mass#",
                "ADCS-mass#", "EPS-mass#", "propellant-mass-injection", "propellant-mass-ADCS", "thermal-mass#",
                "payload-mass#" };
        String[] powerBudgetSlots = { "payload-peak-power#", "satellite-BOL-power#" };
        String[] costBudgetSlots = { "payload-cost#", "bus-cost#", "launch-cost#", "program-cost#",
                "IAT-cost#", "operations-cost#" };
        double[] costMultipliers = { 1e-3, 1e-3, 1.0, 1e-3, 1e-3, 1e-3 };
        for (Fact costFact: result.getCostFacts()) {
            try {
                String missionName = costFact.getSlotValue("Name").stringValue(null);
                // Obtain the list of instruments for this orbit
                List<String> orbitList = Arrays.asList(params.orbitList);
                List<String> instrList = Arrays.asList(params.instrumentList);
                ArrayList<String> payloads = new ArrayList<>();
                int loopStart = params.numInstr*orbitList.indexOf(missionName);
                int loopEnd = loopStart + params.numInstr;
                for (int i = params.numInstr*orbitList.indexOf(missionName); i < loopEnd; ++i) {
                    if (arch.inputs.get(i)) {
                        payloads.add(instrList.get(i-loopStart));
                    }
                }
                // Get the launch vehicle name
                String launchVehicle = costFact.getSlotValue("launch-vehicle").stringValue(null);
                HashMap<String, Double> massBudget = new HashMap<>();
                for (String massSlot: massBudgetSlots) {
                    Double value = costFact.getSlotValue(massSlot).floatValue(null);
                    massBudget.put(massSlot, value);
                }
                HashMap<String, Double> powerBudget = new HashMap<>();
                Double totalPower = 0.0;
                for (String powerSlot: powerBudgetSlots) {
                    Double value = costFact.getSlotValue(powerSlot).floatValue(null);
                    totalPower += value;
                    powerBudget.put(powerSlot, value);
                }
                HashMap<String, Double> costBudget = new HashMap<>();
                Double sumCost = 0.0;
                for (int i = 0; i < costBudgetSlots.length; ++i) {
                    String costSlot = costBudgetSlots[i];
                    Double multiplier = costMultipliers[i];
                    Double value = costFact.getSlotValue(costSlot).floatValue(null);
                    sumCost += value*multiplier;
                    costBudget.put(costSlot, value*multiplier);
                }
                Double totalCost = costFact.getSlotValue("mission-cost#").floatValue(null);
                costBudget.put("others", totalCost - sumCost);
                Double totalMass = costFact.getSlotValue("satellite-launch-mass").floatValue(null);
                information.add(new MissionCostInformation(
                        missionName,
                        payloads,
                        launchVehicle,
                        totalMass,
                        totalPower,
                        totalCost,
                        massBudget,
                        powerBudget,
                        costBudget));
            }
            catch (JessException e) {
                System.err.println(e.toString());
            }
        }

        return information;
    }

    @Override
    public SubobjectiveDetails getSubscoreDetails(BinaryInputArchitecture arch, String subobj) {
        // Get a result with all the important facts
        String bitString = "";
        for (Boolean b: arch.inputs) {
            bitString += b ? "1" : "0";
        }
        // Generate a new architecture
        Architecture architecture = new Architecture(bitString, 1);
        architecture.setEvalMode("DEBUG");
        Result result = AE.evaluateArchitecture(architecture, "Slow");

        String parameter = params.subobjectivesToMeasurements.get(subobj);

        // Obtain list of attributes for this parameter
        ArrayList<String> attrNames = new ArrayList<>();
        HashMap<String, ArrayList<String>> requirementRules = params.requirementRules.get(subobj);
        attrNames.addAll(requirementRules.keySet());
        HashMap<String, Integer> numDecimals = new HashMap<>();
        numDecimals.put("Horizontal-Spatial-Resolution#", 0);
        numDecimals.put("Temporal-resolution#", 0);
        numDecimals.put("Swath#", 0);

        // Loop to get rows of details for each data product
        ArrayList<List<String>> attrValues = new ArrayList<>();
        ArrayList<Double> scores = new ArrayList<>();
        ArrayList<String> takenBy = new ArrayList<>();
        ArrayList<List<String>> justifications = new ArrayList<>();
        for (Fact explanation: result.getExplanations().get(subobj)) {
            try {
                // Try to find the requirement fact!
                int measurementId = explanation.getSlotValue("requirement-id").intValue(null);
                if (measurementId == -1) {
                    continue;
                }
                Fact measurement = null;
                for (Fact capability: result.getCapabilities()) {
                    if (capability.getFactId() == measurementId) {
                        measurement = capability;
                        break;
                    }
                }
                // Start by putting all attribute values into list
                ArrayList<String> rowValues = new ArrayList<>();
                for (String attrName: attrNames) {
                    String attrType = requirementRules.get(attrName).get(0);
                    // Check type and convert to String if needed
                    Value attrValue = measurement.getSlotValue(attrName);
                    switch (attrType) {
                        case "SIB":
                        case "LIB": {
                            Double value = attrValue.floatValue(null);
                            double scale = 100;
                            if (numDecimals.containsKey(attrName)) {
                                scale = Math.pow(10, numDecimals.get(attrName));
                            }
                            value = Math.round(value * scale) / scale;
                            rowValues.add(value.toString());
                            break;
                        }
                        default: {
                            rowValues.add(attrValue.toString());
                            break;
                        }
                    }
                }
                // Get information from explanation fact
                Double score = explanation.getSlotValue("satisfaction").floatValue(null);
                String satisfiedBy = explanation.getSlotValue("satisfied-by").stringValue(null);
                ArrayList<String> rowJustifications = new ArrayList<>();
                ValueVector reasons = explanation.getSlotValue("reasons").listValue(null);
                for (int i = 0; i < reasons.size(); ++i) {
                    String reason = reasons.get(i).stringValue(null);
                    if (!reason.equals("N-A")) {
                        rowJustifications.add(reason);
                    }
                }

                // Put everything in their lists
                attrValues.add(rowValues);
                scores.add(score);
                takenBy.add(satisfiedBy);
                justifications.add(rowJustifications);
            }
            catch (JessException e) {
                System.err.println(e.toString());
            }
        }

        return new SubobjectiveDetails(
                parameter,
                attrNames,
                attrValues,
                scores,
                takenBy,
                justifications);
    }
}

