function j = get_jess_engine2(in)
persistent j1 j2

params = get_params();
if in == 1
    if isempty(j1)
        [j1,~] = RBES_Init_WithRules(params);
    end
    j = j1;
elseif in == 2
    if isempty(j2)
        [j2,~] = RBES_Init_WithRules(params);
    end
    j = j2;
end
return