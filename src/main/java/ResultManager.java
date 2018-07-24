package rbsa.eoss;

/**
 *
 * @author Marc
 */

import rbsa.eoss.local.Params;

import java.io.*;
import java.util.HashMap;

public class ResultManager {
    
    private static ResultManager instance;

    public static ResultManager getInstance() {
        if(instance == null) {
            instance = new ResultManager();
        }
        return instance;
    }

    private HashMap<String, ResultCollection> results;
    
    private ResultManager() {
        results = new HashMap<>();
    }

    public void saveResultCollection(ResultCollection c) {
        results.put(c.getName(), c);
        try {
            FileOutputStream file = new FileOutputStream(c.getFilePath());
            ObjectOutputStream os = new ObjectOutputStream(file);
            os.writeObject(c);
            os.close();
            file.close();
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
            e.printStackTrace();
        }
    }
    
    public ResultCollection loadResultCollectionFromFile(String filePath) {
        ResultCollection res;
        try {
            FileInputStream file = new FileInputStream(filePath);
            ObjectInputStream is = new ObjectInputStream(file);
            res = (ResultCollection)is.readObject();
            is.close();
            file.close();
            results.put(res.getStamp(), res);
            return res;
        }
        catch (Exception e) {
            System.out.println("The result collection is not found");
            System.out.println(e.getMessage());
            return null;
        }
    }
}

