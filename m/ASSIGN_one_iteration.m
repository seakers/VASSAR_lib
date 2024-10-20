%% ASSIGN_one_iteration.m
function [these_results,archs] = ASSIGN_one_iteration()
TEST = 1;

%% SEARCH
disp('Search...');
% select architectures to mutate or improve
ASSIGN_choose_archs_for_local_search;
jess focus SEARCH-HEURISTICS;
jess run;

if ~TEST
%     NRANDOM = 50;
    NRANDOM = 10;
    ASSIGN_assert_random_archs(NRANDOM);
end

%% FILTER
disp('Filter...');
ASSIGN_hard_constraints;
jess focus HARD-CONSTRAINTS;
jess run;

%% EVALUATION
disp('Evaluate...');
options.values = [];
jess unwatch all;
[archs,~,~] = RBES_retrieve_architectures('assigning',options);
results = ASSIGN_evaluate_architectures(archs);
% results.instrument_orbits = orbits;
if ~TEST
    save_results(results,archs,'assigning','bef_downsel');
end

%% DOWN-SELECTION
jess reset;
ASSIGN_down_selection_constraints;
RBES_assert_architectures('assigning',archs,results);
jess focus DOWN-SELECTION;
jess run;

if ~TEST
    % retrieve remaining architectures
    options.values = {'science','cost','utility','pareto-ranking'};
    [archs,values,orbits] = RBES_retrieve_architectures('assigning',options);% values(i,j) contaisn metric j for arch i
    these_results.sciences = values(:,1);
    these_results.costs = values(:,2);
    these_results.utilities = values(:,3);
    these_results.pareto_rankings = values(:,4);
%     these_results.programmatic_risks = values(:,5);
%     these_results.launch_risks = values(:,6);
%     these_results.data_continuities = values(:,7);
%     these_results.instrument_orbits = orbits;

    save_results(these_results,archs,'assigning','aft_select');
else
    these_results = results;
end

end