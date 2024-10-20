function PACK_down_selection_constraints
global params
switch params.CASE_STUDY
    case 'EOS'
        PACK_EOS_down_selection_constraints;
    case 'DECADAL'
    PACK_Decadal_down_selection_constraints;
end
end