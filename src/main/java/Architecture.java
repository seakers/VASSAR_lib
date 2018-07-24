package rbsa.eoss;

import rbsa.eoss.local.Params;

import java.util.*;

import org.apache.commons.lang3.StringUtils;

/**
 *
 * @author dani
 */

public class Architecture implements Comparable<Architecture>, java.io.Serializable {
    private boolean[] bitVector;
    private int numOrbits;
    private int numInstr;
    private boolean[][] bitMatrix;
    private String evalMode;
    private String payload;
    private String orbit;
    private Result result;
    private Random random;
    private String mutate;
    private String crossover;
    private String improve;
    private String heuristicsToApply;
    private String heuristicsApplied;
    private String id;
    private int numSatellites;

    
    //Constructors
    public Architecture(boolean[] bitVector, int numOrbits, int numInstruments, int numSatellites) {
        this.bitVector = bitVector;
        this.numOrbits = numOrbits;
        this.numInstr = numInstruments;
        this.numSatellites = numSatellites;
        evalMode = "RUN";
        bitMatrix = bitString2Mat(bitVector, numOrbits, numInstr);
        orbit = null;
        result = new Result(this,-1,-1,-1);
        random = new Random();
        updateOrbitPayload();
        mutate = "no";
        crossover = "no";
        improve = "no";
        heuristicsToApply = "";
        heuristicsApplied = "";
        id = UUID.randomUUID().toString();
    }

    public Architecture(boolean[][] bitMatrix, int numSatellites) {
        this.bitMatrix = bitMatrix;
        numOrbits = bitMatrix.length;
        numInstr = bitMatrix[0].length;
        bitVector = mat2BitString(bitMatrix);
        evalMode = "RUN";
        this.numSatellites = numSatellites;
        orbit = null;
        result = new Result(this,-1,-1,-1);
        random = new Random();
        updateOrbitPayload();
        mutate = "no";
        crossover = "no";
        improve = "no";
        heuristicsToApply = "";
        heuristicsApplied = "";
        id = UUID.randomUUID().toString();
    }

    public Architecture(String bitString, int numSatellites) {
        Params params = Params.getInstance();
        bitMatrix = booleanString2Matrix(bitString);
        numOrbits = params.numOrbits;
        numInstr = params.numInstr;
        this.numSatellites = numSatellites;
        bitVector = mat2BitString(bitMatrix);
        evalMode = "RUN";
        orbit = null;
        result = new Result(this,-1,-1,-1);
        random = new Random();
        updateOrbitPayload();
        mutate = "no";
        crossover = "no";
        improve = "no";
        heuristicsToApply = "";
        heuristicsApplied = "";
        id = UUID.randomUUID().toString();
    }

    public Architecture(HashMap<String, String[]> mapping, int numSatellites) {
        Params params = Params.getInstance();
        params = Params.getInstance();
        bitMatrix = new boolean[params.numOrbits][params.numInstr];
        for (int o = 0; o < params.numOrbits; o++) {
            for(int i = 0; i < params.numInstr; i++) {
                bitMatrix[o][i] = false;
            }
        }

        for (int o = 0; o < params.numOrbits; o++) {
            String orb = params.orbitList[o];
            String[] payl = mapping.get(orb);
            if (payl == null)
                continue;
            ArrayList<String> thepayl = new ArrayList<>(Arrays.asList(payl));
            for(int i = 0; i < params.numInstr; i++) {
                String instr = params.instrumentList[i];
                if(thepayl.contains(instr))
                    bitMatrix[o][i] = true;
            }
        }

        numOrbits = bitMatrix.length;
        numInstr = bitMatrix[0].length;
        bitVector = mat2BitString(bitMatrix);
        evalMode = "RUN";
        this.numSatellites = numSatellites;
        orbit = null;
        result = new Result(this,-1,-1,-1);
        random = new Random();
        updateOrbitPayload();
        mutate = "no";
        crossover = "no";
        improve = "no";
        heuristicsToApply = "";
        heuristicsApplied = "";
        id = UUID.randomUUID().toString();
    }

