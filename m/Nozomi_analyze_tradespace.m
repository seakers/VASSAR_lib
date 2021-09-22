function [results,arch,result] = Nozomi_analyze_tradespace(AE, params)

    %% Plot last pareto front
    results = plot_results([char(params.path_save_results) '\\perfs_2_2014-02-03--10-19-13.rs']);

    %% Evaluate one arch and explain results
    index = 1; %Arch to evaluate (find out index by clicking on tradespace plot)
    arch = results.front.get(index-1).getArch;% minus 1 because java indices run 0 to n-1, but matlab indeces run 1 to n
    result = AE.evaluateArchitecture(arch,'Slow');
    explain_result(result,AE,params);
end