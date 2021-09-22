function str = SCHED_arch_to_str(seq)
missions = RBES_get_parameter('SCHEDULING_MissionNames');
str = StringArraytoStringWithSpaces(missions(seq));
end