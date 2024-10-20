function PACK_assert_test_archs()
% assert a few packaging architectures with
% instr_list = RBES_get_parameter('packaging_instrument_list');
arch.type = 'packaging';


tmp = PACK_ref_arch;
arch.seq = tmp.arch;
assert_architecture(arch);
n = length(arch.seq);

arch.seq = ones(1,n);% all together
assert_architecture(arch);

arch.seq = 1:n;% all separate
assert_architecture(arch);

% arch.seq = [1 1 1 2 2 2 1 1 1 2 1 1 2 2 1 1];% TERRA and AQUA-AURA (AM-PM)
% assert_architecture(arch);
% 
% arch.seq = PACK_str_to_arch('MODIS CERES CERES-B & AIRS AMSU-A HSB & ASTER MODIS-B AMSR-E MISR & MOPITT CERES-C & HIRDLS MLS OMI TES');% 5 satellites
% assert_architecture(arch);
% 
% arch.seq = PACK_str_to_arch('MODIS CERES CERES-B & AIRS AMSU-A HSB MLS HIRDLS & ASTER MODIS-B AMSR-E MISR CERES-C & MOPITT OMI TES');% 5 satellites
% assert_architecture(arch);
% 
% arch.seq = PACK_str_to_arch('AIRS AMSR-E AMSU-A ASTER CERES-B CERES-C HSB MODIS-B MOPITT OMI MISR &  CERES HIRDLS MLS MODIS TES');% 2 satellites
% assert_architecture(arch);
% 
% arch.seq = PACK_str_to_arch('AIRS AMSR-E AMSU-A HIRDLS HSB MODIS-B TES &  ASTER CERES MISR MODIS &  CERES-B CERES-C MLS OMI MOPITT');% 3 satellites
% assert_architecture(arch);
end