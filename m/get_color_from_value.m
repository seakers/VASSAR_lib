function color = get_color_from_value(value,list,type,colors,edges)

if strcmp(type,'SIB')
    list2 = normalize_SIB(add_el(list,value));
else
    list2 = normalize_LIB(add_el(list,value));
end
norm_value = list2(end);
if norm_value<=edges(1)
    color = colors{1};
    return;
end
for i = 2:length(edges)
    if norm_value <= edges(i)
       color = colors{i-1};
        return;
    end
end

end