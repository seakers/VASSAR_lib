package rbsa.eoss;

import java.util.Hashtable;

public class SIB2Attribute extends EOAttribute {
    public SIB2Attribute(String charact, String val) {
        this.characteristic = charact;
        this.value = val;
        this.type = "SIB2";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("Low", 1);
        this.acceptedValues.put("High", 2);
    }

    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a Small Is Better binary attribute:
        int z = 0;
        if (this.value.compareTo(other.value) == 0) {
            z = 0;
        }
        else if (this.value.compareTo("Low") == 0) {
            z = 1;
        }
        else if (this.value.compareTo("High") == 0 && other.value.compareTo("Low") == 0) {
            z = -1;
        }
        else {
            z = -1;
        }
        return z;
    }

    @Override
    public SIB2Attribute cloneAttribute(EOAttribute other) {
        return new SIB2Attribute(other.characteristic, other.value);
    }
}
