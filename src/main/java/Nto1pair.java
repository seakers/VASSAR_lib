/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbsa.eoss;

import org.apache.commons.lang3.StringUtils;
import org.paukov.combinatorics.ICombinatoricsVector;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;

/**
 *
 * @author Ana-Dani
 */
public class Nto1pair implements Serializable {
    private String[] base;
    private String added;

    public Nto1pair(String[] base, String added) {
        this.base = base;
        this.added = added;
    }
    public Nto1pair(ICombinatoricsVector<String> comb, String added) {
        int N = comb.getSize();
        base = new String[N];
        for (int i = 0;i<N;i++) {
            base[i] = comb.getValue(i);
        }
        this.added = added;
    }
    public ArrayList<String> toArrayList() {
        ArrayList<String> al = new ArrayList<String>();
        al.addAll(Arrays.asList(base));
        al.add(added);
        return al;
    }
    public String[] getBase() {
        return base;
    }

    public String getAdded() {
        return added;
    }

    @Override
    public String toString() {
        return "{" + StringUtils.join(base," & ") + " + " + added + '}';
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 61 * hash + Arrays.deepHashCode(this.base);
        hash = 61 * hash + (this.added != null ? this.added.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final Nto1pair other = (Nto1pair) obj;
        if (!Arrays.deepEquals(this.base, other.base)) {
            return false;
        }
        if ((this.added == null) ? (other.added != null) : !this.added.equals(other.added)) {
            return false;
        }
        return true;
    }
     
}
