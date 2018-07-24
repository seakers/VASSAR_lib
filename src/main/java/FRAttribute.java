package rbsa.eoss;

/**
 *
 * @author Dani
 */
public class FRAttribute extends EOAttribute {

    public FRAttribute(String charact, String val) {
        this.characteristic = charact;
        this.value = val;
        this.type = "FR";
    }

    @Override
    public int SameOrBetter(EOAttribute other) {
        int z = 0;
        int value_this = this.acceptedValues.get(this.value);
        int value_other = other.acceptedValues.get(other.value);
        if (value_this >= value_other) {
            z = 1;
        }
        else if (value_this == value_other) {
            z = 0;
        }
        else {
            z = -1;
        }
        return z;
    }

    @Override
    public FRAttribute cloneAttribute(EOAttribute other){
        return new FRAttribute(other.characteristic, other.value);
    }
}
