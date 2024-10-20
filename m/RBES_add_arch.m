function [archs2,results2] = RBES_add_arch(ref,results,archs)
global params
archs2 = [archs;ref.arch];



% Compute utilities
if strcmp(params.MODE,'PACKAGING')
    results2 = results;
    names = fieldnames(ref);
    for i= 1:length(names)
        if ~strcmp(names{i},'arch') && ~strcmp(names{i},'combined_subobjectives') && ~strcmp(names{i},'mission_costs')
            if strcmp(names{i},'data_continuity') || strcmp(names{i},'utility')
                tmp = names{i};
%                 results2.([tmp(1:end-1) 'ies']) = [results.([tmp(1:end-1) 'ies']); ref.(names{i})];
                results2.([tmp(1:end-1) 'ies'])  = add_el(results.([tmp(1:end-1) 'ies']),ref.(names{i}));
            elseif  strcmp(names{i},'fairness') || strcmp(names{i},'instrument_orbits') || strcmp(names{i},'lv_pack_factors') 
%                 results2.(names{i}) = [results.(names{i}); ref.(names{i})];
                results2.(names{i}) = add_el(results.(names{i}),ref.(names{i}));
            else
%                 results2.([names{i} 's']) = [results.([names{i} 's']); ref.(names{i})];
                results2.([names{i} 's']) = add_el(results.([names{i} 's']),ref.(names{i}));
            end
        end
    end
    if params.DATA_CONTINUITY == 1
        results2.utilities = RBES_compute_utilities3(results2,{'sciences','costs','programmatic_risks','launch_risks','data_continuities'},{'LIB','SIB','SIB','SIB','LIB'},[0.5 0.35 0.05 0.05 0.05]);
    else
        results2.utilities = RBES_compute_utilities3(results2,{'sciences','costs','programmatic_risks','launch_risks'},{'LIB','SIB','SIB','SIB'},[0.5 0.35 0.075 0.075]);
    end

    if isrow(results2.sciences)
        results2.pareto_rankings = RBES_compute_pareto_rankings([-results2.sciences' results2.costs'],7);
    else 
        results2.pareto_rankings = RBES_compute_pareto_rankings([-results2.sciences results2.costs],7);
    end

elseif strcmp(params.MODE,'SCHEDULING')
    results2 = results;
    names = fieldnames(ref);
    for i= 1:length(names)
        if ~strcmp(names{i},'arch')
            if strcmp(names{i},'data_continuity')
                tmp = names{i};
                results2.([tmp(1:end-1) 'ies']) = add_el(results.([tmp(1:end-1) 'ies']),1);
%                 if isrow(results.([tmp(1:end-1) 'ies']))
%                     results2.([tmp(1:end-1) 'ies']) = [results.([tmp(1:end-1) 'ies']) 1];
%                 else
%                     results2.([tmp(1:end-1) 'ies']) = [results.([tmp(1:end-1) 'ies']);1];
%                 end
            elseif strcmp(names{i},'discounted_value') || strcmp(names{i},'programmatic_risk')
                tmp = names{i};
                results2.([tmp 's']) = add_el(results.([tmp 's']),1);
%                 if isrow(results.([tmp 's']))
%                     results2.([tmp 's']) = [results.([tmp 's']) 1];
%                 else
%                     results2.([tmp 's']) = [results.([tmp 's']);1];
%                 end
            elseif  strcmp(names{i},'fairness')
                results2.(names{i}) = add_el(results.(names{i}),ref.(names{i}));
%                 if isrow(results.([tmp 's']))
%                     results2.(names{i}) = [results.(names{i}); ref.(names{i})];
%                 else
%                 end
            else
                results2.(names{i}) = add_el(results.(names{i}),ref.(names{i}));
%                 results2.([names{i} 's']) = [results.([names{i} 's']); ref.(names{i})];
            end
        end
    end
    results2.utilities = RBES_compute_utilities3(results2,{'discounted_values','data_continuities','fairness'},{'LIB','LIB','SIB'},[0.15 0.7 0.15])';
    if isrow(results2.discounted_values)
        results2.pareto_rankings = RBES_compute_pareto_rankings([-results2.discounted_values' -results2.data_continuities'],7);
    else 
        results2.pareto_rankings = RBES_compute_pareto_rankings([-results2.discounted_values -results2.data_continuities],7);
    end
%     results2.pareto_rankings = RBES_compute_pareto_rankings([-results2.discounted_values -results2.data_continuities])';

end

% Compute Pareto rankings
end