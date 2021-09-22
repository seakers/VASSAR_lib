function results = plot_results(filename)
    import rbsa.eoss.*;
    import rbsa.eoss.local.*;
    import java.io.*;
    import java.util.ArrayList;
    
    %% In
    spm = SearchPerformanceManager.getInstance;
    spc = spm.loadSearchPerformanceComparatorFromFile(filename);
    front = spc.getPerf_array.get(spc.getPerf_array.size()-1).getCurrent_pareto_front;
    benefits = zeros(1,front.size);
    costs = zeros(1,front.size);
    for i = 1:front.size
        benefits(i) = front.get(i-1).getScience;
        costs(i) = front.get(i-1).getCost;
    end
    last_results.benefits = benefits;
    last_results.costs = costs;
    avg_pareto_distances = ArrayList2Vec(spc.getAvg_pareto_distances);
    cheapest_max_benefit_archs = spc.getLowest_cost_max_science_arch;
    histories_pareto_distances = ArrayListofArrayList2Matrix(spc.getHistories_avg_pareto_distances);
    histories_cheapest_max_benefit_archs = spc.getHistories_lowest_cost_max_science_arch;
    cheapest_max_benefit_archs_costs = ArrayList2Vec(spc.getCost_of_max_sciences);
    cheapest_max_benefit_archs_sciences = ArrayList2Vec(spc.getMax_sciences);
    nrow = histories_cheapest_max_benefit_archs.size;
    ncol = histories_cheapest_max_benefit_archs.get(0).size;
    histories_costs = zeros(nrow,ncol);
    histories_sciences = zeros(nrow,ncol);
    for i = 1:nrow
        al = histories_cheapest_max_benefit_archs.get(i-1);
        for j = 1:al.size
            res = al.get(j-1);
            histories_sciences(i,j) = res.getScience;
            histories_costs(i,j) = res.getCost;
        end
    end
    %% Out
    results.last_results = last_results;
    results.avg_pareto_distances = avg_pareto_distances;
    results.cheapest_max_benefit_archs_costs = cheapest_max_benefit_archs_costs;
    results.cheapest_max_benefit_archs_sciences = cheapest_max_benefit_archs_sciences;
    results.cheapest_max_benefit_archs = cheapest_max_benefit_archs;
    results.histories_pareto_distances = histories_pareto_distances;
    results.histories_cheapest_max_benefit_archs = histories_cheapest_max_benefit_archs;
    results.histories_sciences = histories_sciences;
    results.histories_costs = histories_costs;
    results.front = front;
    %% Plot
    % Last pareto front
    plot(benefits, costs,'rd','ButtonDownFcn', {@sensitive_plot,front,results});
    
    % Convergence
%     plot(histories_pareto_distances);
end

function sensitive_plot(src,eventdata,front,results)
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [~, i] = min(abs((results.last_results.benefits - xmouse)/xmouse).^2+abs((results.last_results.costs - ymouse)/ymouse).^2);
    arch = front.get(i-1);

    fprintf('Arch = %d, Science = %f, Cost = %f, str = %s\n',i,results.last_results.benefits(i),results.last_results.costs(i),char(arch.toString));
    

end

