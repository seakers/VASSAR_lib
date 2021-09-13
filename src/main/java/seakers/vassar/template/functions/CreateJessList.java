package seakers.vassar.template.functions;

import com.mitchellbosecke.pebble.extension.Function;
import com.mitchellbosecke.pebble.template.EvaluationContext;
import com.mitchellbosecke.pebble.template.PebbleTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CreateJessList implements Function {

    @Override
    public List<String> getArgumentNames() {
        List<String> names = new ArrayList<>();
        names.add("str");
        return names;
    }

    @Override
    public Object execute(Map<String, Object> args, PebbleTemplate self, EvaluationContext context, int lineNumber) {
        String str = (String)args.get("str");

        StringBuilder jessList = new StringBuilder();

        str = str.substring(1, str.length()-1);
        String[] list = str.split(",");

        jessList.append("(create$ ");

        for (String elem: list) {
            jessList.append(elem).append(" ");
        }

        jessList.append(")");


        return jessList.toString();
    }
}
