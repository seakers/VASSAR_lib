function [] = save_results(results,archs,folder,label)
global params

savepath = [params.path_save_results folder '\'];
tmp = clock();
hour = num2str(tmp(4));
min = num2str(tmp(5));
filesave = [savepath label '-' date '-' hour '-' min];
% used_params = params;
save(filesave,'results','archs');
end
