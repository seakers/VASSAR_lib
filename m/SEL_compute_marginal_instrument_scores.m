function marginal_scores = SEL_compute_marginal_instrument_scores(bin_arch)
all = RBES_get_parameter('instrument_list');

%% eval complete arch
[results] = SEL_evaluate_architecture3(bin_arch);
fprintf('Ref score of arch is %f\n',results.science);
ref_science = results.science;



%% eval degraded archs
% list = all(logical(bin_arch));
n = length(bin_arch);
% params.ESTIMATE_COST = 1;
marginal_scores = zeros(n,1);
for i = 1:n
%     mask = logical(strcmp(all,list{i}));
    mask = false(1,n);
    mask(i) = true;
    nmask = ~mask;
    % mask
    present = sum(bin_arch & mask)>0;
    if present
        new_bin_arch = bin_arch & nmask; 
        [results] = SEL_evaluate_architecture3(new_bin_arch);
        marginal_scores(i) = (ref_science- results.science)/ref_science;
    else
        new_bin_arch = bin_arch | mask; 
        [results] = SEL_evaluate_architecture3(new_bin_arch);
        marginal_scores(i) = (-ref_science+ results.science)/ref_science;
    end
    fprintf('Marginal score of instrument %s in mode %d is %f\n',all{i},present,marginal_scores(i));
end

% params.ESTIMATE_COST = 1;
end

