%% RBES_save_DSMs.m
[S_DSM,E_DSM,single_scores,single_costs,single_subobjective_scores,pair_scores,pair_costs,pairs_subobjective_scores] = RBES_update_DSMs;
save DSM_backup EOS_DSMs subobjective_scores_singles pairs_subobjective_scores;
caso = RBES_get_parameter('CASE_STUDY');
if strcmp(caso,'EOS')
    EOS_science_DSM = S_DSM;
    EOS_engineering_DSM = E_DSM;
    save EOS_DSMs EOS_science_DSM EOS_engineering_DSM
end

save pairs_subobjective_scores pairs_subobjective_scores;
subobjective_scores_singles = single_subobjective_scores;
save subobjective_scores_singles subobjective_scores_singles;