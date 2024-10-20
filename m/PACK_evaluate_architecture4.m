function results = PACK_evaluate_architecture4(arch)
%% PACK_evaluate_architecture4.m
global params
r = global_jess_engine();

% This function asserts missions corresponding to the packaging
% architecture given in the input, and then evaluates them

instr_list = params.packaging_instrument_list;

% Clear expl facility
clear explanation_facility

% reset rules engine and asserts deffacts (DATABASE)
r.reset;


%% Assert one Mission per satellite
% pack = arch;
% pack = arch;

ns = max(arch); % number of satellites
% params.NumberOfMissions = ns;
for s = 1:ns
    inds = find(arch == s);% Find instrument ids that fly on satellite s
    sat_instrs = [];
    for i = 1:length(inds)
        sat_instrs = [sat_instrs ' ' instr_list{inds(i)}];% add name of instrument to satellite list
    end
    sat_name = [char(params.satellite_names)  num2str(s)];
    call = ['(assert (MANIFEST::Mission (Name ' sat_name ')' ...
            ' (instruments ' sat_instrs ')' ...
            ' (lifetime ' num2str(params.lifetime) ')' ...
            ' (launch-date 2015)' ...
            ' (select-orbit yes)' ...
            '))'];
        
    r.eval(call);
end
%% Eval manifest
res = RBES_Evaluate_Manifest;
results.science = res.score;
results.cost = res.cost;
% nsat = results.nsat;


end