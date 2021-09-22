function results = SMAP_eval_archs(arch_str)
    r = global_jess_engine;
    n = length(arch_str);
    results.sciences = zeros(n,1);
    results.costs = zeros(n,1);
%     results = cell(n,1);
%     sciences = zeros(n,1);
%     costs = zeros(n,1);
    for i = 1:n
        fprintf('Evaluating arch %d from %d...',i,n);
        jess reset;
        r.eval(['(assert-string "' char(arch_str{i}) '")']);
        jess focus MANIFEST;
        jess run;
        tmp = RBES_Evaluate_Manifest3;
        results.sciences(i) = tmp.score;
        results.costs(i) = tmp.cost;
        fprintf('Done: science = %f, cost = %f\n',tmp.score,tmp.cost);
    end
end