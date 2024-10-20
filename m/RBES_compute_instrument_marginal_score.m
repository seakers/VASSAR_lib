%% RBES_compute_instrument_marginal_score.m
function marg_score = RBES_compute_instrument_marginal_score(instr,arch)

% eval ref arch
if isfield(arch,'science') && ~isempty(arch.science)
    ref_science = arch.science;
else
    [ref_science,~] = PACK_evaluate_architecture3(arch);
end
fprintf('Ref score of arch is %f\n',ref_science);

% create new arch
all = RBES_get_parameter('instrument_list');
presence_mask = logical(strcmp(all,instr))';% 0 0 0 1 0 0 (1 where instr)
ind_instr = find(presence_mask>0,1);
present = sum(arch.selection & presence_mask)>0;

if present
    % descoping mode
    fprintf('Computing marginal score in descoping mode...');
    new_arch.selection = arch.selection & ~presence_mask; 
    tmp = find(arch.selection>0);    
    ind = find(tmp==ind_instr);
    new_arch.packaging = arch.packaging;
    for j = ind:sum(arch.selection) - 1
        new_arch.packaging(j) = arch.packaging(j+1);
    end
    new_arch.packaging(end) = [];
    new_arch.packaging = PACK_fix(new_arch.packaging);
    [score,~] = PACK_evaluate_architecture3(new_arch);
    marg_score = (ref_science- score)/ref_science;
else
    % superscoping mode
    fprintf('Computing marginal score in superscoping mode...');
    new_arch.selection = arch.selection | presence_mask; 
    tmp = find(new_arch.selection>0);    
    ind = find(tmp==ind_instr);
    new_arch.packaging = arch.packaging;
    for j = ind:sum(new_arch.selection)
        new_arch.packaging(j) = arch.packaging(j-1);
    end
%     new_arch.packaging(end+1) = arch.packaging(end);
    new_arch.packaging = PACK_fix(new_arch.packaging);
    [score,~] = PACK_evaluate_architecture3(new_arch);
    marg_score = (score- ref_science)/score;
end
TOL = 1e-6;
if abs(marg_score)<TOL,marg_score=0;end;
fprintf('%f\n',score);
end