function archs = ASSIGN_assert_random_archs(NRANDOM)
global params
norb = length(params.orbit_list);
nins = length(params.assign_instrument_list);
archs = randi(2^norb-1,[NRANDOM nins]);
for i=1:NRANDOM
    arch.type = 'assigning';
    arch.seq = archs(i,:);
    assert_architecture(arch);    
end
end
    