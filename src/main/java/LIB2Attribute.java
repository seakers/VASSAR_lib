package rbsa.eoss;

import java.util.Hashtable;

public class LIB2Attribute extends EOAttribute {
    public LIB2Attribute(String charact, String val){
        this.characteristic = charact;
        this.value = val;
        this.type = "LIB2";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("High", 1);
        this.acceptedValues.put("Low", 2);
    }
    
    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a Large Is Better binary attribute, if this.value = High, it is same or better than other.value
        int z = 0;
        if (this.value.compareTo(other.value) == 0) {
            z = 0;
        }
        else if (this.value.compareTo("High") == 0) {
            z = 1;
        }
        else if (this.value.compareTo("Low") == 0 && other.value.compareTo("High") == 0) {
            z = -1;
        }
        else {
            z = -1;
        }
        return z;
    }

    @Override
    public LIB2Attribute cloneAttribute(EOAttribute other){
        return new LIB2Attribute(other.characteristic, other.value);
    }
}
