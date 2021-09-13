function arr = jess_list_to_array(list_var)
r = global_jess_engine();
arr = cell2mat(jess_value(r.eval(list_var)));
end