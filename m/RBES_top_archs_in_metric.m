function [res,arc] = RBES_top_archs_in_metric(results,archs,metric,type,pct,PLOT)
global params
values = results.(metric);
if strcmp(type,'LIB')
    mode = 'descend';
else
    mode = 'ascend';
end
[~,order] = sort(values,mode);
res = RBES_subset_results(results,order(1:round(pct*size(archs,1)/100)));
arc = archs(order(1:round(pct*size(archs,1)/100)),:);
if PLOT
    f = figure;
    ax = axes('Parent',f);
    plot(res.(metric),'bd','Parent',ax,'MarkerFaceColor','b','MarkerSize',9,'ButtonDownFcn', {@test_sorted_plot,arc,res,metric});
    set(ax,'FontSize',18);
    grid on;
    xlabel('Ranking','FontSize',18);
    axis([1 Inf -Inf Inf]);
    metric2 = regexprep(metric,'_',' ');
    title(['Top ' num2str(pct) ' % architectures in ' metric2 ],'FontSize',18);
    ylabel(metric2,'FontSize',18);
    savepath = ['.\figures\'];
    tmp = clock();
    hour = num2str(tmp(4));
    min = num2str(tmp(5));
    filesave = [savepath metric '-' date '-' hour '-' min '.emf'];
    print('-dmeta',filesave);
end
end