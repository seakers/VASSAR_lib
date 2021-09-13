function RBES_plot25(archs,results,inaxis,incolor)
    xvals = results.(inaxis{1});
    yvals = results.(inaxis{2});
    
    vals = depack_cellofcells(cellfun(@(x)find_att_in_string_fact(x,incolor),archs,'UniformOutput',false));
    unique_vals = unique(vals);
    n = length(unique_vals);
    indexes = cell(n,1);
    colors = {'b','r','g','k','m','y','o'};
    for i = 1 : n
        indexes{i} = cellfun(@(x)strcmp(x,unique_vals{i}),vals);
        scatter(xvals(indexes{i}),yvals(indexes{i}),'Marker','o','MarkerEdgeColor',colors{i},'MarkerFaceColor',colors{i});
        hold on;
    end
    
    grid on;
    xlabel('Science score','Fontsize',20);
    ylabel('Cost estimate ($M)','Fontsize',20);
    legend(unique_vals,'Location','Best');
    set(gca,'FontSize',20);
    print('-dpng',['science_cost_' incolor]);
end