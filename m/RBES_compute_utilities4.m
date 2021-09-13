function utilities = RBES_compute_utilities4(results,variables,types,weights,res_str)
%% RBES_compute_utilities3.m
%
% Usage: = RBES_compute_utilities3(results,weights)
% global params
switch res_str
    case 'cell'
        results = RBES_change_results_struct(results);
        narc = length(results.(variables{1}));
        nmet = length(variables);
        U_matrix = zeros(narc,nmet);

        for i = 1:length(variables)
            if strcmp(types{i},'LIB')
                U_matrix(:,i) = normalize_LIB(results.(variables{i}))';
            elseif strcmp(types{i},'SIB')
                U_matrix(:,i) = normalize_SIB(results.(variables{i}))';
            end

        end
    case 'struct'
        narc = length(results.(['arr_' variables{1}]));
        nmet = length(variables);
        U_matrix = zeros(narc,nmet);

        for i = 1:length(variables)
            if strcmp(types{i},'LIB')
                U_matrix(:,i) = normalize_LIB(results.(['arr_' variables{i}]))';
            elseif strcmp(types{i},'SIB')
                U_matrix(:,i) = normalize_SIB(results.(['arr_' variables{i}]))';
            end

        end
    otherwise
        error('RBES_compute_utilities4(results,variables,types,weights,res_str): res_str can only be cell or struct');
end

utilities = U_matrix*weights';

end



