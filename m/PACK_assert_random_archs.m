function archs = PACK_assert_random_archs(NRANDOM)
archs2 = PACK_generate_random_archs_with_sats(NRANDOM,2);
archs3 = PACK_generate_random_archs_with_sats(NRANDOM,3);
archs4 = PACK_generate_random_archs_with_sats(NRANDOM,4);
archs5 = PACK_generate_random_archs_with_sats(NRANDOM,5);
archs6 = PACK_generate_random_archs_with_sats(NRANDOM,6);
archs = [archs2;archs3;archs4;archs5;archs6];

for i = 1:5*NRANDOM
    arch.type = 'packaging';
    arch.seq = archs(i,:);
    arch.utility = [];
    arch.science = [];
    arch.cost = [];
    arch.pareto_ranking = [];
    assert_architecture(arch);
end
end
    