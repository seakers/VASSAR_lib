function RBES_filter_db_pack(params)
%% prepare for filtering
db_pack = get_db_pack();% retrieve db
[sciences,costs,utilities,archs] = get_metrics_from_db_pack(db_pack);% retrieve arrays for filtering

% filter out architectures that:
% have cost greather than params.MAX_COST
ind2remove = (costs > params.MAX_COST);
sciences(ind2remove) = [];
costs(ind2remove) = [];
utilities(ind2remove) = [];
archs(ind2remove) = [];

% have science less than params.MIN_SCIENCE
ind2remove = (sciences < params.MIN_SCIENCE);
sciences(ind2remove) = [];
costs(ind2remove) = [];
utilities(ind2remove) = [];
archs(ind2remove) = [];

% have utility less than params.MIN_UTILITY when params.WEIGHTS are used
ind2remove = (utilities < params.MIN_UTILITY);
sciences(ind2remove) = [];
costs(ind2remove) = [];
utilities(ind2remove) = [];
archs(ind2remove) = [];

% have a Pareto rank greater than params.MAX_PARETO_RANK
fuzzy_PF = FuzzyParetoFront([-sciences' costs'],params.MAX_PARETO_RANK);
ind2remove = ~fuzzy_PF;
sciences(ind2remove) = [];
utilities(ind2remove) = [];
costs(ind2remove) = [];
archs(ind2remove) = [];
    
% update db_pack
db_pack.clear;
for i = 1:length(archs)
    metrics = java.util.ArrayList;
    metrics.add(sciences(i));
    metrics.add(costs(i));
    metrics.add(utilities(i));
    db_pack.put(archs{i},metrics);
end
end
