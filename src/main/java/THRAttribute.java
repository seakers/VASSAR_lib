package rbsa.eoss;

/**
 *
 * @author Dani
 */
import java.util.Hashtable;

public class THRAttribute extends OLAttribute {
    public THRAttribute(String charact, String val){
        Hashtable<String, Integer> accepted = new Hashtable<>();
        accepted.put("Improves-predicted-SOA", 1);
        accepted.put("Improves-SOA", 2);
        accepted.put("useful-but-worse-than-SOA", 3);
        accepted.put("not-enough", 4);
        this.characteristic = charact;
        this.value = val;
        this.acceptedValues = accepted;
        this.type = "THR";
    }
}


