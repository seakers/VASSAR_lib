function RBES_evaluate_ref_arch(results,archs)
ref = PACK_ref_arch;
[~,results2] = RBES_add_arch(ref,results,archs);
us = RBES_compute_utilities3(results2,{'sciences','costs','programmatic_risks','launch_risks'},{'LIB','SIB','SIB','SIB'},[0.5 0.35 0.1 0.05]);
pr = RBES_compute_pareto_rankings([-results2.sciences results2.costs]);
ref.pareto_ranking = pr(end);
ref.utility = us(end);
RBES_set_parameter('ref_pack_arch',ref);
end