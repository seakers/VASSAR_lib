package seakers.vassar.template.functions;

import com.mitchellbosecke.pebble.extension.AbstractExtension;
import com.mitchellbosecke.pebble.extension.Function;

import java.util.HashMap;
import java.util.Map;

public class JessExtension extends AbstractExtension {
    @Override
    public Map<String, Function> getFunctions() {
        HashMap<String, Function> jessFunctions = new HashMap<>();
        jessFunctions.put("createJessList", new CreateJessList());
        return jessFunctions;
    }
}
