function merged_results = SEL_merge_results(results_to_merge)
%% SEL_merge_results.m
%
% Usage:
% cell_results{1} = results1;
% cell_results{2} = results2;
% cell_results{3} = results3;
% merged_results = SEL_merge_results(cell_results);

merged_sciences = results_to_merge{1}.sciences;
merged_costs = results_to_merge{1}.costs;
merged_archs = results_to_merge{1}.archs;
% merged_utilities = results_to_merge{1}.utilities;
% merged_pareto_rankings = results_to_merge{1}.pareto_rankings;

for i = 2:length(results_to_merge)
    these_results = results_to_merge{i};   
    merged_sciences = [merged_sciences;these_results.sciences];
    merged_costs = [merged_costs;these_results.costs];
    merged_archs = [merged_archs;these_results.archs];
%     merged_utilities = [merged_utilities;these_results.utilities];
%     merged_pareto_rankings = [merged_pareto_rankings; these_results.pareto_rankings];
end
merged_results.sciences = merged_sciences;
merged_results.costs = merged_costs;
merged_results.archs = merged_archs;

merged_results.utilities = RBES_compute_utilities(merged_sciences,merged_costs);
merged_results.pareto_rankings = RBES_compute_pareto_rankings([-merged_sciences merged_costs]);
end

