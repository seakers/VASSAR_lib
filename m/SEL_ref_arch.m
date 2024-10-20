function [arch,ref] = SEL_ref_arch(varargin)
%% SEL_ref_arch.m
global params

ref_sel_arch = RBES_get_parameter('ref_sel_arch');
arch = ref_sel_arch.arch;
ref.arch = params.ref_sel_arch.arch;

if ~isfield(params.ref_sel_arch,'science') || nargin>0
    disp('Evaluating reference architecture...');
    resu = SEL_evaluate_architecture3(ref.arch);
    
    % risk
    trls = params.instrument_trls;
    risk = sum(trls<5)/length(trls);
    fprintf('Science = %f, Cost = %f, Risk = %f\n',resu.science,resu.cost,risk);
    ref.science = resu.science;
    ref.cost = resu.cost;
    ref.programmatic_risk = risk;% rik of schedule slippage, risk of launch failure
    RBES_set_parameter('ref_sel_arch',ref);
else
    ref = params.ref_sel_arch;
end