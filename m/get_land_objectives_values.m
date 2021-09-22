function [obj_ECO1,obj_ECO2,obj_ECO3,obj_ECO4,obj_ECO5,land_score] = get_land_objectives_values(r)
subobj_ECO1_1 = r.eval('?*subobj-ECO1-1*').floatValue(r.getGlobalContext());
subobj_ECO1_2 = r.eval('?*subobj-ECO1-2*').floatValue(r.getGlobalContext());
subobj_ECO1_3 = r.eval('?*subobj-ECO1-3*').floatValue(r.getGlobalContext());
subobj_ECO1_4 = r.eval('?*subobj-ECO1-4*').floatValue(r.getGlobalContext());
obj_ECO1 = [1/4 1/4 1/4 1/4]*[subobj_ECO1_1 subobj_ECO1_2 subobj_ECO1_3 subobj_ECO1_4]';


subobj_ECO2_1 = r.eval('?*subobj-ECO2-1*').floatValue(r.getGlobalContext());
subobj_ECO2_2 = r.eval('?*subobj-ECO2-2*').floatValue(r.getGlobalContext());
subobj_ECO2_3 = r.eval('?*subobj-ECO2-3*').floatValue(r.getGlobalContext());
obj_ECO2 = [2/5 2/5 1/5]*[subobj_ECO2_1 subobj_ECO2_2 subobj_ECO2_3]';

subobj_ECO3_1 = r.eval('?*subobj-ECO3-1*').floatValue(r.getGlobalContext());
subobj_ECO3_2 = r.eval('?*subobj-ECO3-2*').floatValue(r.getGlobalContext());
subobj_ECO3_3 = r.eval('?*subobj-ECO3-3*').floatValue(r.getGlobalContext());
obj_ECO3 = [1/2 1/4 1/4]*[subobj_ECO3_1 subobj_ECO3_2 subobj_ECO3_3]';

subobj_ECO4_1 = r.eval('?*subobj-ECO4-1*').floatValue(r.getGlobalContext());
subobj_ECO4_2 = r.eval('?*subobj-ECO4-2*').floatValue(r.getGlobalContext());
subobj_ECO4_3 = r.eval('?*subobj-ECO4-3*').floatValue(r.getGlobalContext());
subobj_ECO4_4 = r.eval('?*subobj-ECO4-4*').floatValue(r.getGlobalContext());
obj_ECO4 = [1/4 1/4 1/4 1/4]*[subobj_ECO4_1 subobj_ECO4_2 subobj_ECO4_3 subobj_ECO4_4]';

subobj_ECO5_1 = r.eval('?*subobj-ECO5-1*').floatValue(r.getGlobalContext());
subobj_ECO5_2 = r.eval('?*subobj-ECO5-2*').floatValue(r.getGlobalContext());
subobj_ECO5_3 = r.eval('?*subobj-ECO5-3*').floatValue(r.getGlobalContext());
obj_ECO5 = [1/2 1/4 1/4 ]*[subobj_ECO5_1 subobj_ECO5_2 subobj_ECO5_3]';

land_score = [.28 .24 .20 .16 .12]*[obj_ECO1 obj_ECO2 obj_ECO3 obj_ECO4 obj_ECO5]';

return