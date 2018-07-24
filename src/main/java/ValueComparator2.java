package rbsa.eoss;

import java.util.Comparator;
import java.util.HashMap;

/**
 *
 * @author Ana-Dani
 */
public class ValueComparator2 implements Comparator<Nto1pair> {

    HashMap<Nto1pair, Double> base;
    public ValueComparator2(HashMap<Nto1pair, Double> base) {
        this.base = base;
    }

    // Note: this comparator imposes orderings that are inconsistent with equals.    
    @Override
    public int compare(Nto1pair a, Nto1pair b) {
        if (base.get(a) >= base.get(b)) {
            return -1;
        } else {
            return 1;
        } // returning 0 would merge keys
    }
}
