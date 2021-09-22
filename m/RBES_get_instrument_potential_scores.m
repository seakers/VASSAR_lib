%% RBES_get_instrument_potential_scores.m
these_params = RBES_get_global_params();
instrs = these_params.instrument_list;
n = length(instrs);
scores = zeros(n,1);
for i = 1:n
    names = these_params.instruments_to_subobjectives.get(instrs{i});
    scores(i) = RBES_get_potential_score(names);
end