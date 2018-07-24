package rbsa.eoss;

/**
 *
 * @author Dani
 */
import jess.*;
import java.io.Serializable;

public class SameOrBetter implements Userfunction , Serializable {
    private static final long serialVersionUID = 1L;

    @Override
    public String getName() {
        return "SameOrBetter";
    }

    @Override
    public Value call(ValueVector vv, Context c) throws JessException {
        Value v1 = vv.get(1).resolveValue(c);
        Value v2 = vv.get(2).resolveValue(c);
        Value v3 = vv.get(3).resolveValue(c);

        String attribute = v1.toString();
        String value = v2.toString();
        String target = v3.toString();

        if (value.equalsIgnoreCase("nil")) {
            return new Value(-1, RU.INTEGER);
        }
        if (value.matches("-?\\d+(\\.\\d+)?")) {
            return new Value(-1, RU.INTEGER);
        }

        if (target.equalsIgnoreCase("nil")) {
            return new Value(1, RU.INTEGER);
        }
        if (target.matches("-?\\d+(\\.\\d+)?")) {
            return new Value(-1, RU.INTEGER);
        }
        EOAttribute tmp = GlobalVariables.measurementAttributeSet.get(attribute);
        tmp.value = value;
        EOAttribute attValue = tmp.cloneAttribute(tmp);
        tmp.value = target;
        EOAttribute attTarget = tmp.cloneAttribute(tmp);

        int result = attValue.SameOrBetter(attTarget);
        return new Value(result, RU.INTEGER);
    }
}
