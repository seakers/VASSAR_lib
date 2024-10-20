function PACK_Decadal_hard_constraints()
% assert_hard_constraint('max-sats','8');
% assert_hard_constraint('max-instrs-per-sat','8');
% assert_hard_constraint('together-instruments','SMAP_RAD SMAP_MWR');% because they share a common dish, and otherwise the model separates them due to active-passive penalty
% assert_hard_constraint('apart-instruments','ASC_LID ACE_LID');
% assert_hard_constraint('apart-instruments','DESD_LID ASC_LID');
% assert_hard_constraint('apart-instruments','DESD_LID ACE_LID');

% jess assert (HARD-CONSTRAINTS::FORCE-ORBIT (of-instrument SMAP_RAD) (required-orbit SSO-600-SSO-DD));
% jess assert (HARD-CONSTRAINTS::FORCE-ORBIT (of-instrument HYSP_VIS) (required-orbit SSO-800-SSO-AM));
end