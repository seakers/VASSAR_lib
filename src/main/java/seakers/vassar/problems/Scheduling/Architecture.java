package seakers.vassar.problems.Scheduling;

import seakers.vassar.architecture.AbstractArchitecture;
import java.util.*;

public class Architecture extends AbstractArchitecture{

    private int[] schedule;

    public Architecture(int[] intArray) {
        super();
        this.schedule = intArray;
    }

    @Override
    public String toString(String delimiter){
        StringJoiner sj = new StringJoiner(delimiter);
        sj.add("xd");
        return sj.toString();
    }

    @Override
    public boolean isFeasibleAssignment() {
        return true;
    }

    public int[] getSchedule() {
        return schedule;
    }
}
