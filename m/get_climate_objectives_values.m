function [obj_C1,obj_C2,obj_C3,obj_C4,obj_C5,climate_score] = get_climate_objectives_values(r)
subobj_C1_1 = r.eval('?*subobj-C1-1*').floatValue(r.getGlobalContext());
subobj_C1_2 = r.eval('?*subobj-C1-2*').floatValue(r.getGlobalContext());
subobj_C1_3 = r.eval('?*subobj-C1-3*').floatValue(r.getGlobalContext());
subobj_C1_4 = r.eval('?*subobj-C1-4*').floatValue(r.getGlobalContext());
subobj_C1_5 = r.eval('?*subobj-C1-5*').floatValue(r.getGlobalContext());
subobj_C1_6 = r.eval('?*subobj-C1-6*').floatValue(r.getGlobalContext());
subobj_C1_7 = r.eval('?*subobj-C1-7*').floatValue(r.getGlobalContext());
subobj_C1_8 = r.eval('?*subobj-C1-8*').floatValue(r.getGlobalContext());
subobj_C1_9 = r.eval('?*subobj-C1-9*').floatValue(r.getGlobalContext());
subobj_C1_10 = r.eval('?*subobj-C1-10*').floatValue(r.getGlobalContext());
subobj_C1_11 = r.eval('?*subobj-C1-11*').floatValue(r.getGlobalContext());
subobj_C1_12 = r.eval('?*subobj-C1-12*').floatValue(r.getGlobalContext());

obj_C1 = [1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12]*[subobj_C1_1 subobj_C1_2 subobj_C1_3 subobj_C1_4 subobj_C1_5 subobj_C1_6 subobj_C1_7 ...
    subobj_C1_8 subobj_C1_9 subobj_C1_10 subobj_C1_11 subobj_C1_12]';


subobj_C2_1 = r.eval('?*subobj-C2-1*').floatValue(r.getGlobalContext());
subobj_C2_2 = r.eval('?*subobj-C2-2*').floatValue(r.getGlobalContext());
subobj_C2_3 = r.eval('?*subobj-C2-3*').floatValue(r.getGlobalContext());
subobj_C2_4 = r.eval('?*subobj-C2-4*').floatValue(r.getGlobalContext());
subobj_C2_5 = r.eval('?*subobj-C2-5*').floatValue(r.getGlobalContext());
subobj_C2_6 = r.eval('?*subobj-C2-6*').floatValue(r.getGlobalContext());
subobj_C2_7 = r.eval('?*subobj-C2-7*').floatValue(r.getGlobalContext());

obj_C2 = [1/10 1/10 1/10 1/10 1/10 1/10 4/10]*[subobj_C2_1 subobj_C2_2 subobj_C2_3 subobj_C2_4 subobj_C2_5 subobj_C2_6 subobj_C2_7]';

subobj_C3_1 = r.eval('?*subobj-C3-1*').floatValue(r.getGlobalContext());
subobj_C3_2 = r.eval('?*subobj-C3-2*').floatValue(r.getGlobalContext());
subobj_C3_3 = r.eval('?*subobj-C3-3*').floatValue(r.getGlobalContext());
subobj_C3_4 = r.eval('?*subobj-C3-4*').floatValue(r.getGlobalContext());
subobj_C3_5 = r.eval('?*subobj-C3-5*').floatValue(r.getGlobalContext());
subobj_C3_6 = r.eval('?*subobj-C3-6*').floatValue(r.getGlobalContext());

obj_C3 = [1/6 1/6 1/6 1/6 1/6 1/6]*[subobj_C3_1 subobj_C3_2 subobj_C3_3 subobj_C3_4 subobj_C3_5 subobj_C3_6]';



subobj_C4_1 = r.eval('?*subobj-C4-1*').floatValue(r.getGlobalContext());
subobj_C4_2 = r.eval('?*subobj-C4-2*').floatValue(r.getGlobalContext());
subobj_C4_3 = r.eval('?*subobj-C4-3*').floatValue(r.getGlobalContext());
subobj_C4_4 = r.eval('?*subobj-C4-4*').floatValue(r.getGlobalContext());
subobj_C4_5 = r.eval('?*subobj-C4-5*').floatValue(r.getGlobalContext());
subobj_C4_6 = r.eval('?*subobj-C4-6*').floatValue(r.getGlobalContext());

obj_C4 = [1/6 1/6 1/6 1/6 1/6 1/6]*[subobj_C4_1 subobj_C4_2 subobj_C4_3 subobj_C4_4 subobj_C4_5 subobj_C4_6]';

subobj_C5_1 = r.eval('?*subobj-C5-1*').floatValue(r.getGlobalContext());
subobj_C5_2 = r.eval('?*subobj-C5-2*').floatValue(r.getGlobalContext());
subobj_C5_3 = r.eval('?*subobj-C5-3*').floatValue(r.getGlobalContext());
subobj_C5_4 = r.eval('?*subobj-C5-4*').floatValue(r.getGlobalContext());
obj_C5 = [1/4 1/4 1/4 1/4]*[subobj_C5_1 subobj_C5_2 subobj_C5_3 subobj_C5_4]';

climate_score = [.2353 .2353 .2353 .1765 .1176]*[obj_C1 obj_C2 obj_C3 obj_C4 obj_C5]';
return