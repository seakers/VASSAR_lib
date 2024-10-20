function meas = RBES_subobj_to_meas(subobj)
global params
if iscell(subobj)
    subobj = subobj{1};
end
var_name = ['?*subobj-' subobj '*'];
tmp = params.subobjectives_to_measurements.get(var_name).toString;
meas = tmp.substring(2,tmp.length-2);
end