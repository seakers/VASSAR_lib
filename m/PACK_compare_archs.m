function comparison = PACK_compare_archs(arch1,arch2)
%% PACK_compare_archs.m
%
% a1 = PACK_get_arch_from_results(results,3)
% Usage: PACK_compare_archs(a1,PACK_ref_arch)

% global params
fprintf('************************************************************\n');
fprintf('************************************************************\n');
fprintf('Arch1: Science = %f, Cost = %f, Pareto rank = %d, prog risk = %f, launch risk = %f, util = %f\n',arch1.science,arch1.cost,arch1.pareto_ranking,arch1.programmatic_risk,arch1.launch_risk,arch1.utility);
fprintf('Arch2: Science = %f, Cost = %f, Pareto rank = %d, prog risk = %f, launch risk = %f, util = %f\n',arch2.science,arch2.cost,arch2.pareto_ranking,arch2.programmatic_risk,arch2.launch_risk,arch2.utility);
fprintf('************************************************************\n');

str = PACK_arch_to_str(arch1.arch);
ninstr = cellfun(@length,PACK_arch2sats(arch1.arch));
fprintf('Arch1 with %d sats (%s) : %s\n',max(arch1.arch),num2str(ninstr'),str);
str = PACK_arch_to_str(arch2.arch);
ninstr = cellfun(@length,PACK_arch2sats(arch2.arch));
fprintf('Arch2 with %d sats (%s): %s\n',max(arch2.arch),num2str(ninstr'),str);
fprintf('************************************************************\n');

R = input('Would you like to evaluate both architectures?(y/n): ','s');
if strcmp(R,'y')
     fprintf('\n');
%      fprintf('Arch1 is missing subobjectives\n');
     re = PACK_evaluate_architecture8(arch1.arch);
     [total_miss1,partial_miss1] = RBES_missing_subobjectives(re.combined_subobjectives,0);
     fprintf('Arch1 is missing synergies\n');
     missing_synergies1 = PACK_get_missing_synergies(arch1.arch);
     fprintf('Arch1 has current interferences\n');
     costs1 = RBES_Show_Penalties2(arch1.arch,re.orbits);
     current_interferences1 = PACK_get_current_interferences(arch1.arch);
     
%      fprintf('******************************\n');
%      fprintf('Arch2 is missing subobjectives\n');
     re = PACK_evaluate_architecture8(arch2.arch);
     [total_miss2,partial_miss2] = RBES_missing_subobjectives(re.combined_subobjectives,0);
     fprintf('Arch2 is missing synergies\n');
     missing_synergies2 = PACK_get_missing_synergies(arch2.arch);
     fprintf('Arch2 has current interferences\n');
     costs2 = RBES_Show_Penalties2(arch2.arch,re.orbits);
     current_interferences2 = PACK_get_current_interferences(arch2.arch);
     names = RBES_subobjective_names();
     for n = 1:RBES_count_subobj()
         subobj = names{n};
        if total_miss1(n) == 1 && total_miss2(n) == 0
            if partial_miss2(n) == 1
                
                fprintf('Arch 1 completely misses %s (%s) while arch2 only misses it partially\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
            else
                fprintf('Arch 1 completely misses %s (%s) while arch2 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
            end
        elseif total_miss1(n) == 0 && total_miss2(n) == 1
            if partial_miss1(n) == 1
                fprintf('Arch 2 completely misses %s (%s) while arch1 only misses it partially\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
            else
                fprintf('Arch 2 completely misses %s (%s) while arch1 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
            end
        elseif total_miss1(n) == 0 && total_miss2(n) == 0
            if partial_miss1(n) == 1 && partial_miss2(n) == 0
                fprintf('Arch 1 partially misses subobj %s (%s) while arch2 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
            elseif partial_miss1(n) == 0 && partial_miss2(n) == 1
                fprintf('Arch 2 partially misses subobj %s (%s) while arch1 fully satisfies it\n',names{n},char(RBES_subobj_to_meas(subobj(8:end))));
            end
        end
     end
     comparison.costs1 = costs1;
     comparison.costs2 = costs2;
     comparison.diff_cost = sum(costs2) - sum(costs1);
     comparison.missing_synergies1 = missing_synergies1;
     comparison.missing_synergies2 = missing_synergies2;
     comparison.current_interferences1 = current_interferences1;
     comparison.current_interferences2 = current_interferences2;
else
     comparison =  true;
end

fprintf('End of comparison\n');
fprintf('************************************************************\n');


end
