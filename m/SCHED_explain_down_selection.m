function [filtered_archs,filtered_results] = SCHED_explain_down_selection(archs,results,i)
global params
r = global_jess_engine();

close;SCHED_plot_results2(results,archs,i);

disp('Repeating Down-selection in explanation mode...');

jess reset;
SCHED_Decadal_down_selection_constraints;

% assert all selection architectures with their sciences, costs, utilities
% and Pareto rankings
ref = SCHED_ref_arch;
[archs2,results2] = RBES_add_arch(ref,results,archs);
RBES_assert_architectures('scheduling',archs2,results2);

% PACK_EOS_hard_constraints;
% jess focus HARD-CONSTRAINTS;
% jess run;

% apply rules
jess focus DOWN-SELECTION;
jess run;

% put info on plot
reasons = {'delete-archs-not-enough-pareto-ranking','delete-archs-too-little-data-continuity','delete-archs-too-little-discounted-value', ...
    'delete-archs-too-little-utility','delete-archs-too-much-unfairness'};
colors = {'g','r','k','m','c'};
% loop over architectures
indexes = cell(length(reasons),1);
for i = 1:length(reasons),indexes{i}=[];end
h = gcf;
hold on;
n = 1;
for i = 1:size(archs,1)
    str = SCHED_arch_to_str(archs(i,:));
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

for i = 1:length(reasons)
    if ~isempty(indexes{i})
        plot(results.discounted_values(indexes{i}),results.data_continuities(indexes{i}),'LineStyle','None','Marker','d','MarkerEdgeColor','r','MarkerFaceColor',char(colors(i)));
    end
end
legend([{'Selected alternative architectures','Reference architecture'} reasons(not(cellfun(@isempty,indexes)))],'Location','SouthEast');
savepath = [params.path_save_results 'scheduling\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'SCHED--DV-vs-DC-explained-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);


options.values = {'discounted-value','data-continuity','utility','pareto-ranking','programmatic-risk','fairness'};
[filtered_archs,values] = RBES_retrieve_architectures('scheduling',options);% values(i,j) contaisn metric j for arch i
filtered_results.discounted_values = values(:,1);
filtered_results.data_continuities = values(:,2);
filtered_results.utilities = values(:,3);
filtered_results.pareto_rankings = values(:,4);
filtered_results.programmatic_risks = values(:,5);
filtered_results.fairness = values(:,6);
save_results(filtered_results,archs,'scheduling','aft_select');
    
end

function SCHED_plot_results2(results,archs,i)
global params
UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');

discounted_values = results.discounted_values;
data_continuities = results.data_continuities;
programmatic_risks = results.programmatic_risks;
fairness = results.fairness;

if UTILITIES
    utilities = RBES_compute_utilities3(results,{'discounted_values','data_continuities'},{'LIB','LIB'},[0.5 0.5]);

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
pl = plot(discounted_values,data_continuities,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs,discounted_values,data_continuities,utilities,pareto_ranks,programmatic_risks,fairness,params});

hold on;
ref2 = plot(1,1,'rs','MarkerSize', 10,'MarkerFaceColor','r','Parent',ax);
% axis([0.96 max(discounted_values) min(data_continuities) max(data_continuities)]);
grid on;
xlabel('Discounted value');
ylabel('Data continuity score');
title(['Results for generation ' num2str(i)]);

end

