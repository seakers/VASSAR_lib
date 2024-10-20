function pareto_rankings = RBES_compute_pareto_rankings(varargin)
%% RBES_compute_pareto_rankings.m
% 
% Usage: pareto_rankings = RBES_compute_pareto_rankings(values)
values = varargin{1};
if nargin > 1
    maxParetoMembership = varargin{2};
else
    maxParetoMembership = 3;
end
PLOT = false;
n_points = size(values,1);
fuzzy_PF = false(n_points,1);
pareto_rankings = (1+maxParetoMembership).*ones(n_points,1);%init to 1+maxParetoMembership, means anyting > maxParetoMembership
metrics = values;
metrics(:,3) = [1:n_points]';
if PLOT
    plot(-metrics(:,1),metrics(:,2),'kx');
    hold on;
    f2 = figure;
    plot(-values(:,1),values(:,2),'bx');
    hold on;
    colors = {'bo','ro','ko','go','mo'};
end
for i = 1:maxParetoMembership
    front = paretofront(metrics(:,1:2));% calculate local pareto front
    if PLOT
        plot(-metrics(front,1),metrics(front,2),colors{i});
        fuzzy_PF(metrics(front,3)) = true;
    end
    
    pareto_rankings(metrics(front,3)) = i;
    metrics(front,:) = [];% remove these points
end
if PLOT
    S = -values(:,1);
    E = values(:,2);
    tmp = false(n_points,1);
    indexes = find(fuzzy_PF);
    for j = 1:length(indexes)
        tmp = or(tmp,and(S>=S(indexes(j)),E<=E(indexes(j))));

    end
    fuzzy_PF = tmp;
    plot(-values(fuzzy_PF,1),values(fuzzy_PF,2),'ro');
end
end