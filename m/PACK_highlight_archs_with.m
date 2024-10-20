function PACK_highlight_archs_with(archs,results,i)
global params
PLOT_FLAGS = [1 1 1 1 1 1 1 1];

UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');
DC =isfield(results,'data_continuities');

sciences = results.sciences;
costs = results.costs;
programmatic_risks = results.programmatic_risks;
launch_risks = results.launch_risks;

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
if DC
    data_continuities = results.data_continuities;
else
    data_continuities = [];
end


nsats = max(archs,[],2);
ind2 = nsats == 2;
ind3 = nsats == 3;
ind4 = nsats == 4;
ind5 = nsats == 5;
ind6 = nsats == 6;
ind7 = nsats == 7;
ind8 = nsats == 8;
ind9 = nsats == 9;

f = figure;
ax = axes('Parent',f);
% if PLOT_FLAGS(1) == 1
%     s2 = plot(sciences(ind2),costs(ind2),'Marker','o','Parent',ax,'MarkerSize', 5, 'MarkerEdgeColor','g','MarkerFaceColor','g', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs(ind2,:),sciences(ind2),costs(ind2),utilities(ind2),pareto_ranks(ind2),programmatic_risks(ind2),launch_risks(ind2),data_continuities,params});
% end
% hold on
% if PLOT_FLAGS(2) == 1
%     s3 = plot(sciences(ind3),costs(ind3),'Marker','o','Parent',ax,'MarkerSize', 5, 'MarkerEdgeColor','r','MarkerFaceColor','r', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs(ind3,:),sciences(ind3),costs(ind3),utilities(ind3),pareto_ranks(ind3),programmatic_risks(ind3),launch_risks(ind3),data_continuities,params});
% end
% if PLOT_FLAGS(3) == 1
%     s4 = plot(sciences(ind4),costs(ind4),'Marker','o','Parent',ax,'MarkerSize', 5, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs(ind4,:),sciences(ind4),costs(ind4),utilities(ind4),pareto_ranks(ind4),programmatic_risks(ind4),launch_risks(ind4),data_continuities,params});
% end
% if PLOT_FLAGS(4) == 1
%     s5 = plot(sciences(ind5),costs(ind5),'Marker','o','Parent',ax,'MarkerSize', 5, 'MarkerEdgeColor','k','MarkerFaceColor','k', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs(ind5,:),sciences(ind5),costs(ind5),utilities(ind5),pareto_ranks(ind5),programmatic_risks(ind5),launch_risks(ind5),data_continuities,params});
% end
% if PLOT_FLAGS(5) == 1
%     s6 = plot(sciences(ind6),costs(ind6),'Marker','o','Parent',ax,'MarkerSize', 5, 'MarkerEdgeColor','y','MarkerFaceColor','y', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs(ind6,:),sciences(ind6),costs(ind6),utilities(ind6),pareto_ranks(ind6),programmatic_risks(ind6),launch_risks(ind6),data_continuities,params});
% end
% if PLOT_FLAGS(6) == 1
%     s7 = plot(sciences(ind7),costs(ind7),'Marker','o','Parent',ax,'MarkerSize', 5, 'MarkerEdgeColor','m','MarkerFaceColor','m', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs(ind7,:),sciences(ind7),costs(ind7),utilities(ind7),pareto_ranks(ind7),programmatic_risks(ind7),launch_risks(ind7),data_continuities,params});
% end
% if PLOT_FLAGS(7) == 1
%     s8 = plot(sciences(ind8),costs(ind8),'Marker','o','Parent',ax,'MarkerSize', 5, 'MarkerEdgeColor','c','MarkerFaceColor','c', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs(ind8,:),sciences(ind8),costs(ind8),utilities(ind8),pareto_ranks(ind8),programmatic_risks(ind8),launch_risks(ind8),data_continuities,params});
% end

if PLOT_FLAGS(1) == 1
    s2 = plot(sciences(ind2),costs(ind2),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','k','MarkerFaceColor','w', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind2,:),sciences(ind2),costs(ind2),utilities(ind2),pareto_ranks(ind2),programmatic_risks(ind2),launch_risks(ind2),data_continuities,params});
end
hold on
if PLOT_FLAGS(2) == 1
    s3 = plot(sciences(ind3),costs(ind3),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','c','MarkerFaceColor','c', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind3,:),sciences(ind3),costs(ind3),utilities(ind3),pareto_ranks(ind3),programmatic_risks(ind3),launch_risks(ind3),data_continuities,params});
end
if PLOT_FLAGS(3) == 1
    s4 = plot(sciences(ind4),costs(ind4),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','m','MarkerFaceColor','m', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind4,:),sciences(ind4),costs(ind4),utilities(ind4),pareto_ranks(ind4),programmatic_risks(ind4),launch_risks(ind4),data_continuities,params});
end
if PLOT_FLAGS(4) == 1
    s5 = plot(sciences(ind5),costs(ind5),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','y','MarkerFaceColor','y', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind5,:),sciences(ind5),costs(ind5),utilities(ind5),pareto_ranks(ind5),programmatic_risks(ind5),launch_risks(ind5),data_continuities,params});
end
if PLOT_FLAGS(5) == 1
    s6 = plot(sciences(ind6),costs(ind6),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind6,:),sciences(ind6),costs(ind6),utilities(ind6),pareto_ranks(ind6),programmatic_risks(ind6),launch_risks(ind6),data_continuities,params});
end
if PLOT_FLAGS(6) == 1
    s7 = plot(sciences(ind7),costs(ind7),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','r','MarkerFaceColor','r', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind7,:),sciences(ind7),costs(ind7),utilities(ind7),pareto_ranks(ind7),programmatic_risks(ind7),launch_risks(ind7),data_continuities,params});
end
if PLOT_FLAGS(7) == 1
    s8 = plot(sciences(ind8),costs(ind8),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','g','MarkerFaceColor','g', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind8,:),sciences(ind8),costs(ind8),utilities(ind8),pareto_ranks(ind8),programmatic_risks(ind8),launch_risks(ind8),data_continuities,params});
end
if PLOT_FLAGS(8) == 1
    s9 = plot(sciences(ind9),costs(ind9),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','k','MarkerFaceColor','k', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(ind9,:),sciences(ind9),costs(ind9),utilities(ind9),pareto_ranks(ind9),programmatic_risks(ind9),launch_risks(ind9),data_continuities,params});
end

PACK_ref_arch;
ref = plot(params.ref_pack_arch.science,params.ref_pack_arch.cost,'bs','MarkerSize', 10,'MarkerFaceColor','b','Parent',ax);
grid on;
xlabel('Normalized Science');
ylabel('Lifecycle cost (FY00$M)');
title(['Results for generation ' num2str(i)]);
labels = {'2 sats','3 sats','4 sats','5 sats','6 sats','7 sats','8 sats','9 sats','ref'};
legend(labels([logical(PLOT_FLAGS) true]),'Location','NorthWest');

savepath = [params.path_save_results 'packaging\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'PACK--science-vs-cost-with-nsats-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);
end