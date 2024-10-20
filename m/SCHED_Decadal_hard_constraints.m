function SCHED_Decadal_hard_constraints
% assert_hard_constraint('between-dates-constraints','JASON-1','1997 2002');% to close gap from TOPEX-POSEIDON
% assert_hard_constraint('after-date-constraints','AQUA','2001');% for overlap with A train
% assert_hard_constraint('before-date-constraints','TERRA','2002');% constrained by international partner
% assert_hard_constraint('between-dates-constraints','AURA','2002 2008');% for overlap with A train especially Cloudsat and Calipso
% assert_hard_constraint('between-dates-constraints','METEOR-SAGE-III','1999 2003');% constrained by international partner
% assert_hard_constraint('before-date-constraints','ORBVIEW-SEAWIFS','2000');% constrained by international partner
% assert_hard_constraint('after-date-constraints','SORCE','2000');% TRL
% assert_hard_constraint('before-date-constraints','ACRIMSAT','2001');% to close gap

% assert_hard_constraint('before-date-constraints','ORBVIEW-SEAWIFS','1996');% boundary conditions
% assert_hard_constraint('before-date-constraints','TRMM','1996');% boundary conditions
% assert_hard_constraint('before-date-constraints','LANDSAT-7','1998');% boundary conditions
% assert_hard_constraint('before-date-constraints','TERRA','2002');% boundary conditions

assert_hard_constraint('by-beginning-constraints','SMAP ICESAT-II DESDYNI CLARREO');% boundary conditions
% assert_hard_constraint('by-end-constraints','3D-WINDS');% boundary conditions

% assert_hard_constraint('between-dates-constraints','JASON-1','1997 2002');% to close gap from TOPEX-POSEIDON
% assert_hard_constraint('after-date-constraints','AQUA','2001');% for overlap with A train
% assert_hard_constraint('between-dates-constraints','AURA','2002 2008');% for overlap with A train especially Cloudsat and Calipso
% assert_hard_constraint('between-dates-constraints','METEOR-SAGE-III','1999 2003');% constrained by international partner
% assert_hard_constraint('before-date-constraints','ORBVIEW-SEAWIFS','2000');% constrained by international partner

% assert_hard_constraint('after-date-constraints','SORCE','2000');% TRL
% assert_hard_constraint('after-date-constraints','CLOUDSAT','2000');% TRL
% assert_hard_constraint('after-date-constraints','CALIPSO','2000');% TRL
% assert_hard_constraint('after-date-constraints','OSTM','2004');% TRL


% assert_hard_constraint('before-date-constraints','ACRIMSAT','2001');% to close gap
end