    //Getters
    public int getNumSatellites() {
        return numSatellites;
    }
    public String getId() {
        return id;
    }
    public double getUtility() {
        return result.getUtility();
    }
    public String getOrbit() {
        return orbit;
    }
    public String getMutate() {
        return mutate;
    }
    public String getCrossover() {
        return crossover;
    }
    public String getImprove() {
        return improve;
    }
    public String getEvalMode() {
        return evalMode;
    }
    public boolean[] getBitVector() {
        return bitVector;
    }
    public boolean[][] getBitMatrix() {
        return bitMatrix;
    }
    public Result getResult() {
        return result;
    }
    public int getTotalInstruments() {
        return sumAllInstruments(bitMatrix);
    }
    public String getHeuristicsToApply() {
        return heuristicsToApply;
    }
    
    //Setters
    public void setUtility(double utility) {
        result.setUtility(utility);
    }
    public void setMutate(String mutate) {
        this.mutate = mutate;
    }
    public void setCrossover(String crossover) {
        this.crossover = crossover;
    }
    public void setImprove(String improve) {
        this.improve = improve;
    }
    public void setResult(Result result) {
        this.result = result;
    }
    public void setBitVector(boolean[] bitVector) {
        this.bitVector = bitVector;
    }
    public void setEvalMode(String evalMode) {
        this.evalMode = evalMode;
    }
    public void setHeuristicsToApply(String heuristicsToApply) {
        this.heuristicsToApply = heuristicsToApply;
    }

    //toString
    @Override
    public String toString() {
        Params params = Params.getInstance();
        String ret = "Arch = " + numSatellites + " x ";
        for (int o = 0; o < numOrbits; o++) {
            String orb = params.orbitList[o];
            String[] payls = this.getPayloadInOrbit(orb);
            if (payls != null) {
                ret += "\n" + orb + ": " + StringUtils.join(payls, " ") ;
            }
        }
        return ret;
    }

    public String toFactString() {
        Params params = Params.getInstance();
        String ret = "(MANIFEST::ARCHITECTURE" + " (id " + id + ") (num-sats-per-plane " + numSatellites + ") (bitString " + toBitString() + ") (payload " + payload + ") (orbit " + orbit + ")"
                + " (mutate " + mutate + " ) (crossover " + crossover + ") (improve " + improve + ") (heuristics-to-apply " + heuristicsToApply + " ) (heuristics-applied " + heuristicsApplied + ") "
                + "(factHistory F" + params.nof + ")";
        params.nof++;
        if (result != null) {
            ret += " (benefit " + result.getScience() + " ) (lifecycle-cost " + result.getCost() + ")" + " (pareto-ranking " + result.getParetoRanking() + " ) (utility " + result.getUtility() + ")";
        }
        ret += ")";
        return ret;
    }

    public String toBitString() {
        String str = "\"";
        for (boolean b: bitVector) {
            String c = "0";
            if (b) {
                c = "1";
            }
            str += c;
        }
        str += "\"";
        return str;
    }

    // Heuristics
    public Architecture mutate1bit() {
        Params params = Params.getInstance();
        if (random.nextBoolean()) { // mutate matrix but not nsats
            Integer index = random.nextInt(numOrbits*numInstr - 1);
            boolean[] newBitString = new boolean[numOrbits*numInstr];
            System.arraycopy(bitVector,0, newBitString,0,numOrbits*numInstr);
            newBitString[index] = !bitVector[index];
            Architecture newOne = new Architecture(newBitString, this.numOrbits, this.numInstr, this.numSatellites);
            newOne.setCrossover(crossover);
            newOne.setImprove(improve);
            return newOne;
        }
        else { // mutate nsats but not matrix
            Architecture newOne = new Architecture(bitVector, this.numOrbits, this.numInstr,
                    params.numSatellites[random.nextInt(params.numSatellites.length)]);
            newOne.setCrossover(crossover);
            newOne.setImprove(improve);
            return newOne;
        }
    }

    public Architecture crossover1point(Architecture other) {
        Integer index = random.nextInt(numOrbits*numInstr - 1);
        boolean[] otherBs = other.getBitVector();
        boolean[] newBitString = new boolean[numOrbits*numInstr];
        System.arraycopy(bitVector, 0, newBitString,0, index);
        System.arraycopy(otherBs, index+1, newBitString,index+1, numOrbits*numInstr - index - 1);//norb*ninstr
        if (random.nextBoolean()) {
            return new Architecture(newBitString, this.numOrbits, this.numInstr, numSatellites);
        }
        else {
            return new Architecture(newBitString, this.numOrbits, this.numInstr, other.getNumSatellites());
        }
        //System.out.println("crossover1point");
    }

