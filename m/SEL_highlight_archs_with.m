function indexes = SEL_highlight_archs_with(instr,archs,results)
global params


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
instr_index = find(strcmp(params.instrument_list,instr),1);
indexes = logical(archs(:,instr_index));

hold on;
yes = plot(sciences(indexes),costs(indexes),'Marker','d','Parent',gca,'MarkerSize', 8, 'MarkerEdgeColor','g','MarkerFaceColor','g', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(indexes,:),sciences(indexes),costs(indexes),utilities(indexes),pareto_ranks(indexes),programmatic_risks(indexes),fairness(indexes),params});
no = plot(sciences(~indexes),costs(~indexes),'Marker','d','Parent',gca,'MarkerSize', 8, 'MarkerEdgeColor','r','MarkerFaceColor','r', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(~indexes,:),sciences(~indexes),costs(~indexes),utilities(~indexes),pareto_ranks(~indexes),programmatic_risks(~indexes),fairness(~indexes),params});

end