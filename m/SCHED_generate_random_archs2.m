function archs = SCHED_generate_random_archs2(NRANDOM,N,vbeg,vend)
all = 1:N;

vmed = all(~ismember(all,union(vbeg,vend)));
archs = zeros(NRANDOM,N);
for i = 1:NRANDOM
    archs(i,:) = [vbeg(randperm(length(vbeg))) vmed(randperm(length(vmed))) vend(randperm(length(vend)))];
end
end