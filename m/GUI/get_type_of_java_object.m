function obj = get_type_of_java_object(value)
arr_list = java.util.ArrayList;

if iscell(value)
    obj = 'ArrayList<';
    in = '';
    in = get_type_of_java_object(value{1,1});  
    obj = [obj in '>'];
    return;
end

if isempty(value)
    obj = '';
    return;
end

if isnumeric(value)
    if(size(value,2) > 1)
        obj = 'ArrayList<';
        in = '';
        in = get_type_of_java_object(value(1));
        obj = [obj in '>'];
        return;
    elseif mod(value,1)==0
        obj = 'Integer';
        return;
    else
        obj = 'Double';
        return;
    end
elseif ischar(value)
    if strcmp(value,'nil')
        obj = '';
        return;
    else
        obj = 'String';
        return;
    end
end
end