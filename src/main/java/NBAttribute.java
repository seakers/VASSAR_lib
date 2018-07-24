package rbsa.eoss;

// package KBSAofEOSS;
import java.util.Hashtable;

public class NBAttribute extends EOAttribute {
    public NBAttribute(String charact, String val){
        this.characteristic = charact;
        this.value = val;
        this.type = "NB";
        this.acceptedValues = new Hashtable<>();
        this.acceptedValues.put("Yes", 1);
        this.acceptedValues.put("No", 2);
    }
    
    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a neutral Boolean, if this.value = no, it is same or better than other.value
        int z = 0;
        if (this.value.compareTo(other.value) == 0) {
            z = 0;
        }
        else {
            z = -1;
        }
        return z;
    }

    @Override
    public NBAttribute cloneAttribute(EOAttribute other) {
        return new NBAttribute(other.characteristic, other.value);
    }
}
