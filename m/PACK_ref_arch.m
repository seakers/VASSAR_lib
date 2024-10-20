function ref = PACK_ref_arch(varargin)
global params
ref.arch = params.ref_pack_arch.arch;

if ~isfield(params.ref_pack_arch,'programmatic_risk') || nargin>0
    disp('Evaluating reference architecture...');
    resu = PACK_evaluate_architecture8(ref.arch);
    fprintf('Science = %f, Cost = %f\n',resu.science,resu.cost);
    ref.science = resu.science;
    ref.cost = resu.cost;
    ref.data_continuity = resu.data_continuity;
    ref.programmatic_risk = PACK_compute_programmatic_risk(ref.arch);% rik of schedule slippage, risk of launch failure
    ref.launch_risk = 1 - PACK_entropy(ref.arch);
    ref.instrument_orbits = resu.orbits;
    ref.lv_pack_factors = resu.lv_pack_factors;
    ref.combined_subobjectives = resu.combined_subobjectives;
    RBES_set_parameter('ref_pack_arch',ref);
else
    ref = params.ref_pack_arch;
end

end