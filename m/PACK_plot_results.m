function PACK_plot_results(results,archs,i)
global params
UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');
DC =isfield(results,'data_continuities');

sciences = results.sciences;
costs = results.costs;
programmatic_risks = results.programmatic_risks;
launch_risks = results.launch_risks;
if DC
    data_continuities = results.data_continuities;
else
    data_continuities = [];
end

if UTILITIES
    utilities = results.utilities;
else
    utilities = [];
end

if PARETO
    pareto_ranks = results.pareto_rankings;
else
    pareto_ranks = [];
end


% utilities = results.utilities;
% pareto_ranks = results.pareto_ranks;
scrsz = get(0,'ScreenSize');
f = figure('Position',[1 0 0.55*scrsz(3) 0.6*scrsz(4)]);
ax = axes('Parent',f,'FontSize',18);
pl = plot(sciences,costs,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,launch_risks,data_continuities,params});
hold on;


% params.ref_pack_arch.science = 0.8088;% EOS Packaging 27-Apr-2012 7-56 after selection
% params.ref_pack_arch.cost = 2609.5;% 
% standard buses

% params.ref_pack_arch.science = 0.8088;% EOS Packaging 29-Apr-2012 11-19
% params.ref_pack_arch.cost = 2002.5;% Jan 10 2012

params.ref_pack_arch.science = 0.394;% Decadal Packaging 18-Apr-2012 9-11 aft_analysis filtered with fuzzypf only
params.ref_pack_arch.cost = 8250;% 

% params.ref_pack_arch_struct.arch  = params.ref_pack_arch;
% PACK_ref_arch;
ref = plot(params.ref_pack_arch.science,params.ref_pack_arch.cost,'rs','MarkerSize', 10,'MarkerFaceColor','r','Parent',ax);
utopia = plot(max(sciences),min(costs),'yp','MarkerSize', 10,'MarkerFaceColor','y','Parent',ax);
range_x = max(sciences) - min(sciences);
range_y = max([costs;params.ref_pack_arch.cost]) - min([costs;params.ref_pack_arch.cost]);
axis([min(sciences) - 0.1*range_x , max(sciences) + 0.1*range_x , min([costs;params.ref_pack_arch.cost]) - 0.1*range_y, max([costs;params.ref_pack_arch.cost]) + 0.1*range_y]);
grid on;
xlabel('Normalized Science');
ylabel('Lifecycle cost (FY00$M)');
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
    leg = legend({'Selected alternative architectures','Reference architecture','Utopia point'},'Location','NorthWest');
end

% set(leg,'Location','NorthWest');

savepath = [params.path_save_results 'packaging\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'PACK--science-vs-cost-' date '-' hour '-' minu '.emf'];
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
