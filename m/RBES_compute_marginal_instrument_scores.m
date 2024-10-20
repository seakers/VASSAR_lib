function marginal_scores = RBES_compute_marginal_instrument_scores(arch)
all = RBES_get_parameter('instrument_list');

%% eval complete arch
% [results] = SEL_evaluate_architecture3(arch);
[ref_science,~] = PACK_evaluate_architecture3(arch);
fprintf('Ref score of arch is %f\n',ref_science);
% ref_science = results.science;

%% eval degraded archs
list = all(logical(arch.selection));
n = sum(arch.selection);
% params.ESTIMATE_COST = 1;
marginal_scores = zeros(n,1);
for i = 1:n
    mask = ~logical(strcmp(all,list{i}))';
    new_arch.selection = arch.selection & mask; 
%     [results] = SEL_evaluate_architecture3(new_bin_arch);
    tmp = find(arch.selection>0);    
    ind = find(tmp==i);
    new_arch.packaging = arch.packaging;
    
    for j = ind:sum(arch.selection) - 1
        new_arch.packaging(j) = arch.packaging(j+1);
    end
    new_arch.packaging(end) = [];
    new_arch.packaging = PACK_fix(new_arch.packaging);
    [science,~] = PACK_evaluate_architecture3(new_arch);
    marginal_scores(i) = (ref_science- science)/ref_science;
    fprintf('Marginal score of instrument %s is %f\n',list{i},marginal_scores(i));
end

% params.ESTIMATE_COST = 1;
end

