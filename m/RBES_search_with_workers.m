%% RBES_search_with_workers.m
RBES_Init_Params_EOS;
[r,params] = RBES_Init_WithRules(params);

matlabpool 2
MAXSAT = 5;
NARCH = 10;
NINSTR = 16;
x = randi(MAXSAT,[NARCH NINSTR]);
sciences = zeros(NARCH,1);
costs  = zeros(NARCH,1);

tic;
parfor i = 1:size(x,1)
    fprintf('Arch %d of %d...\n',i,size(x,1));
    arch = PACK_fix(x(i,:));
    [sciences(i),costs(i)] = PACK_evaluate_architecture(r,params,arch);
end
toc