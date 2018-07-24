package rbsa.eoss;

import java.util.Hashtable;

public class AttributeBuilder {
    // types of attributes:
    // GB good boolean (yes/no, yes includes no), BB bad boolean (no includes yes, NB neutral Boolean (yes and no are simply different)
    // LIB2 (High, Low High incldues low) LIB3 (High,Medium,Low, High includes all), LIB5 (with highest and lowest) 
    // SIB2 (Low, High, Low incldues high) SIB3 (Low,Medium,High, Low includes all), SIB5 (with lowest and highest)
    // NL Neutral List (they are just all different, e.g., bands)
    // OL Ordered List (unspecified list of values, but they have a defined preference order)
    public static Hashtable<String, EOAttribute> AttributeObjectList;
    
    private AttributeBuilder() {
    }
    
    public static void add(String typ, EOAttribute obj) {
        AttributeObjectList.put(typ, obj);
    }

    public static EOAttribute makeMeasurementAttribute(String charact, String val) {
        EOAttribute att = GlobalVariables.measurementAttributeSet.get(charact);
        att.characteristic = charact;
        String type = att.type;
        if ((type.compareTo("NL") == 0) || (type.compareTo("OL") == 0)) {
            if (att.CheckValue(val)) {
                att.value = val;
            }
            else {
                System.out.println("AttributeBuilder: Error, value " + val + " not in accepted values of atrribute " + charact);
            }
        }
        else {
            att.value = val;
        }
        return att;
    }

    public static EOAttribute make(String type, String charact, String val) {
        EOAttribute att = new EOAttribute();
        if (type.compareTo("GB") == 0) {
            att = new GBAttribute(charact, val);
        }
        else if (type.compareTo("BB") == 0) {
            att = new BBAttribute(charact, val);
        }
        else if (type.compareTo("NB") == 0) {
            att = new NBAttribute(charact, val);
        }
        else if (type.compareTo("LIB2") == 0) {
            att = new LIB2Attribute(charact, val);
        }
        else if (type.compareTo("LIB3") == 0) {
            att = new LIB3Attribute(charact, val);
        }
        else if (type.compareTo("LIB5") == 0) {
            att = new LIB5Attribute(charact, val);
        }
        else if (type.compareTo("SIB2") == 0) {
            att = new SIB2Attribute(charact, val);
        }
        else if (type.compareTo("SIB3") == 0) {
            att = new SIB3Attribute(charact, val);
        }
        else if (type.compareTo("SIB5") == 0) {
            att = new SIB5Attribute(charact, val);
        }
        else if (type.compareTo("NL") == 0) {
            att = new NLAttribute(charact, val);
        }
        else if (type.compareTo("OL") == 0) {
            att = new OLAttribute(charact, val);
        }
        else if (type.compareTo("FR") == 0) {
            att = new EOAttribute(charact, val);
            att.type = "FR";
        }
        else if (type.compareTo("THR")==0){
            att = new THRAttribute(charact, val);
            att.type = "THR";
        }
        else {
            System.out.println("Missing Attribute Type" + type);
        }
        return att;
    }

    public static EOAttribute make(String type, String charact, String val, Hashtable<String, Integer> accepted) {
        EOAttribute att = new EOAttribute();
        if (type.compareTo("NL") == 0) {
            att = new NLAttribute(charact, val, accepted);
        }
        else if (type.compareTo("OL") == 0) {
            att = new OLAttribute(charact, val, accepted);
        }
        return att;
    }
}
