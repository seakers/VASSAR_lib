function [obj_SE1,obj_SE2,obj_SE3,obj_SE4,obj_SE5,solidearth_score] = get_solidearth_objectives_values(r)
subobj_SE1_1 = r.eval('?*subobj-SE1-1*').floatValue(r.getGlobalContext());
subobj_SE1_2 = r.eval('?*subobj-SE1-2*').floatValue(r.getGlobalContext());
subobj_SE1_3 = r.eval('?*subobj-SE1-3*').floatValue(r.getGlobalContext());
obj_SE1 = [3/5 1/5 1/5]*[subobj_SE1_1 subobj_SE1_2 subobj_SE1_3]';


subobj_SE2_1 = r.eval('?*subobj-SE2-1*').floatValue(r.getGlobalContext());
subobj_SE2_2 = r.eval('?*subobj-SE2-2*').floatValue(r.getGlobalContext());
subobj_SE2_3 = r.eval('?*subobj-SE2-3*').floatValue(r.getGlobalContext());
obj_SE2 = [3/5 1/5 1/5]*[subobj_SE2_1 subobj_SE2_2 subobj_SE2_3]';

subobj_SE3_1 = r.eval('?*subobj-SE3-1*').floatValue(r.getGlobalContext());
subobj_SE3_2 = r.eval('?*subobj-SE3-2*').floatValue(r.getGlobalContext());
obj_SE3 = [4/5 1/5]*[subobj_SE3_1 subobj_SE3_2]';

subobj_SE4_1 = r.eval('?*subobj-SE4-1*').floatValue(r.getGlobalContext());
subobj_SE4_2 = r.eval('?*subobj-SE4-2*').floatValue(r.getGlobalContext());
subobj_SE4_3 = r.eval('?*subobj-SE4-3*').floatValue(r.getGlobalContext());
subobj_SE4_4 = r.eval('?*subobj-SE4-4*').floatValue(r.getGlobalContext());

obj_SE4 = [1/2 1/6 1/6 1/6]*[subobj_SE4_1 subobj_SE4_2 subobj_SE4_3 subobj_SE4_4]';

subobj_SE5_1 = r.eval('?*subobj-SE5-1*').floatValue(r.getGlobalContext());

obj_SE5 = subobj_SE5_1;

solidearth_score = [.286 .238 .190 .143 .143]*[obj_SE1 obj_SE2 obj_SE3 obj_SE4 obj_SE5]';
return