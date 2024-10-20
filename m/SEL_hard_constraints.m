function SEL_hard_constraints
cs = RBES_get_parameter('CASE_STUDY');

if strcmp(cs,'EOS')
    SEL_EOS_hard_constraints;
elseif strcmp(cs,'IRIDIUM')
    SEL_Iridium_hard_constraints;
elseif strcmp(cs,'DECADAL')
    SEL_Decadal_hard_constraints;
else
end