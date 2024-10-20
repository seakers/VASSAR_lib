function SEL_Decadal_hard_constraints()
% assert_hard_constraint('fix-instruments','ASTER HSB SEAWIFS MOPITT AMSR-E SAGE-III');% International partners
% % assert_hard_constraint('fix-instruments','SAGE-III'); % for data continuity
% assert_hard_constraint('xor-instruments','SCANSCAT SEAWINDS');
% assert_hard_constraint('xor-instruments','GGI DORIS');
% assert_hard_constraint('xor-instruments','MLS SAFIRE');% 610
% assert_hard_constraint('xor-instruments','GLAS GLRS');
% assert_hard_constraint('not-instruments','IPEI XIE GOS');
% assert_hard_constraint('group-instruments','SWOT_SAR SWOT_MWR');
% assert_hard_constraint('group-instruments','SWOT_SAR SWOT_MWR');
% assert_hard_constraint('group-instruments','SWOT_SAR SWOT_MWR');
assert_hard_constraint('group-instruments','SWOT_SAR SWOT_MWR');

end