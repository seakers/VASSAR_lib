function update_results_plot(varargin)
%% update_results_plot.m
%
% Usage:
% update_results_plot();% will use latest results file
% update_results_plot('filename.rs');% with specified results file
%
% Plots current view of the Pareto frontier
%
    import rbsa.eoss.*;
    import rbsa.eoss.local.*;
    import java.io.*;
    global params
    persistent last_sciences last_costs;
    if nargin == 0
        tmp = dir('./results/*.rs');
        n = length(tmp);
        names = cell(n,1);
        dates = zeros(n,1);
        for i = 1:n
            names{i} = tmp(i).name;
            dates(i) = tmp(i).datenum;
        end
        [~,order] = sort(dates,'descend');
        sorted_names = names(order);
        filename = sorted_names{1};
        fprintf('Using last file %s\n',filename);
    else
        filename = varargin{1};
    end
    RM = ResultManager.getInstance;
    results = RM.loadResultCollectionFromFile([char(params.path_save_results) '\\' filename]).getFront;
    n = length(results);
    narch = results.size;
    sciences = zeros(n,1);
    costs = zeros(n,1);
    for i = 1:narch
        sciences(i) = results.get(i-1).getScience;
        costs(i) = results.get(i-1).getCost;
    end
    plot(sciences,costs,'rd','Parent',gca);
    
    xlabel('Science');
    ylabel('Cost');
    grid on;
    title(filename);
    if ~isempty(last_sciences)
        hold on;
        plot(last_sciences,last_costs,'bd','Parent',gca);
        legend({'Current','Last'});
    end
    last_sciences = sciences;
    last_costs = costs;
end