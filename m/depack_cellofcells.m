function vals = depack_cellofcells(values)
vals = cell(1,length(values));
for i = 1:length(values)
    vals{i} = values{i}{1};
end
end