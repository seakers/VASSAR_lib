function list = explanation_facility(subobj,p,o,who,att)
% write to excel file
persistent list_of_objectives_satisfied
if ~iscell(list_of_objectives_satisfied)
    list_of_objectives_satisfied = cell(0,5);
end
if nargin == 0
    list = list_of_objectives_satisfied;
    return
else
    n = size(list_of_objectives_satisfied,1);
    list_subobjectives = list_of_objectives_satisfied(:,1);
    list_measurements = list_of_objectives_satisfied(:,2);
    list_instruments = list_of_objectives_satisfied(:,4);
    
    and1 = find(cellfun(@(x)strcmp(x,subobj),list_subobjectives));% 1 only where right subobj
    and2 = find(cellfun(@(x)strcmp(x,p),list_measurements));% 1 only where right subobj
    and4 = find(cellfun(@(x)strcmp(x,who),list_instruments));% 1 only where right subobj
    index = intersect(intersect(and1,and2),and4);
    if isempty(index) % new line
        list_of_objectives_satisfied{n+1,1} = subobj;
        list_of_objectives_satisfied{n+1,2} = p;
        list_of_objectives_satisfied{n+1,3} = o;
        list_of_objectives_satisfied{n+1,4} = who;
        list_of_objectives_satisfied{n+1,5} = att;
        list = list_of_objectives_satisfied;
    else % another line exists with same subobj, same measurement, same instrument
        list_of_objectives_satisfied{index,5} = strcat(list_of_objectives_satisfied{index,5},'++',att);
        list = list_of_objectives_satisfied;
    end
     
     
    return
end
