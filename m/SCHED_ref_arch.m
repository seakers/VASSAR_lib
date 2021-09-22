function ref = SCHED_ref_arch(varargin)
global params
ref.arch = params.ref_sched_arch.arch;
if isjava(params.SCHEDULING_MissionScores) && params.SCHEDULING_MissionScores.size == 0
    disp('Computing mission scores...');
    SCHED_compute_mission_scores;
end
if ~isfield(params.ref_sched_arch,'discounted_value') || nargin>0
    disp('Evaluating reference architecture...');
    resu = SCHED_evaluate_architecture3(ref.arch);
    fprintf('DV = %f, DC= %f\n',resu.discounted_value,resu.data_continuity_score);
    ref.discounted_value = resu.discounted_value;
    ref.data_continuity = resu.data_continuity_score;
    ref.programmatic_risk = 0;
    ref.fairness = SCHED_compute_fairness(ref.arch);
    RBES_set_parameter('ref_sched_arch',ref);
else
    ref = params.ref_sched_arch;
end

end