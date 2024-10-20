function [these_results,archs] = SEL_one_iteration()
TEST = 0;

%% SEARCH
% select architectures to mutate or improve
disp('Search...');
SEL_choose_archs_for_local_search;
jess focus SEARCH-HEURISTICS;
jess run;
if ~TEST
    SEL_assert_random_archs(200);
end

%% FILTER
disp('Filter...');
% SEL_EOS_hard_constraints;
SEL_Decadal_hard_constraints;
jess focus HARD-CONSTRAINTS;
jess run;

%% EVALUATION
disp('Evaluate...');
[archs,results] = SEL_evaluate_architectures;% archs are the binary arrays
if ~TEST
    save_results(results,archs,'selection','bef_downsel');
end

%% DOWN-SELECTION
disp('Down-select...');

jess reset;
% SEL_EOS_down_selection_constraints;
SEL_Decadal_down_selection_constraints;
RBES_assert_architectures('selection',archs,results);
jess focus DOWN-SELECTION;
jess run;

%% SAVE
if ~TEST
    % retrieve remaining architectures
    options.values = {'science','cost','utility','pareto-ranking','programmatic-risk','fairness'};
    [archs,values] = RBES_retrieve_architectures('selection',options);% values(i,j) contaisn metric j for arch i
    these_results.sciences = values(:,1);
    these_results.costs = values(:,2);
    these_results.utilities = values(:,3);
    these_results.pareto_rankings = values(:,4);
    these_results.programmatic_risks = values(:,5);
    these_results.fairness = values(:,6);
    save_results(these_results,archs,'selection','aft_select');
end

end