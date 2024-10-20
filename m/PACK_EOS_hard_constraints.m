function PACK_EOS_hard_constraints()
assert_hard_constraint('max-sats','6');
assert_hard_constraint('max-instrs-per-sat','10');
assert_hard_constraint('apart-instruments','CERES CERES-C');
assert_hard_constraint('together-instruments','AIRS AMSU-A HSB');% 607
assert_hard_constraint('apart-instruments','CERES CERES-C');
assert_hard_constraint('apart-instruments','MODIS MODIS-B');
% jess assert (HARD-CONSTRAINTS::FORCE-ORBIT (of-instrument ASTER) (required-orbit SSO-800-SSO-AM));
% jess assert (HARD-CONSTRAINTS::FORCE-ORBIT (of-instrument TES) (required-orbit SSO-800-SSO-PM));
% jess assert (HARD-CONSTRAINTS::FORCE-ORBIT (of-instrument AIRS) (required-orbit SSO-800-SSO-PM));
end