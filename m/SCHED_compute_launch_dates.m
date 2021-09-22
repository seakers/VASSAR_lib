function launch_dates =  SCHED_compute_launch_dates(archs)
[narc,nmiss] = size(archs);
launch_dates = zeros(narc,nmiss);
for i = 1:narc
    launch_dates(i,:) = get_launch_dates_from_seq2(archs(i,:));
end
end