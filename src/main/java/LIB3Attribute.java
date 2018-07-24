package rbsa.eoss;

import java.util.Hashtable;

public class LIB3Attribute extends EOAttribute {
    public LIB3Attribute(String charact, String val) {
        this.characteristic = charact;
        this.value = val;
        this.type = "LIB3";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("High", 1);
        this.acceptedValues.put("Medium", 2);
        this.acceptedValues.put("Low", 3);
    }

    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a Large Is Better ternary attribute:
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
    public String Improve() {
        // By default
        if (this.value.compareTo("Low") == 0) {
            this.value = "Medium";
        }
        else if (this.value.compareTo("Medium") == 0) {
            this.value = "High";
        }
        return this.value;
    }

    @Override
    public LIB3Attribute cloneAttribute(EOAttribute other) {
        return new LIB3Attribute(other.characteristic, other.value);
    }

}
