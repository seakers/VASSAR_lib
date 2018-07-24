package rbsa.eoss;

/**
 *
 * @author Ana-Dani
 */

import java.io.Serializable;
import java.util.HashMap;
import java.util.TreeMap;

public class NDSM implements Serializable {
    //private double[][] matrix;
    private String[] elements;
    private int numel;
    private HashMap<Nto1pair, Double> map;
    private HashMap<String, Integer> indices;
    private String description;
    
    public NDSM(String[] el, String desc) {
        elements = el;
        numel = el.length;
        map = new HashMap<>();
        indices = new HashMap<>();
        for (int i = 0; i < numel; i++) {
            indices.put(el[i],i);
        }
        description = desc;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
    public void setInteraction(String[] el1, String el2, double x) {
        Nto1pair key = new Nto1pair(el1, el2);
        if (!map.containsKey(key)) {
            map.put(key, x);
        }
    }

    public Double getInteraction(String[] el1,String el2) {
        return map.get(new Nto1pair(el1,el2));
    }

    public String printAllInteractions() {
        String ret = "";
        for (Nto1pair key: map.keySet()) {
            Double val = map.get(key);
            if (val != 0.0) {
                System.out.println(key.toString() + " : " + val);
            }
        }
        return ret;
    }
    public TreeMap<Nto1pair,Double> getAllInteractions(String operator) {
        HashMap<Nto1pair, Double> unsorted_map = new HashMap<>();
        ValueComparator2 bvc =  new ValueComparator2(map);
        TreeMap<Nto1pair, Double> sorted_map = new TreeMap<>(bvc);
        
        for (Nto1pair key : map.keySet()) {
            Double val = map.get(key);
            if ((val == 0.0 && operator.equalsIgnoreCase("0")) || (val > 0.0 && operator.equalsIgnoreCase("+")) || (val < 0.0 && operator.equalsIgnoreCase("-"))) {
                unsorted_map.put(key, val);
            }
        }
        sorted_map.putAll(unsorted_map);
        return sorted_map;
    }

    public String[] getElements() {
        return elements;
    }

    public void setElements(String[] elements) {
        this.elements = elements;
    }

    public int getNumel() {
        return numel;
    }

    public void setNumel(int numel) {
        this.numel = numel;
    }

    public HashMap<Nto1pair, Double> getMap() {
        return map;
    }

    public void setMap(HashMap<Nto1pair, Double> map) {
        this.map = map;
    }

    public HashMap<String, Integer> getIndices() {
        return indices;
    }

    public void setIndices(HashMap<String, Integer> indices) {
        this.indices = indices;
    }
    
}


