function [AE, params] = Nozomi_init(folder)
    cd(folder);
    javaaddpath(['.',filesep,'java',filesep,'jess.jar']);
    javaaddpath(['.',filesep,'java',filesep,'jxl.jar']);
    javaaddpath(['.',filesep,'java',filesep,'combinatoricslib-2.0.jar']);
    javaaddpath(['.',filesep,'java',filesep,'commons-lang3-3.1.jar']);
    javaaddpath(['.',filesep,'java',filesep,'matlabcontrol-4.0.0.jar']);
    javaaddpath(['.',filesep,'java',filesep,'EON_PATH.jar']);
    import rbsa.eoss.*
    import rbsa.eoss.local.*
    import java.io.*;
    params =  rbsa.eoss.local.Params(folder,'CRISP-ATTRIBUTES','test','normal','');
    AE =  rbsa.eoss.ArchitectureEvaluator.getInstance;
end
