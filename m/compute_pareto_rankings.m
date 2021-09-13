function pareto_rankings = compute_pareto_rankings(values,maxParetoMembership)
%% compute_pareto_rankings.m
% pareto_rankings = compute_pareto_rankings(values,maxParetoMembership)
% values is a npoints x nmetrics array where each metric needs to be
% minimized (put minus signs accordingly)
%
% Usage (assuming sciences and costs are column vectors of equal length):
% maxParetoMembership = 5;
% pareto_rankings = compute_pareto_rankings([-sciences costs],maxParetoMembership)
%

n_points = size(values,1);
pareto_rankings = (1+maxParetoMembership).*ones(n_points,1);%init to 1+maxParetoMembership, means anyting > maxParetoMembership
metrics = values;
metrics(:,3) = [1:n_points]';% this is just an index used for 
figure;
plot(-values(:,1),values(:,2),'bx');
hold on;
colors = {'bo','ro','ko','go','mo'};
for i = 1:maxParetoMembership
    front = paretofront(metrics(:,1:2));% calculate local pareto front
    plot(-metrics(front,1),metrics(front,2),colors{i});
    pareto_rankings(metrics(front,3)) = i;
    metrics(front,:) = [];% remove these points
end

end