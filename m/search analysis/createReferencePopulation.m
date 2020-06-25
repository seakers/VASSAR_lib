function createReferencePopulation(filepath, saveFileName)
%this function creates a reference nondominated population from the
%population files resulting from the search.

try
    eoss_java_init();
    origin = cd(filepath);
    files = dir('*all.pop');
    h = waitbar(0, 'Processing populations...');
    refPop = org.moeaframework.core.Population;
    for i=1:length(files)
        refPop.addAll(org.moeaframework.core.PopulationIO.read(java.io.File(files(i).name)));
        waitbar(i/length(files), h);
    end
    
    org.moeaframework.core.PopulationIO.write(java.io.File(strcat(saveFileName,'_all.pop')),refPop);
    org.moeaframework.core.PopulationIO.writeObjectives(java.io.File(strcat(saveFileName,'_all.obj')),refPop);
    
    nobj = refPop.get(0).getNumberOfObjectives;
    objectives = zeros(refPop.size,nobj);
    nfe = zeros(refPop.size,1);
    for i = 0:refPop.size-1
        objectives(i+1,:) = refPop.get(i).getObjectives;
        nfe(i+1) = refPop.get(i).getAttribute('NFE');
    end
    save(strcat(saveFileName,'_all.mat'),'objectives','nfe');
    
catch me
    close(h)
    clear refPop
    error(me.message)
    erorr(e.stack)
    cd(origin)
    eoss_java_end();
end
close(h)
clear refPop
cd(origin)
eoss_java_end();

end