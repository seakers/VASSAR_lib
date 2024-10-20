function list = get_related_suboj(meas)
persistent meas_subobj_corresp
if(isempty(meas_subobj_corresp))
    load meas_subobj_corresp;
end
if meas(1) ~= '"'
    meas = ['"' meas '"'];
end
list = meas_subobj_corresp.get(meas);
end

