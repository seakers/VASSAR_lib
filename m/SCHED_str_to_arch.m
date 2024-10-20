function seq = SCHED_str_to_arch(str)
mission_ids = RBES_get_parameter('SCHEDULING_MissionIds');
missions = regexp(str,'\s','split');
seq = zeros(1,length(missions));
for i = 1:length(missions)
    seq(i) = mission_ids.get(missions{i});
end
end