function [filtered_archs,filtered_results] = PACK_explain_down_selection(archs,results,i)
global params
r = global_jess_engine();


disp('Repeating Down-selection in explanation mode...');

jess reset;
% SEL_EOS_hard_constraints;

%% assert architectures
ref = PACK_ref_arch;
[archs2,results2] = RBES_add_arch(ref,results,archs);
RBES_assert_architectures('packaging',archs2,results2);
ref.utility = results2.utilities(end);
ref.pareto_ranking = results2.pareto_rankings(end);
RBES_set_parameter('ref_pack_arch',ref);

%% Filter bad orbits
% PACK_EOS_hard_constraints;
% PACK_Decadal_hard_constraints;
% jess focus HARD-CONSTRAINTS;
% jess run;

%% Retrieve and plot

options.values = {'science','cost','utility','pareto-ranking','programmatic-risk','launch-risk','data-continuity'};
[archs,values,orbits] = RBES_retrieve_architectures('packaging',options);% values(i,j) contaisn metric j for arch i
results.sciences = values(:,1);
results.costs = values(:,2);
results.utilities = values(:,3);
results.pareto_rankings = values(:,4);
results.programmatic_risks = values(:,5);
results.launch_risks = values(:,6);
results.data_continuities = values(:,7);
results.instrument_orbits = orbits;
close;PACK_plot_results2(results,archs,i);


%% Down select apply rules
PACK_down_selection_constraints;
jess focus DOWN-SELECTION;
jess run;

% put info on plot
reasons = {'delete-archs-not-enough-pareto-ranking','delete-archs-too-expensive','delete-archs-too-little-science', ...
    'delete-archs-too-little-utility','delete-archs-too-much-programmatic-risk','delete-archs-too-much-launch-risk' ...
    'delete-archs-breaking-hard-orbit-requirements'};
colors = {'g','r','k','m','c','y','w'};
% loop over architectures
indexes = cell(length(reasons),1);
for i = 1:length(reasons),indexes{i}=[];end
h = gcf;
hold on;
n = 1;
for i = 1:size(archs,1)
    str = PACK_arch_to_str(archs(i,:));
    tmp = r.eval(['(why-was-arch-eliminated "' char(str) '")']);
    reason = jess_value(tmp);
    if reason ~= 0
        index = cellfun(@(x)strcmp(x,reason),reasons);
        indexes{index} = [indexes{index} i];
%         science = jess_value(r.eval(['(get-arch-eliminated-science ' num2str(seq) ')']));
%         cost = jess_value(r.eval(['(get-arch-eliminated-cost ' num2str(seq) ')']));
%         plot(science,cost,'Marker','d','MarkerEdgeColor','r','MarkerFaceColor',char(colors(index)));
    else
        n = n + 1;
    end
end
unselected = [];
for i = 1:length(indexes)
    unselected = [unselected indexes{i}];
end
selected = 1:size(archs,1);
selected(unselected) = [];

for i = 1:length(reasons)
    if ~isempty(indexes{i})
        plot(results.sciences(indexes{i}),results.costs(indexes{i}),'LineStyle','None','Marker','d','MarkerEdgeColor','r','MarkerFaceColor',char(colors(i)));
    end
end
plot(results.sciences(selected),results.costs(selected),'LineStyle','None','Marker','d','MarkerEdgeColor','b','MarkerFaceColor','b');
ref = plot(params.ref_pack_arch.science,params.ref_pack_arch.cost,'LineStyle','None','Marker','s','MarkerEdgeColor','r','MarkerSize', 10,'MarkerFaceColor','r');

legend([{'Selected alternative architectures','Reference architecture'} reasons(not(cellfun(@isempty,indexes)))],'Location','NorthWest');
savepath = [params.path_save_results 'packaging\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'PACK--science-vs-cost-explained-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);


options.values = {'science','cost','utility','pareto-ranking','programmatic-risk','launch-risk','data-continuity'};
[filtered_archs,values,orbits] = RBES_retrieve_architectures('packaging',options);% values(i,j) contaisn metric j for arch i
filtered_results.sciences = values(:,1);
filtered_results.costs = values(:,2);
filtered_results.utilities = values(:,3);
filtered_results.pareto_rankings = values(:,4);
filtered_results.programmatic_risks = values(:,5);
filtered_results.launch_risks = values(:,6);
filtered_results.data_continuities = values(:,7);
filtered_results.orbits = orbits;    
end

function PACK_plot_results2(results,archs,i)
global params
UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');

sciences = results.sciences;
costs = results.costs;
programmatic_risks = results.programmatic_risks;
launch_risks = results.launch_risks;

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


% utilities = results.utilities;
% pareto_ranks = results.pareto_ranks;
f = figure;
ax = axes('Parent',f);
pl = plot(sciences,costs,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,launch_risks,[],params});
hold on;
PACK_ref_arch;
ref = plot(params.ref_pack_arch.science,params.ref_pack_arch.cost,'rs','MarkerSize', 10,'MarkerFaceColor','r','Parent',ax);
grid on;
xlabel('Normalized Science');
ylabel('Lifecycle cost (FY00$M)');
title(['Results for generation ' num2str(i)]);
end

