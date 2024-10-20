function RBES_compare_missions(miss1,miss2)
global params
% miss1 = create_test_mission('test',{instr1},params.startdate,params.lifetime,[],63);
[scor1,panel_score,objective_scor,subobjective_scor1,data_continuity_score,data_continuity_matrix,cos] = RBES_Evaluate_Mission(miss1);
% miss2 = create_test_mission('test',{instr2},params.startdate,params.lifetime,[],63);
[scor2,panel_score,objective_scor,subobjective_scor2,data_continuity_score,data_continuity_matrix,cos] = RBES_Evaluate_Mission(miss2);
% missc = create_test_mission('test',{instr1,instr2},params.startdate,params.lifetime,[],63);
% [scorc,panel_score,objective_scor,subobjective_scorc,data_continuity_score,data_continuity_matrix,cos] = RBES_Evaluate_Mission(missc);

[total_miss2,partial_miss2] = RBES_missing_subobjectives(subobjective_scor2);
[total_miss1,partial_miss1] = RBES_missing_subobjectives(subobjective_scor1);

names = RBES_subobjective_names();
 for n = 1:RBES_count_subobj()
     subobj = names{n};
    if total_miss1(n) == 1 && total_miss2(n) == 0
        if partial_miss2(n) == 1

            fprintf('Mission 1 completely misses %s (%s) while miss2 only misses it partially\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
        else
            fprintf('Mission 1 completely misses %s (%s) while miss2 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
        end
    elseif total_miss1(n) == 0 && total_miss2(n) == 1
        if partial_miss1(n) == 1
            fprintf('Mission 2 completely misses %s (%s) while miss1 only misses it partially\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
        else
            fprintf('Mission 2 completely misses %s (%s) while miss1 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
        end
    elseif total_miss1(n) == 0 && total_miss2(n) == 0
        if partial_miss1(n) == 1 && partial_miss2(n) == 0
            fprintf('Mission 1 partially misses subobj %s (%s) while miss2 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
        elseif partial_miss1(n) == 0 && partial_miss2(n) == 1
            fprintf('Mission 2 partially misses subobj %s (%s) while miss1 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
        end
    end
 end