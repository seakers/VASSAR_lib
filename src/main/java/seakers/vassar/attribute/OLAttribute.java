package seakers.vassar.attribute;

import java.util.Hashtable;

public class OLAttribute extends EOAttribute {

    public OLAttribute(){
        this.characteristic = "N/A";
        this.value = "N/A";
        this.type = "OL";
        this.acceptedValues = new Hashtable<>();
    }

    public OLAttribute(String charact, String val, Hashtable<String, Integer> accepted) {
        this.characteristic = charact;
        this.value = val;
        this.type = "OL";
        this.acceptedValues = accepted != null ? accepted : new Hashtable<>();
    }

    public OLAttribute(String charact, String val) {
        this.characteristic = charact;
        this.value = val;
        this.type = "OL";
        this.acceptedValues = new Hashtable<>();
    }

    @Override
    public int SameOrBetter(EOAttribute other) {
        // Since this is a Neutral List attribute:
        int z = 0;
        
        // Add null checks
        if (this.acceptedValues == null) {
            this.acceptedValues = new Hashtable<>();
        }
        if (other.acceptedValues == null) {
            other.acceptedValues = new Hashtable<>();
        }
        
        // Add null checks for values
        if (this.value == null) {
            this.value = "N/A";
        }
        if (other.value == null) {
            other.value = "N/A";
        }
        
        // Get values with null checks
        Integer value_this = this.acceptedValues.get(this.value);
        Integer value_other = other.acceptedValues.get(other.value);
        
        if (value_this == null) {
            value_this = 0; // Default to lowest value if not found
        }
        if (value_other == null) {
            value_other = 0; // Default to lowest value if not found
        }
        
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
    public String Worsen() {
        int old_num_value = this.acceptedValues.get(this.value);
        int size = this.acceptedValues.size();
        Hashtable<Integer, String> reverse = this.getReverseAcceptedValues();
        int new_num_value = 0;
        if (old_num_value < size) {
            new_num_value = old_num_value  + 1;
        }
        else {
            new_num_value = old_num_value;
        }
        return reverse.get(new_num_value);
    }

    @Override
    public String Improve() {
        int old_num_value = this.acceptedValues.get(this.value);
        Hashtable<Integer, String> reverse = this.getReverseAcceptedValues();
        int new_num_value = 0;
        if (old_num_value > 1) {
            new_num_value = old_num_value  - 1;
        }
        else {
            new_num_value = old_num_value;
        }
        return reverse.get(new_num_value);
    }

    @Override
    public OLAttribute cloneAttribute(EOAttribute other){
        return new OLAttribute(other.characteristic, other.value, other.acceptedValues);
    }
}
