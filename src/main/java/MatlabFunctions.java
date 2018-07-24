/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

/**
 *
 * @author dani
 */
import java.util.HashMap;
import java.util.ArrayList;
import java.lang.reflect.Method;

import jess.*;

public class MatlabFunctions implements Userfunction {
    private HashMap<String,Interval> valueInvHashmap;
    private HashMap<Interval,String> valueHashmap;
    private Value vvalueInvHashmap;
    private Value vvalueHashmap;
    private HashMap<Integer,Double> infFactors;
    private ValueVector instrumentList;
    private Resource res;
    private Method m;
    private HashMap<String, LaunchVehicle> lvDatabase;

    public HashMap<Integer, Double> getInfFactors() {
        return infFactors;
    }

    public MatlabFunctions(Resource res) {
        this.res = res;
        m = null;
        valueInvHashmap = new HashMap<>(5);
        valueInvHashmap.put("Full", new Interval("interval", 1.0, 1.0));
        valueInvHashmap.put("Most", new Interval("interval", 0.66, 1.0));
        //valueInvHashmap.put("Half",new Interval("interval",0.4,0.6));
        valueInvHashmap.put("Some", new Interval("interval", 0.33, 0.66));
        valueInvHashmap.put("Marginal", new Interval("interval", 0.0, 0.33));
        vvalueInvHashmap = new Value(valueInvHashmap);
        
        valueHashmap = new HashMap<>(5);
        valueHashmap.put(new Interval("interval", 1.0, 1.0), "Full");
        valueHashmap.put(new Interval("interval", 0.66, 1.0), "Most");
        //valueHashmap.put(new Interval("interval",0.4,0.6),"Half");
        valueHashmap.put(new Interval("interval", 0.33, 0.66), "Some");
        valueHashmap.put(new Interval("interval", 0.0, 0.33), "Marginal");
        vvalueHashmap = new Value(valueHashmap);

        lvDatabase = new HashMap<>();
        
        infFactors = new HashMap<>();
        initializeInflationFactors();
    }
    @Override
    public String getName()
    {
        return "MatlabFunctions";
    }
    
    @Override
    public Value call(ValueVector vv, Context context) throws JessException {
        Class<?>[] partypes = new Class<?>[2];
        try {
            partypes[0] = vv.getClass();
            partypes[1] = context.getClass();
            
            m = this.getClass().getDeclaredMethod(vv.get(1).toString(), partypes);
            
            Value v = (Value)m.invoke(this, vv, context);
            
            return v;
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public Method getMethod() {
        return m;
    }

    public void setMethod( Method m ) {
        this.m = m;
    }

    public Resource getResource() {
        return res;
    }

    public void setResource(Resource res) {
        this.res = res;
    }
    
    private void initializeInflationFactors() {
        String factors = "0.097,0.088,0.08,0.075,0.078,0.08,0.081,0.084,0.082,"
                + "0.081,0.081,0.085,0.095,0.1,0.102,0.105,0.113,0.13,"
                + "0.14,0.138,0.14,0.151,0.154,0.155,0.156,0.156,0.158,"
                + "0.163,0.168,0.169,0.172,0.174,0.175,0.178,0.18,0.183,"
                + "0.188,0.194,0.202,0.213,0.225,0.235,0.243,0.258,0.286,"
                + "0.312,0.33,0.352,0.379,0.422,0.479,0.528,0.56,0.578,"
                + "0.603,0.625,0.636,0.66,0.687,0.72,0.759,0.791,0.815,"
                + "0.839,0.861,0.885,0.911,0.932,0.947,0.967,1,1.028,"
                + "1.045,1.069,1.097,1.134,1.171,1.171,1.216,1.208,1.226,"
                + "1.244,1.264,1.285,1.307,1.328,1.35,1.372,1.395,1.418";
        
        String[] tmp = factors.split(",");
        for( int i = 1930, j = 0; i<= 2019; i++, j++ )
            infFactors.put(new Integer(i), new Double(tmp[j]));
    }

    public String toJessList(String str) {
        //str = [a,b,c]; goal is to return (create$ a b c)
        String str2 = str.substring(1, str.length()-1);//get rid of []
        return " (create$ " + str2.replace(",", " ") + ")";
    }

    public String stringArraytoStringWithSpaces(String[] array) {
        String res = array[0];
        for (int i = 1; i < array.length; i++) {
            res += " " + array[i];
        }
        return res;
    }

    public String stringArraytoStringWith(String[] array, String ss) {
        String res = array[0];
        for (int i = 1; i < array.length; i++) {
            res += ss + array[i];
        }
        return res;
    }

    public int sumRowBool(boolean[][] mat, int row) {
        int x = 0;
        int ncols = mat[0].length;
        for (int i = 0; i < ncols; i++) {
            if (mat[row][i]) {
                x += 1;
            }
        }
        return x;
    }

    public ArrayList<String> jessList2ArrayList(ValueVector vv, Rete r) {
        ArrayList<String> al = new ArrayList<>();
        try {
            for (int i = 0; i < vv.size(); i++) {
                al.add(vv.get(i).stringValue(r.getGlobalContext()));
            }
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            al = null;
        }
        return al;
    }

    public Value getValueInvHashmap(Funcall vv, Context c) {
        return vvalueInvHashmap;
    }

    public Value getValueHashmap(Funcall vv, Context c) {
        return vvalueHashmap;
    }

    public void addLaunchVehicletoDB(String id, LaunchVehicle lv) {
        lvDatabase.put(id, lv);
    }

    public Value getLaunchVehicleCost(Funcall vv, Context c) {
        String id;
        try {
            id = vv.get(2).stringValue(c);
            double cost = lvDatabase.get(id).getCost();
            return new Value(cost, RU.FLOAT);

        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public Value getLaunchVehicleDimensions(Funcall vv, Context c) {
        String id;
        try {
            id = vv.get(2).stringValue(c);
            double h = lvDatabase.get(id).getHeight();
            double d = lvDatabase.get(id).getDiameter();
            ValueVector vv2 = new ValueVector(2);
            vv2.add(d);
            vv2.add(h);
            return new Value(vv2, RU.LIST);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public Value getLaunchVehiclePerformanceCoeffs(Funcall vv, Context c) {
        String id;
        String orb;
        try {
            id = vv.get(2).stringValue(c);
            orb = vv.get(3).stringValue(c);
            ValueVector coeffs = lvDatabase.get(id).getPayloadCoeffsOrbit(orb);
            return new Value( coeffs, RU.LIST );
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }
}
