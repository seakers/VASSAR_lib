package seakers.vassar.architecture;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public abstract class AbstractArchitecture {

    protected String id;
    protected List<Double> objectives;

    protected AbstractArchitecture(){
        this.id = UUID.randomUUID().toString();
        this.objectives = new ArrayList<>();
    }

    public abstract boolean isFeasibleAssignment();

    public boolean isEvaluated(){
        if(this.objectives == null){
            return false;
        }else if(this.objectives.size() == 0){
            return false;
        }else{
            return true;
        }
    }

    public String ppString(){
        return toString(",");
    }

    public abstract String toString(String delimiter);
}
