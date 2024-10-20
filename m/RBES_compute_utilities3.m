function utilities = RBES_compute_utilities3(results,variables,types,weights)
%% RBES_compute_utilities3.m
%
% Usage: = RBES_compute_utilities3(results,weights)
% global params
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

utilities = U_matrix*weights';

end



