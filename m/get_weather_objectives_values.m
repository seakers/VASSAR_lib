function [obj_WE1,obj_WE2,obj_WE3,obj_WE4,obj_WE5,obj_WE6,obj_WE7,weather_score] = get_weather_objectives_values(r)
subobj_WE1_1 = r.eval('?*subobj-WE1-1*').floatValue(r.getGlobalContext());
subobj_WE1_2 = r.eval('?*subobj-WE1-2*').floatValue(r.getGlobalContext());
subobj_WE1_3 = r.eval('?*subobj-WE1-3*').floatValue(r.getGlobalContext());
subobj_WE1_4 = r.eval('?*subobj-WE1-4*').floatValue(r.getGlobalContext());
subobj_WE1_5 = r.eval('?*subobj-WE1-5*').floatValue(r.getGlobalContext());
obj_WE1 = [1/5 1/5 1/5 1/5 1/5]*[subobj_WE1_1 subobj_WE1_2 subobj_WE1_3 subobj_WE1_4 subobj_WE1_5]';


subobj_WE2_1 = r.eval('?*subobj-WE2-1*').floatValue(r.getGlobalContext());
subobj_WE2_2 = r.eval('?*subobj-WE2-2*').floatValue(r.getGlobalContext());
subobj_WE2_3 = r.eval('?*subobj-WE2-3*').floatValue(r.getGlobalContext());
subobj_WE2_4 = r.eval('?*subobj-WE2-4*').floatValue(r.getGlobalContext());
subobj_WE2_5 = r.eval('?*subobj-WE2-5*').floatValue(r.getGlobalContext());
subobj_WE2_6 = r.eval('?*subobj-WE2-6*').floatValue(r.getGlobalContext());
obj_WE2 = [1/3 1/3*1/3 1/3*1/3 1/3*1/3 1/6 1/6]*[subobj_WE2_1 subobj_WE2_2 subobj_WE2_3 subobj_WE2_4 subobj_WE2_5 subobj_WE2_6]';

subobj_WE3_1 = r.eval('?*subobj-WE3-1*').floatValue(r.getGlobalContext());
subobj_WE3_2 = r.eval('?*subobj-WE3-2*').floatValue(r.getGlobalContext());
subobj_WE3_3 = r.eval('?*subobj-WE3-3*').floatValue(r.getGlobalContext());
subobj_WE3_4 = r.eval('?*subobj-WE3-4*').floatValue(r.getGlobalContext());

obj_WE3 = [1/4 1/4 1/4 1/4]*[subobj_WE3_1 subobj_WE3_2 subobj_WE3_3 subobj_WE3_4]';



subobj_WE4_1 = r.eval('?*subobj-WE4-1*').floatValue(r.getGlobalContext());
subobj_WE4_2 = r.eval('?*subobj-WE4-2*').floatValue(r.getGlobalContext());
subobj_WE4_3 = r.eval('?*subobj-WE4-3*').floatValue(r.getGlobalContext());
subobj_WE4_4 = r.eval('?*subobj-WE4-4*').floatValue(r.getGlobalContext());
subobj_WE4_5 = r.eval('?*subobj-WE4-5*').floatValue(r.getGlobalContext());
obj_WE4 = [1/5 1/5 1/5 1/5 1/5]*[subobj_WE4_1 subobj_WE4_2 subobj_WE4_3 subobj_WE4_4 subobj_WE4_5]';

subobj_WE5_1 = r.eval('?*subobj-WE5-1*').floatValue(r.getGlobalContext());
obj_WE5 = subobj_WE5_1;


subobj_WE6_1 = r.eval('?*subobj-WE6-1*').floatValue(r.getGlobalContext());
subobj_WE6_2 = r.eval('?*subobj-WE6-2*').floatValue(r.getGlobalContext());
subobj_WE6_3 = r.eval('?*subobj-WE6-3*').floatValue(r.getGlobalContext());
subobj_WE6_4 = r.eval('?*subobj-WE6-4*').floatValue(r.getGlobalContext());
subobj_WE6_5 = r.eval('?*subobj-WE6-5*').floatValue(r.getGlobalContext());
subobj_WE6_6 = r.eval('?*subobj-WE6-6*').floatValue(r.getGlobalContext());
subobj_WE6_7 = r.eval('?*subobj-WE6-7*').floatValue(r.getGlobalContext());

obj_WE6 = [1/7 1/7 1/7 1/7 1/7 1/7 1/7]*[subobj_WE6_1 subobj_WE6_2 subobj_WE6_3 subobj_WE6_4 subobj_WE6_5 subobj_WE6_6 subobj_WE6_7]';

subobj_WE7_1 = r.eval('?*subobj-WE7-1*').floatValue(r.getGlobalContext());
subobj_WE7_2 = r.eval('?*subobj-WE7-2*').floatValue(r.getGlobalContext());
subobj_WE7_3 = r.eval('?*subobj-WE7-3*').floatValue(r.getGlobalContext());
subobj_WE7_4 = r.eval('?*subobj-WE7-4*').floatValue(r.getGlobalContext());
subobj_WE7_5 = r.eval('?*subobj-WE7-5*').floatValue(r.getGlobalContext());
subobj_WE7_6 = r.eval('?*subobj-WE7-6*').floatValue(r.getGlobalContext());
subobj_WE7_7 = r.eval('?*subobj-WE7-7*').floatValue(r.getGlobalContext());
subobj_WE7_8 = r.eval('?*subobj-WE7-8*').floatValue(r.getGlobalContext());
subobj_WE7_9 = r.eval('?*subobj-WE7-9*').floatValue(r.getGlobalContext());
subobj_WE7_10 = r.eval('?*subobj-WE7-10*').floatValue(r.getGlobalContext());
subobj_WE7_11 = r.eval('?*subobj-WE7-11*').floatValue(r.getGlobalContext());
subobj_WE7_12 = r.eval('?*subobj-WE7-12*').floatValue(r.getGlobalContext());


obj_WE7 = [1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 1/12 ]*[subobj_WE7_1 subobj_WE7_2 subobj_WE7_3 subobj_WE7_4 subobj_WE7_5 ...
    subobj_WE7_6 subobj_WE7_7 subobj_WE7_8 subobj_WE7_9 subobj_WE7_10 subobj_WE7_11 subobj_WE7_12]';


weather_score = [.1924 .1538 .1154 .0769 .1923 .1538 .1154]*[obj_WE1 obj_WE2 obj_WE3 obj_WE4 obj_WE5 obj_WE6 obj_WE7]';
return