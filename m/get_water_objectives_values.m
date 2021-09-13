function [obj_WA1,obj_WA2,obj_WA3,obj_WA4,obj_WA5,obj_WA6,obj_WA7,water_score] = get_water_objectives_values(r)
subobj_WA1_1 = r.eval('?*subobj-WA1-1*').floatValue(r.getGlobalContext());
subobj_WA1_2 = r.eval('?*subobj-WA1-2*').floatValue(r.getGlobalContext());
obj_WA1 = [1/2 1/2]*[subobj_WA1_1 subobj_WA1_2]';


subobj_WA2_1 = r.eval('?*subobj-WA2-1*').floatValue(r.getGlobalContext());
subobj_WA2_2 = r.eval('?*subobj-WA2-2*').floatValue(r.getGlobalContext());
subobj_WA2_3 = r.eval('?*subobj-WA2-3*').floatValue(r.getGlobalContext());
obj_WA2 = [1/2 1/4 1/4]*[subobj_WA2_1 subobj_WA2_2 subobj_WA2_3]';

subobj_WA3_1 = r.eval('?*subobj-WA3-1*').floatValue(r.getGlobalContext());
subobj_WA3_2 = r.eval('?*subobj-WA3-2*').floatValue(r.getGlobalContext());
subobj_WA3_3 = r.eval('?*subobj-WA3-3*').floatValue(r.getGlobalContext());
subobj_WA3_4 = r.eval('?*subobj-WA3-4*').floatValue(r.getGlobalContext());
obj_WA3 = [1/2 1/6 1/6 1/6]*[subobj_WA3_1 subobj_WA3_2 subobj_WA3_3 subobj_WA3_4]';



subobj_WA4_1 = r.eval('?*subobj-WA4-1*').floatValue(r.getGlobalContext());
subobj_WA4_2 = r.eval('?*subobj-WA4-2*').floatValue(r.getGlobalContext());
subobj_WA4_3 = r.eval('?*subobj-WA4-3*').floatValue(r.getGlobalContext());
subobj_WA4_4 = r.eval('?*subobj-WA4-4*').floatValue(r.getGlobalContext());
obj_WA4 = [1/2 1/6 1/6 1/6]*[subobj_WA4_1 subobj_WA4_2 subobj_WA4_3 subobj_WA4_4]';

subobj_WA5_1 = r.eval('?*subobj-WA5-1*').floatValue(r.getGlobalContext());
subobj_WA5_2 = r.eval('?*subobj-WA5-2*').floatValue(r.getGlobalContext());
subobj_WA5_3 = r.eval('?*subobj-WA5-3*').floatValue(r.getGlobalContext());
subobj_WA5_4 = r.eval('?*subobj-WA5-4*').floatValue(r.getGlobalContext());
obj_WA5 = [1/4 1/4 1/4 1/4]*[subobj_WA5_1 subobj_WA5_2 subobj_WA5_3 subobj_WA5_4]';


subobj_WA6_1 = r.eval('?*subobj-WA6-1*').floatValue(r.getGlobalContext());
subobj_WA6_2 = r.eval('?*subobj-WA6-2*').floatValue(r.getGlobalContext());
subobj_WA6_3 = r.eval('?*subobj-WA6-3*').floatValue(r.getGlobalContext());
obj_WA6 = [1/3 1/3 1/3]*[subobj_WA6_1 subobj_WA6_2 subobj_WA6_3]';

subobj_WA7_1 = r.eval('?*subobj-WA7-1*').floatValue(r.getGlobalContext());
subobj_WA7_2 = r.eval('?*subobj-WA7-2*').floatValue(r.getGlobalContext());
subobj_WA7_3 = r.eval('?*subobj-WA7-3*').floatValue(r.getGlobalContext());
subobj_WA7_4 = r.eval('?*subobj-WA7-4*').floatValue(r.getGlobalContext());
obj_WA7 = [1/4 1/4 1/4 1/4]*[subobj_WA7_1 subobj_WA7_2 subobj_WA7_3 subobj_WA7_4]';

water_score = [.287 .238 .190 .095 .079 .063 .048]*[obj_WA1 obj_WA2 obj_WA3 obj_WA4 obj_WA5 obj_WA6 obj_WA7]';

return