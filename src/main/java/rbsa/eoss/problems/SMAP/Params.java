package rbsa.eoss.problems.SMAP;

import rbsa.eoss.local.BaseParams;

public class Params extends BaseParams {

    private static Params instance;

    public static Params initInstance(String p, String mode, String name, String runMode, String searchClp) {
        instance = new Params(p, mode, name, runMode, searchClp);
        return instance;
    }

    public static Params newInstance(String p, String mode, String name, String runMode, String searchClp) {
        instance = new Params(p, mode, name, runMode, searchClp);
        return instance;
    }

    public static Params getInstance() {
        return instance;
    }

    private Params(String path, String mode, String name, String runMode, String search_clp){
        super(path, mode, name, runMode, search_clp);
    }
}
