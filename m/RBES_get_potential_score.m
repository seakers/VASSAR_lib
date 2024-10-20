function score = RBES_get_potential_score(names)
score = RBES_get_array_subobj_weights'*RBES_get_array_subobj_scores(RBES_find_subobj_by_names(names));
end