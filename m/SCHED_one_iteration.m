%% SCHED_one_iteration.m
function [these_results,archs] = SCHED_one_iteration()
TEST = RBES_get_parameter('TEST');

%% SEARCH
% select architectures to mutate or improve
SCHED_choose_archs_for_local_search;

% jess watch rules;
disp('Search...');
jess focus SEARCH-HEURISTICS;
jess run;

% assert a few random architectures to complete population (actual # < N because of repetition)
if TEST
    NRANDOM = 100;
else
    NRANDOM = 300;
end

archs = SCHED_generate_random_archs(NRANDOM); 
for i = 1:size(archs,1)
    arch.type = 'scheduling';
    arch.seq = archs(i,:);
    arch.utility = [];
    arch.discounted_value = [];
    arch.data_continuity = [];
    arch.pareto_ranking = [];
    assert_architecture(arch);
end

% vbeg = [13 18 11 17];
% vend = [16 6 5 14];
% NN = RBES_get_parameter('SCHEDULING_num_missions');
% archs = SCHED_generate_random_archs2(NRANDOM/10,NN,vbeg,vend);
% for i = 1:size(archs,1)
%     arch.type = 'scheduling';
%     arch.seq = archs(i,:);
%     arch.utility = [];
%     arch.discounted_value = [];
%     arch.data_continuity = [];
%     arch.pareto_ranking = [];
%     assert_architecture(arch);
% end

%% FILTER
disp('Filter...');
% SCHED_EOS_hard_constraints;
SCHED_Decadal_hard_constraints;
jess focus HARD-CONSTRAINTS;
jess run;

%% EVALUATION
% Evaluate them all
disp('Evaluate...');
options.values = [];
jess unwatch all;
[archs,~] = RBES_retrieve_architectures('scheduling',options);
results = SCHED_evaluate_architectures(archs);
if ~TEST
    SCHED_plot_results(results,archs,0);
    tmp = results;
    results.overall_dcmatrix = [];
    save_results(results,archs,'scheduling','bef_select');
    results = tmp;
end

%% DOWN-SELECTION
disp('Down-select...');
jess reset;
% SCHED_EOS_down_selection_constraints;
SCHED_Decadal_down_selection_constraints
RBES_assert_architectures('scheduling',archs,results);
jess focus DOWN-SELECTION;
jess run;

if ~TEST
    % retrieve remaining architectures
    options.values = {'discounted-value','data-continuity','utility','pareto-ranking','programmatic-risk','fairness'};
    [archs,values] = RBES_retrieve_architectures('scheduling',options);% values(i,j) contaisn metric j for arch i
    these_results.discounted_values = values(:,1);
    these_results.data_continuities = values(:,2);
    these_results.utilities = values(:,3);
    these_results.pareto_rankings = values(:,4);
    these_results.programmatic_risks = values(:,5);
    these_results.fairness = values(:,6); 
    save_results(these_results,archs,'scheduling','aft_select');
else
    these_results = results;
end

end