function ASSIGN_assert_test_archs()
% assert a few packaging architectures with
% instr_list = RBES_get_parameter('packaging_instrument_list');
arch.type = 'assigning';
tmp = ASSIGN_ref_arch;
arch.seq = tmp.arch;
assert_architecture(arch);
n = length(arch.seq);

arch.seq = ones(1,n);% all in first orbit only
assert_architecture(arch);

arch.seq = 2.*ones(1,n);% all in second orbit only
assert_architecture(arch);

arch.seq = 3.*ones(1,n);% all in both orbits
assert_architecture(arch);

arch.seq = [1 2 3 1 2];% a random one
assert_architecture(arch);

end