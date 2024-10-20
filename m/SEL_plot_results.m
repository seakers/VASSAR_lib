function SEL_plot_results(results,archs,i)
global params
PLOT_REF = true;
UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');

sciences = results.sciences;
costs = results.costs;
programmatic_risks = results.programmatic_risks;
fairness = results.fairness;

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
f = figure;
ax = axes('Parent',f);
pl = plot(sciences,costs,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,fairness,[],params});
hold on;
tmp = params.ref_sel_arch;
if ~isfield(tmp,'science')
    disp('Evaluating reference architecture...');
    resu = SEL_evaluate_architecture3(logical(SEL_ref_arch()));
    fprintf('Science = %f, Cost = %f\n',resu.science,resu.cost);
    ref_sel_arch.science = resu.science;
    if strcmp(params.CASE_STUDY,'IRIDIUM')
        NR = [1000 0 8000 1000 0 1000 8000 5000];
        RC = [110 85 100 100 60 100 100 100];
        cost_vec = NR + 66.*RC;
        ref_sel_arch.cost = cost_vec*[1 1 1 1 1 0 0 0]'/1000;
    else
        ref_sel_arch.cost = resu.cost;
    end
    
    ref_sel_arch.arch = logical(SEL_ref_arch());
    RBES_set_parameter('ref_sel_arch',ref_sel_arch);
end
if PLOT_REF
    ref = plot(params.ref_sel_arch.science,params.ref_sel_arch.cost,'rs','MarkerSize', 9,'MarkerFaceColor','r','Parent',ax);
end
grid on;
xlabel('Normalized Science');
ylabel('Lifecycle cost (FY00$M)');
title(['Results for generation ' num2str(i)]);

%% Utility lines
% umin = min(utilities);
% umax = max(utilities);
% u1 = u_to_mag(1/4,umin,umax);
% u2 = u_to_mag(1/2,umin,umax);
% u3 = u_to_mag(3/4,umin,umax);
% 
% weight_cost = params.WEIGHTS(2);
% [x1,y1] = iso_utility_line(u1,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
% line(x1,y1,'LineStyle','--','Color',[1 0 0]);
% [x2,y2] = iso_utility_line(u2,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
% line(x2,y2,'LineStyle','--','Color',[0 1 0]);
% [x3,y3] = iso_utility_line(u3,weight_cost,min(sciences),max(sciences),min(costs),max(costs));
% line(x3,y3,'LineStyle','--','Color',[0 0 1]);
% l1 = ['u25=' num2str(1/100*round(100*u1))];
% l2 = ['u50=' num2str(1/100*round(100*u2))];
% l3 = ['u75=' num2str(1/100*round(100*u3))];
% 
% leg = legend({'Selected alternative architectures','Reference architecture',l1,l2,l3});

if PLOT_REF 
    leg = legend({'Selected alternative architectures','Reference architecture'});
else
%     leg = legend({'Selected alternative architectures'});
end
set(leg,'Location','NorthWest');

savepath = [params.path_save_results 'selection\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'science-vs-cost-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);
end

% function test_plot(src,eventdata,archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,fairness,params)
%     mouse = get(gca, 'CurrentPoint');
%     xmouse = mouse(1,1);
%     ymouse = mouse(1,2);
%     [val, i] = min(abs(sciences - xmouse).^2+abs(costs - ymouse).^2);
%     xpoint   = sciences(i);
%     ypoint   = costs(i);
%     arch = archs(i,:);
%     
%     fprintf('Arch = %d, utility = %f, Science = %f, Cost = %f, #instruments = %d\n',i,utilities(i),sciences(i),costs(i),sum(archs(i,:)));
%     fprintf('Pareto rank = %d, risk = %f, fairness = %f\n',pareto_ranks(i),programmatic_risks(i),fairness(i));
% 
%     arr = params.instrument_list(logical(archs(i,:)));
%     str = StringArraytoStringWithSpaces(arr);
%     fprintf('Payload = %s\n',str);
% end

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
