function newv = add_el(vec,el)

if iscell(vec)
    newv = vec;
    newv(end+1) = {el};
    return;
elseif isrow(vec)
    newv = [vec el];
else
    newv = [vec;el];
end
end