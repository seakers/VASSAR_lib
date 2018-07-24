package rbsa.eoss;

import java.util.Hashtable;

public class BBAttribute extends EOAttribute {
    public BBAttribute(String charact, String val) {
        this.characteristic = charact;
        this.value = val;
        this.type = "BB";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("No", 1);
        this.acceptedValues.put("Yes", 2);
    }
    
    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a bad Boolean, if this.value = no, it is same or better than other.value
        int z = 0;
        if (this.value.compareTo(other.value) == 0) {
            z = 0;
        }
        else if (this.value.compareTo("no") == 0) {
            z = 1;
        }
        else if (this.value.compareTo("yes") == 0 && other.value.compareTo("no") == 0){
            z = -1;
        }
        else {
            z = -1;
        }
        return z;
    }

    @Override
    public BBAttribute cloneAttribute(EOAttribute other) {
        return new BBAttribute(other.characteristic, other.value);
    }
}
