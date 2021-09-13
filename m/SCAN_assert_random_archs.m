function archs = SCAN_assert_random_archs(NRANDOM)
global params
levels = cellfun(@length,params.options,'UniformOutput',false);
values = cellfun(@(x)randi(x,NRANDOM,1),levels,'UniformOutput',false);
archs = cell2mat(values);
for i = 1:NRANDOM
    SCAN_assert_arch(archs(i,:),[]);
end
end
    