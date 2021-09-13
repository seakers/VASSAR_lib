function map = pack_arch_to_hashmap(pack_arch,instr_names,miss_names)
map = java.util.HashMap;
for i =1:length(miss_names)
%     ind = find(pack_arch == i);
    map.put(miss_names{i},instr_names(pack_arch == i));
end
end