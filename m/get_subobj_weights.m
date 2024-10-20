function [ws,s] = get_subobj_weights(subobjs)
    global params
%     subobj_weights_map = subobj_weight_map();
    n = length(subobjs);
    ws = zeros(1,n);
    s = 0;
    for i = 1:n
        ws(i) = params.subobj_weights_map.get(subobjs{i});
        s = s + ws(i);
    end
end