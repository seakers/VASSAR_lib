function RBES_compare_subobjective_structs(subobjective_scor1,subobjective_scor2)
% global params


[total_miss2,partial_miss2,scores2] = RBES_missing_subobjectives(subobjective_scor2,0);
[total_miss1,partial_miss1,scores1] = RBES_missing_subobjectives(subobjective_scor1,0);

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
        elseif partial_miss1(n) == 1 && partial_miss2(n) == 1 && scores1(n) ~= scores2(n)
            fprintf('Both missions partially miss subobj %s (%s) with different scores: miss1 = %f, miss2 = %f\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))),scores1(n),scores2(n));
        end
    end
 end