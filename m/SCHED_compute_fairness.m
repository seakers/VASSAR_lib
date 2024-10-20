function unfairness = SCHED_compute_fairness(archs)
global params
[narc,nmiss] = size(archs);
unfairness = zeros(narc,1);

for i = 1:narc
    panel_scores_over_time = zeros(params.npanels,nmiss);
    cumulative_panel_scores = zeros(params.npanels,nmiss);
    deviations = zeros(1,nmiss);
    for j = 1:nmiss
        % get mission in jth position of ith architecture
        miss_ID = archs(i,j);
        
        % get panel scores of this mission
        panel_scores_over_time(:,j) = params.SCHEDULING_mission_panel_scores(miss_ID,:)';%row array
        if j == 1
            cumulative_panel_scores(:,j) = panel_scores_over_time(:,j);
        else
            cumulative_panel_scores(:,j) = cumulative_panel_scores(:,j-1) + panel_scores_over_time(:,j);
        end
        deviations(j) = max(cumulative_panel_scores(:,j))-min(cumulative_panel_scores(:,j));
    end
    unfairness(i) = sum(deviations);
end

end