package rbsa.eoss;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Set;
import java.io.*;

public class FuzzyValue implements Serializable {
    //private static final long serialVersionUID = 9032778100864812066L;
    private String param;
    private double num_val;
    private Interval interv;
    private String unit;
    private HashMap<Interval,String> conv_table;

    public FuzzyValue(String param, double num_val, double min, double max, String unit, HashMap<Interval, String> conv_table) {
        this.param = param;
        this.interv = new Interval("interval", min, max);
        this.num_val = this.interv.getMean();
        this.unit = unit;
        this.conv_table = conv_table;
    }

    public FuzzyValue(String param, Interval interv, String unit, HashMap<Interval, String> conv_table) {
        this.param = param;
        this.interv = interv;
        this.num_val = this.interv.getMean();
        this.unit = unit;
        this.conv_table = conv_table;
    }

    public FuzzyValue(String param, Interval interv, String unit)  {
        this.param = param;
        this.interv = interv;
        this.num_val = this.interv.getMean();
        this.unit = unit;
    }

    public FuzzyValue(String param, String fuzzy_val, String unit, HashMap<String, Interval> conv_table)  {
        this.param = param;
        this.interv = conv_table.get(fuzzy_val);
        this.num_val = this.interv.getMean();
        this.unit = unit;
        HashMap<Interval, String> newMap = new HashMap<>();
        for (Entry<String, Interval> entry: conv_table.entrySet()) {
            newMap.put(entry.getValue(), entry.getKey());
        }
        this.conv_table = newMap;
    }

    // Manipulating fuzzy values
    public FuzzyValue add(FuzzyValue other) {
        // assume same unit and parameter
        Interval int1 = this.interv;
        Interval int2 = other.getInterv();
        Interval int3 = int1.add(int2);
        return new FuzzyValue(this.param, int3, this.unit, this.conv_table);
    }

    public FuzzyValue minus(FuzzyValue other) {
        Interval int1 = this.interv;
        Interval int2 = other.getInterv();
        Interval int3 = int1.minus(int2);
        return new FuzzyValue(this.param, int3, this.unit, this.conv_table);
    }

    public FuzzyValue times(double scal) {
        Interval int1 = this.interv.times(scal);
        return new FuzzyValue(this.param, int1, this.unit, this.conv_table);
    }

    public FuzzyValue prod(FuzzyValue other) {
        Interval int1 = this.interv;
        Interval int2 = other.getInterv();
        Interval int3 = int1.prod(int2);
        return new FuzzyValue(this.param, int3, this.unit, this.conv_table);
    }

    @Override
    public String toString() {
        return ("[ " + this.interv.getMin() + " , " + this.interv.getMax() + " ]");
    }

    // Getters and setters
    public double getNum_val() {
        return this.num_val;
    }

    public String getUnit() {
        return this.unit;
    }

    public Interval getInterv() {
        return this.interv;
    }

    public String getParam() {
        return this.param;
    }

    public String getFuzzy_val() {
        Set<Interval> intervs = this.conv_table.keySet();
        Iterator<Interval> all_int = intervs.iterator();
        while (all_int.hasNext()) {
            Interval tmp = all_int.next();
            if (tmp.intersects(new Interval("delta",this.num_val,0.0))) {
                return this.conv_table.get(tmp);
            }
        }
        return "N/A";
    }
}
