package rbsa.eoss;

import java.util.Hashtable;

public class SIB3Attribute extends EOAttribute {
    public SIB3Attribute(String charact, String val){
        this.characteristic = charact;
        this.value = val;
        this.type = "SIB3";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("Low", 1);
        this.acceptedValues.put("Medium", 2);
        this.acceptedValues.put("High", 3);
    }

    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a Small Is Better ternary attribute:
        int z = 0;
        int value_this = this.acceptedValues.get(this.value);
        int value_other = other.acceptedValues.get(other.value);
        if (value_this == value_other) {
            z = 0;
        }
        else if (value_this > value_other) {
            z = -1;
        }
        else if (value_this < value_other) {
            z = 1;
        }
        else {
            z = -1;
        }
        return z;
    }

    @Override
    public SIB3Attribute cloneAttribute(EOAttribute other) {
        return new SIB3Attribute(other.characteristic, other.value);
    }
}
