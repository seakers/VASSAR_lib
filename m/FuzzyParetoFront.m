function fuzzy_PF = FuzzyParetoFront(values,maxParetoMembership)
%% FuzzyParetoFront.m
% Usage: 
% values = [metric1 metric2];% metric1 and metric2 are column arrays
% containing the values of the metrics to be MINIMIZED
%
% maxParetoMembership = 2;% number of times the algorithm is recursively
% run
%
% fuzzy_PF = FuzzyParetoFront(values,maxParetoMembership);
% 
%% Begin
n_points = size(values,1);
% n_metrics = size(values,2);
fuzzy_PF = false(n_points,1);
% front = zeros(n_points,1);
metrics = values;
metrics(:,3) = [1:n_points]';
% f2 = figure;
% plot(-values(:,1),values(:,2),'bx');
% hold on;
for i = 1:maxParetoMembership
    front = paretofront(metrics(:,1:2));% calculate local pareto front
%     plot(-metrics(front,1),metrics(front,2),'ro');
    fuzzy_PF(metrics(front,3)) = true;
    metrics(front,:) = [];
end
S = -values(:,1);
E = values(:,2);
tmp = false(n_points,1);
indexes = find(fuzzy_PF);
for j = 1:length(indexes)
    tmp = or(tmp,and(S>=S(indexes(j)),E<=E(indexes(j))));
    
end
fuzzy_PF = tmp;
% plot(-values(fuzzy_PF,1),values(fuzzy_PF,2),'ro');
return
