function results = RBES_look_around(str_arch)
    jess reset;
    jess batch ".\\clp\\look_around_rules.clp";
    jess(['bind ?f (assert-string "' char(str_arch) '")']);
    
    ff = jess('modify ?f (source yes)');
    jess focus LOOK-AROUND;
    jess run;
    archs = SMAP_retrieve_archs();
    ind = cellfun(@(x)isequal(x,ff.toString),archs);
    results = SMAP_eval_archs(archs);
    
    sciences = results.sciences;
    costs = results.costs;
    pareto_ranks = RBES_compute_pareto_rankings([-sciences costs],7);
    utilities = RBES_compute_utilities3(results,{'sciences','costs'},{'LIB','SIB'},[0.5 0.5]);
    
    p1 = scatter(sciences(~ind),costs(~ind),'bo','MarkerFaceColor','none','ButtonDownFcn',{@sensitive_plot,archs(~ind),sciences(~ind),costs(~ind),utilities(~ind),pareto_ranks(~ind)});
%     grid on;
%     xlabel('Science score','Fontsize',20);
%     ylabel('Cost estimate ($M)','Fontsize',20);
%     
%     %Obtain the axes size (in axpos) in Points
%     s = 5;
%     currentunits = get(gca,'Units');
%     set(gca, 'Units', 'Points');
%     axpos = get(gca,'Position');
%     set(gca, 'Units', currentunits);
%     markerWidth = s/diff(xlim)*axpos(3); % Calculate Marker width in points
    set(p1, 'SizeData', 50);

    hold on;
    p2 = scatter(sciences(ind),costs(ind),'rd','MarkerFaceColor','r','ButtonDownFcn',{@sensitive_plot,archs(ind),sciences(ind),costs(ind),utilities(ind),pareto_ranks(ind)});
    set(gca,'FontSize',20);
    set(p2, 'SizeData', 50);
    print -dpng look_around_results;
end