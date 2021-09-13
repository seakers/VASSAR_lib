function results = SCHED_evaluate_architectures(archs)
% global params
narc = size(archs,1);
if narc == 0
    error('No architectures left.\n');
end
for i = 1:narc
    fprintf('Evaluating arch %d of %d...\n',i,narc);
    res = SCHED_evaluate_architecture3(archs(i,:));
%     results.sciences(i) = res.science;
%     results.costs(i) = res.cost;
%     results.programmatic_risks(i) = SCHED_compute_programmatic_risk(archs(i,:));
    results.programmatic_risks(i) = 0; %not needed in schedule
%     results.fairness(i) = res.fairness;
    results.data_continuities(i) = res.data_continuity_score;
    results.discounted_values(i) = res.discounted_value;
    results.overall_dcmatrix{i} = res.overall_dcmatrix;
    results.launch_dates(i,:) = res.launch_dates;
    fprintf('Arch %d of %d: DV = %f, DC= %f\n',i,narc,res.discounted_value,res.data_continuity_score);
end

% Compute fairness
results.fairness = SCHED_compute_fairness(archs);

% Compute utilities
results.utilities = RBES_compute_utilities3(results,{'discounted_values','data_continuities','fairness'},{'LIB','LIB','SIB'},[0.15 0.7 0.15]);

% Compute Pareto rankings
results.pareto_rankings = RBES_compute_pareto_rankings([-results.discounted_values' -results.data_continuities']);



end