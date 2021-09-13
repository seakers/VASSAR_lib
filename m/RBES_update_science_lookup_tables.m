%% RBES_update_science_lookup_tables.m
function  [r,params] = RBES_update_science_lookup_tables(r,params)

%% PAIRS
% options.get_results_from = []; % recompute
options.get_results_from = 'EOS_pairwise_results_with_rep_Nov28th2011'; % retrieve from file
options.with_synergies = 1; % 1 = with synergies, 2 = without, 3 = difference (S-DSM)
[r,pair_scores,pair_costs] = SEL_compute_pair_scores(r,params,options);

params.instrument_pairs_costs = java.util.HashMap;
params.instrument_pairs_scores = java.util.HashMap;
for i = 1:length(params.instrument_list)
    params.instrument_pairs_scores.put(params.instrument_list{i},pair_scores(i));
    params.instrument_pairs_costs.put(params.instrument_list{i},pair_costs(i));
end
%% SINGLES
options.get_results_from = []; % retrieve from file
[r,single_scores,single_costs] = SEL_compute_single_scores(r,params,options);
params.instrument_single_scores = java.util.HashMap;
params.instrument_single_costs = java.util.HashMap;
for i = 1:length(params.instrument_list)
    params.instrument_single_scores.put(params.instrument_list{i},single_scores(i));
    params.instrument_single_costs.put(params.instrument_list{i},single_costs(i));
end
end