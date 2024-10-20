function SEL_down_selection_constraints
cs = RBES_get_parameter('CASE_STUDY');

if strcmp(cs,'EOS')
    SEL_EOS_down_selection_constraints;
elseif strcmp(cs,'IRIDIUM')
    SEL_Iridium_down_selection_constraints;
elseif strcmp(cs,'DECADAL')
    SEL_Decadal_down_selection_constraints;
else
end