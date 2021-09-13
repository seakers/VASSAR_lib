%% PACK_one_iteration.m
function [these_results,archs] = PACK_one_iteration()
TEST = 0;

%% SEARCH
disp('Search...');
% select architectures to mutate or improve
PACK_choose_archs_for_local_search;
jess focus SEARCH-HEURISTICS;
jess run;

if ~TEST
%     NRANDOM = 50;
    NRANDOM = 50;
    PACK_assert_random_archs(NRANDOM);
end

%% FILTER
disp('Filter...');
PACK_hard_constraints;
jess focus HARD-CONSTRAINTS;
jess run;

%% EVALUATION
disp('Evaluate...');
options.values = [];
jess unwatch all;
[archs,~,~] = RBES_retrieve_architectures('packaging',options);
results = PACK_evaluate_architectures(archs);
% results.instrument_orbits = orbits;
if ~TEST
    save_results(results,archs,'packaging','bef_downsel');
end
% 
% %% FILTER 2
% disp('Filter again for orbit constraints...');
% PACK_EOS_hard_constraints;
% jess focus HARD-CONSTRAINTS;
% jess run;

%% DOWN-SELECTION
% 
jess reset;
% PACK_EOS_down_selection_constraints;
PACK_down_selection_constraints;
RBES_assert_architectures('packaging',archs,results);
jess focus DOWN-SELECTION;
jess run;

if ~TEST
    % retrieve remaining architectures
    options.values = {'science','cost','utility','pareto-ranking','programmatic-risk','launch-risk','data-continuity'};
    [archs,values,orbits] = RBES_retrieve_architectures('packaging',options);% values(i,j) contaisn metric j for arch i
    these_results.sciences = values(:,1);
    these_results.costs = values(:,2);
    these_results.utilities = values(:,3);
    these_results.pareto_rankings = values(:,4);
    these_results.programmatic_risks = values(:,5);
    these_results.launch_risks = values(:,6);
    these_results.data_continuities = values(:,7);
    these_results.instrument_orbits = orbits;

    save_results(these_results,archs,'packaging','aft_select');
else
    these_results = results;
end

end