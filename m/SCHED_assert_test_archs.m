function SCHED_assert_test_archs()

arch.type = 'scheduling';
tmp = SCHED_ref_arch;
arch.seq = tmp.arch;
assert_architecture(arch);
n = length(arch.seq);

arch.seq = 1:n;% in order
assert_architecture(arch);


end