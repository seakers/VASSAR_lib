function [filtered_archs,filtered_results] = SEL_explain_down_selection(archs,results,i)
global params
r = global_jess_engine();

close;SEL_plot_results2(results,archs,i);

disp('Repeating Down-selection in explanation mode...');

jess reset;
% SEL_hard_constraints;
% jess focus HARD-CONSTRAINTS;
% jess run;

RBES_assert_architectures('selection',archs,results);
% 
% disp('Filter...');
% jess focus HARD-CONSTRAINTS;
% jess run;

% retrieve
% options.values = {'science','cost','programmatic-risk','fairness','utility','pareto-ranking'};
% options.specials = {};
% [archs2,~,results2] = RBES_retrieve_architectures2('selection',options);
% options.values = {'science','cost','utility','pareto-ranking','programmatic-risk','fairness'};
% [archs,values] = RBES_retrieve_architectures('selection',options);% values(i,j) contaisn metric j for arch i
% these_results.sciences = values(:,1);
% these_results.costs = values(:,2);
% these_results.utilities = values(:,3);
% these_results.pareto_rankings = values(:,4);
% these_results.programmatic_risks = values(:,5);
% these_results.fairness = values(:,6);
% save_results(these_results,archs,'selection','aft_select');
% results2 = these_results;    
% archs2 = archs;

disp('Downselect');
% jess reset;
SEL_down_selection_constraints;
% RBES_assert_architectures('selection',archs2,results2);

% apply rules
jess focus DOWN-SELECTION;
jess run;

% put info on plot
reasons = {'delete-archs-not-enough-pareto-ranking','delete-archs-too-expensive','delete-archs-too-little-science',...
    'delete-archs-too-little-utility','delete-archs-too-much-programmatic-risk','delete-archs-that-dont-fit'};
colors = {'g','r','k','m','c','y','b'};
% loop over architectures
indexes = cell(length(reasons),1);
for i = 1:length(reasons),indexes{i}=[];end
h = gcf;
hold on;
n = 1;
saved = zeros(length(params.instrument_list),1);
for i = 1:size(archs,1)
%     seq = bi2de(archs(i,:));
    str = SEL_arch_to_str(archs(i,:));
    tmp = r.eval(['(why-was-arch-eliminated "' str '")']);
    reason = jess_value(tmp);
    if reason ~= 0
        index = cellfun(@(x)strcmp(x,reason),reasons);
        indexes{index} = [indexes{index} i];
%         science = jess_value(r.eval(['(get-arch-eliminated-science ' num2str(seq) ')']));
%         cost = jess_value(r.eval(['(get-arch-eliminated-cost ' num2str(seq) ')']));
%         plot(science,cost,'Marker','d','MarkerEdgeColor','r','MarkerFaceColor',char(colors(index)));
    else
        saved(n) = i;
        n = n + 1;
    end
end

for i = 1:length(reasons)
    if ~isempty(indexes{i})
        plot(results.sciences(indexes{i}),results.costs(indexes{i}),'LineStyle','None','Marker','d','MarkerEdgeColor',char(colors(i)),'MarkerFaceColor',char(colors(i)));% with face color
%         plot(results.sciences(indexes{i}),results.costs(indexes{i}),'LineStyle','None','Marker','d','MarkerEdgeColor',char(colors(i)));% without face color
    end
end
legend([{'Selected alternative architectures','Reference architecture'} reasons(not(cellfun(@isempty,indexes)))],'Location','NorthWest');
savepath = [params.path_save_results 'selection\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'SEL--science-vs-cost-explained-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);

saved(n:end) = [];

options.values = {'science','cost','utility','pareto-ranking','programmatic-risk','fairness'};
[filtered_archs,values] = RBES_retrieve_architectures('selection',options);% values(i,j) contaisn metric j for arch i
filtered_results.sciences = values(:,1);
filtered_results.costs = values(:,2);
filtered_results.utilities = values(:,3);
filtered_results.pareto_rankings = values(:,4);
filtered_results.programmatic_risks = values(:,5);
filtered_results.fairness = values(:,6);

    
end

function SEL_plot_results2(results,archs,i)
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


% utilities = results.utilities;
% pareto_ranks = results.pareto_ranks;
f = figure;
ax = axes('Parent',f);
pl = plot(sciences,costs,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,fairness,params});
% pl = plot(sciences,costs,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b', 'LineStyle','None', ...
%     'ButtonDownFcn', {@test_plot,archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,fairness,params});
hold on;
tmp = params.ref_sel_arch;
if ~isfield(tmp,'science')
    disp('Evaluating reference architecture...');
    resu = SEL_evaluate_architecture3(logical(SEL_ref_arch()));
    fprintf('Science = %f, Cost = %f\n',resu.science,resu.cost);
    ref_sel_arch.science = resu.science;
    if strcmp(params.CASE_STUDY,'IRIDIUM')
        NR = [1000 0 8000 1000 0 1000 8000 5000];
        RC = [110 85 100 100 60 100 100 100];
        cost_vec = NR + 66.*RC;
        ref_sel_arch.cost = cost_vec*[1 1 1 1 1 0 0 0]'/1000;
    else
        ref_sel_arch.cost = resu.cost;
    end
    ref_sel_arch.arch = logical(SEL_ref_arch());
    RBES_set_parameter('ref_sel_arch',ref_sel_arch);
end
ref = plot(params.ref_sel_arch.science,params.ref_sel_arch.cost,'rs','MarkerSize', 9,'MarkerFaceColor','r','Parent',ax);
grid on;
xlabel('Normalized Science');
ylabel('Lifecycle cost (FY00$M)');
title(['Results for generation ' num2str(i)]);
end

