function arr = get_array_from_cell_struct(cell_struct,name)
arr = cellfun(@(x)getfield(x,name),cell_struct);
end