    public Architecture improveOrbit() {
        Params params = Params.getInstance();
        // Find a random non-empty orbit and its payload
        String[] payload0 = null;
        int numTrials = 0;
        String orb;
        ArrayList<String> theOrbits = new ArrayList<>();
        Collections.addAll(theOrbits, params.orbitList);
        Collections.shuffle(theOrbits); // this sorts orbits in random order
        while (numTrials < params.numOrbits) {
            orb = theOrbits.get(numTrials);
            payload0 = getPayloadInOrbit(orb);
            if (payload0 == null) { // is there any instrument in this orbit?
                numTrials++;
                continue;
            }
            else {
                ArrayList<String> thePayloads = new ArrayList<>();
                Collections.addAll(thePayloads, payload0);
                Collections.shuffle(thePayloads); // this sorts orbits in random order
                for (String instr: thePayloads) {
                    ArrayList<String> list = new ArrayList<>();
                    list.add(instr);

                    // get all orbit scores
                    ArrayList<Map.Entry<String, Double>> list2 =
                            new ArrayList<>(ArchitectureEvaluator.getInstance().getAllOrbitScores(list).entrySet());

                    // sort orbits and get best_orbit
                    list2.sort(Collections.reverseOrder(ByValueComparator));
                    String bestOrbit = list2.get(0).getKey();
                    Double newScore = list2.get(0).getValue();
                    Double oldScore = ArchitectureEvaluator.getInstance().getScore(list, orb);

                    if (newScore > oldScore && random.nextFloat() < params.probAccept) {
                        //System.out.println("improveOrbit");
                        return new Architecture(moveInstrument(bitMatrix, instr, orb, bestOrbit), numSatellites);
                    }
                }
            }
            numTrials++;
        }
        // If all orbits are empty mutate 1 bit = add 1 instrument to 1 orbit
        if(payload0 == null || payload0.length == 0) {
            //System.out.println("improveOrbit > mutate1bit");
            return mutate1bit();
        }

        // Otherwise, all instruments are in hthe best possible orbits, so return unchanged
        System.out.println("improveOrbit > No changes");
        return new Architecture(bitMatrix, numSatellites);
    }

    public Architecture addSynergy() {
        Params params = Params.getInstance();
        // Find a random non-empty orbit and its payload
        String[] payload0 = null;
        ArrayList<String> missing;
        String orb;
        ArrayList<String> theOrbits = new ArrayList<>();
        Collections.addAll(theOrbits, params.orbitList);
        Collections.shuffle(theOrbits); //this sorts orbits in random order
        int numTrials = 0;
        while (numTrials < params.numOrbits) {
            orb = theOrbits.get(numTrials);
            payload0 = getPayloadInOrbit(orb);
            if (payload0 == null) { // is there any instrument in this orbit?
                numTrials++;
                continue;
            }
            else {
                ArrayList<TreeMap<Nto1pair, Double>> tmList = new ArrayList<>();
                // get dsm and positive binary synergies for that orbit
                NDSM sdsm = params.allDsms.get("SDSM2@" + orb);
                tmList.add(sdsm.getAllInteractions("+"));
                // try with 3-lateral synergies
                sdsm = params.allDsms.get("SDSM3@" + orb);
                tmList.add(sdsm.getAllInteractions("+"));

                for (TreeMap<Nto1pair, Double> tm: tmList) {
                    // Find a missing synergy from interaction tree
                    Iterator<Nto1pair> it = tm.keySet().iterator();
                    for (int i = 0; i < tm.size(); i++) {
                        // get next strongest interaction
                        Nto1pair nt = it.next();

                        // if architecture already contains that interaction, OR if does not contain N-1 elements from the interaction continue
                        ArrayList<String> al = new ArrayList<>();
                        Collections.addAll(al, nt.getBase());
                        al.add(nt.getAdded());
                        ArrayList<String> thePayload = new ArrayList<>();
                        Collections.addAll(thePayload, payload0);
                        if(capturesInteraction(thePayload, al) || !containsAllBut1FromInteraction(thePayload, al) ||
                                random.nextFloat() > params.probAccept) {
                            continue;
                        }
                        else {
                            //otherwise find missing element and return;
                            missing = new ArrayList<>(al);
                            missing.removeAll(thePayload);
                            //System.out.println("addSynergy");
                            if (!Arrays.asList(params.instrumentList).contains(missing.get(0))) {
                                continue;
                            }
                            return new Architecture(addInstrumentToOrbit(bitMatrix, missing.get(0), orb), numSatellites);
                        }
                    }
                }
            }
            numTrials++;
        }

        // If all orbits are empty mutate 1 bit = add 1 instrument to 1 orbit
        if (payload0 == null) {
            System.out.println("addSynergy > mutate1bit");
            return mutate1bit();
        }

        // if there are non-empty orbits, but all 2- and 3-synergies are captured, return best neighbor
        //System.out.println("addSynergy > No changes");
        return new Architecture(bitMatrix, numSatellites);
    }

