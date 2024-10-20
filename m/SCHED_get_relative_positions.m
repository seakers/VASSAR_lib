function [pos,lds] = SCHED_get_relative_positions(archs,miss1,miss2)
global params
i1 = params.SCHEDULING_MissionIds.get(miss1);
i2 = params.SCHEDULING_MissionIds.get(miss2);
narc = size(archs,1);
pos = zeros(narc,2);
lds = zeros(narc,2);

for i = 1:narc
    launch_dates = get_launch_dates_from_seq2(archs(i,:));
    lds(i,1) = launch_dates(i1);
    lds(i,2) = launch_dates(i2);
    pos(i,1) = find(archs(i,:) == i1,1);
    pos(i,2) = find(archs(i,:) == i2,1);
end
end

