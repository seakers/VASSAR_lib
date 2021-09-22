function [results,iso_archs] = PACK_plot_cost_risk_space(results,archs,i)
global params
UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');
DC =isfield(results,'data_continuities') && length(results.data_continuities)>1;

sciences = results.sciences;
indexes = sciences > 0.38;
sciences =sciences(indexes);
costs = results.costs(indexes);
programmatic_risks = results.programmatic_risks(indexes);
launch_risks = results.launch_risks(indexes);
risks = 0.5*(launch_risks + programmatic_risks);

if DC
    data_continuities = results.data_continuities(indexes);
else
    data_continuities = [];
end

if UTILITIES
    utilities = results.utilities(indexes);
else
    utilities = [];
end

if PARETO
    pareto_ranks = results.pareto_rankings(indexes);
else
    pareto_ranks = [];
end
%% Iso results
iso_results.sciences = sciences;
iso_results.costs = costs;
iso_results.programmatic_risks = programmatic_risks;
iso_results.launch_risks = launch_risks;
iso_results.risks = risks;
iso_results.science_pareto_rankings = pareto_ranks;
iso_results.pareto_rankings = RBES_compute_pareto_rankings([iso_results.costs iso_results.risks],5);
front = iso_results.pareto_rankings < 4;
front_science = iso_results.science_pareto_rankings < 4;

iso_results.utilities = RBES_compute_utilities3(iso_results,{'costs','programmatic_risks','launch_risks'},{'SIB','SIB','SIB'},[0.7 0.15 0.15]);
iso_archs = archs(indexes,:);

%% Plotss

% utilities = results.utilities;
% pareto_ranks = results.pareto_ranks;
f = figure;
ax = axes('Parent',f);
% fr = plot(costs(front),risks(front),'Marker','o','Parent',ax,'MarkerSize', 10, 'MarkerEdgeColor','g', 'MarkerFaceColor','g','LineStyle','None', ...
%     'ButtonDownFcn', {@PACK_mouseclick_cost_risk,iso_archs,sciences(front),costs(front),utilities(front),pareto_ranks(front),programmatic_risks(front),launch_risks(front),data_continuities(front),params});
fr = plot(costs(front),risks(front),'Marker','o','Parent',ax,'MarkerSize', 12, 'MarkerEdgeColor','g', 'MarkerFaceColor','g','LineStyle','None', ...
    'ButtonDownFcn', {@PACK_mouseclick_cost_risk,iso_archs(front,:),sciences(front),costs(front),utilities(front),pareto_ranks(front),programmatic_risks(front),launch_risks(front),[],params});
hold on;

% fr = plot(costs(front_science),risks(front_science),'Marker','o','Parent',ax,'MarkerSize', 10, 'MarkerEdgeColor','k', 'MarkerFaceColor','k','LineStyle','None', ...
%     'ButtonDownFcn', {@PACK_mouseclick_cost_risk,iso_archs(front_science,:),sciences(front_science),costs(front_science),utilities(front_science),pareto_ranks(front_science),programmatic_risks(front_science),launch_risks(front_science),[],params});

% pl = plot(costs,risks,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
%     'ButtonDownFcn', {@PACK_mouseclick_cost_risk,iso_archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,launch_risks,data_continuities,params});

pl = plot(costs,risks,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@PACK_mouseclick_cost_risk,iso_archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,launch_risks,[],params});

% params.ref_pack_arch_struct.science = 0.7731;% Jan 10 2012
% params.ref_pack_arch_struct.cost = 3846.4;% Jan 10 2012
% params.ref_pack_arch_struct.arch  = params.ref_pack_arch;
% PACK_ref_arch;
ref = plot(params.ref_pack_arch.cost,0.2875,'rs','MarkerSize', 10,'MarkerFaceColor','r','Parent',ax);
utopia = plot(min(costs),min(risks),'yp','MarkerSize', 10,'MarkerFaceColor','y','Parent',ax);

grid on;
xlabel('Lifecycle cost (FY00$M)');
ylabel('Normalized Risk');
title(['Results for generation ' num2str(i)]);

%% Utility lines
UTIL_LINES = 0;
if UTIL_LINES
    umin = min(utilities);
    umax = max(utilities);
    u1 = u_to_mag(1/4,umin,umax);
    u2 = u_to_mag(1/2,umin,umax);
    u3 = u_to_mag(3/4,umin,umax);

    weight_cost = params.WEIGHTS(2);
    [x1,y1] = iso_utility_line(u1,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
    line(x1,y1,'LineStyle','--','Color',[1 0 0]);
    [x2,y2] = iso_utility_line(u2,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
    line(x2,y2,'LineStyle','--','Color',[0 1 0]);
    [x3,y3] = iso_utility_line(u3,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
    line(x3,y3,'LineStyle','--','Color',[0 0 1]);
    l1 = ['u25=' num2str(1/100*round(100*u1))];
    l2 = ['u50=' num2str(1/100*round(100*u2))];
    l3 = ['u75=' num2str(1/100*round(100*u3))];
    leg = legend({'Selected alternative architectures','Reference architecture',l1,l2,l3});
else
    leg = legend({'Fuzzy Pareto front cost-risk','Archs. with top 10% science score','Reference architecture','Utopia point'});
end

set(leg,'Location','SouthEast');

savepath = [params.path_save_results 'packaging\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'PACK--cost-vs-risk-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);
end

function mag = u_to_mag(u,mi,ma)
% in u = magn - magn_min / magn_max - magn_min returns magn from u
mag = mi + u*(ma - mi);
end

function [x,y] = iso_utility_line(u0,w_cost,scmin,scmax,cmin,cmax)
% returns the two vectors [x1 x2] [y1 y2] such that the line that passess
% through (x1,y1) and (x2,y2) is the iso-utility u0
usc1 = u0*(1+w_cost) - w_cost;
x1 = u_to_mag(usc1,scmin,scmax);
y1 = cmin;

auco2 = 1 - (u0*(w_cost + 1) - 1)/w_cost;
y2 = u_to_mag(auco2,cmin,cmax);
x2 = scmax;

x = [x1 x2];
y = [y1 y2];
end
