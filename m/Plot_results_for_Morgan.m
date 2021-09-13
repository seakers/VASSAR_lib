function Plot_results_for_Morgan(results,archs,i)
%% Plot_results_for_Morgan.m
% This function plots the risk/cost tradespace in an instrument packaging
% problem. Risk is computed as an average of programmatic and launch risk.
% The relative weights between programmatic and launch risk can be changed
% in this code (line 21)
%
% Usage: After loading a results file, type:
%       Plot_results_for_Morgan(results,archs,10)
% Inputs: 
%   - results, archs, from running PACK_algorithm1
%   - i is just an integer that represents the number of iterations needed
%   to get these results. It is only used to put in the title of the chart.
%
% Daniel Selva <dselva@mit.edu> Mar-23-2012
%

global params
UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');

costs = results.costs;
programmatic_risks = results.programmatic_risks;
launch_risks = results.launch_risks;
risks = (programmatic_risks + launch_risks)/2;% change weights here if desired

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

f = figure;
ax = axes('Parent',f);
pl = plot(risks,costs,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@morgans_plot_aid,archs,costs,utilities,pareto_ranks,programmatic_risks,launch_risks,risks,params});

grid on;
xlabel('Normalized Science');
ylabel('Lifecycle cost (FY00$M)');
title(['Results for generation ' num2str(i)]);

% leg = legend({'Selected alternative architectures','Reference architecture'});
% set(leg,'Location','NorthWest');

savepath = [params.path_save_results 'packaging\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'PACK--risk-vs-cost-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);
end

function morgans_plot_aid(src,eventdata,archs,costs,utilities,pareto_ranks,programmatic_risks,launch_risks,risks,params)
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [val, i] = min(abs((risks - xmouse)/xmouse).^2+abs((costs - ymouse)/ymouse).^2);
    xpoint   = risks(i);
    ypoint   = costs(i);
    arch = archs(i,:);
    ninstr = cellfun(@length,PACK_arch2sats(archs(i,:)));
    str = PACK_arch_to_str(archs(i,:));
    fprintf('Arch = %d with % sats, programmatic risk = %f, launch risk = %f, combined risk = %f, cost = %f\n', ...
        i,sum(archs(i,:)),programmatic_risks(i),launch_risks(i),risks(i),costs(i));

    fprintf('Assignment = %s\n',max(archs(i,:)),num2str(ninstr'),str);
end

