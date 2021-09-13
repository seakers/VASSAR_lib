%% IEEE_KISA_init.m
function IEEE_KISA_init(folder)
    global params AE AG r 
    import rbsa.eoss.*;
    import rbsa.eoss.local.*;
    import java.io.*;
    r = global_jess_engine;
    params = Params(folder,'CRISP-ATTRIBUTES','test','normal','');
    AE = ArchitectureEvaluator.getInstance;
    AE.init(1);
    AG = ArchitectureGenerator.getInstance;

end