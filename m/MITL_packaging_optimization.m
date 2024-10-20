%% MITL_packaging_optimization.m

%% Initialization

RBES_Init_Params_EOS;

[r,params]  = RBES_Init_WithRules(params);
instr       = params.packaging_instrument_list;
ninstr      = length(instr);

%% Configure GA

%% Loop
stop = false;
while(~stop)
    %% Run N generations of the GA
    
    %% Check if we want to stop
    fid = fopen('control_matlab.txt','r');
    s = fscanf(fid,'%s\n');
    if strcmp(s(end-3:end),'stop')
        save;
        stop = true;
    end
end