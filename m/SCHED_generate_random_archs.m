function archs = SCHED_generate_random_archs(N)
global params
n = params.SCHEDULING_num_missions;
archs = zeros(N,n);
for i = 1:N
    archs(i,:) = randperm(n);
end
archs = unique(archs,'rows');
end