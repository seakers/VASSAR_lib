function dev_times = RBES_estimate_dev_times(archs)
narc = size(archs,1);
dev_times = zeros(narc,1);
for i = 1:narc
    [dev_times(i),~] = RBES_estimate_dev_time(archs(i,:));
end
dev_times = normalize_SIB(dev_times);
end