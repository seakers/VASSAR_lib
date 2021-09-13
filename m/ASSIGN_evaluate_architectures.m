function results = ASSIGN_evaluate_architectures(archs)
global params
narc = size(archs,1);
for i = 1:narc
    fprintf('Evaluating arch %d of %d...\n',i,narc);
    res = ASSIGN_evaluate_architecture(archs(i,:));
    results.sciences(i) = res.science;
    results.costs(i) = res.cost;
%     results.data_continuities(i) = res.data_continuity;
%     results.programmatic_risks(i) = PACK_compute_programmatic_risk(archs(i,:));% rik of schedule slippage, risk of launch failure
%     results.launch_risks(i) = 1 - PACK_entropy(archs(i,:));
%     results.instrument_orbits{i} = res.orbits;
%     results.lv_pack_factors{i} = res.lv_pack_factors;
    fprintf('Arch %d of %d: science = %f, cost = %f\n',i,narc,res.science,res.cost);
end
% save last_results results archs;

results.sciences = results.sciences';
results.costs = results.costs';
% results.programmatic_risks = results.programmatic_risks';
% results.launch_risks = results.launch_risks';
% ref = ASSIGN_ref_arch();
% if ref.data_continuity>0
%     
%     results.data_continuities = results.data_continuities'./ref.data_continuity;
% else
%     results.data_continuities = 0;
% end
% Compute utilities

% if params.DATA_CONTINUITY == 1
%     results.utilities = RBES_compute_utilities3(results,{'sciences','costs','programmatic_risks','launch_risks','data_continuities'},{'LIB','SIB','SIB','SIB','LIB'},[0.5 0.35 0.05 0.05 0.05]);
% else
%     results.utilities = RBES_compute_utilities3(results,{'sciences','costs','programmatic_risks','launch_risks'},{'LIB','SIB','SIB','SIB'},[0.5 0.35 0.075 0.075]);
% end
results.utilities = RBES_compute_utilities3(results,params.utility_metrics_names,params.utility_metrics_types,params.utility_metrics_weights);

% Compute Pareto rankings
if isrow(results.sciences)
    results.pareto_rankings = RBES_compute_pareto_rankings([-results.sciences' results.costs'],params.MAX_PARETO_RANKING);
else 
    results.pareto_rankings = RBES_compute_pareto_rankings([-results.sciences results.costs],params.MAX_PARETO_RANKING);
end

end