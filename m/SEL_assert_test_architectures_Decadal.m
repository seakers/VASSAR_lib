function SEL_assert_test_architectures_Decadal()

jess unwatch all;
jess watch rules;
jess reset;
%% ENUMERATION
% Architectures to be considered
% % examples of given architectures
arch.type = 'selection';
arch.seq = [];

% assert ref architecture
ref = SEL_ref_arch;
arch.instruments = get_instr_from_seq(bi2de(ref));% 606
assert_architecture(arch);
end