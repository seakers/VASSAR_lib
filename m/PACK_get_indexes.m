function indexes = PACK_get_indexes(payload,list)
cellfun(@(x)strcmp(list,x),payload,'UniformOutput',false);
tmp = cellfun(@(x)strcmp(list,x),payload,'UniformOutput',false);
indexes = cellfun(@(x)find(x,1),tmp);
end