    public Architecture addRandomToSmallSat() {
        Params params = Params.getInstance();
        // Find a random non-empty orbit and its payload
        String[] payload0 = null;
        int MAXSIZE = 3;
        int numTrials = 0;
        String orb = "";
        ArrayList<String> theOrbits = new ArrayList<>();
        Collections.addAll(theOrbits, params.orbitList);
        Collections.shuffle(theOrbits);//this sorts orbits in random order
        while (numTrials < params.numOrbits)  {
            orb = theOrbits.get(numTrials);
            payload0 = getPayloadInOrbit(orb);
            if (payload0 == null || payload0.length > MAXSIZE) { // is there at most MAXSIZE instruments in this orbit?
                numTrials++;
            }
            else {
                break;
            }
        }
        // If all orbits are empty mutate 1 bit = add 1 instrument to 1 orbit
        if (payload0 == null || numTrials == params.numOrbits) {
            System.out.println("addRandomToSmallSat > mutate1bit");
            return mutate1bit();
        }

        // Return new architecture with one instrument (random) added to orb
        ArrayList<String> candidates = new ArrayList<>();
        Collections.addAll(candidates, params.instrumentList);
        ArrayList<String> flown = new ArrayList<>();
        Collections.addAll(flown, payload0);

        candidates.removeAll(flown);
        Collections.shuffle(candidates); //this sorts candidates in random order
        String instr = candidates.get(0); //so we can pick the first one
        boolean[][] new_mat = addInstrumentToOrbit(bitMatrix, instr, orb);
        //System.out.println("addRandomToSmallSat");
        return new Architecture(new_mat, numSatellites);
    }

    public Architecture removeRandomFromLoadedSat() {
        Params params = Params.getInstance();
        // Find a random non-empty orbit and its payload
        String[] payload0 = null;
        int MINSIZE = 3;
        int numTrials = 0;
        String orb = "";
        ArrayList<String> theOrbits = new ArrayList<>();
        Collections.addAll(theOrbits, params.orbitList);
        Collections.shuffle(theOrbits); //this sorts orbits in random order
        while (numTrials < params.numOrbits) {
            orb = theOrbits.get(numTrials);
            payload0 = getPayloadInOrbit(orb);
            if (payload0 == null || payload0.length < MINSIZE) { // is there at least MINSIZE instruments in this orbit?
                numTrials++;
            }
            else {
                break;
            }
        }
        // If all orbits are empty mutate 1 bit = add 1 instrument to 1 orbit
        if (payload0 == null || numTrials == params.numOrbits) {
            //System.out.println("removeRandomFromLoadedSat > mutate1bit");
            return mutate1bit();
        }
        // Return new architecture with one instrument (random) removed from orb
        ArrayList<String> candidates = new ArrayList<>();
        Collections.addAll(candidates, payload0);
        Collections.shuffle(candidates);//this sorts candidates in random order
        String instr = candidates.get(0);
        boolean[][] new_mat = removeInstrumentFromOrbit(bitMatrix, instr, orb);
        //System.out.println("removeRandomFromLoadedSat");
        return new Architecture(new_mat, numSatellites);
    }

