package rbsa.eoss.local.test.search;


import java.util.ArrayList;
import java.util.List;

public class Utils {

    public static boolean dominates(List<Double> objectives1, List<Double> objectives2){

        // Assumes Smaller-is-better
        boolean at_least_as_good_as = true;
        boolean better_than_in_one = false;

        for(int i = 0; i < objectives1.size(); i++){

            if(objectives1.get(i) < objectives2.get(i)){
                // First better than Second
                better_than_in_one=true;

            }else if(objectives1.get(i) <= objectives2.get(i)){
                // First is worse than Second
                at_least_as_good_as = false;
            }
        }

        return at_least_as_good_as && better_than_in_one; // First dominates Second
    }

    public static boolean dominates(double[] objectives1, double[] objectives2){

        // Assumes Smaller-is-better
        boolean at_least_as_good_as = true;
        boolean better_than_in_one = false;

        for(int i = 0; i < objectives1.length; i++){

            if(objectives1[i] < objectives2[i]){
                // First better than Second
                better_than_in_one=true;

            }else if(objectives1[i] <= objectives2[i]){
                // First is worse than Second
                at_least_as_good_as = false;
            }
        }

        return at_least_as_good_as && better_than_in_one; // First dominates Second
    }
}
