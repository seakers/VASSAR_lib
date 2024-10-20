function [j,params] = get_jess_engine(j)
persistent r

params = get_params();
if strcmp(ctrl,'new')
    clear r;
    [r,params] = RBES_Init_WithRules(params);
    r.reset;
    j = r;
elseif strcmp(ctrl,'clean')
    j = r.clone();
end
end