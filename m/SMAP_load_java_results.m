function SMAP_load_java_results(file)
%     RBES_f('C:\Users\dani\Documents\My Dropbox\RBES SMAP for IEEEAero14');
%     javaaddpath('./java/combinatoricslib-2.0.jar');
%     javaaddpath('./java/RBSA-EOSS-SMAP.jar');
%     javaaddpath('./java/commons-lang3-3.1.jar');
%     import rbsa.eoss.*;
%     import rbsa.eoss.local.*;

%     params = Params('C:\\Users\\Dani\\My Documents\\My Dropbox\\RBES SMAP for IEEEAero14','CRISP-ATTRIBUTES','test','normal');%C:\\Users\\Ana-Dani\\Dropbox\\EOCubesats\\RBES_Cubesats7" OR C:\\Users\\dani\\My Documents\\My Dropbox\\EOCubesats\\RBES_Cubesats7
    RM = ResultManager.getInstance();
    res = RM.loadResultCollectionFromFile(['./results/' file '.rs']);
    stack = res.getResults;
    SMAP_java_plot(stack,0);
end