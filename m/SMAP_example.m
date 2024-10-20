%% SMAP_example.m
function SMAP_example()
%     RBES_Init_Params_SMAP('PACKAGING');
%     RBES_Init_WithRules;
    %% Enumeration
    jess reset;
%     jess batch "C:\\Users\\dani\\Documents\\My
%     Dropbox\\RBES\\clp\\smap_rules.clp";% not needed because already in
%     InitWithRules
    jess assert (MANIFEST::ARCHITECTURE (num-instruments 0) (doesnt-fly (get-instruments)));
    jess focus ENUMERATION;
    jess run;

    %% Evaluation
    archs = SMAP_retrieve_archs();
    results = SMAP_eval_archs(archs);

    %% Post-processing
%     sciences = get_array_from_cell_struct(results,'score');
%     costs = get_array_from_cell_struct(results,'cost');
    sciences = results.sciences;
    costs = results.costs;
    pareto_ranks = RBES_compute_pareto_rankings([-sciences costs],7);
    utilities = RBES_compute_utilities3(results,{'sciences','costs'},{'LIB','SIB'},[0.5 0.5]);

    %% Save
    save_results(results,archs,'smap','example');

    %% Plot
    scatter(sciences,costs,'ButtonDownFcn', ...
        {@sensitive_plot,archs,sciences,costs,utilities,pareto_ranks});
    grid on;
    xlabel('Science score','Fontsize',18);
    ylabel('Cost estimate ($M)','Fontsize',18);
end



