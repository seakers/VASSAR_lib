function [] = SCHED_boxplots(results)
global params
launch_dates = results.launch_dates;
ref_launch_dates = get_launch_dates_from_seq2(params.ref_sched_arch.arch);
figure;
nmiss = size(launch_dates,2);
truncated_names = cell(nmiss,1);
for i = 1:nmiss
    truncated_names{i} = params.SCHEDULING_MissionNames{i}(1:3);
end
boxplot(launch_dates,'labels',truncated_names);
set(gca,'FontSize',18);
hold on
plot(ref_launch_dates,'kd','MarkerFaceColor','k');
if isfield(params,'SCHEDULING_MissionLaunchDates')
    real_lds = RBES_get_parameter('SCHEDULING_MissionLaunchDates');
    plot(real_lds,'gd','MarkerFaceColor','g');
    legend('Reference schedule','Real schedule');
else
    legend('Reference schedule');
end
text_h = findobj(gca, 'Type', 'text');
for cnt = 1:length(text_h)
    set(text_h(cnt),    'FontSize', 16,'HorizontalAlignment', 'center','VerticalAlignment','top')
end
end