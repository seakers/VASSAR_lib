package rbsa.eoss;

import java.util.Hashtable;
 
public class GBAttribute extends EOAttribute {
    public GBAttribute(String charact, String val) {
        super();
        this.characteristic = charact;
        this.value = val;
        this.type = "GB";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("Yes", 1);
        this.acceptedValues.put("No", 2);
    }

    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a good Boolean, if this.value = yes, it is same or better than other.value
        int z = 0;
        if (this.value.compareTo(other.value) == 0) {
            z = 0;
        }
        else if (this.value.compareTo("yes") == 0) {
            z = 1;
        }
        else if (this.value.compareTo("no") == 0 && other.value.compareTo("yes") == 0) {
            z = -1;
        }
        else {
            z = -1;
        }
        return z;
    }

    @Override
    public GBAttribute cloneAttribute(EOAttribute other) {
        return new GBAttribute(other.characteristic, other.value);
    }
}
