function [science,cost] = SEL_evaluate_architecture2(params,arch)
%% SEL_evaluate_architecture2.m
% This function utilizes the HashMap EOS_Instrument_scores or equivalent to
% retrieve and add the scores of all the instruments in the architecture.
n = length(arch);
sciences = zeros(n,1);
costs = zeros(n,1);
science = 0;
cost = 0;
for i = 1:length(arch)
    [sciences(i),costs(i)] = SEL_get_scores(params.instrument_names{i},arch(i),params);   %ncopies=arch(i)
    science = science + sciences(i);
    cost = costs + costs(i);
end

end