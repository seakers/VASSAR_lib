function eoss_java_init()
%imports the jar file so that EOSS class can be accessed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Add the java class path for EOSS orekit jar file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
jarFile1 = ['.',filesep,'dist',filesep,'EOSS.jar'];
jarFile2 = ['.',filesep,'dist',filesep,'lib',filesep,'mopAOS.jar'];
tmp = javaclasspath;
javaclasspathadded1 = false;
javaclasspathadded2 = false;

%search through current dynamics paths to see if jar file is already in
%dynamic path (could occur if scenario_builder script throws an error
%before the path is removed at the end)
for i=1:length(tmp)
    if ~isempty(strfind(tmp{i},jarFile1))
        javaclasspathadded1 = true;
    end
    if ~isempty(strfind(tmp{i},jarFile2))
        javaclasspathadded2 = true;
    end
end

if ~javaclasspathadded1
    javaaddpath(['.',filesep,'dist',filesep,'EOSS.jar']);
end
if ~javaclasspathadded2
    javaaddpath(['.',filesep,'dist',filesep,'lib',filesep,'mopAOS.jar']);
end