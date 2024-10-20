function archs = SEL_assert_random_archs(NRANDOM)
instrument_list = RBES_get_parameter('instrument_list');
n = length(instrument_list);
archs = rand(NRANDOM,n)>0.5;
archs = unique(archs,'rows');
NRANDOM = size(archs,1);
% archs = randi(2^n-1,N);
for i = 1:NRANDOM
    arr = instrument_list(archs(i,:));
    str = StringArraytoStringWithSpaces(arr);
    arch.type = 'selection';
    arch.instruments = str;
    arch.utility = [];
    arch.science = [];
    arch.cost = [];
    arch.pareto_ranking = [];
    arch.seq = bi2de(archs(i,:));
    assert_architecture(arch);
end
end
    