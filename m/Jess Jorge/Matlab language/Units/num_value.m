function [number] = num_value(magnitude)
    basic_units = get_basic_units();
    number = double(subs(magnitude,basic_units,{ones(size(basic_units))}));
end