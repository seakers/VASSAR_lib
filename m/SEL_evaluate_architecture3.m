function results = SEL_evaluate_architecture3(arch)
%% SEL_evaluate_architecture3.m
% This function asserts missions corresponding to the selection
% architecture given in the input, and then evaluates them
% arch = [1 1 0 0 0 1 0 1 0 0] where 1 means that instrument i flies
% all instruments are considered flown separately

global params
% NR = [1000 0 8000 1000 0 1000 8000 5000];
% RC = [110 85 100 100 60 100 100 100];
NR = [1000 0 8000 1000 0 1000 8000 5000 0];
RC = [110 85 100 100 60 100 100 100 60];
cost_vec = NR + 66.*RC;

if strcmp(params.CASE_STUDY,'IRIDIUM')
    orbit = get_Iridium_orbit();
else
    orbit = [];
end
all = params.instrument_list;
list = all(logical(arch));
mission = create_test_mission('test',list,params.startdate,params.lifetime,orbit);


% fprintf('Evaluating arch %s\n',SEL_arch_to_str(arch));
[results.science,results.panel_scores,~,~,~,~,cos] = RBES_Evaluate_Mission(mission);
if strcmp(params.CASE_STUDY,'IRIDIUM')
        results.cost = cost_vec*arch'/1000;
else
        results.cost = cos;
end
% fprintf('Science = %f, Cost = %f\n',results.science,results.cost);
end