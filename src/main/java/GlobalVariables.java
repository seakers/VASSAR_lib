package rbsa.eoss;

import java.util.HashMap;

public class GlobalVariables {
    // This class contains all the hashtables used to define the parameters
    // List of measurement parameters
    public static HashMap<String, Integer> measurementAttributeList;
    public static HashMap<Integer, String> measurementAttributeKeys;
    public static HashMap<String, String> measurementAttributeTypes;
    public static HashMap<String, EOAttribute> measurementAttributeSet;

    // List of instrument parameters
    public static HashMap<String, Integer> instrumentAttributeList;
    public static HashMap<Integer, String> instrumentAttributeKeys;
    public static HashMap<String, String> instrumentAttributeTypes;
    public static HashMap<String, EOAttribute> instrumentAttributeSet;

    public static void defineMeasurement(HashMap<String, Integer> attribs, HashMap<Integer, String> attribKeys,
                                         HashMap<String, String> attribTypes, HashMap<String, EOAttribute> attribSet) {
        measurementAttributeList = attribs;
        measurementAttributeKeys = attribKeys;
        measurementAttributeTypes = attribTypes;
        measurementAttributeSet = attribSet;
    }
    public static void defineInstrument(HashMap<String, Integer> attribs, HashMap<Integer, String> attribKeys,
                                        HashMap<String, String> attribTypes, HashMap<String, EOAttribute> attribSet){
        instrumentAttributeList = attribs;
        instrumentAttributeKeys = attribKeys;
        instrumentAttributeTypes = attribTypes;
        instrumentAttributeSet = attribSet;
    }
}