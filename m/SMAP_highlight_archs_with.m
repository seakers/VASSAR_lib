function [indexes,results2,archs2] = SMAP_highlight_archs_with(attr,val,archs,results,varargin)
    vals = cellfun(@(x)find_att_in_string_fact(x,attr),archs,'UniformOutput',false);
    indexes = cellfun(@(x)strcmp(x,val),vals);
    [results2,archs2] = RBES_subset_results(results,archs,indexes);
    if nargin > 4
        % plot
        color = varargin{1};
        sciences = results.sciences;
        costs = results.costs;
        pareto_ranks = RBES_compute_pareto_rankings([-sciences costs],7);
        utilities = RBES_compute_utilities3(results,{'sciences','costs'},{'LIB','SIB'},[0.5 0.5]);
        sciences2 = results2.sciences;
        costs2 = results2.costs;
        pareto_ranks2 = RBES_compute_pareto_rankings([-sciences2 costs2],7);
        utilities2 = RBES_compute_utilities3(results2,{'sciences','costs'},{'LIB','SIB'},[0.5 0.5]);
        
        scatter(sciences,costs,'bo','MarkerFaceColor','none','ButtonDownFcn',{@sensitive_plot,archs,sciences,costs,utilities,pareto_ranks});
        grid on;
        xlabel('Science score','Fontsize',20);
        ylabel('Cost estimate ($M)','Fontsize',20);
        hold on;
        scatter(sciences2,costs2,'Marker','o','MarkerEdgeColor',color,'MarkerFaceColor',color,'ButtonDownFcn', {@sensitive_plot,archs2,sciences2,costs2,utilities2,pareto_ranks2});
        set(gca,'FontSize',20);
        h = legend({'Others',[attr ' = ' val]});
        set(h,'FontSize',18);
        print('-dpng',['highlight_' attr]);
   
        
    end
end