    public Architecture removeSuperfluous() {
        Params params = Params.getInstance();
        String[] payload0 = null;
        String orb;
        ArrayList<String> theOrbits = new ArrayList<>();
        Collections.addAll(theOrbits, params.orbitList);
        Collections.shuffle(theOrbits);//this sorts orbits in random order
        int numTrials = 0;
        while (numTrials < params.numOrbits)  {
            orb = theOrbits.get(numTrials);
            payload0 = getPayloadInOrbit(orb);
            if (payload0 == null) { // is there any instrument in this orbit?
                numTrials++;
                continue;
            }
            else {
                ArrayList<TreeMap<Nto1pair, Double>> tmList = new ArrayList<>();
                // get redundancy dsm and zero binary inteferences for that orbit
                // TODO: Remove 12 somehow
                NDSM rdsm = params.allDsms.get("RDSM" + (12) + "@" + orb);
                tmList.add(rdsm.getAllInteractions("-"));
                //try with 3-lateral interferences
                rdsm = params.allDsms.get("RDSM3@" + orb);
                tmList.add(rdsm.getAllInteractions("-"));

                for (TreeMap<Nto1pair, Double> tm: tmList) {
                    // Find a missing synergy from interaction tree
                    Iterator<Nto1pair> it = tm.keySet().iterator();
                    for (int i = 0; i < tm.size(); i++) {
                        Nto1pair nt = it.next();
                        ArrayList<String> al = new ArrayList<>();
                        Collections.addAll(al, nt.getBase());
                        al.add(nt.getAdded());
                        ArrayList<String> thePayload = new ArrayList<>();
                        Collections.addAll(thePayload, payload0);
                        if ((!nt.getAdded().equalsIgnoreCase("SMAP_ANT")) && capturesInteraction(thePayload, al)
                                && random.nextFloat() < params.probAccept) {
                            //System.out.println("removeSuperfluous");
                            if (!Arrays.asList(params.instrumentList).contains(nt.getAdded())) {
                                continue;
                            }
                            return new Architecture(removeInstrumentFromOrbit(bitMatrix, nt.getAdded(), orb), numSatellites);
                        }
                    }
                }
            }
            numTrials++;
        }
        //If all orbits are empty mutate 1 bit = add 1 instrument to 1 orbit
        if (payload0 == null) {
            //System.out.println("removeSuperfluous > mutate");
            return mutate1bit();
        }
        // if there are non-empty orbits, but all 2- and 3-inteferences are already solved, return with no changes
        System.out.println("removeSuperfluous > No changes");
        return new Architecture(bitMatrix, numSatellites);
    }

    // Support functions for heuristics
    public boolean[][] addInstrumentToOrbit(boolean[][] old, String toadd, String where) {
        Params params = Params.getInstance();
        // create copy of current matrix
        boolean[][] thenew = new boolean[numOrbits][numInstr];
        for (int i = 0; i < old.length; i++) {
            System.arraycopy(old[i], 0, thenew[i], 0, old[0].length);
        }
        // add the missing instrument in the right orbit and return
        thenew[params.orbitIndexes.get(where)][params.instrumentIndexes.get(toadd)] = true;
        return thenew;
    }

    public boolean[][] removeInstrumentFromOrbit(boolean[][] old, String instr, String from) {
        Params params = Params.getInstance();
        // create copy of current matrix
        boolean[][] thenew = new boolean[numOrbits][numInstr];
        for (int i = 0; i < old.length; i++) {
            System.arraycopy(old[i], 0, thenew[i], 0, old[0].length);
        }
        // add the missing instrument in the right orbit and return
        thenew[params.orbitIndexes.get(from)][params.instrumentIndexes.get(instr)] = false;
        return thenew;
    }

    public boolean[][] moveInstrument(boolean[][] old, String instr, String from, String to) {
        Params params = Params.getInstance();
        //create copy of current matrix
        boolean[][] thenew = new boolean[numOrbits][numInstr];
        for (int i = 0; i < old.length; i++) {
            System.arraycopy(old[i], 0, thenew[i], 0, old[0].length);
        }
        //add the missing instrument in the right orbit and return
        thenew[params.orbitIndexes.get(from)][params.instrumentIndexes.get(instr)] = false;
        thenew[params.orbitIndexes.get(to)][params.instrumentIndexes.get(instr)] = true;
        return thenew;
    }

    private Boolean capturesInteraction(ArrayList<String> thePayload, ArrayList<String> al) {
        // returns true if payl contains all elements in nt IN THE desired ORBIT
        return (al.containsAll(thePayload));
    }

    private Boolean containsAllBut1FromInteraction(ArrayList<String> thePayload, ArrayList<String> al) {
        // returns true if payl contains all but 1 elements in nt IN THE desired ORBIT
        int count = 0;
        for (int i = 0; i < al.size(); i++) {
            if (thePayload.contains(al.get(i))) {
                count++;
            }
        }
        // return true if from the N elements in the interaction, we have exactly N-1 elements in the payload (i.e. 1 missing)
        return count == al.size()-1;
    }
    
