function results2 = RBES_results_with_new_weights(archs,results,varargin)
    if nargin == 2
        [w_sh,w_obj,w_sub] = RBES_read_weights_from_excel;
    else
        w_sh = varargin{1};
        w_obj = varargin{2};
        w_sub = varargin{3};
    end
    old_results = results;
    results = RBES_change_results_struct(old_results);
    results2 = cell(length(results),1);
    for i = 1:length(results)
        [score,sh_scores,obj_scores] = RBES_get_score_from_subobj_struct(results{i}.subobjective_scores,w_sub,w_obj,w_sh);
        results2{i}.score = score;
        results2{i}.sciences = score;
        results2{i}.panel_scores = sh_scores;
        results2{i}.objective_scores = obj_scores;
        results2{i}.subobjective_scores = results{i}.subobjective_scores;
    end
    
    results2 = RBES_change_results_struct(results2);
    results2.fuzzy_sciences = old_results.fuzzy_sciences;
    results2.fuzzy_costs = old_results.fuzzy_costs;
    results2.costs = old_results.costs;
    results = results2;
    sciences = results.sciences;
    costs = results.costs;
    pareto_ranks = RBES_compute_pareto_rankings([-sciences costs],7);
    utilities = RBES_compute_utilities3(results,{'sciences','costs'},{'LIB','SIB'},[0.5 0.5]);
    
    scatter(sciences,costs,'bo','MarkerFaceColor','none','ButtonDownFcn',{@sensitive_plot,archs,sciences,costs,utilities,pareto_ranks});
    grid on;
    xlabel('Science score','Fontsize',20);
    ylabel('Cost estimate ($M)','Fontsize',20);
    front = pareto_ranks<2;
    hold on;
    scatter(sciences(front),costs(front),'ro','MarkerFaceColor','r','ButtonDownFcn', {@sensitive_plot,archs(front),sciences(front),costs(front),utilities(front),pareto_ranks(front)});
    set(gca,'FontSize',20);
    print -dpng det_results;
end