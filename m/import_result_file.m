%% import_result_file.m
function [results,archs] = import_result_file(file)
    resMngr = rbsa.eoss.ResultManager.getInstance();
    rc = resMngr.loadResultCollectionFromFile(file);
    resus = rc.getResults;
    narc = resus.size;
    archs = cell(narc,1);
    results.sciences = zeros(narc,1);
    results.costs = zeros(narc,1);
    results.pareto_ranks = zeros(narc,1);
    for i = 1:narc
        resu = resus.pop;
        archs{i} = resu.getArch();
        results.sciences(i) = resu.getScience();
        results.costs(i) = resu.getCost();
        results.pareto_ranks(i) = resu.getParetoRanking();
    end
    save([file '.mat'],'results','archs');
    SMAP_plot(results,archs,false);
end