    // Utils
    public boolean[][] booleanString2Matrix(String bitString) {
        Params params = Params.getInstance();
        boolean[][] mat = new boolean[params.numOrbits][params.numInstr];
        for (int i = 0; i < params.numOrbits; i++) {
            for (int j = 0; j < params.numInstr; j++) {
                String b = bitString.substring(params.numInstr *i + j,params.numInstr*i + j + 1);
                if (b.equalsIgnoreCase("1")) {
                    mat[i][j] = true;
                }
                else if (b.equalsIgnoreCase("0")) {
                    mat[i][j] = false;
                }
                else {
                    System.out.println("Architecture: booleanString2Matrix string b is nor equal to 1 or 0!");
                }
            }         
        }
        return mat;
    }

    public static boolean[][] bitString2Mat(boolean[] bitString, int norb, int ninstr) {
        boolean[][] mat = new boolean[norb][ninstr];
        int b = 0;
        for (int i = 0; i < norb; i++) {
            for (int j = 0; j < ninstr; j++) {
                mat[i][j] = bitString[b++];
            }         
        }
        return mat;
    }

    public static boolean[] mat2BitString(boolean[][] mat) {
        int norb = mat.length;
        int ninstr = mat[0].length;
        boolean[] bitString = new boolean[norb*ninstr];
        int b = 0;
        for (int i = 0; i < norb; i++) {
            for (int j = 0; j < ninstr; j++) {
               bitString[b++] = mat[i][j];
            }
        }
        return bitString;
    }

    private int sumRowBool(boolean[][] mat, int row) {
        int x = 0;
        int ncols = mat[0].length;
        for (int i = 0;i<ncols;i++) {
            if (mat[row][i]) {
                x += 1;
            }
        }
        return x;
    }

    private int sumAllInstruments(boolean[][] mat) {
        int x = 0;
        for (boolean[] row: mat) {
            for (boolean val: row) {
                if (val) {
                    x += 1;
                }
            }
        }
        return x;
    }

    public String[] getPayloadInOrbit(String orb) {
        Params params = Params.getInstance();
        String[] thepayloads = null;
         for (int i = 0; i < params.numOrbits; i++) {
            if (orb.equalsIgnoreCase(params.orbitList[i])) {
                int n = sumRowBool(bitMatrix, i);
                thepayloads = new String[n];
                int k = 0;
                for (int j = 0; j < params.numInstr; j++) {
                    if (bitMatrix[i][j]) {
                        thepayloads[k++] = params.instrumentList[j];
                    }
                }
            }
        }
        return thepayloads;
    }

    private void updateOrbitPayload() {
        Params params = Params.getInstance();
        for (int i = 0; i < params.numOrbits; i++) {
            int n = sumRowBool(bitMatrix, i);
            if (n > 0) {
                orbit = params.orbitList[i];
                payload = "";
                int k = 0;
                for (int j = 0; j < params.numInstr; j++) {
                    if (bitMatrix[i][j]) {
                        payload += " " + params.instrumentList[j];
                        k++;
                    }
                }
            }
        }
    }
    
    //CompareTo
    @Override
    public int compareTo(Architecture other) {
        if(this.toBitString().compareTo(other.toBitString()) == 0 && this.getNumSatellites() == other.getNumSatellites()) {
            return 0;
        }
        else {
            return 1;
        }
    }

    private static int compare2zero(double x) {
        if(x < 0) {
            return 1;
        }
        else if (x > 0) {
            return -1;
        }
        else {
            return 0;
        }
    }

    public static Comparator<Architecture> ArchCrowdDistComparator = (Architecture a1, Architecture a2) -> {
        double x = (a1.getResult().getCrowdingDistance() - a2.getResult().getCrowdingDistance());
        return compare2zero(x);
    };

    public static Comparator<Architecture> ArchScienceComparator = (Architecture a1, Architecture a2) -> {
        double x = (a1.getResult().getScience() - a2.getResult().getScience());
        return compare2zero(x);
    };

    public static Comparator<Architecture> ArchCostComparator = (Architecture a1, Architecture a2) -> {
        double x = (a1.getResult().getCost() - a2.getResult().getCost());
        return compare2zero(x);
    };

    public static Comparator<Map.Entry<String,Double>> ByValueComparator = Comparator.comparing(Map.Entry<String,Double>::getValue);
    
    public boolean isFeasibleAssignment() {
        Params params = Params.getInstance();
        return (sumAllInstruments(bitMatrix) <= params.MAX_TOTAL_INSTR);
    }
    
    public Architecture copy(){
        Architecture arch = new Architecture(this.bitVector, this.numOrbits, this.numInstr, this.numSatellites);
        arch.setResult(this.result);
        return arch;
    }
}
