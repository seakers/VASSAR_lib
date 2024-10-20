function [science,total_cost,nsat] = PACK_evaluate_architecture2(j,arch)
%% PACK_evaluate_architecture2.m
r = get_jess_engine2(j);
params = get_params();

% This function asserts missions corresponding to the packaging
% architecture given in the input, and then evaluates them

instr_list = params.packaging_instrument_list;

% Clear expl facility
% clear explanation_facility

% reset rules engine and asserts deffacts (DATABASE)
r.reset;


%% Assert one Mission per satellite
% pack = arch.packaging;
pack = arch;

ns = max(pack); % number of satellites
params.NumberOfMissions = ns;
for s = 1:ns
    inds = find(pack == s);% Find instrument ids that fly on satellite s
    sat_instrs = [];
    for i = 1:length(inds)
        sat_instrs = [sat_instrs ' ' instr_list{inds(i)}];% add name of instrument to satellite list
    end
    sat_name = [char(params.satellite_names)  num2str(s)];
    call = ['(assert (MANIFEST::Mission (Name ' sat_name ')' ...
            ' (instruments ' sat_instrs ')' ...
            ' (lifetime ' num2str(params.lifetime) ')' ...
            ' (launch-date 2015)' ...
            '))'];
    r.eval(call);
end
%% Eval manifest
results = RBES_Evaluate_Manifest(r,params);
science = results.score;
total_cost = results.cost;
nsat = results.nsat;


end