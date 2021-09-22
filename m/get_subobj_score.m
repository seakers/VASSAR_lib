function scor = get_subobj_score(struct,subobj)
all_scores = RBES_get_array_subobj_scores(struct);
scor = all_scores(strcmp(RBES_subobjective_names,subobj));
end