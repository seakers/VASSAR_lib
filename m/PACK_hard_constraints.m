function PACK_hard_constraints()
global params
switch params.CASE_STUDY
    case 'EOS'
        PACK_EOS_hard_constraints;
    case 'DECADAL'
        PACK_Decadal_hard_constraints;
end
end