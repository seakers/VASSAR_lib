package rbsa.eoss;

import java.util.Hashtable;

public class LIB5Attribute extends EOAttribute {
    public LIB5Attribute(String charact, String val) {
        this.characteristic = charact;
        this.value = val;
        this.type = "LIB5";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("Highest", 1);
        this.acceptedValues.put("High", 2);
        this.acceptedValues.put("Medium", 3);
        this.acceptedValues.put("Low", 4);
        this.acceptedValues.put("Lowest", 3);
    }

    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a Large Is Better ternary attribute:
        int z = 0;
        int value_this = this.acceptedValues.get(this.value);
        int value_other = other.acceptedValues.get(other.value);
        if(value_this == value_other) {
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
    public LIB5Attribute cloneAttribute(EOAttribute other){
        return new LIB5Attribute(other.characteristic, other.value);
    }

}
