package rbsa.eoss;

/**
 *
 * @author Dani
 */
import jess.*;
import java.io.Serializable;

public class Worsen implements Userfunction , Serializable {
    private static final long serialVersionUID = 1L;

    public String getName() {
        return "Worsen";
    }

    public Value call(ValueVector vv, Context c) throws JessException {
        Value v1 = vv.get(1).resolveValue(c);
        Value v2 = vv.get(2).resolveValue(c);

        String attribute = v1.toString();
        String value = v2.stringValue(c);
        if (value.equalsIgnoreCase("nil")) {
            return new Value(-1, RU.INTEGER);
        }

        EOAttribute tmp = GlobalVariables.measurementAttributeSet.get(attribute);
        tmp.value = value;
        EOAttribute att_value = tmp.cloneAttribute(tmp);
        tmp.value = value;

        String result = att_value.Worsen();

        return new Value(result, RU.STRING);
    }
}


