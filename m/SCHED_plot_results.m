function SCHED_plot_results(results,archs,i)
global params
UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');

discounted_values = results.discounted_values;
data_continuities = results.data_continuities;
programmatic_risks = results.programmatic_risks;
fairness = results.fairness;

if UTILITIES
    utilities = RBES_compute_utilities3(results,{'discounted_values','data_continuities','fairness'},{'LIB','LIB','SIB'},[0.15 0.7 0.15]);

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
pl = plot(discounted_values,data_continuities,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs,discounted_values,data_continuities,utilities,pareto_ranks,programmatic_risks,fairness,[],params});

hold on;
% params.ref_pack_arch_struct.science = 0.7731;% Jan 10 2012
% params.ref_pack_arch_struct.cost = 3846.4;% Jan 10 2012
% params.ref_pack_arch_struct.arch  = params.ref_pack_arch;
% 
% ref = plot(params.ref_pack_arch_struct.science,params.ref_pack_arch_struct.cost,'r*','MarkerSize', 8,'Parent',ax);
ref = SCHED_ref_arch;
ref2 = plot(1,1,'rs','MarkerSize', 10,'MarkerFaceColor','r','Parent',ax);
% axis([0.96 max(discounted_values) min(data_continuities) max(data_continuities)]);
grid on;
xlabel('Discounted value');
ylabel('Data continuity score');
title(['Results for generation ' num2str(i)]);

%% Utility lines
umin = min(utilities);
umax = max(utilities);
u1 = u_to_mag(1/4,umin,umax);
u2 = u_to_mag(1/2,umin,umax);
u3 = u_to_mag(3/4,umin,umax);

weight_DC = 0.5;
[x1,y1] = iso_utility_line(u1,weight_DC,min(discounted_values),max(discounted_values),min(data_continuities),max(data_continuities));
line(x1,y1,'LineStyle','--','Color',[1 0 0]);
[x2,y2] = iso_utility_line(u2,weight_DC,min(discounted_values),max(discounted_values),min(data_continuities),max(data_continuities));
line(x2,y2,'LineStyle','--','Color',[0 1 0]);
[x3,y3] = iso_utility_line(u3,weight_DC,min(discounted_values),max(discounted_values),min(data_continuities),max(data_continuities));
line(x3,y3,'LineStyle','--','Color',[0 0 1]);
l1 = ['u25=' num2str(1/100*round(100*u1))];
l2 = ['u50=' num2str(1/100*round(100*u2))];
l3 = ['u75=' num2str(1/100*round(100*u3))];

leg = legend({'Selected alternative architectures','Reference architecture',l1,l2,l3});
% leg = legend({'Selected alternative architectures',l1,l2,l3});

set(leg,'Location','Best');

savepath = [params.path_save_results 'scheduling\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'SCHED--DV-vs-DC-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);
end

