function SCHED_compare_clusters(results,archs,indexes)
global params
if ~isfield(results,'launch_dates')
    results.launch_dates = SCHED_compute_launch_dates(archs);
end
nclusters = length(indexes);
for i = 1:nclusters
    results_cluster = RBES_subset_results(results,indexes{i});
    SCHED_boxplots(results_cluster);
    savepath = [params.path_save_results 'scheduling\'];
    tmp = clock();
    hour = num2str(tmp(4));
    minu = num2str(tmp(5));
    filesave = [savepath 'SCHED--boxplots_launch_dates-cluster-' num2str(i) '-' date '-' hour '-' minu '.emf'];
    print('-dmeta',filesave);
end